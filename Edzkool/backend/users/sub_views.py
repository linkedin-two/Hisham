"""
Helper/auth views moved out of the main `views.py`.

This module contains login/logout/password reset and the legacy
`SendOTPView`. They are implemented as small APIView classes so they
can be mounted to URLs from `users/urls.py` or included where needed.
"""
import logging
import secrets
from datetime import timedelta
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.contrib.auth import authenticate, get_user_model
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from edvoayge.throttling import AuthRateThrottle
from rest_framework_simplejwt.tokens import RefreshToken, AccessToken
from rest_framework_simplejwt.exceptions import TokenError

from .serializers import (
    LoginSerializer, PasswordChangeSerializer,
    PasswordResetRequestSerializer, PasswordResetConfirmSerializer,
    UserMinimalSerializer
)
from .models import UserSession, UserActivity, OTPVerification, UserProfile
from .services import EmailService
from edvoayge.api_response import api_error, api_success

logger = logging.getLogger(__name__)
User = get_user_model()


class LoginView(APIView):
    permission_classes = [AllowAny]
    throttle_classes = [AuthRateThrottle]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        user = authenticate(username=email, password=password)
        if not user:
            return api_error(
                message="Invalid credentials",
                error_code="unauthorized",
                status_code=status.HTTP_401_UNAUTHORIZED,
            )

        refresh = RefreshToken.for_user(user)
        access = str(refresh.access_token)
        return api_success(
            data={
                "user": UserMinimalSerializer(user).data,
                "access": access,
                "refresh": str(refresh),
                "token": access,
            },
            message="Login successful",
            status_code=status.HTTP_200_OK,
        )


