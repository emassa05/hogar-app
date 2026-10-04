import json
import logging
import re
import sys
from datetime import UTC, datetime
from typing import Any

from app.common.request_context import current_request_id

_SENSITIVE_KEYS = re.compile(
    r"(password|token|secret|authorization|code|otp|cookie|phone)", re.IGNORECASE
)
_BEARER = re.compile(r"Bearer\s+[A-Za-z0-9._~+/=-]+", re.IGNORECASE)
_JWT = re.compile(r"eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+")
_PHONE = re.compile(r"\+\d{8,15}")
_REDACTED = "[REDACTED]"
_RESERVED_ATTRIBUTES = frozenset(vars(logging.makeLogRecord({})).keys()) | {"message", "asctime"}


def redact_text(text: str) -> str:
    text = _BEARER.sub(f"Bearer {_REDACTED}", text)
    text = _JWT.sub(_REDACTED, text)
    return _PHONE.sub(_REDACTED, text)


def redact_value(key: str, value: Any) -> Any:
    if _SENSITIVE_KEYS.search(key):
        return _REDACTED
    if isinstance(value, dict):
        return {inner_key: redact_value(inner_key, inner) for inner_key, inner in value.items()}
    if isinstance(value, str):
        return redact_text(value)
    return value


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "timestamp": datetime.fromtimestamp(record.created, UTC).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": redact_text(record.getMessage()),
            "request_id": current_request_id() or None,
        }
        extras = {
            key: redact_value(key, value)
            for key, value in vars(record).items()
            if key not in _RESERVED_ATTRIBUTES
        }
        payload.update(extras)
        if record.exc_info:
            payload["exception"] = redact_text(self.formatException(record.exc_info))
        return json.dumps(payload, default=str, ensure_ascii=False)


def configure_logging(level: str) -> None:
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())
    root = logging.getLogger()
    root.handlers.clear()
    root.addHandler(handler)
    root.setLevel(level.upper())
    for noisy in ("uvicorn.access",):
        logging.getLogger(noisy).handlers.clear()
        logging.getLogger(noisy).propagate = True
