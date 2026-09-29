import logging
import os
import traceback

from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags

logger = logging.getLogger(__name__)


class EmailService:
    """Email operations for OTP and notifications."""

    @staticmethod
    def send_otp_email(email_address, otp_code, user_name=None):
        """Send OTP verification email. Never logs the OTP code."""
        try:
            logger.info('Sending OTP email to %s', email_address)

            resend_key = os.getenv('RESEND_API_KEY')
            if resend_key:
                import resend
                resend.api_key = resend_key
                html_content = render_to_string('emails/otp_email.html', {
                    'otp_code': otp_code,
                    'user_name': user_name or 'User',
                    'app_name': 'Edzkool',
                }) if os.path.exists(
                    os.path.join(settings.BASE_DIR, 'templates', 'emails', 'otp_email.html')
                ) else (
                    f'<p>Your Edzkool verification code is: <strong>{otp_code}</strong></p>'
                    f'<p>This code expires in 15 minutes.</p>'
                )
                resend.Emails.send({
                    'from': getattr(settings, 'DEFAULT_FROM_EMAIL', 'office@bfuturetechnologies.com'),
                    'to': email_address,
                    'subject': 'Edzkool OTP Verification',
                    'html': html_content,
                })
                logger.info('OTP email sent via Resend to %s', email_address)
                return True, 'Email sent successfully'

            context = {
                'otp_code': otp_code,
                'user_name': user_name or 'User',
                'app_name': 'Edzkool',
            }
            html_message = render_to_string('emails/otp_email.html', context)
            plain_message = strip_tags(html_message)
            email_sent = send_mail(
                subject='Edzkool OTP Verification',
                message=plain_message,
                from_email=getattr(settings, 'DEFAULT_FROM_EMAIL', 'office@bfuturetechnologies.com'),
                recipient_list=[email_address],
                html_message=html_message,
                fail_silently=False,
            )
            if email_sent:
                logger.info('OTP email sent via SMTP to %s', email_address)
                return True, 'Email sent successfully'
            logger.error('Failed to send OTP email to %s', email_address)
            return False, 'send_mail returned False'

        except Exception as e:
            logger.exception('Exception sending OTP email to %s', email_address)
            return False, f'Exception: {str(e)}'

    @staticmethod
    def test_email_connection():
        try:
            email_sent = send_mail(
                subject='Edzkool Email Test',
                message='Email configuration test.',
                from_email=getattr(settings, 'DEFAULT_FROM_EMAIL', 'office@bfuturetechnologies.com'),
                recipient_list=[getattr(settings, 'DEFAULT_FROM_EMAIL', 'office@bfuturetechnologies.com')],
                fail_silently=False,
            )
            return bool(email_sent)
        except Exception:
            logger.exception('Email connection test failed')
            return False

    @staticmethod
    def get_email_config_status():
        return {
            'backend': getattr(settings, 'EMAIL_BACKEND', 'Not configured'),
            'host': getattr(settings, 'EMAIL_HOST', 'Not configured'),
            'port': getattr(settings, 'EMAIL_PORT', 'Not configured'),
            'use_tls': getattr(settings, 'EMAIL_USE_TLS', False),
            'host_user': getattr(settings, 'EMAIL_HOST_USER', 'Not configured'),
            'host_password': 'Configured' if getattr(settings, 'EMAIL_HOST_PASSWORD', None) else 'Not configured',
            'default_from_email': getattr(settings, 'DEFAULT_FROM_EMAIL', 'Not configured'),
        }
