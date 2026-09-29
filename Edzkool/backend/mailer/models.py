from django.db import models


class OTPVerification(models.Model):
    otp_type = models.CharField(max_length=50, default='email')
    contact = models.CharField(max_length=255)
    otp_code = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)
    is_verified = models.BooleanField(default=False)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.contact} - {self.otp_code} ({self.otp_type})"
