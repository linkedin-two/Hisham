import os
import logging
from django.utils.text import slugify

logger = logging.getLogger(__name__)


def auto_organize_legacy_media():
    """
    Automatically runs in normal backend flow to convert unreadable UUID media filenames
    on disk and database to human-readable title-based names.
    """
    try:
        from notes.models import Flashcard

        renamed_count = 0
        for card in Flashcard.objects.exclude(pdf_file=''):
            if card.pdf_file and os.path.exists(card.pdf_file.path):
                old_path = card.pdf_file.path
                dirname, old_filename = os.path.split(old_path)
                ext = os.path.splitext(old_filename)[1].lower()

                parts = []
                if card.subject and hasattr(card.subject, 'name'):
                    parts.append(card.subject.name)
                if card.sub_subject and hasattr(card.sub_subject, 'name'):
                    parts.append(card.sub_subject.name)
                if hasattr(card, 'description') and card.description:
                    parts.append(card.description[:30])

                if not parts:
                    continue

                new_slug = slugify("_".join(parts)).replace("-", "_")[:100]
                new_filename = f"{new_slug}{ext}"

                if old_filename != new_filename:
                    new_path = os.path.join(dirname, new_filename)
                    counter = 1
                    base_slug = new_slug
                    while os.path.exists(new_path) and new_path != old_path:
                        new_filename = f"{base_slug}_{counter}{ext}"
                        new_path = os.path.join(dirname, new_filename)
                        counter += 1

                    try:
                        os.rename(old_path, new_path)
                        rel_path = os.path.relpath(new_path, card.pdf_file.storage.location).replace("\\", "/")
                        card.pdf_file.name = rel_path
                        card.save(update_fields=['pdf_file'])
                        renamed_count += 1
                        logger.info(f"Auto-renamed PDF: {old_filename} -> {new_filename}")
                    except Exception as err:
                        logger.warning(f"Could not auto-rename {old_filename}: {err}")

        if renamed_count > 0:
            logger.info(f"Auto media organization completed: {renamed_count} files organized.")
    except Exception as e:
        logger.warning(f"Auto media organization check skipped: {e}")
