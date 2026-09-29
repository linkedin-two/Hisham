from rest_framework.throttling import ScopedRateThrottle


class AuthRateThrottle(ScopedRateThrottle):
    """Rate limit authentication-sensitive endpoints."""
    scope = 'auth'
