import base64
import binascii
import json
from typing import Annotated, Any

from fastapi import Query

from app.common.errors import ValidationFailedError

CursorQuery = Annotated[str | None, Query(max_length=512)]
LimitQuery = Annotated[int, Query(ge=1, le=100)]


def encode_cursor(position: dict[str, Any]) -> str:
    raw = json.dumps(position, separators=(",", ":"), default=str).encode()
    return base64.urlsafe_b64encode(raw).decode().rstrip("=")


def decode_cursor(cursor: str) -> dict[str, Any]:
    padded = cursor + "=" * (-len(cursor) % 4)
    try:
        decoded = json.loads(base64.urlsafe_b64decode(padded.encode()))
    except (binascii.Error, ValueError, UnicodeDecodeError) as error:
        raise ValidationFailedError.single(
            "query.cursor", "invalid_format", "Invalid cursor."
        ) from error
    if not isinstance(decoded, dict):
        raise ValidationFailedError.single("query.cursor", "invalid_format", "Invalid cursor.")
    return decoded
