from django.core.management.base import BaseCommand

from notes.services.flashcard_pdf import process_pending_flashcards


class Command(BaseCommand):
    help = (
        "Process pending flashcard PDF conversions. "
        "Run via Render Cron every few minutes (free-tier safe, one PDF at a time)."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--limit",
            type=int,
            default=1,
            help="Maximum number of flashcards to process in this run (default: 1).",
        )

    def handle(self, *args, **options):
        limit = options["limit"]
        processed = process_pending_flashcards(limit=limit)
        self.stdout.write(
            self.style.SUCCESS(f"Processed {processed} flashcard PDF job(s).")
        )
