import os
from django.utils.text import slugify


def title_based_upload_path(folder_prefix):
    """
    Returns an upload_to callable that names files according to model metadata
    (subject, title, name) with clean separators instead of random UUIDs.

    Example:
      folder_prefix = "flashcards/pdfs"
      output = "flashcards/pdfs/anatomy_cardiovascular_system.pdf"
    """
    def _upload_to(instance, filename):
        ext = os.path.splitext(filename)[1].lower()
        parts = []

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

        if not parts:
            clean_name = os.path.splitext(filename)[0]
            parts.append(clean_name)

        combined = "_".join(parts)
        safe_slug = slugify(combined).replace("-", "_")
        safe_slug = safe_slug[:120].strip("_") or "file"

        return f"{folder_prefix}/{safe_slug}{ext}"

    return _upload_to
