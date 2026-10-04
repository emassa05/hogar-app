from collections.abc import Mapping
from enum import StrEnum
from http import HTTPStatus
from typing import Any, ClassVar


class ErrorCode(StrEnum):
    VALIDATION_ERROR = "VALIDATION_ERROR"
    UNAUTHENTICATED = "UNAUTHENTICATED"
    INVALID_CREDENTIALS = "INVALID_CREDENTIALS"
    ACCOUNT_LOCKED = "ACCOUNT_LOCKED"
    INVALID_REFRESH_TOKEN = "INVALID_REFRESH_TOKEN"
    INVALID_VERIFICATION_TOKEN = "INVALID_VERIFICATION_TOKEN"
    PHONE_ALREADY_REGISTERED = "PHONE_ALREADY_REGISTERED"
    VERIFICATION_NOT_FOUND = "VERIFICATION_NOT_FOUND"
    VERIFICATION_EXPIRED = "VERIFICATION_EXPIRED"
    VERIFICATION_CODE_INVALID = "VERIFICATION_CODE_INVALID"
    VERIFICATION_ATTEMPTS_EXCEEDED = "VERIFICATION_ATTEMPTS_EXCEEDED"
    VERIFICATION_RESEND_TOO_SOON = "VERIFICATION_RESEND_TOO_SOON"
    SMS_DELIVERY_FAILED = "SMS_DELIVERY_FAILED"
    RATE_LIMITED = "RATE_LIMITED"
    FORBIDDEN = "FORBIDDEN"
    ADMIN_REQUIRED = "ADMIN_REQUIRED"
    NOT_FOUND = "NOT_FOUND"
    HOUSEHOLD_NOT_FOUND = "HOUSEHOLD_NOT_FOUND"
    MEMBER_NOT_FOUND = "MEMBER_NOT_FOUND"
    INVITATION_NOT_FOUND = "INVITATION_NOT_FOUND"
    INVITATION_EXPIRED = "INVITATION_EXPIRED"
    ALREADY_MEMBER = "ALREADY_MEMBER"
    LAST_ADMIN_MUST_TRANSFER = "LAST_ADMIN_MUST_TRANSFER"
    TEMPLATES_ALREADY_APPLIED = "TEMPLATES_ALREADY_APPLIED"
    TASK_NOT_FOUND = "TASK_NOT_FOUND"
    TASK_COMPLETED_LOCKED = "TASK_COMPLETED_LOCKED"
    PARTICIPATION_NOT_AVAILABLE = "PARTICIPATION_NOT_AVAILABLE"
    PARTICIPATION_NOT_OWNED = "PARTICIPATION_NOT_OWNED"
    ASSIGNEE_RESTRICTED = "ASSIGNEE_RESTRICTED"
    ROUTINE_NOT_FOUND = "ROUTINE_NOT_FOUND"
    UNPLANNED_TASK_OUT_OF_RANGE = "UNPLANNED_TASK_OUT_OF_RANGE"
    SIMILAR_TASKS_FOUND = "SIMILAR_TASKS_FOUND"
    SWAP_REQUEST_NOT_FOUND = "SWAP_REQUEST_NOT_FOUND"
    SWAP_REQUEST_NOT_PENDING = "SWAP_REQUEST_NOT_PENDING"
    COMMENT_NOT_FOUND = "COMMENT_NOT_FOUND"
    ATTACHMENT_TOO_LARGE = "ATTACHMENT_TOO_LARGE"
    UNSUPPORTED_MEDIA_TYPE = "UNSUPPORTED_MEDIA_TYPE"
    SUGGESTION_NOT_FOUND = "SUGGESTION_NOT_FOUND"
    SUGGESTION_NOT_PENDING = "SUGGESTION_NOT_PENDING"
    CAPACITY_SUM_INVALID = "CAPACITY_SUM_INVALID"
    CAPACITY_NOT_CONFIGURED = "CAPACITY_NOT_CONFIGURED"
    VERSION_CONFLICT = "VERSION_CONFLICT"
    IDEMPOTENCY_KEY_REUSED = "IDEMPOTENCY_KEY_REUSED"
    CONFLICT = "CONFLICT"
    SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE"
    INTERNAL_ERROR = "INTERNAL_ERROR"


