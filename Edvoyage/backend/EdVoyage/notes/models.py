import logging

from django.db import models, transaction
from django.utils import timezone
from edvoayge.file_utils import title_based_upload_path

logger = logging.getLogger(__name__)


class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    
    def __str__(self):
        return self.name


class Subject(models.Model):
    name = models.CharField(max_length=100, unique=True)
    
    def __str__(self):
        return self.name

class SubSubject(models.Model):
    subject = models.ForeignKey(Subject, related_name='flashcards', on_delete=models.CASCADE)
    name = models.CharField(max_length=150)
    def __str__(self):
        return f"{self.name}"


class Doctor(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name

class Video(models.Model):
    category = models.ForeignKey(Category, related_name='videos', on_delete=models.CASCADE)
    subject = models.ForeignKey(Subject, related_name='videos', on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    video_url = models.URLField()
    is_free = models.BooleanField(default=False)
    logo = models.ImageField(upload_to='video_logos/')
    doctor = models.ForeignKey(Doctor, related_name='videos', on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['-id']  # newest first


class MCQ(models.Model):
    category = models.ForeignKey(Category, related_name='mcqs', on_delete=models.CASCADE)
    subject = models.ForeignKey(Subject, related_name='mcqs', on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    is_free = models.BooleanField(default=False)
    logo = models.ImageField(upload_to='mcq_logos/')

    def __str__(self):
        return f"{self.subject.name} - {self.title}"



class Question(models.Model):
    """
    This model represents a single question within an MCQ set.
    It is linked to a specific MCQ.
    """
    mcq = models.ForeignKey(MCQ, related_name='questions', on_delete=models.CASCADE)
    text = models.TextField(help_text="The text of the question.")

    def __str__(self):
        # Returns the first 50 characters of the question for a clean admin display
        return self.text[:50]

class Option(models.Model):
    """
    This model represents one of the possible answers for a Question.
    It is linked to a specific Question and has a flag to mark the correct answer.
    """
    question = models.ForeignKey(Question, related_name='options', on_delete=models.CASCADE)
    text = models.CharField(max_length=255, help_text="The text for this answer option.")
    is_correct = models.BooleanField(default=False, help_text="Mark this if it is the correct answer.")

    def __str__(self):
        return f"Option for question: {self.question.id} | {self.text}"

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['question', 'is_correct'],
                condition=models.Q(is_correct=True),
                name='unique_correct_option_for_question'
            )
        ]




class ClinicalCase(models.Model):
    """
    Represents a clinical case examination with detailed sections for data entry.
    Each section is a TextField to accommodate large amounts of text.
    """
    
    # A title field to easily identify each case

    category = models.ForeignKey(Category, related_name='cases', on_delete=models.CASCADE)
    doctor = models.ForeignKey(Doctor, related_name='cases', on_delete=models.CASCADE)
    subject = models.ForeignKey(Subject, related_name='cases', on_delete=models.CASCADE)
    case_title = models.CharField(max_length=255, help_text="Enter the title for this clinical case, e.g., 'Cardiovascular Examination of Patient X'.")

    # The fields you requested for large text input
    gather_equipments = models.TextField(
        verbose_name="Gather Equipments",
        help_text="List all necessary equipment for the examination."
    )
    
    introduction = models.TextField(
        verbose_name="Introduction",
        help_text="Describe the introduction to the patient, including consent."
    )
    
    general_inspection = models.TextField(
        verbose_name="General Inspection",
        help_text="Detail the findings from the general inspection of the patient."
    )
    
    closer_inspection = models.TextField(
        verbose_name="Closer Inspection",
        help_text="Detail the findings from a closer, more focused inspection."
    )
    
    palpation = models.TextField(
        verbose_name="Palpation",
        help_text="Record the findings from palpation."
    )
    
    final_examination = models.TextField(
        verbose_name="Final Examination",
        help_text="Describe any final examination steps, like auscultation or percussion."
    )
    
    references = models.TextField(
        verbose_name="References",
        help_text="List any references or sources cited.",
        blank=True, # This field is optional
        null=True
    )

    # Timestamps for tracking when the record was created or updated
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        """
        Returns a human-readable string representation of the case,
        which is used in the Django admin site.
        """
        return self.case_title

    class Meta:
        verbose_name = "Clinical Case"
        verbose_name_plural = "Clinical Cases"
        ordering = ['-created_at'] # Show the most recent cases first








class Flashcard(models.Model):
    class ProcessingStatus(models.TextChoices):
        IDLE = "idle", "Idle"
        PENDING = "pending", "Pending"
        PROCESSING = "processing", "Processing"
        COMPLETED = "completed", "Completed"
        FAILED = "failed", "Failed"

    category = models.ForeignKey(Category, related_name='flashcards', on_delete=models.CASCADE)
    subject = models.ForeignKey(Subject, related_name='subject_name', on_delete=models.CASCADE)
    sub_subject = models.ForeignKey(SubSubject, related_name='sub_subject_name', on_delete=models.CASCADE)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    pdf_file = models.FileField(upload_to=title_based_upload_path("flashcards/pdfs"), blank=True, null=True)
    processing_status = models.CharField(
        max_length=20,
        choices=ProcessingStatus.choices,
        default=ProcessingStatus.IDLE,
    )
    processing_error = models.TextField(blank=True, default="")
    processing_updated_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.subject.name} → {self.sub_subject.name}"

    def save(self, *args, **kwargs):
        pdf_changed = self._pdf_file_changed()

        if self.pdf_file and pdf_changed:
            self.processing_status = self.ProcessingStatus.PENDING
            self.processing_error = ""
            self.processing_updated_at = timezone.now()

        super().save(*args, **kwargs)

        if self.pdf_file and pdf_changed:
            flashcard_id = self.pk
            transaction.on_commit(
                lambda: self._enqueue_pdf_processing(flashcard_id)
            )

    def _enqueue_pdf_processing(self, flashcard_id: int) -> None:
        from notes.services.flashcard_pdf import enqueue_flashcard_pdf_processing

        enqueue_flashcard_pdf_processing(flashcard_id)

    def _pdf_file_changed(self) -> bool:
        if not self.pdf_file:
            return False
        if not self.pk:
            return True
        previous = (
            Flashcard.objects.filter(pk=self.pk)
            .values_list("pdf_file", flat=True)
            .first()
        )
        return previous != self.pdf_file.name




class FlashcardImage(models.Model):
    flashcard = models.ForeignKey(
        Flashcard,
        related_name="images",
        on_delete=models.CASCADE
    )
    image = models.ImageField(upload_to=title_based_upload_path("flashcards"))
    caption = models.CharField(max_length=255, blank=True)

    def __str__(self):
        return f"'{self.caption}' of Flashcard ID {self.flashcard.id}"
