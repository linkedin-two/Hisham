"""
Helper/auth views moved out of the main `views.py`.

This module contains login/logout/password reset and the legacy
`SendOTPView`. They are implemented as small APIView classes so they
can be mounted to URLs from `users/urls.py` or included where needed.
"""
import logging
import random
import string
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.contrib.auth import authenticate, get_user_model
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

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
        # NOTE: we avoid creating sessions/tokens here per user's request
        return api_success(
            data={"user": UserMinimalSerializer(user).data},
            message="Login accepted",
            status_code=status.HTTP_200_OK,
        )


class LogoutView(APIView):
    def post(self, request):
        # Stateless logout placeholder (no server-side sessions enforced)
        return api_success(data=None, message="Logout accepted", status_code=status.HTTP_200_OK)


class ChangePasswordView(APIView):
    def post(self, request):
        serializer = PasswordChangeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        # Per user's instruction, do not rely on request.user — use email if provided
        email = request.data.get('email')
        if not email:
            return api_error(
                message="Email required",
                error_code="bad_request",
                status_code=status.HTTP_400_BAD_REQUEST,
            )
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return api_error(
                message="User not found",
                error_code="not_found",
                status_code=status.HTTP_404_NOT_FOUND,
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
    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return api_error(
                message="User not found",
                error_code="not_found",
                status_code=status.HTTP_404_NOT_FOUND,
            )
        otp_code = ''.join(random.choices(string.digits, k=6))
        otp = OTPVerification.objects.create(user=user, otp_type='password_reset', contact=email, otp_code=otp_code)
        EmailService.send_otp_email(email, otp_code)
        return api_success(
            data={"otp": otp_code},
            message="OTP sent",
            status_code=status.HTTP_200_OK,
        )


class PasswordResetConfirmView(APIView):
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
        otp_code = ''.join(random.choices(string.digits, k=6))
        otp = OTPVerification.objects.create(otp_type='register', contact=contact, otp_code=otp_code)
        EmailService.send_otp_email(contact, otp_code)
        return api_success(
            data={"otp": otp_code},
            message="OTP sent",
            status_code=status.HTTP_201_CREATED,
        )
