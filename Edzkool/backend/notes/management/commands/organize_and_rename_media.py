import os
from django.core.management.base import BaseCommand
from django.utils.text import slugify
from notes.models import Flashcard, FlashcardImage


class Command(BaseCommand):
    help = "Renames existing unreadable UUID media files on disk and DB to human-readable title-slugged filenames."

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS("Starting media file renaming & organization process..."))
        renamed_count = 0

        # Process Flashcard PDFs
        for card in Flashcard.objects.exclude(pdf_file=''):
            if card.pdf_file and os.path.exists(card.pdf_file.path):
                old_path = card.pdf_file.path
                dirname, old_filename = os.path.split(old_path)
                ext = os.path.splitext(old_filename)[1].lower()

                parts = [card.subject.name, card.sub_subject.name]
                new_slug = slugify("_".join(parts)).replace("-", "_")[:100] or f"flashcard_{card.pk}"
                new_filename = f"{new_slug}{ext}"

                if old_filename != new_filename:
                    new_path = os.path.join(dirname, new_filename)
                    # Check collision
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
                        self.stdout.write(f"Renamed PDF: {old_filename} -> {new_filename}")
                    except Exception as e:
                        self.stdout.write(self.style.ERROR(f"Error renaming {old_filename}: {e}"))

        self.stdout.write(self.style.SUCCESS(f"Completed! Total files renamed: {renamed_count}"))
