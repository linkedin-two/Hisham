from __future__ import annotations

from typing import Any, Dict, Optional

from django.http import Http404
from rest_framework import exceptions, status
from rest_framework.response import Response
from rest_framework.views import exception_handler


def _envelope(*, status_code: int, message: str, error_code: str, details: Any = None) -> Response:
    return Response(
        {
            "success": False,
            "message": message,
            "data": None,
            "errors": {"code": error_code, "details": details},
            "meta": {},
        },
        status=status_code,
    )


def standardized_exception_handler(exc: Exception, context: Dict[str, Any]) -> Optional[Response]:
    """Standardize error responses into a consistent JSON envelope.

    This is intentionally conservative:
    - It only standardizes *errors* (non-2xx)
    - It keeps existing success response shapes intact to avoid breaking clients
    """

    response = exception_handler(exc, context)

    if response is None:
        # Non-DRF exceptions
        if isinstance(exc, Http404):
            return _envelope(
                status_code=status.HTTP_404_NOT_FOUND,
                message="Not found",
                error_code="not_found",
                details=str(exc) or None,
            )

        return _envelope(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            message="Internal server error",
            error_code="server_error",
            details=str(exc) or None,
        )

    status_code = int(response.status_code)

    # DRF exceptions commonly have `.detail`
    details: Any
    if isinstance(exc, exceptions.APIException):
        details = getattr(exc, "detail", response.data)
    else:
        details = response.data

    if status_code == status.HTTP_400_BAD_REQUEST:
        return _envelope(status_code=status_code, message="Bad request", error_code="bad_request", details=details)
    if status_code == status.HTTP_401_UNAUTHORIZED:
        return _envelope(status_code=status_code, message="Unauthorized", error_code="unauthorized", details=details)
    if status_code == status.HTTP_403_FORBIDDEN:
        return _envelope(status_code=status_code, message="Forbidden", error_code="forbidden", details=details)
    if status_code == status.HTTP_404_NOT_FOUND:
        return _envelope(status_code=status_code, message="Not found", error_code="not_found", details=details)
    if status_code == status.HTTP_405_METHOD_NOT_ALLOWED:
        return _envelope(status_code=status_code, message="Method not allowed", error_code="method_not_allowed", details=details)
    if status_code == status.HTTP_429_TOO_MANY_REQUESTS:
        return _envelope(status_code=status_code, message="Too many requests", error_code="rate_limited", details=details)

    # Default for any other non-2xx
    if status_code >= 400:
        return _envelope(status_code=status_code, message="Request failed", error_code="request_failed", details=details)

    return response
