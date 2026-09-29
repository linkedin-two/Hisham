# Generated manually for background PDF processing on Render.

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("notes", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="flashcard",
            name="processing_error",
            field=models.TextField(blank=True, default=""),
        ),
        migrations.AddField(
            model_name="flashcard",
            name="processing_status",
            field=models.CharField(
                choices=[
                    ("idle", "Idle"),
                    ("pending", "Pending"),
                    ("processing", "Processing"),
                    ("completed", "Completed"),
                    ("failed", "Failed"),
                ],
                default="idle",
                max_length=20,
            ),
        ),
        migrations.AddField(
            model_name="flashcard",
            name="processing_updated_at",
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
