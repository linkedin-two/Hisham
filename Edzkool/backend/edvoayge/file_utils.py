import os
import re
from django.utils.text import slugify
from django.utils.deconstruct import deconstructible
from django.core.files.storage import default_storage


def clean_english_slug(text, max_length=90):
    """
    Converts any text into a clean, human-readable English slug using underscores.
    Strips non-alphanumeric chars, removes leading/trailing and duplicate underscores.
    """
    if not text:
        return ""
    slug = slugify(str(text)).replace("-", "_")
    slug = re.sub(r"_+", "_", slug).strip("_")
    return slug[:max_length]


@deconstructible
class TitleBasedUploadPath:
    """
    Deconstructible callable for Django upload_to that names files according to model metadata
    (subject, sub-subject, title, caption, page numbers) with clean English separators.
    Guarantees no random UUIDs, hashes, or machine-generated gibberish in the media folder.
    """
    def __init__(self, folder_prefix):
        self.folder_prefix = folder_prefix.strip("/")

    def __call__(self, instance, filename):
        ext = os.path.splitext(filename)[1].lower()
        parts = []

        # 1. Related parent model (e.g., FlashcardImage -> Flashcard)
        parent = getattr(instance, 'flashcard', None)
        if parent:
            if getattr(parent, 'subject', None) and hasattr(parent.subject, 'name'):
                parts.append(str(parent.subject.name))
            if getattr(parent, 'sub_subject', None) and hasattr(parent.sub_subject, 'name'):
                parts.append(str(parent.sub_subject.name))
            if getattr(parent, 'description', None) and parent.description:
                parts.append(str(parent.description[:30]))

        # 2. Direct model attributes
        if hasattr(instance, 'subject') and instance.subject and hasattr(instance.subject, 'name'):
            parts.append(str(instance.subject.name))
        if hasattr(instance, 'sub_subject') and instance.sub_subject and hasattr(instance.sub_subject, 'name'):
            parts.append(str(instance.sub_subject.name))
        if hasattr(instance, 'case_title') and instance.case_title:
            parts.append(str(instance.case_title))
        if hasattr(instance, 'title') and instance.title:
            parts.append(str(instance.title))
        if hasattr(instance, 'name') and instance.name:
            parts.append(str(instance.name))

        # 3. Caption or page number (e.g. "Page 1" -> "page_1")
        caption = getattr(instance, 'caption', None)
        page_suffix = ""
        if caption:
            cap_slug = clean_english_slug(caption, 20)
            if cap_slug:
                page_suffix = f"_{cap_slug}"
        elif "_page_" in filename.lower() or "page_" in filename.lower():
            match = re.search(r"page_?(\d+)", filename.lower())
            if match:
                page_suffix = f"_page_{match.group(1)}"

        # 4. Fallback to sanitized original filename if no metadata parts found
        if not parts:
            clean_original = os.path.splitext(filename)[0]
            # Strip standard 36-char UUIDs if present
            clean_original = re.sub(
                r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
                "file",
                clean_original,
            )
            # Strip 32-char hex UUIDs
            clean_original = re.sub(r"[0-9a-fA-F]{32}", "file", clean_original)
            parts.append(clean_original)

        base_slug = clean_english_slug("_".join(parts), 80) or "file"
        final_slug = f"{base_slug}{page_suffix}"

        # 5. Prevent collisions with clean sequential numbers (_1, _2...) instead of random Django hashes
        target_path = f"{self.folder_prefix}/{final_slug}{ext}"
        counter = 1
        try:
            while default_storage.exists(target_path):
                target_path = f"{self.folder_prefix}/{final_slug}_{counter}{ext}"
                counter += 1
        except Exception:
            # In case default_storage is not configured or in migrations, fallback gracefully
            pass

        return target_path


def title_based_upload_path(folder_prefix):
    return TitleBasedUploadPath(folder_prefix)
