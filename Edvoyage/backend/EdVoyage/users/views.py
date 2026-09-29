"""Very small, focused views for the `users` app.

This module exposes exactly two JSON endpoints and nothing else:
- `list_users` : GET -> return full data for all users (no pagination)
- `get_user_by_email` : GET with `?email=` -> return that user's full data

No prints, no pagination, no `@action`, no extra helpers.
"""

from django.contrib.auth import get_user_model
from rest_framework.decorators import api_view, parser_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from django.db.models import Q
from django_filters.rest_framework import DjangoFilterBackend
from edvoayge.api_response import api_success, api_error
from .serializers import UserSerializer
from .models import UserProfile
from edvoayge.api_response import api_error, api_success

User = get_user_model()


def _get_or_create_user_by_email(email: str):
    email = (email or '').strip()
    if not email:
        return None

    user = User.objects.filter(Q(email__iexact=email) | Q(profile__email__iexact=email)).first()
    if user:
        return user

    base_username = email.split('@')[0] if '@' in email else email
    username = base_username
    suffix = 1
    while User.objects.filter(username__iexact=username).exists():
        suffix += 1
        username = f"{base_username}{suffix}"

    user = User.objects.create(username=username, email=email)
    try:
        user.set_unusable_password()
        user.save(update_fields=['password'])
    except Exception:
        pass

    UserProfile.objects.get_or_create(user=user, defaults={'email': email})
    return user


@api_view(["GET"])
def list_users(request):
    """Return full data for all users as JSON (no pagination)."""
    users = User.objects.all()
    serializer = UserSerializer(users, many=True)
    return api_success(data=serializer.data, message="OK", status_code=status.HTTP_200_OK)


@api_view(["GET"])
def get_user_by_email(request):
    """Return a single user's full data when `?email=` is provided."""
    email = (request.query_params.get("email") or "").strip()
    if not email:
        return api_error(
            message="Email parameter is required",
            error_code="bad_request",
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    user = _get_or_create_user_by_email(email)
 
    
    if not user:
        return api_error(
            message="User not found",
            error_code="not_found",
            status_code=status.HTTP_200_OK,
        )

    serializer = UserSerializer(user)
    return api_success(data=serializer.data, message="OK", status_code=status.HTTP_200_OK)


@api_view(["POST"])
@parser_classes([MultiPartParser, FormParser])
def upload_profile_image(request):
    """Accept multipart POST with `email` and `profile_picture` file.

    - `email` (form field): identifies which user's profile to update
    - `profile_picture` (file): the new image file

    Returns the full user data JSON on success.
    """
    email = (request.data.get("email") or request.query_params.get("email") or "").strip()
    if not email:
        return api_error(
            message="Email parameter is required",
            error_code="bad_request",
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    image = request.FILES.get("profile_picture")
    if not image:
        return api_error(
            message="profile_picture file is required",
            error_code="bad_request",
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    user = _get_or_create_user_by_email(email)
    if not user:
        return api_error(
            message="User not found",
            error_code="not_found",
            status_code=status.HTTP_200_OK,
        )

    profile, _ = UserProfile.objects.get_or_create(user=user, defaults={"email": user.email})
    profile.profile_picture = image
    profile.save()

    serializer = UserSerializer(user)
    return api_success(
        data=serializer.data,
        message="Profile image updated",
        status_code=status.HTTP_200_OK,
    )
