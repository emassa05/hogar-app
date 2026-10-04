import uuid
from datetime import datetime
from enum import StrEnum

from sqlalchemy import Enum, ForeignKey, Index, String
from sqlalchemy.orm import Mapped, mapped_column

from app.common.database import Base, UuidPrimaryKeyMixin


class VerificationPurpose(StrEnum):
    REGISTRATION = "registration"
    PASSWORD_RESET = "password_reset"


class PhoneVerification(UuidPrimaryKeyMixin, Base):
    __tablename__ = "phone_verifications"

    phone: Mapped[str] = mapped_column(String(20), index=True)
    purpose: Mapped[VerificationPurpose] = mapped_column(
        Enum(
            VerificationPurpose,
            name="verification_purpose",
            values_callable=lambda members: [m.value for m in members],
        )
    )
    code_hash: Mapped[str] = mapped_column(String(64))
    failed_attempts: Mapped[int] = mapped_column(default=0)
    is_deliverable: Mapped[bool]
    expires_at: Mapped[datetime]
    resend_available_at: Mapped[datetime]
    verified_at: Mapped[datetime | None]
    consumed_at: Mapped[datetime | None]
    created_at: Mapped[datetime]


class SmsDispatch(UuidPrimaryKeyMixin, Base):
    __tablename__ = "sms_dispatches"
    __table_args__ = (Index("ix_sms_dispatches_phone_sent_at", "phone", "sent_at"),)

    phone: Mapped[str] = mapped_column(String(20))
    sent_at: Mapped[datetime]


class LoginThrottle(Base):
    __tablename__ = "login_throttles"

    phone: Mapped[str] = mapped_column(String(20), primary_key=True)
    failed_attempts: Mapped[int] = mapped_column(default=0)
    locked_until: Mapped[datetime | None]


class AuthSession(UuidPrimaryKeyMixin, Base):
    __tablename__ = "auth_sessions"

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    created_at: Mapped[datetime]
    expires_at: Mapped[datetime]
    revoked_at: Mapped[datetime | None]


class RefreshToken(UuidPrimaryKeyMixin, Base):
    __tablename__ = "refresh_tokens"

    session_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("auth_sessions.id", ondelete="CASCADE"), index=True
    )
    token_hash: Mapped[str] = mapped_column(String(64), unique=True)
    created_at: Mapped[datetime]
    expires_at: Mapped[datetime]
    rotated_at: Mapped[datetime | None]
