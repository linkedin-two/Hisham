import uuid
from django.db import models



class Notification(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=255)
    description = models.TextField()
    subtitle = models.CharField(max_length=255, blank=True)
    is_offer = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['is_offer', 'created_at']),
            models.Index(fields=['created_at']),
        ]

    def __str__(self):
        return self.title