class LogoutView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        """Logout user by blacklisting refresh token."""
        try:
            refresh_token = request.data.get('refresh_token')

            if refresh_token:
                try:
                    RefreshToken(refresh_token).blacklist()
                except TokenError:
                    logger.warning('Invalid or already blacklisted refresh token')

            user = request.user if getattr(request.user, 'is_authenticated', False) else None
            if user:
                device_id = request.headers.get('Device-ID', '')
                if device_id:
                    UserSession.objects.filter(
                        user=user,
                        device_id=device_id,
                        is_active=True,
                    ).update(is_active=False)

                UserActivity.objects.create(
                    user=user,
                    activity_type='logout',
                    ip_address=self._get_client_ip(request),
                    user_agent=request.headers.get('User-Agent', ''),
                    details={'device_id': device_id},
                )
                logger.info('User %s logged out successfully', user)

            return api_success(data=None, message='Logout successful', status_code=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"Error during logout: {e}")
            return api_error(
                message="Logout failed",
                error_code="logout_failed",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def _get_client_ip(self, request):
        """Get client IP address from request"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            return x_forwarded_for.split(',')[0].strip()
        return request.META.get('REMOTE_ADDR', '')


class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]
    throttle_classes = [AuthRateThrottle]

    def post(self, request):
        serializer = PasswordChangeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = request.user
        if not user or not user.is_authenticated:
            return api_error(
                message='Authentication required',
                error_code='unauthorized',
                status_code=status.HTTP_401_UNAUTHORIZED,
            )
        email = request.data.get('email')
        if email and user.email.lower() != email.lower():
            return api_error(
                message='You can only change your own password',
                error_code='forbidden',
                status_code=status.HTTP_403_FORBIDDEN,
            )
        old_password = serializer.validated_data['old_password']
        new_password = serializer.validated_data['new_password']
        if not user.check_password(old_password):
            return api_error(
                message="Invalid old password",
                error_code="bad_request",
                status_code=status.HTTP_400_BAD_REQUEST,
            )
        user.set_password(new_password)
        user.save()
        return api_success(data=None, message="Password changed successfully", status_code=status.HTTP_200_OK)


class PasswordResetRequestView(APIView):
    permission_classes = [AllowAny]
    throttle_classes = [AuthRateThrottle]

    GENERIC_RESPONSE = 'If an account exists for this email, an OTP has been sent.'

    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        user = User.objects.filter(email__iexact=email).first()
        if user:
            otp_code = str(secrets.randbelow(900000) + 100000)
            OTPVerification.objects.create(
                user=user,
                otp_type='password_reset',
                contact=email,
                otp_code=otp_code,
            )
            EmailService.send_otp_email(email, otp_code)
        return api_success(
            data=None,
            message=self.GENERIC_RESPONSE,
            status_code=status.HTTP_200_OK,
        )


class PasswordResetConfirmView(APIView):
    permission_classes = [AllowAny]
    throttle_classes = [AuthRateThrottle]

    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        otp_code = serializer.validated_data['otp_code']
        new_password = serializer.validated_data['new_password']
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return api_error(
                message="User not found",
                error_code="not_found",
                status_code=status.HTTP_404_NOT_FOUND,
            )
        try:
            otp = OTPVerification.objects.get(user=user, otp_code=otp_code, is_verified=False, is_expired=False)
        except OTPVerification.DoesNotExist:
            return api_error(
                message="Invalid OTP",
                error_code="bad_request",
                status_code=status.HTTP_400_BAD_REQUEST,
            )
        otp.is_verified = True
        otp.save()
        user.set_password(new_password)
        user.save()
        return api_success(data=None, message="Password reset successful", status_code=status.HTTP_200_OK)


class SendOTPView(APIView):
    permission_classes = [AllowAny]
    throttle_classes = [AuthRateThrottle]
    MAX_OTP_REQUESTS = 3
    OTP_WINDOW_MINUTES = 10

    def post(self, request):
        contact = request.data.get('contact')
        if not contact:
            return api_error(
                message="Email required",
                error_code="bad_request",
                status_code=status.HTTP_400_BAD_REQUEST,
            )
        # Validate basic email format
        if '@' not in contact:
            return api_error(
                message="Invalid email",
                error_code="bad_request",
                status_code=status.HTTP_400_BAD_REQUEST,
            )
        
        # Normalize email
        contact = contact.lower().strip()
        
        # Rate limiting check
        from django.utils import timezone
        from datetime import timedelta
        
        time_window = timezone.now() - timedelta(minutes=self.OTP_WINDOW_MINUTES)
        recent_otps = OTPVerification.objects.filter(
            contact=contact,
            created_at__gte=time_window,
            otp_type='register'
        ).count()
        
        if recent_otps >= self.MAX_OTP_REQUESTS:
            logger.warning(f"OTP rate limit exceeded for {contact}")
            return api_error(
                message=f"Too many OTP requests. Please try again after {self.OTP_WINDOW_MINUTES} minutes.",
                error_code="rate_limit_exceeded",
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            )
        
        otp_code = str(secrets.randbelow(900000) + 100000)
        OTPVerification.objects.create(otp_type='register', contact=contact, otp_code=otp_code)
        
        try:
            EmailService.send_otp_email(contact, otp_code)
            logger.info(f"OTP sent successfully to {contact}")
        except Exception as e:
            logger.error(f"Failed to send OTP to {contact}: {e}")
            # Don't expose OTP in response if email fails
            return api_error(
                message="Failed to send OTP. Please try again later.",
                error_code="email_failed",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
        
        return api_success(
            data={"message": "OTP sent successfully"},
            message="OTP sent",
            status_code=status.HTTP_201_CREATED,
        )


class DeleteAccountView(APIView):
    """GDPR-style account deletion — deactivates user and blacklists tokens."""
    permission_classes = [IsAuthenticated]
    throttle_classes = [AuthRateThrottle]

    def delete(self, request):
        return self._delete_account(request)

    def post(self, request):
        return self._delete_account(request)

    def _delete_account(self, request):
        user = request.user
        confirm_email = (request.data.get('confirm_email') or '').lower().strip()
        password = request.data.get('password', '')

        if confirm_email and confirm_email != user.email.lower():
            return api_error(
                message='Email confirmation does not match your account.',
                error_code='email_mismatch',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        if password:
            if not user.check_password(password):
                return api_error(
                    message='Incorrect password.',
                    error_code='invalid_password',
                    status_code=status.HTTP_400_BAD_REQUEST,
                )

        refresh_token = request.data.get('refresh_token')
        if refresh_token:
            try:
                RefreshToken(refresh_token).blacklist()
            except TokenError:
                pass

        UserActivity.objects.create(
            user=user,
            activity_type='account_deleted',
            ip_address=self._get_client_ip(request),
            user_agent=request.headers.get('User-Agent', ''),
            details={},
        )

        user.is_active = False
        user.email = f'deleted_{user.id}_{user.email}'
        if hasattr(user, 'username'):
            user.username = f'deleted_{user.id}_{getattr(user, "username", user.id)}'
        user.set_unusable_password()
        user.save()

        UserSession.objects.filter(user=user, is_active=True).update(is_active=False)

        logger.info('Account deleted (deactivated) for user id %s', user.id)
        return api_success(
            data=None,
            message='Account deleted successfully.',
            status_code=status.HTTP_200_OK,
        )

    def _get_client_ip(self, request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            return x_forwarded_for.split(',')[0].strip()
        return request.META.get('REMOTE_ADDR', '')
