import uuid
from datetime import datetime

from sqlalchemy import func, select, update
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.auth.models import (
    AuthSession,
    LoginThrottle,
    PhoneVerification,
    RefreshToken,
    SmsDispatch,
)


class VerificationRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def add(self, verification: PhoneVerification) -> PhoneVerification:
        self.session.add(verification)
        await self.session.flush()
        return verification

    async def get_for_update(self, verification_id: uuid.UUID) -> PhoneVerification | None:
        return await self.session.scalar(
            select(PhoneVerification)
            .where(PhoneVerification.id == verification_id)
            .with_for_update()
        )

    async def record_dispatch(self, phone: str, sent_at: datetime) -> None:
        self.session.add(SmsDispatch(phone=phone, sent_at=sent_at))
        await self.session.flush()

    async def dispatches_since(self, phone: str, since: datetime) -> tuple[int, datetime | None]:
        count, oldest = (
            await self.session.execute(
                select(func.count(SmsDispatch.id), func.min(SmsDispatch.sent_at)).where(
                    SmsDispatch.phone == phone, SmsDispatch.sent_at > since
                )
            )
        ).one()
        return int(count), oldest


class LoginThrottleRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_for_update(self, phone: str) -> LoginThrottle:
        await self.session.execute(
            insert(LoginThrottle)
            .values(phone=phone, failed_attempts=0, locked_until=None)
            .on_conflict_do_nothing()
        )
        throttle = await self.session.scalar(
            select(LoginThrottle).where(LoginThrottle.phone == phone).with_for_update()
        )
        if throttle is None:
            raise RuntimeError("Login throttle row could not be locked")
        return throttle

    async def reset(self, phone: str) -> None:
        await self.session.execute(
            update(LoginThrottle)
            .where(LoginThrottle.phone == phone)
            .values(failed_attempts=0, locked_until=None)
        )


class SessionRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def add_session(self, auth_session: AuthSession) -> AuthSession:
        self.session.add(auth_session)
        await self.session.flush()
        return auth_session

    async def add_refresh_token(self, refresh_token: RefreshToken) -> None:
        self.session.add(refresh_token)
        await self.session.flush()

    async def get_active_session(self, session_id: uuid.UUID, now: datetime) -> AuthSession | None:
        return await self.session.scalar(
            select(AuthSession).where(
                AuthSession.id == session_id,
                AuthSession.revoked_at.is_(None),
                AuthSession.expires_at > now,
            )
        )

    async def get_refresh_token_for_update(self, token_hash: str) -> RefreshToken | None:
        return await self.session.scalar(
            select(RefreshToken).where(RefreshToken.token_hash == token_hash).with_for_update()
        )

    async def get_session_for_update(self, session_id: uuid.UUID) -> AuthSession | None:
        return await self.session.scalar(
            select(AuthSession).where(AuthSession.id == session_id).with_for_update()
        )

    async def revoke_session(self, session_id: uuid.UUID, now: datetime) -> None:
        await self.session.execute(
            update(AuthSession)
            .where(AuthSession.id == session_id, AuthSession.revoked_at.is_(None))
            .values(revoked_at=now)
        )

    async def revoke_all_for_user(self, user_id: uuid.UUID, now: datetime) -> None:
        await self.session.execute(
            update(AuthSession)
            .where(AuthSession.user_id == user_id, AuthSession.revoked_at.is_(None))
            .values(revoked_at=now)
        )
