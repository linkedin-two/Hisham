import logging
import secrets

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import OTPVerification
from .serializers import SendOTPSerializer
from .services import EmailService

logger = logging.getLogger(__name__)


class CreateOTPView(APIView):
    """API endpoint to receive POST request with email, generate OTP, and send email."""

    authentication_classes = []
    permission_classes = []

    @staticmethod
    def generate_otp():
        return str(secrets.randbelow(900000) + 100000)

    def post(self, request):
        serializer = SendOTPSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'success': False,
                'message': 'Invalid input',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        contact = serializer.validated_data['validated_contact']
        otp_type = serializer.validated_data.get('otp_type', 'email')

        otp_code = self.generate_otp()
        try:
            OTPVerification.objects.create(otp_type=otp_type, contact=contact, otp_code=otp_code)
        except Exception as db_err:
            logger.warning('Could not save OTP to database: %s', db_err)

        email_sent, debug_msg = EmailService.send_otp_email(contact, otp_code)

        if email_sent:
            return Response({
                'success': True,
                'message': 'OTP created and sent',
                'data': {'email_sent': True, 'contact': contact}
            }, status=status.HTTP_201_CREATED)

        logger.error('OTP email failed for %s: %s', contact, debug_msg)
        return Response({
            'success': False,
            'message': 'Failed to send OTP. Please try again later.',
            'error_code': 'email_failed',
            'details': debug_msg
        }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class HealthCheckView(APIView):
    """Health check / ping endpoint for cron jobs and uptime monitors."""

    authentication_classes = []
    permission_classes = []

    def get(self, request):
        return Response({
            'status': 'ok',
            'message': 'Edzkool backend mailer service is running',
            'service': 'mailer'
        }, status=status.HTTP_200_OK)

    def head(self, request):
        return Response(status=status.HTTP_200_OK)

    def post(self, request):
        contact = request.data.get('email') or request.data.get('contact')
        if contact:
            otp_code = str(secrets.randbelow(900000) + 100000)
            try:
                OTPVerification.objects.create(otp_type='email', contact=contact, otp_code=otp_code)
            except Exception as db_err:
                logger.warning('Could not save OTP to database: %s', db_err)
            email_sent, debug_msg = EmailService.send_otp_email(contact, otp_code)
            return Response({
                'success': email_sent,
                'status': 'ok' if email_sent else 'error',
                'message': 'OTP created and sent via health POST' if email_sent else 'Failed to send OTP email',
                'data': {'email_sent': email_sent, 'contact': contact},
                'details': debug_msg
            }, status=status.HTTP_200_OK if email_sent else status.HTTP_503_SERVICE_UNAVAILABLE)

        return Response({
            'status': 'ok',
            'message': 'Edzkool backend mailer service is running',
            'service': 'mailer'
        }, status=status.HTTP_200_OK)
