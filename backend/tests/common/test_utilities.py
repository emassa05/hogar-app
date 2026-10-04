import logging
import uuid

import pytest
from fastapi import FastAPI
from pydantic import BaseModel

from app.common.database import get_database
from app.common.errors import ConflictError, ErrorCode, ValidationFailedError
from app.common.idempotency import run_idempotent
from app.common.logging import JsonFormatter, redact_text
from app.common.pagination import decode_cursor, encode_cursor


class Counter(BaseModel):
    value: int


def test_cursor_roundtrip() -> None:
    position = {"due_date": "2026-10-04", "id": "abc"}

    assert decode_cursor(encode_cursor(position)) == position


def test_invalid_cursor_raises_validation_error() -> None:
    with pytest.raises(ValidationFailedError):
        decode_cursor("not-base64-json!")


def test_redaction_hides_tokens_and_phones() -> None:
    text = "Bearer abc.def.ghi sent to +56987654321 eyJa.eyJb.sig"

    redacted = redact_text(text)

    assert "+56987654321" not in redacted
    assert "abc.def.ghi" not in redacted
    assert "eyJa.eyJb.sig" not in redacted


def test_json_formatter_redacts_sensitive_extras() -> None:
    record = logging.makeLogRecord(
        {"msg": "login", "levelname": "INFO", "password": "Secret1", "user_id": "u-1"}
    )

    output = JsonFormatter().format(record)

    assert "Secret1" not in output
    assert "u-1" in output


@pytest.mark.usefixtures("app")
async def test_idempotent_operation_runs_once() -> None:
    calls = 0

    async def operation() -> Counter:
        nonlocal calls
        calls += 1
        return Counter(value=calls)

    user_id, key = uuid.uuid4(), uuid.uuid4()
    async with get_database().session_factory() as session:
        first = await run_idempotent(
            session,
            user_id=user_id,
            scope="test",
            key=key,
            request_payload={"a": 1},
            response_model=Counter,
            operation=operation,
        )
        await session.commit()
        second = await run_idempotent(
            session,
            user_id=user_id,
            scope="test",
            key=key,
            request_payload={"a": 1},
            response_model=Counter,
            operation=operation,
        )

    assert first == second == Counter(value=1)
    assert calls == 1


async def test_idempotency_key_reuse_with_different_payload_conflicts(app: FastAPI) -> None:
    async def operation() -> Counter:
        return Counter(value=1)

    user_id, key = uuid.uuid4(), uuid.uuid4()
    async with get_database().session_factory() as session:
        await run_idempotent(
            session,
            user_id=user_id,
            scope="test",
            key=key,
            request_payload={"a": 1},
            response_model=Counter,
            operation=operation,
        )
        await session.commit()
        with pytest.raises(ConflictError) as error:
            await run_idempotent(
                session,
                user_id=user_id,
                scope="test",
                key=key,
                request_payload={"a": 2},
                response_model=Counter,
                operation=operation,
            )

    assert error.value.code is ErrorCode.IDEMPOTENCY_KEY_REUSED
