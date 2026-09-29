from django.conf import settings
from django.core.files import File
from django.core.files.storage import default_storage
from django.core.management.base import BaseCommand

from notes.models import FlashcardImage


class Command(BaseCommand):
    help = (
        "Upload legacy local flashcard image files from media/ to S3. "
        "Requires valid AWS credentials in .env or Render Environment."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="List files that would be uploaded without uploading.",
        )

    def handle(self, *args, **options):
        dry_run = options["dry_run"]

        local_root = settings.BASE_DIR / "media"
        uploaded = 0
        skipped = 0
        missing = 0

        for flashcard_image in FlashcardImage.objects.select_related("flashcard").iterator():
            storage_name = flashcard_image.image.name
            if not storage_name:
                skipped += 1
                continue

            if default_storage.exists(storage_name):
                self.stdout.write(f"Already on storage: {storage_name}")
                skipped += 1
                continue

            local_path = local_root / storage_name
            if not local_path.is_file():
                self.stderr.write(self.style.ERROR(f"Missing local file: {local_path}"))
                missing += 1
                continue

            if dry_run:
                self.stdout.write(f"Would upload: {local_path} -> {storage_name}")
                uploaded += 1
                continue

            with open(local_path, "rb") as handle:
                default_storage.save(storage_name, File(handle))

            self.stdout.write(self.style.SUCCESS(f"Uploaded: {storage_name}"))
            uploaded += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"Done. uploaded={uploaded} skipped={skipped} missing={missing}"
            )
        )
