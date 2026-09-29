from django.core.management.base import BaseCommand
from notes.models import (
    Category,
    Subject,
    Doctor,
    Video,
    MCQ,
    Question,
    Option,
    ClinicalCase,
    Flashcard,
    FlashcardImage
)


class Command(BaseCommand):

    def handle(self, *args, **kwargs):

        self.stdout.write("Deleting Options...")
        Option.objects.all().delete()

        self.stdout.write("Deleting Questions...")
        Question.objects.all().delete()

        self.stdout.write("Deleting MCQs...")
        MCQ.objects.all().delete()

        self.stdout.write("Deleting Videos...")
        Video.objects.all().delete()

        self.stdout.write("Deleting Flashcard Images...")
        FlashcardImage.objects.all().delete()

        self.stdout.write("Deleting Flashcards...")
        Flashcard.objects.all().delete()

        self.stdout.write("Deleting Clinical Cases...")
        ClinicalCase.objects.all().delete()

        self.stdout.write("Deleting Doctors...")
        Doctor.objects.all().delete()

        self.stdout.write("Deleting Subjects...")
        Subject.objects.all().delete()

        self.stdout.write("Deleting Categories...")
        Category.objects.all().delete()

        self.stdout.write(self.style.SUCCESS("All notes data cleared successfully"))