import logging
import os

from django.conf import settings
from django.core.mail import send_mail

logger = logging.getLogger(__name__)


class EmailService:
    """Email operations for OTP and notifications with Edzkool brand template."""

    @staticmethod
    def get_otp_html_template(otp_code):
        return f"""
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your OTP Code - Edzkool</title>
</head>
<body style="margin: 0; padding: 0; background-color: #F4F6F8; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color: #F4F6F8; padding: 40px 15px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width: 520px; background-color: #ffffff; border-radius: 14px; overflow: hidden; box-shadow: 0 6px 20px rgba(0,0,0,0.06); border: 1px solid #E6E9EF;">
          
          <!-- Top Header Banner with Edzkool Brand Gradient -->
          <tr>
            <td style="background: linear-gradient(135deg, #144787 0%, #0F3B6A 100%); padding: 28px 24px; text-align: center;">
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr>
                  <td align="center" style="padding-bottom: 8px;">
                    <!-- Edzkool Brand Header Logo -->
                    <span style="font-size: 26px; font-weight: 900; color: #ffffff; letter-spacing: 1px;">Edz<span style="color: #FD9202;">kool</span></span>
                  </td>
                </tr>
                <tr>
                  <td align="center">
                    <h1 style="margin: 0; font-size: 20px; font-weight: 700; color: #ffffff; letter-spacing: 0.5px;">Your OTP Code</h1>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Main Content Card -->
          <tr>
            <td style="padding: 35px 30px; color: #1F2937; font-size: 15px; line-height: 1.6;">
              <p style="margin-top: 0; font-size: 16px; font-weight: 600; color: #1F2937;">Hello,</p>
              <p style="margin-bottom: 20px; color: #4B5563;">Your One-Time Password (OTP) for account verification is:</p>
              
              <!-- OTP Display Box -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin: 25px 0;">
                <tr>
                  <td align="center" style="background-color: #F4F6F8; border-radius: 12px; padding: 22px; border: 1px solid #E6E9EF;">
                    <span style="font-size: 34px; font-weight: 800; color: #144787; letter-spacing: 8px; font-family: 'Courier New', Courier, monospace;">{otp_code}</span>
                  </td>
                </tr>
              </table>
              
              <p style="font-size: 14px; color: #4B5563; margin-bottom: 12px;">
                This OTP is valid for <strong>15 minutes</strong>. Please do not share this code with anyone.
              </p>
              <p style="font-size: 13px; color: #6C757D; margin-bottom: 28px;">
                If you didn't request this code, please ignore this email.
              </p>
              <p style="margin-bottom: 0; font-size: 14px; font-weight: 600; color: #144787;">
                Thank you for using our service!
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #F8FAFC; padding: 18px; text-align: center; border-top: 1px solid #E6E9EF; color: #94A3B8; font-size: 12px;">
              &copy; 2026 Edzkool. All rights reserved.
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
"""

    @classmethod
    def send_otp_email(cls, email_address, otp_code, user_name=None):
        """Send OTP verification email using Resend API or SMTP fallback."""
        try:
            logger.info('Sending OTP email to %s', email_address)
            html_content = cls.get_otp_html_template(otp_code)

            resend_key = os.getenv('RESEND_API_KEY') or getattr(settings, 'RESEND_API_KEY', None)
            if resend_key:
                import resend
                resend.api_key = resend_key
                from_email = os.getenv('RESEND_FROM_EMAIL', 'onboarding@resend.dev')

                resend.Emails.send({
                    'from': from_email,
                    'to': email_address,
                    'subject': 'Your OTP Code - Edzkool',
                    'html': html_content,
                })
                logger.info('OTP email sent via Resend to %s', email_address)
                return True, 'Email sent successfully via Resend'

            subject = 'Your OTP Code - Edzkool'
            text_message = f'Hello,\nYour One-Time Password (OTP) for account verification is: {otp_code}\n\nThis OTP is valid for 15 minutes.'
            from_addr = (
                getattr(settings, 'DEFAULT_FROM_EMAIL', None) or
                getattr(settings, 'EMAIL_HOST_USER', None) or
                'office@bfuturetechnologies.com'
            )
            email_sent = send_mail(
                subject=subject,
                message=text_message,
                from_email=from_addr,
                recipient_list=[email_address],
                html_message=html_content,
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
