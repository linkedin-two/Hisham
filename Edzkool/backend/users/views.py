"""Focused user profile API endpoints with strict authorization."""

import os

from django.contrib.auth import get_user_model
from django.db.models import Q
from rest_framework.decorators import api_view, parser_classes, permission_classes
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import IsAuthenticated, IsAdminUser

from edvoayge.api_response import api_success, api_error
from edvoayge.auth_utils import get_user_email
from .serializers import UserSerializer
from .models import UserProfile

User = get_user_model()


def _lookup_user_by_email(email: str):
    """Look up an existing user by email — never creates accounts."""
    email = (email or '').strip()
    if not email:
        return None
    return User.objects.filter(
        Q(email__iexact=email) | Q(profile__email__iexact=email)
    ).first()


def _can_access_user_profile(request, target_email: str) -> bool:
    """True if the requester may read the profile for target_email."""
    if request.user.is_staff:
        return True
    request_email = get_user_email(request.user).lower()
    return request_email and request_email == target_email.lower()


@api_view(['GET'])
@permission_classes([IsAdminUser])
def list_users(request):
    """Return full data for all users (admin only)."""
    users = User.objects.all()
    serializer = UserSerializer(users, many=True)
    return api_success(data=serializer.data, message='OK', status_code=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_by_email(request):
    """Return user profile for self, or any email if staff."""
    requested_email = (request.query_params.get('email') or '').strip()

    if request.user.is_staff:
        if not requested_email:
            return api_error(
                message='Email parameter is required',
                error_code='bad_request',
                status_code=status.HTTP_400_BAD_REQUEST,
            )
        target_email = requested_email
    else:
        target_email = get_user_email(request.user)
        if requested_email and requested_email.lower() != target_email.lower():
            return api_error(
                message='You can only access your own profile',
                error_code='forbidden',
                status_code=status.HTTP_403_FORBIDDEN,
            )

    if not target_email:
        return api_error(
            message='No email associated with this account',
            error_code='bad_request',
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    user = _lookup_user_by_email(target_email)
    if not user:
        return api_error(
            message='User not found',
            error_code='not_found',
            status_code=status.HTTP_404_NOT_FOUND,
        )

    serializer = UserSerializer(user, context={'request': request})
    return api_success(data=serializer.data, message='OK', status_code=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def upload_profile_image(request):
    """Upload profile picture for the authenticated user only."""
    email = (
        request.data.get('email')
        or request.query_params.get('email')
        or get_user_email(request.user)
        or ''
    ).strip()

    if not email:
        return api_error(
            message='Email parameter is required',
            error_code='bad_request',
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    if not _can_access_user_profile(request, email):
        return api_error(
            message='You can only upload profile images to your own account',
            error_code='forbidden',
            status_code=status.HTTP_403_FORBIDDEN,
        )

    image = request.FILES.get('profile_picture')
    if not image:
        return api_error(
            message='profile_picture file is required',
            error_code='bad_request',
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
    if image.content_type not in allowed_types:
        return api_error(
            message='Invalid file type. Allowed types: JPEG, PNG, GIF, WebP',
            error_code='invalid_file_type',
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    allowed_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
    ext = os.path.splitext(image.name.lower())[1]
    if ext not in allowed_extensions:
        return api_error(
            message=f'Invalid file extension. Allowed: {", ".join(allowed_extensions)}',
            error_code='invalid_file_extension',
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    max_size = 5 * 1024 * 1024
    if image.size > max_size:
        return api_error(
            message='File too large. Maximum size: 5MB',
            error_code='file_too_large',
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    user = request.user if get_user_email(request.user).lower() == email.lower() else _lookup_user_by_email(email)
    if not user:
        return api_error(
            message='User not found',
            error_code='not_found',
            status_code=status.HTTP_404_NOT_FOUND,
        )

    profile, _ = UserProfile.objects.get_or_create(user=user, defaults={'email': user.email or email})
    profile.profile_picture = image
    profile.save()

    serializer = UserSerializer(user, context={'request': request})
    return api_success(
        data=serializer.data,
        message='Profile image updated',
        status_code=status.HTTP_200_OK,
    )
