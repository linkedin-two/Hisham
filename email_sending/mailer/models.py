from django.db import models
from django.utils import timezone


class OTPVerification(models.Model):
    contact = models.CharField(max_length=255)
    otp_type = models.CharField(max_length=50, default='email')
    otp_code = models.CharField(max_length=10)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.contact} - {self.otp_code}"
