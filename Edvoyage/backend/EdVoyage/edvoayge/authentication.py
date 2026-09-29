"""DRF authentication helpers."""

from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError


class OptionalJWTAuthentication(JWTAuthentication):
    """Validate JWT when present, but treat invalid/expired tokens as anonymous.

    Default JWTAuthentication returns 401 when a Bearer token is present but
    invalid. That breaks public endpoints (AllowAny) for clients that still
    send a stale token from SharedPreferences — common on mobile apps.
    """

    def authenticate(self, request):
        header = self.get_header(request)
        if header is None:
            return None

        raw_token = self.get_raw_token(header)
        if raw_token is None:
            return None

        try:
            validated_token = self.get_validated_token(raw_token)
        except (InvalidToken, TokenError):
            return None

        return self.get_user(validated_token), validated_token
