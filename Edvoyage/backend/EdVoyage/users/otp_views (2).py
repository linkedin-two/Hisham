"""
OTP related views moved into their own module.

This file contains `OTPVerificationViewSet` copied from the original
views file so OTP logic is isolated.
"""
import random
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import OTPVerification, UserProfile
from .serializers import OTPVerificationSerializer, OTPCreateSerializer, OTPVerifySerializer, UserSerializer
from .services import EmailService


class OTPVerificationViewSet(viewsets.ModelViewSet):
    queryset = OTPVerification.objects.select_related('user')
    serializer_class = OTPVerificationSerializer

    @classmethod
    def generate_otp(cls):
        cls.otp = str(random.randint(100000, 999999))
        return cls.otp

    @classmethod
    def verify_otp_code(cls, user_input):
        # Minimal placeholder implementation; rely on DB records
        return True

    def get_queryset(self):
        return OTPVerification.objects.all()

    @action(detail=False, methods=['post'], url_path='create')
    def create_otp(self, request):
        serializer = OTPCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        otp_type = serializer.validated_data['otp_type']
        contact = serializer.validated_data['contact']
        otp_code = self.generate_otp()
        otp = OTPVerification.objects.create(otp_type=otp_type, contact=contact, otp_code=otp_code)
        email_sent = EmailService.send_otp_email(contact, otp_code)
        if email_sent:
            return Response({'success': True, 'data': OTPVerificationSerializer(otp).data}, status=status.HTTP_201_CREATED)
        otp.delete()
        return Response({'success': False, 'message': 'Failed to send email'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['post'], url_path='verify')
    def verify_otp(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        otp_code = serializer.validated_data['otp_code']
        contact = (serializer.validated_data['contact'] or '').strip()

        otp = (
            OTPVerification.objects.filter(
                contact__iexact=contact,
                otp_code=otp_code,
            )
            .order_by('-created_at')
            .first()
        )
        if not otp:
            return Response(
                {'success': False, 'message': 'Invalid OTP'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.is_blocked and otp.blocked_until and timezone.now() < otp.blocked_until:
            return Response(
                {'success': False, 'message': 'OTP is temporarily blocked. Try later.'},
                status=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        if otp.is_verified:
            return Response(
                {'success': True, 'message': 'OTP already verified'},
                status=status.HTTP_200_OK,
            )

        if otp.is_expired_property:
            otp.is_expired = True
            otp.save(update_fields=['is_expired'])
            return Response(
                {'success': False, 'message': 'OTP expired'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Mark OTP verified
        otp.is_verified = True
        otp.verified_at = timezone.now()
        otp.failed_attempts = 0
        otp.is_blocked = False
        otp.blocked_until = None
        otp.save(update_fields=['is_verified', 'verified_at', 'failed_attempts', 'is_blocked', 'blocked_until'])

        # Auto-register / auto-restore user + profile
        User = get_user_model()
        user = User.objects.filter(email__iexact=contact).first()
        created_user = False

        if not user:
            base_username = contact.split('@')[0]
            username = base_username
            suffix = 1
            while User.objects.filter(username__iexact=username).exists():
                suffix += 1
                username = f"{base_username}{suffix}"

            user = User.objects.create(
                username=username,
                email=contact,
            )
            try:
                user.set_unusable_password()
                user.save(update_fields=['password'])
            except Exception:
                # If custom user model doesn't support it, ignore
                pass
            created_user = True

        profile, _ = UserProfile.objects.get_or_create(user=user, defaults={'email': contact})
        if not profile.email:
            profile.email = contact
            profile.save(update_fields=['email'])

        data = UserSerializer(user, context={'request': request}).data
        return Response(
            {
                'success': True,
                'message': 'OTP verified',
                'created_user': created_user,
                'data': data,
            },
            status=status.HTTP_200_OK,
        )
