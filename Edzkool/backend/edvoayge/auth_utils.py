"""Shared JWT authentication helpers for DRF and legacy function views."""

from django.contrib.auth import get_user_model
from rest_framework_simplejwt.authentication import JWTAuthentication


def authenticate_jwt_request(request):
    """Return the authenticated User from a JWT Bearer token, or None."""
    auth = JWTAuthentication()
    try:
        result = auth.authenticate(request)
        if result is not None:
            return result[0]
    except Exception:
        pass

    user = getattr(request, 'user', None)
    if user is not None and getattr(user, 'is_authenticated', False):
        return user
    return None


def require_authenticated_user(request):
    """Return authenticated User or None."""
    return authenticate_jwt_request(request)


def get_user_email(user):
    """Resolve the canonical email address for a Django user."""
    email = (getattr(user, 'email', None) or '').strip()
    if email:
        return email
    profile = getattr(user, 'profile', None)
    if profile is not None:
        return (getattr(profile, 'email', None) or '').strip()
    return ''


def get_or_create_django_user(email: str):
    """Get or create a Django auth user for the given email."""
    User = get_user_model()
    email = (email or '').strip()
    if not email:
        return None

    user = User.objects.filter(email__iexact=email).first()
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
    return user
