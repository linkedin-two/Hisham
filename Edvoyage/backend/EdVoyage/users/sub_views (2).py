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
            return Response({'success': False, 'message': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
        # NOTE: we avoid creating sessions/tokens here per user's request
        return Response({'success': True, 'message': 'Login accepted', 'user': UserMinimalSerializer(user).data})


class LogoutView(APIView):
    def post(self, request):
        # Stateless logout placeholder (no server-side sessions enforced)
        return Response({'success': True, 'message': 'Logout accepted'})


class ChangePasswordView(APIView):
    def post(self, request):
        serializer = PasswordChangeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        # Per user's instruction, do not rely on request.user — use email if provided
        email = request.data.get('email')
        if not email:
            return Response({'success': False, 'message': 'Email required'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'success': False, 'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        old_password = serializer.validated_data['old_password']
        new_password = serializer.validated_data['new_password']
        if not user.check_password(old_password):
            return Response({'success': False, 'message': 'Invalid old password'}, status=status.HTTP_400_BAD_REQUEST)
        user.set_password(new_password)
        user.save()
        return Response({'success': True, 'message': 'Password changed successfully'})


class PasswordResetRequestView(APIView):
    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'success': False, 'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        otp_code = ''.join(random.choices(string.digits, k=6))
        otp = OTPVerification.objects.create(user=user, otp_type='password_reset', contact=email, otp_code=otp_code)
        EmailService.send_otp_email(email, otp_code)
        return Response({'success': True, 'message': 'OTP sent', 'otp': otp_code})


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
            return Response({'success': False, 'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        try:
            otp = OTPVerification.objects.get(user=user, otp_code=otp_code, is_verified=False, is_expired=False)
        except OTPVerification.DoesNotExist:
            return Response({'success': False, 'message': 'Invalid OTP'}, status=status.HTTP_400_BAD_REQUEST)
        otp.is_verified = True
        otp.save()
        user.set_password(new_password)
        user.save()
        return Response({'success': True, 'message': 'Password reset successful'})


class SendOTPView(APIView):
    def post(self, request):
        contact = request.data.get('contact')
        if not contact:
            return Response({'success': False, 'message': 'Email required'}, status=status.HTTP_400_BAD_REQUEST)
        # Validate basic email format
        if '@' not in contact:
            return Response({'success': False, 'message': 'Invalid email'}, status=status.HTTP_400_BAD_REQUEST)
        otp_code = ''.join(random.choices(string.digits, k=6))
        otp = OTPVerification.objects.create(otp_type='register', contact=contact, otp_code=otp_code)
        EmailService.send_otp_email(contact, otp_code)
        return Response({'success': True, 'message': 'OTP sent', 'otp': otp_code}, status=status.HTTP_201_CREATED)
