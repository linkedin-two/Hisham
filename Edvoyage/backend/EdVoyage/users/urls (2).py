"""
URL patterns for users app (simplified).

This module registers only the `UserViewSet` and OTP routes. A
separate function-based endpoint `users/by-email/` is exposed for
fetching a user by email.
"""

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import list_users, get_user_by_email
from .views import upload_profile_image
from .otp_views import OTPVerificationViewSet
from .sub_views import SendOTPView

# Create router for ViewSets (we only register OTP here)
router = DefaultRouter()
router.register(r'otp', OTPVerificationViewSet, basename='otp')


app_name = 'users'

urlpatterns = [
    # Include router URLs
    path('', include(router.urls)),
    # Standalone endpoint for fetching a user by email
    # List all users (full JSON)
    path('users/', list_users, name='users-list'),
    # Standalone endpoint for fetching a user by email
    path('users/by-email/', get_user_by_email, name='user-by-email'),
       
    # Legacy/simple OTP sending endpoint
    path('send-otp/', SendOTPView.as_view(), name='send-otp'),

    path('upload-profile-image/', upload_profile_image, name='users-upload-profile-image'),
]