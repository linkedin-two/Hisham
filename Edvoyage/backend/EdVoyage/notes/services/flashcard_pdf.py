"""Background-friendly PDF → flashcard image conversion for Render free tier.

No Celery/Redis required. Uses:
  1. DB status fields (pending → processing → completed/failed)
  2. Optional in-process thread after admin save (fast feedback when web is awake)
  3. Management command + Render Cron as the reliable worker
"""

from __future__ import annotations

import gc
import io
import logging
import os
import threading
from datetime import timedelta
from uuid import uuid4

import fitz
from django.core.files import File
from django.db import close_old_connections, connection, transaction
from django.utils import timezone
from PIL import Image

from notes.models import Flashcard, FlashcardImage
from notes.services.flashcard_watermark import apply_watermark

logger = logging.getLogger(__name__)

STALE_PROCESSING_MINUTES = 15
DEFAULT_ZOOM = float(os.getenv("FLASHCARD_PDF_ZOOM", "1.5"))
DEFAULT_JPEG_QUALITY = int(os.getenv("FLASHCARD_JPEG_QUALITY", "80"))


def _pdf_zoom() -> float:
    return max(1.0, min(DEFAULT_ZOOM, 3.0))


def convert_pdf_to_flashcard_images(flashcard: Flashcard) -> int:
    """Convert flashcard PDF pages to JPEG images. Returns number of pages created."""
    if not flashcard.pdf_file:
        return 0

    flashcard.images.all().delete()

    with flashcard.pdf_file.open("rb") as pdf_handle:
        pdf_bytes = pdf_handle.read()

    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    page_count = 0

    try:
        matrix = fitz.Matrix(_pdf_zoom(), _pdf_zoom())

        for page_number, page in enumerate(doc, start=1):
            pixmap = page.get_pixmap(matrix=matrix)
            try:
                image = Image.frombytes(
                    "RGB",
                    (pixmap.width, pixmap.height),
                    pixmap.samples,
                )
                image = apply_watermark(image).convert("RGB")
                image_io = io.BytesIO()
                image.save(image_io, format="JPEG", quality=DEFAULT_JPEG_QUALITY)
                image_io.seek(0)

                FlashcardImage.objects.create(
                    flashcard=flashcard,
                    image=File(image_io, name=f"{uuid4()}.jpg"),
                    caption=f"Page {page_number}",
                )
                page_count += 1
            finally:
                del pixmap
                if page_number % 10 == 0:
                    gc.collect()
    finally:
        doc.close()
        del pdf_bytes
        gc.collect()

    return page_count


def _mark_status(flashcard_id: int, status: str, *, error: str = "") -> None:
    Flashcard.objects.filter(pk=flashcard_id).update(
        processing_status=status,
        processing_error=error[:2000] if error else "",
        processing_updated_at=timezone.now(),
    )


def process_flashcard_pdf(flashcard_id: int) -> bool:
    """Run conversion for one flashcard. Returns True on success."""
    close_old_connections()

    try:
        flashcard = Flashcard.objects.get(pk=flashcard_id)
    except Flashcard.DoesNotExist:
        logger.warning("Flashcard %s no longer exists", flashcard_id)
        return False

    if not flashcard.pdf_file:
        _mark_status(flashcard_id, Flashcard.ProcessingStatus.FAILED, error="No PDF file")
        return False

    _mark_status(flashcard_id, Flashcard.ProcessingStatus.PROCESSING)

    try:
        pages = convert_pdf_to_flashcard_images(flashcard)
        _mark_status(flashcard_id, Flashcard.ProcessingStatus.COMPLETED)
        logger.info(
            "Flashcard %s converted (%s pages)",
            flashcard_id,
            pages,
        )
        return True
    except Exception as exc:
        logger.exception("Flashcard %s PDF conversion failed", flashcard_id)
        _mark_status(
            flashcard_id,
            Flashcard.ProcessingStatus.FAILED,
            error=str(exc),
        )
        return False
    finally:
        close_old_connections()


def reset_stale_processing_jobs() -> int:
    """Re-queue jobs stuck in 'processing' after a worker crash or timeout."""
    cutoff = timezone.now() - timedelta(minutes=STALE_PROCESSING_MINUTES)
    updated = Flashcard.objects.filter(
        processing_status=Flashcard.ProcessingStatus.PROCESSING,
        processing_updated_at__lt=cutoff,
    ).update(
        processing_status=Flashcard.ProcessingStatus.PENDING,
        processing_error="Re-queued after stale processing timeout",
        processing_updated_at=timezone.now(),
    )
    if updated:
        logger.warning("Reset %s stale flashcard processing job(s)", updated)
    return updated


def claim_next_pending_flashcard(*, flashcard_id: int | None = None) -> Flashcard | None:
    """Atomically claim one pending flashcard for processing (Postgres skip_locked)."""
    reset_stale_processing_jobs()
    close_old_connections()

    with transaction.atomic():
        qs = (
            Flashcard.objects.filter(
                processing_status=Flashcard.ProcessingStatus.PENDING,
            )
            .exclude(pdf_file="")
            .filter(pdf_file__isnull=False)
            .order_by("processing_updated_at", "id")
        )
        if flashcard_id is not None:
            qs = qs.filter(pk=flashcard_id)

        if connection.features.has_select_for_update:
            if connection.features.has_select_for_update_skip_locked:
                qs = qs.select_for_update(skip_locked=True)
            else:
                qs = qs.select_for_update()

        flashcard = qs.first()
        if flashcard is None:
            return None

        flashcard.processing_status = Flashcard.ProcessingStatus.PROCESSING
        flashcard.processing_error = ""
        flashcard.processing_updated_at = timezone.now()
        flashcard.save(
            update_fields=["processing_status", "processing_error", "processing_updated_at"]
        )
        return flashcard


def process_pending_flashcards(*, limit: int = 1) -> int:
    """Process up to `limit` pending flashcards. Used by Render Cron."""
    processed = 0
    for _ in range(max(1, limit)):
        flashcard = claim_next_pending_flashcard()
        if flashcard is None:
            break
        process_flashcard_pdf(flashcard.pk)
        processed += 1
    return processed


def _run_in_background(flashcard_id: int) -> None:
    try:
        flashcard = claim_next_pending_flashcard(flashcard_id=flashcard_id)
        if flashcard is None:
            return
        process_flashcard_pdf(flashcard_id)
    except Exception:
        logger.exception("Background flashcard processing failed for %s", flashcard_id)


def enqueue_flashcard_pdf_processing(flashcard_id: int) -> None:
    """Queue PDF conversion: DB status + best-effort background thread."""
    Flashcard.objects.filter(pk=flashcard_id).update(
        processing_status=Flashcard.ProcessingStatus.PENDING,
        processing_error="",
        processing_updated_at=timezone.now(),
    )

    thread = threading.Thread(
        target=_run_in_background,
        args=(flashcard_id,),
        name=f"flashcard-pdf-{flashcard_id}",
        daemon=True,
    )
    thread.start()
    logger.info("Queued flashcard %s for background PDF conversion", flashcard_id)
