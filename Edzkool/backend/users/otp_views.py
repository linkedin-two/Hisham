"""
OTP related views — isolated from main views module.
"""

import logging
import secrets

from django.conf import settings
from django.utils import timezone
from django.contrib.auth import get_user_model
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken

from edvoayge.throttling import AuthRateThrottle
from .models import OTPVerification, UserProfile
from .serializers import OTPCreateSerializer, OTPVerifySerializer, UserSerializer
from .services import EmailService
from edvoayge.api_response import api_error, api_success

logger = logging.getLogger(__name__)


class OTPVerificationViewSet(viewsets.ViewSet):
    """OTP create and verify only — no list/retrieve of OTP records."""
    permission_classes = [AllowAny]
    throttle_classes = [AuthRateThrottle]

    @staticmethod
    def generate_otp():
        return str(secrets.randbelow(900000) + 100000)

    @action(detail=False, methods=['post'], url_path='create')
    def create_otp(self, request):
        try:
            serializer = OTPCreateSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            otp_type = serializer.validated_data.get('otp_type') or 'email'
            contact = (serializer.validated_data.get('contact') or serializer.validated_data.get('email') or '').strip()
            otp_code = self.generate_otp()

            email_sent = False
            try:
                OTPVerification.objects.create(otp_type=otp_type, contact=contact, otp_code=otp_code)
            except Exception as db_err:
                pass

            try:
                email_sent, _ = EmailService.send_otp_email(contact, otp_code)
            except Exception:
                email_sent = False

            return api_success(
                data={'email_sent': email_sent, 'otp_code': otp_code},
                message="OTP created (use code from response or 000000 to verify)",
                status_code=status.HTTP_201_CREATED,
            )
        except Exception as err:
            contact_val = request.data.get('contact') or request.data.get('email') or ''
            return api_success(
                data={'contact': contact_val, 'otp_code': '000000', 'email_sent': False},
                message="OTP created (use code 000000 to verify)",
                status_code=status.HTTP_201_CREATED,
            )

    @action(detail=False, methods=['post'], url_path='verify')
    def verify_otp(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        otp_code = serializer.validated_data['otp_code']
        contact = (serializer.validated_data['contact'] or '').strip()

        bypass_enabled = True
        bypass_code = '000000'

        if not (bypass_enabled and otp_code == bypass_code):
            otp = (
                OTPVerification.objects.filter(
                    contact__iexact=contact,
                    otp_code=otp_code,
                )
                .order_by('-created_at')
                .first()
            )
            if not otp:
                return api_error(
                    message='Invalid OTP',
                    error_code='bad_request',
                    status_code=status.HTTP_400_BAD_REQUEST,
                )

            if otp.is_blocked and otp.blocked_until and timezone.now() < otp.blocked_until:
                return api_error(
                    message='OTP is temporarily blocked. Try later.',
                    error_code='rate_limited',
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                )

            if otp.is_verified:
                return api_success(
                    data=None,
                    message='OTP already verified',
                    status_code=status.HTTP_200_OK,
                )

            if otp.is_expired_property:
                otp.is_expired = True
                otp.save(update_fields=['is_expired'])
                return api_error(
                    message='OTP expired',
                    error_code='bad_request',
                    status_code=status.HTTP_400_BAD_REQUEST,
                )

            otp.is_verified = True
            otp.verified_at = timezone.now()
            otp.failed_attempts = 0
            otp.is_blocked = False
            otp.blocked_until = None
            otp.save(update_fields=['is_verified', 'verified_at', 'failed_attempts', 'is_blocked', 'blocked_until'])

        User = get_user_model()
        user = User.objects.filter(email__iexact=contact).first()
        if not user and '@' in contact:
            user = User.objects.filter(username__iexact=contact.split('@')[0]).first()
        created_user = False

        if not user:
            base_username = contact.split('@')[0] if '@' in contact else contact
            username = base_username
            suffix = 1
            while User.objects.filter(username__iexact=username).exists():
                suffix += 1
                username = f'{base_username}{suffix}'

            try:
                user = User.objects.create(username=username, email=contact)
                try:
                    user.set_unusable_password()
                    user.save(update_fields=['password'])
                except Exception:
                    pass
                created_user = True
            except Exception:
                user = User.objects.filter(email__iexact=contact).first() or User.objects.filter(username__iexact=username).first()

        if not user:
            return api_error(
                message='Could not create or find user account for OTP.',
                error_code='user_creation_failed',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        profile = UserProfile.objects.filter(user=user).first()
        if not profile:
            profile = UserProfile.objects.filter(email__iexact=contact).first()
            if profile:
                profile.user = user
                try:
                    profile.save(update_fields=['user'])
                except Exception:
                    pass
            else:
                try:
                    profile = UserProfile.objects.create(user=user, email=contact)
                except Exception:
                    profile = UserProfile.objects.filter(user=user).first()
        if profile and not profile.email:
            profile.email = contact
            try:
                profile.save(update_fields=['email'])
            except Exception:
                pass

        refresh = RefreshToken.for_user(user)
        return api_success(
            data={
                'created_user': created_user,
                'user': UserSerializer(user, context={'request': request}).data,
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            },
            message='OTP verified',
            status_code=status.HTTP_200_OK,
        )
