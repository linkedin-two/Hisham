import os
import re
import logging
from django.utils.text import slugify

logger = logging.getLogger(__name__)


def clean_slug(text, max_len=80):
    if not text:
        return ""
    slug = slugify(str(text)).replace("-", "_")
    slug = re.sub(r"_+", "_", slug).strip("_")
    return slug[:max_len]


def auto_organize_legacy_media():
    """
    Automatically converts unreadable, UUID, or hash-based filenames on disk and database
    into clean, human-readable English filenames for both PDFs and split flashcard images.
    Makes the media folder clean, understandable, and easily usable.
    """
    try:
        from notes.models import Flashcard, FlashcardImage

        renamed_pdfs = 0
        renamed_images = 0

        # ----------------------------------------------------------------------
        # 1. Clean and organize Flashcard PDF files
        # ----------------------------------------------------------------------
        for card in Flashcard.objects.exclude(pdf_file=''):
            try:
                if not card.pdf_file or not hasattr(card.pdf_file, 'path') or not os.path.exists(card.pdf_file.path):
                    continue

                old_path = card.pdf_file.path
                dirname, old_filename = os.path.split(old_path)
                ext = os.path.splitext(old_filename)[1].lower() or ".pdf"

                parts = []
                if card.subject and hasattr(card.subject, 'name'):
                    parts.append(str(card.subject.name))
                if card.sub_subject and hasattr(card.sub_subject, 'name'):
                    parts.append(str(card.sub_subject.name))
                if hasattr(card, 'description') and card.description:
                    parts.append(str(card.description[:30]))

                if not parts:
                    clean_original = os.path.splitext(old_filename)[0]
                    clean_original = re.sub(r"[0-9a-fA-F\-]{20,}", "document", clean_original)
                    parts.append(clean_original)

                base_slug = clean_slug("_".join(parts), 80) or f"notes_{card.pk}"
                new_filename = f"{base_slug}{ext}"

                if old_filename != new_filename:
                    new_path = os.path.join(dirname, new_filename)
                    counter = 1
                    while os.path.exists(new_path) and os.path.abspath(new_path) != os.path.abspath(old_path):
                        new_filename = f"{base_slug}_{counter}{ext}"
                        new_path = os.path.join(dirname, new_filename)
                        counter += 1

                    if os.path.abspath(new_path) != os.path.abspath(old_path):
                        os.rename(old_path, new_path)
                        rel_path = os.path.relpath(new_path, card.pdf_file.storage.location).replace("\\", "/")
                        card.pdf_file.name = rel_path
                        card.save(update_fields=['pdf_file'])
                        renamed_pdfs += 1
                        logger.info(f"Organized PDF: {old_filename} -> {new_filename}")
            except Exception as err:
                logger.warning(f"Could not organize PDF {getattr(card, 'id', 'unknown')}: {err}")

        # ----------------------------------------------------------------------
        # 2. Clean and organize Flashcard split images
        # ----------------------------------------------------------------------
        for img in FlashcardImage.objects.select_related('flashcard', 'flashcard__subject', 'flashcard__sub_subject').all():
            try:
                if not img.image or not hasattr(img.image, 'path') or not os.path.exists(img.image.path):
                    continue

                old_path = img.image.path
                dirname, old_filename = os.path.split(old_path)
                ext = os.path.splitext(old_filename)[1].lower() or ".jpg"

                # Check if old filename is an unreadable UUID (e.g. 8-4-4-4-12 hex chars or random hex)
                is_ugly_name = bool(re.search(r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}", old_filename) or re.search(r"^[0-9a-fA-F]{24,}", old_filename))

                card = img.flashcard
                parts = []
                if card:
                    if card.subject and hasattr(card.subject, 'name'):
                        parts.append(str(card.subject.name))
                    if card.sub_subject and hasattr(card.sub_subject, 'name'):
                        parts.append(str(card.sub_subject.name))
                if not parts:
                    parts.append("flashcard")

                page_str = ""
                if img.caption:
                    page_match = re.search(r"(\d+)", img.caption)
                    if page_match:
                        page_str = f"_page_{page_match.group(1)}"
                    else:
                        page_str = f"_{clean_slug(img.caption, 20)}"
                elif "_page_" in old_filename.lower():
                    page_match = re.search(r"page_?(\d+)", old_filename.lower())
                    if page_match:
                        page_str = f"_page_{page_match.group(1)}"

                base_slug = clean_slug("_".join(parts), 70) or f"card_{getattr(card, 'id', 1)}"
                new_filename = f"{base_slug}{page_str}{ext}"

                # Only rename if filename actually changed or was ugly UUID
                if is_ugly_name or (old_filename != new_filename and not old_filename.startswith(base_slug)):
                    new_path = os.path.join(dirname, new_filename)
                    counter = 1
                    while os.path.exists(new_path) and os.path.abspath(new_path) != os.path.abspath(old_path):
                        new_filename = f"{base_slug}{page_str}_{counter}{ext}"
                        new_path = os.path.join(dirname, new_filename)
                        counter += 1

                    if os.path.abspath(new_path) != os.path.abspath(old_path):
                        os.rename(old_path, new_path)
                        rel_path = os.path.relpath(new_path, img.image.storage.location).replace("\\", "/")
                        img.image.name = rel_path
                        img.save(update_fields=['image'])
                        renamed_images += 1
                        logger.info(f"Organized Flashcard Image: {old_filename} -> {new_filename}")
            except Exception as err:
                logger.warning(f"Could not organize image {getattr(img, 'id', 'unknown')}: {err}")

        total_renamed = renamed_pdfs + renamed_images
        if total_renamed > 0:
            logger.info(f"Media folder organization completed: {renamed_pdfs} PDFs, {renamed_images} images organized with clean English names.")
    except Exception as e:
        logger.warning(f"Auto media organization check skipped: {e}")
