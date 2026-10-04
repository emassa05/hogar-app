import uuid
from dataclasses import dataclass

from sqlalchemy.ext.asyncio import AsyncSession

from app.common.clock import utc_now
from app.common.config import Settings
from app.common.errors import ErrorCode, UnauthenticatedError
from app.common.security.tokens import hash_opaque_token, issue_access_token, new_opaque_token
from app.modules.auth.models import AuthSession, RefreshToken
from app.modules.auth.repository import SessionRepository


@dataclass(frozen=True, slots=True)
class TokenPair:
    access_token: str
    refresh_token: str
    expires_in: int


def invalid_refresh_token() -> UnauthenticatedError:
    return UnauthenticatedError(ErrorCode.INVALID_REFRESH_TOKEN, "Refresh token is not valid.")


class SessionService:
    def __init__(self, session: AsyncSession, settings: Settings) -> None:
        self.session = session
        self.settings = settings
        self.sessions = SessionRepository(session)

    async def start(self, user_id: uuid.UUID) -> TokenPair:
        now = utc_now()
        auth_session = await self.sessions.add_session(
            AuthSession(
                id=uuid.uuid4(),
                user_id=user_id,
                created_at=now,
                expires_at=now + self.settings.refresh_token_ttl,
            )
        )
        return await self._issue(auth_session)

    async def refresh(self, refresh_token: str) -> TokenPair:
        now = utc_now()
        stored = await self.sessions.get_refresh_token_for_update(hash_opaque_token(refresh_token))
        if stored is None:
            raise invalid_refresh_token()
        auth_session = await self.sessions.get_session_for_update(stored.session_id)
        if auth_session is None or auth_session.revoked_at is not None:
            raise invalid_refresh_token()
        if stored.rotated_at is not None:
            await self.sessions.revoke_session(auth_session.id, now)
            await self.session.commit()
            raise invalid_refresh_token()
        if stored.expires_at <= now or auth_session.expires_at <= now:
            raise invalid_refresh_token()

        stored.rotated_at = now
        auth_session.expires_at = now + self.settings.refresh_token_ttl
        tokens = await self._issue(auth_session)
        await self.session.commit()
        return tokens

    async def logout(self, refresh_token: str) -> None:
        stored = await self.sessions.get_refresh_token_for_update(hash_opaque_token(refresh_token))
        if stored is None:
            return
        auth_session = await self.sessions.get_session_for_update(stored.session_id)
        if auth_session is not None:
            await self.sessions.revoke_session(auth_session.id, utc_now())
            await self.session.commit()

    async def revoke_all(self, user_id: uuid.UUID) -> None:
        await self.sessions.revoke_all_for_user(user_id, utc_now())

    async def _issue(self, auth_session: AuthSession) -> TokenPair:
        now = utc_now()
        refresh_token = new_opaque_token()
        await self.sessions.add_refresh_token(
            RefreshToken(
                id=uuid.uuid4(),
                session_id=auth_session.id,
                token_hash=hash_opaque_token(refresh_token),
                created_at=now,
                expires_at=auth_session.expires_at,
            )
        )
        access = issue_access_token(auth_session.user_id, auth_session.id, self.settings)
        return TokenPair(
            access_token=access.value,
            refresh_token=refresh_token,
            expires_in=int(self.settings.access_token_ttl.total_seconds()),
        )