class AppError(Exception):
    status: ClassVar[HTTPStatus] = HTTPStatus.INTERNAL_SERVER_ERROR
    default_code: ClassVar[ErrorCode] = ErrorCode.INTERNAL_ERROR
    default_message: ClassVar[str] = "Unexpected error."

    def __init__(
        self,
        code: ErrorCode | None = None,
        message: str | None = None,
        details: Mapping[str, Any] | None = None,
        headers: Mapping[str, str] | None = None,
    ) -> None:
        self.code = code or self.default_code
        self.message = message or self.default_message
        self.details = dict(details or {})
        self.headers = dict(headers or {})
        super().__init__(self.message)


class BadRequestError(AppError):
    status = HTTPStatus.BAD_REQUEST
    default_code = ErrorCode.VALIDATION_ERROR
    default_message = "Bad request."


class UnauthenticatedError(AppError):
    status = HTTPStatus.UNAUTHORIZED
    default_code = ErrorCode.UNAUTHENTICATED
    default_message = "Authentication required."


class ForbiddenError(AppError):
    status = HTTPStatus.FORBIDDEN
    default_code = ErrorCode.FORBIDDEN
    default_message = "Permission denied."


class NotFoundError(AppError):
    status = HTTPStatus.NOT_FOUND
    default_code = ErrorCode.NOT_FOUND
    default_message = "Resource not found."


class ConflictError(AppError):
    status = HTTPStatus.CONFLICT
    default_code = ErrorCode.CONFLICT
    default_message = "Resource state conflict."


class GoneError(AppError):
    status = HTTPStatus.GONE
    default_code = ErrorCode.NOT_FOUND
    default_message = "Resource is no longer available."


class PreconditionFailedError(AppError):
    status = HTTPStatus.PRECONDITION_FAILED
    default_code = ErrorCode.VERSION_CONFLICT
    default_message = "Resource version does not match."


class PayloadTooLargeError(AppError):
    status = HTTPStatus.REQUEST_ENTITY_TOO_LARGE
    default_code = ErrorCode.ATTACHMENT_TOO_LARGE
    default_message = "Payload too large."


class UnsupportedMediaTypeError(AppError):
    status = HTTPStatus.UNSUPPORTED_MEDIA_TYPE
    default_code = ErrorCode.UNSUPPORTED_MEDIA_TYPE
    default_message = "Unsupported media type."


class UnprocessableError(AppError):
    status = HTTPStatus.UNPROCESSABLE_ENTITY
    default_code = ErrorCode.VALIDATION_ERROR
    default_message = "Request validation failed."


class LockedError(AppError):
    status = HTTPStatus.LOCKED
    default_code = ErrorCode.ACCOUNT_LOCKED
    default_message = "Resource is locked."


class TooManyRequestsError(AppError):
    status = HTTPStatus.TOO_MANY_REQUESTS
    default_code = ErrorCode.RATE_LIMITED
    default_message = "Too many requests."

    def __init__(
        self,
        code: ErrorCode | None = None,
        message: str | None = None,
        retry_after_seconds: int | None = None,
        details: Mapping[str, Any] | None = None,
    ) -> None:
        merged_details = dict(details or {})
        headers: dict[str, str] = {}
        if retry_after_seconds is not None:
            merged_details["retry_after_seconds"] = retry_after_seconds
            headers["Retry-After"] = str(retry_after_seconds)
        super().__init__(code=code, message=message, details=merged_details, headers=headers)


class BadGatewayError(AppError):
    status = HTTPStatus.BAD_GATEWAY
    default_code = ErrorCode.SMS_DELIVERY_FAILED
    default_message = "Upstream provider failed."


class ServiceUnavailableError(AppError):
    status = HTTPStatus.SERVICE_UNAVAILABLE
    default_code = ErrorCode.SERVICE_UNAVAILABLE
    default_message = "Service unavailable."


class FieldError:
    __slots__ = ("code", "field", "message")

    def __init__(self, field: str, code: str, message: str) -> None:
        self.field = field
        self.code = code
        self.message = message

    def as_dict(self) -> dict[str, str]:
        return {"field": self.field, "code": self.code, "message": self.message}


class ValidationFailedError(UnprocessableError):
    def __init__(self, fields: list[FieldError], message: str | None = None) -> None:
        super().__init__(
            code=ErrorCode.VALIDATION_ERROR,
            message=message,
            details={"fields": [field.as_dict() for field in fields]},
        )

    @classmethod
    def single(cls, field: str, code: str, message: str) -> "ValidationFailedError":
        return cls([FieldError(field, code, message)])
