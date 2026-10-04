import hashlib
import json
import uuid
from collections.abc import Awaitable, Callable
from datetime import datetime, timedelta
from typing import Annotated, Any

from fastapi import Header
from pydantic import BaseModel
from sqlalchemy import JSON, String, UniqueConstraint, delete, select, text
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Mapped, mapped_column

from app.common.clock import utc_now
from app.common.database import Base, UuidPrimaryKeyMixin
from app.common.errors import ConflictError, ErrorCode

IDEMPOTENCY_TTL = timedelta(hours=24)

IdempotencyKeyHeader = Annotated[uuid.UUID, Header(alias="Idempotency-Key")]


class IdempotencyRecord(UuidPrimaryKeyMixin, Base):
    __tablename__ = "idempotency_records"
    __table_args__ = (UniqueConstraint("user_id", "scope", "key"),)

    user_id: Mapped[uuid.UUID]
    scope: Mapped[str] = mapped_column(String(100))
    key: Mapped[uuid.UUID]
    request_hash: Mapped[str] = mapped_column(String(64))
    response_body: Mapped[dict[str, Any]] = mapped_column(JSON)
    created_at: Mapped[datetime]


def fingerprint(payload: Any) -> str:
    serialized = json.dumps(payload, sort_keys=True, default=str, separators=(",", ":"))
    return hashlib.sha256(serialized.encode()).hexdigest()


async def run_idempotent[ResponseT: BaseModel](
    session: AsyncSession,
    *,
    user_id: uuid.UUID,
    scope: str,
    key: uuid.UUID,
    request_payload: Any,
    response_model: type[ResponseT],
    operation: Callable[[], Awaitable[ResponseT]],
) -> ResponseT:
    lock_id = int.from_bytes(
        hashlib.sha256(f"{user_id}:{scope}:{key}".encode()).digest()[:8], signed=True
    )
    await session.execute(text("SELECT pg_advisory_xact_lock(:lock_id)"), {"lock_id": lock_id})
    request_hash = fingerprint(request_payload)
    existing = await session.scalar(
        select(IdempotencyRecord).where(
            IdempotencyRecord.user_id == user_id,
            IdempotencyRecord.scope == scope,
            IdempotencyRecord.key == key,
            IdempotencyRecord.created_at > utc_now() - IDEMPOTENCY_TTL,
        )
    )
    if existing is not None:
        if existing.request_hash != request_hash:
            raise ConflictError(
                ErrorCode.IDEMPOTENCY_KEY_REUSED,
                "Idempotency key was already used with a different request.",
            )
        return response_model.model_validate(existing.response_body)

    response = await operation()
    await session.execute(
        insert(IdempotencyRecord)
        .values(
            id=uuid.uuid4(),
            user_id=user_id,
            scope=scope,
            key=key,
            request_hash=request_hash,
            response_body=response.model_dump(mode="json"),
            created_at=utc_now(),
        )
        .on_conflict_do_update(
            index_elements=["user_id", "scope", "key"],
            set_={
                "request_hash": request_hash,
                "response_body": response.model_dump(mode="json"),
                "created_at": utc_now(),
            },
        )
    )
    await session.commit()
    return response


async def purge_expired_idempotency_records(session: AsyncSession) -> None:
    await session.execute(
        delete(IdempotencyRecord).where(IdempotencyRecord.created_at <= utc_now() - IDEMPOTENCY_TTL)
    )
