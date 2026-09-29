from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class ClassMeetLink(models.Model):
    """Google Meet URL configured per school class (1-10)."""

    class_number = models.PositiveSmallIntegerField(
        unique=True,
        validators=[MinValueValidator(1), MaxValueValidator(10)],
        verbose_name='Class Number',
    )
    meet_url = models.URLField(max_length=500, blank=True, default='', verbose_name='Meet URL')
    is_active = models.BooleanField(default=True, verbose_name='Active')
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Class Meet Link'
        verbose_name_plural = 'Class Meet Links'
        ordering = ['class_number']

    def __str__(self):
        return f'Class {self.class_number}'
