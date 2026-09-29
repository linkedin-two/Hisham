from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Optional

from rest_framework.response import Response


@dataclass
class ApiError:
    code: str
    details: Any = None


def api_success(*, data: Any = None, message: str = "OK", meta: Optional[Dict[str, Any]] = None, status_code: int = 200) -> Response:
    return Response(
        {
            "success": True,
            "message": message,
            "data": data,
            "errors": None,
            "meta": meta or {},
        },
        status=status_code,
    )


def api_error(*, message: str = "Error", error_code: str = "error", details: Any = None, meta: Optional[Dict[str, Any]] = None, status_code: int = 400) -> Response:
    return Response(
        {
            "success": False,
            "message": message,
            "data": None,
            "errors": {"code": error_code, "details": details},
            "meta": meta or {},
        },
        status=status_code,
    )
