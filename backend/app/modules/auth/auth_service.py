from dataclasses import dataclass
from datetime import datetime
from typing import NoReturn

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.clock import seconds_until, utc_now
from app.common.config import Settings
from app.common.errors import (
    ConflictError,
    ErrorCode,
    LockedError,
    UnauthenticatedError,
)
from app.common.security.passwords import hash_password, needs_rehash, verify_password
from app.common.sms import SmsSender
from app.modules.auth.models import LoginThrottle, VerificationPurpose
from app.modules.auth.repository import LoginThrottleRepository
from app.modules.auth.schemas import LoginRequest, PasswordResetRequest, RegisterRequest
from app.modules.auth.session_service import SessionService, TokenPair
from app.modules.auth.verification_service import PhoneVerificationService
from app.modules.users.models import User
from app.modules.users.repository import UserRepository


@dataclass(frozen=True, slots=True)
class AuthenticatedUser:
    user: User
    tokens: TokenPair


class AuthService:
    def __init__(self, session: AsyncSession, settings: Settings, sms_sender: SmsSender) -> None:
        self.session = session
        self.settings = settings
        self.users = UserRepository(session)
        self.throttles = LoginThrottleRepository(session)
        self.verifications = PhoneVerificationService(session, settings, sms_sender)
        self.sessions = SessionService(session, settings)

    async def register(self, request: RegisterRequest) -> AuthenticatedUser:
        phone = await self.verifications.consume_token(
            request.verification_token, VerificationPurpose.REGISTRATION
        )
        if await self.users.phone_exists(phone):
            raise ConflictError(ErrorCode.PHONE_ALREADY_REGISTERED, "Phone is already registered.")
        try:
            user = await self.users.add(
                phone=phone,
                name=request.name,
                avatar=request.avatar,
                password_hash=hash_password(request.password),
            )
        except IntegrityError as error:
            raise ConflictError(
                ErrorCode.PHONE_ALREADY_REGISTERED, "Phone is already registered."
            ) from error
        tokens = await self.sessions.start(user.id)
        await self.session.commit()
        return AuthenticatedUser(user, tokens)

    async def login(self, request: LoginRequest) -> AuthenticatedUser:
        throttle = await self.throttles.get_for_update(request.phone)
        self._ensure_not_locked(throttle)

        user = await self.users.get_by_phone(request.phone)
        password_hash = user.password_hash if user else None
        if user is None or not verify_password(request.password, password_hash):
            await self._register_failure(throttle)

        throttle.failed_attempts = 0
        throttle.locked_until = None
        if needs_rehash(user.password_hash):
            user.password_hash = hash_password(request.password)
        tokens = await self.sessions.start(user.id)
        await self.session.commit()
        return AuthenticatedUser(user, tokens)

    async def reset_password(self, request: PasswordResetRequest) -> AuthenticatedUser:
        phone = await self.verifications.consume_token(
            request.verification_token, VerificationPurpose.PASSWORD_RESET
        )
        user = await self.users.get_by_phone(phone)
        if user is None:
            raise UnauthenticatedError(
                ErrorCode.INVALID_VERIFICATION_TOKEN, "Verification token is not valid."
            )
        user.password_hash = hash_password(request.new_password)
        await self.sessions.revoke_all(user.id)
        await self.throttles.reset(phone)
        tokens = await self.sessions.start(user.id)
        await self.session.commit()
        return AuthenticatedUser(user, tokens)

    def _ensure_not_locked(self, throttle: LoginThrottle) -> None:
        if throttle.locked_until is not None and throttle.locked_until > utc_now():
            self._raise_locked(throttle.locked_until)

    def _raise_locked(self, locked_until: datetime) -> NoReturn:
        retry_after = max(1, seconds_until(locked_until))
        raise LockedError(
            ErrorCode.ACCOUNT_LOCKED,
            "Too many failed attempts.",
            details={"retry_after_seconds": retry_after},
            headers={"Retry-After": str(retry_after)},
        )

    async def _register_failure(self, throttle: LoginThrottle) -> NoReturn:
        max_attempts = self.settings.login_max_failed_attempts
        throttle.failed_attempts += 1
        if throttle.failed_attempts >= max_attempts:
            locked_until = utc_now() + self.settings.login_lockout
            throttle.failed_attempts = 0
            throttle.locked_until = locked_until
            await self.session.commit()
            self._raise_locked(locked_until)
        await self.session.commit()
        raise UnauthenticatedError(
            ErrorCode.INVALID_CREDENTIALS,
            "Phone number or password is incorrect.",
            details={"remaining_attempts": max_attempts - throttle.failed_attempts},
        )
