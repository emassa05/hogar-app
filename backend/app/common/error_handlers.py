import logging
from collections.abc import Sequence
from http import HTTPStatus
from typing import Any

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.types import ASGIApp, Message, Receive, Scope, Send

from app.common.errors import AppError, ErrorCode, FieldError
from app.common.request_context import current_request_id

logger = logging.getLogger(__name__)

_PYDANTIC_TYPE_TO_FIELD_CODE = {
    "missing": "required",
    "string_too_short": "too_short",
    "too_short": "too_short",
    "string_too_long": "too_long",
    "too_long": "too_long",
    "greater_than": "out_of_range",
    "greater_than_equal": "out_of_range",
    "less_than": "out_of_range",
    "less_than_equal": "out_of_range",
    "string_pattern_mismatch": "invalid_format",
    "uuid_parsing": "invalid_format",
    "uuid_type": "invalid_format",
    "date_parsing": "invalid_format",
    "date_from_datetime_parsing": "invalid_format",
    "time_parsing": "invalid_format",
    "datetime_parsing": "invalid_format",
    "json_invalid": "invalid_format",
    "enum": "invalid_choice",
    "literal_error": "invalid_choice",
    "extra_forbidden": "unknown_field",
    "value_error": "invalid_value",
    "set_type": "invalid_type",
    "list_type": "invalid_type",
    "dict_type": "invalid_type",
    "model_type": "invalid_type",
    "model_attributes_type": "invalid_type",
    "int_type": "invalid_type",
    "int_parsing": "invalid_type",
    "int_from_float": "invalid_type",
    "float_type": "invalid_type",
    "float_parsing": "invalid_type",
    "bool_type": "invalid_type",
    "bool_parsing": "invalid_type",
    "string_type": "invalid_type",
}


def error_body(code: ErrorCode, message: str, details: dict[str, Any]) -> dict[str, Any]:
    return {
        "error": {
            "code": code.value,
            "message": message,
            "details": details,
            "request_id": current_request_id(),
        }
    }


def _json_error(
    status: HTTPStatus,
    code: ErrorCode,
    message: str,
    details: dict[str, Any] | None = None,
    headers: dict[str, str] | None = None,
) -> JSONResponse:
    return JSONResponse(
        status_code=status.value,
        content=error_body(code, message, details or {}),
        headers=headers,
    )


def _field_path(location: Sequence[int | str]) -> str:
    return ".".join(str(part) for part in location)


def _field_error(error: dict[str, Any]) -> FieldError:
    error_type = str(error.get("type", "invalid_value"))
    code = _PYDANTIC_TYPE_TO_FIELD_CODE.get(error_type, error_type)
    message = str(error.get("msg", "Invalid value."))
    return FieldError(_field_path(error.get("loc", ())), code, message)


async def handle_app_error(_: Request, exc: Exception) -> JSONResponse:
    if not isinstance(exc, AppError):
        raise exc
    if exc.status >= HTTPStatus.INTERNAL_SERVER_ERROR:
        logger.error("application error", extra={"error_code": exc.code.value})
    return _json_error(exc.status, exc.code, exc.message, exc.details, exc.headers)


async def handle_validation_error(_: Request, exc: Exception) -> JSONResponse:
    if not isinstance(exc, RequestValidationError):
        raise exc
    fields = [_field_error(dict(error)).as_dict() for error in exc.errors()]
    return _json_error(
        HTTPStatus.UNPROCESSABLE_ENTITY,
        ErrorCode.VALIDATION_ERROR,
        "Request validation failed.",
        {"fields": fields},
    )


async def handle_http_exception(_: Request, exc: Exception) -> JSONResponse:
    if not isinstance(exc, StarletteHTTPException):
        raise exc
    status = HTTPStatus(exc.status_code)
    code = {
        HTTPStatus.NOT_FOUND: ErrorCode.NOT_FOUND,
        HTTPStatus.UNAUTHORIZED: ErrorCode.UNAUTHENTICATED,
        HTTPStatus.FORBIDDEN: ErrorCode.FORBIDDEN,
        HTTPStatus.TOO_MANY_REQUESTS: ErrorCode.RATE_LIMITED,
        HTTPStatus.UNSUPPORTED_MEDIA_TYPE: ErrorCode.UNSUPPORTED_MEDIA_TYPE,
        HTTPStatus.REQUEST_ENTITY_TOO_LARGE: ErrorCode.ATTACHMENT_TOO_LARGE,
    }.get(status, ErrorCode.CONFLICT if status < 500 else ErrorCode.INTERNAL_ERROR)
    headers = dict(exc.headers) if exc.headers else None
    return _json_error(status, code, status.phrase, headers=headers)


class UnhandledErrorMiddleware:
    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        response_started = False

        async def tracking_send(message: Message) -> None:
            nonlocal response_started
            if message["type"] == "http.response.start":
                response_started = True
            await send(message)

        try:
            await self.app(scope, receive, tracking_send)
        except Exception:
            logger.exception("unhandled error")
            if response_started:
                raise
            response = _json_error(
                HTTPStatus.INTERNAL_SERVER_ERROR, ErrorCode.INTERNAL_ERROR, "Unexpected error."
            )
            await response(scope, receive, send)


def register_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(AppError, handle_app_error)
    app.add_exception_handler(RequestValidationError, handle_validation_error)
    app.add_exception_handler(StarletteHTTPException, handle_http_exception)
