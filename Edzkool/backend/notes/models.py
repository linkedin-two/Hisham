from django.db import models
from django.utils import timezone
from django.utils.text import slugify
from edvoayge.file_utils import title_based_upload_path
import os
import platform
import io
import logging
from uuid import uuid4
from django.core.files import File
from pdf2image import convert_from_path

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








def _convert_pdf_to_images_task(flashcard_id):
    """
    Background worker to extract images from an uploaded Flashcard PDF.
    Runs asynchronously so Django admin HTTP requests respond in <1 second
    and never hit Gunicorn's 30-second worker timeout on large (14MB+) files.
    """
    from notes.models import Flashcard, FlashcardImage

    try:
        flashcard = Flashcard.objects.filter(pk=flashcard_id).first()
        if not flashcard or not flashcard.pdf_file:
            return

        temp_pdf_path = None
        try:
            try:
                pdf_path = flashcard.pdf_file.path
            except (NotImplementedError, AttributeError):
                import tempfile
                with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as tf:
                    for chunk in flashcard.pdf_file.chunks():
                        tf.write(chunk)
                    temp_pdf_path = tf.name
                pdf_path = temp_pdf_path

            if not os.path.exists(pdf_path):
                logger.warning(f"Flashcard {flashcard_id}: PDF file not found at {pdf_path}")
                return

            title_parts = []
            if flashcard.subject and hasattr(flashcard.subject, 'name'):
                title_parts.append(str(flashcard.subject.name))
            if flashcard.sub_subject and hasattr(flashcard.sub_subject, 'name'):
                title_parts.append(str(flashcard.sub_subject.name))
            if not title_parts and flashcard.pdf_file:
                pdf_base = os.path.splitext(os.path.basename(flashcard.pdf_file.name))[0]
                title_parts.append(pdf_base)
            if not title_parts and flashcard.description:
                title_parts.append(str(flashcard.description[:30]))
            title_slug = slugify("_".join(title_parts)).replace("-", "_")[:80] or f"flashcard_{flashcard_id}"

            # 1. Fast path: pypdfium2 (self-contained, zero system dependencies, low memory, very fast)
            converted = False
            try:
                import pypdfium2 as pdfium
                pdf = pdfium.PdfDocument(pdf_path)
                num_pages = len(pdf)
                for i, page in enumerate(pdf, start=1):
                    image = page.render(scale=1.5).to_pil()
                    image_io = io.BytesIO()
                    image.save(image_io, format="JPEG", quality=85)
                    image_io.seek(0)

                    filename = f"{title_slug}_page_{i}.jpg"
                    FlashcardImage.objects.create(
                        flashcard=flashcard,
                        image=File(image_io, name=filename),
                        caption=f"Page {i}"
                    )
                    image_io.close()
                converted = True
                logger.info(f"Flashcard {flashcard_id}: Successfully extracted {num_pages} images via pypdfium2.")
            except ImportError:
                pass
            except Exception as e:
                logger.warning(f"Flashcard {flashcard_id}: pypdfium2 conversion failed, trying fallback: {e}")

            # 2. Fallback: pdf2image (requires poppler-utils)
            if not converted:
                try:
                    from pdf2image import convert_from_path
                    poppler_kwargs = {}
                    if platform.system() == "Windows" and os.path.exists(r"C:\poppler\bin"):
                        poppler_kwargs["poppler_path"] = r"C:\poppler\bin"

                    pages = convert_from_path(
                        pdf_path,
                        dpi=120,
                        fmt="jpeg",
                        thread_count=1,
                        **poppler_kwargs
                    )
                    for i, page in enumerate(pages, start=1):
                        image_io = io.BytesIO()
                        page.save(image_io, format="JPEG", quality=85)
                        image_io.seek(0)

                        filename = f"{title_slug}_page_{i}.jpg"
                        FlashcardImage.objects.create(
                            flashcard=flashcard,
                            image=File(image_io, name=filename),
                            caption=f"Page {i}"
                        )
                        image_io.close()
                    logger.info(f"Flashcard {flashcard_id}: Successfully extracted {len(pages)} images via pdf2image.")
                except Exception as fallback_err:
                    logger.warning(f"Flashcard {flashcard_id}: pdf2image fallback failed: {fallback_err}")

        finally:
            if temp_pdf_path and os.path.exists(temp_pdf_path):
                try:
                    os.remove(temp_pdf_path)
                except Exception:
                    pass

    except Exception as exc:
        logger.exception(f"Flashcard {flashcard_id}: Background PDF image extraction failed: {exc}")


class Flashcard(models.Model):
    category = models.ForeignKey(Category, related_name='flashcards', on_delete=models.CASCADE)
    subject = models.ForeignKey(Subject, related_name='subject_name', on_delete=models.CASCADE)
    sub_subject = models.ForeignKey(SubSubject, related_name='sub_subject_name', on_delete=models.CASCADE, null=True, blank=True)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    pdf_file = models.FileField(upload_to=title_based_upload_path("flashcards/pdfs"), blank=True, null=True)

    def __str__(self):
        sub_name = self.sub_subject.name if self.sub_subject else "General"
        subj_name = self.subject.name if self.subject else "Unknown"
        return f"{subj_name} → {sub_name}"

    def save(self, *args, **kwargs):
        # Check if a new file is uploaded
        new_pdf = self.pk is None or "pdf_file" in kwargs.get("update_fields", [])

        super().save(*args, **kwargs)

        if self.pdf_file and new_pdf:
            # Clear old images first (in case of update)
            self.images.all().delete()
            import threading
            threading.Thread(
                target=_convert_pdf_to_images_task,
                args=(self.pk,),
                daemon=True
            ).start()


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
