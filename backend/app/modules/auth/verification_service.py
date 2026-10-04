import uuid
from datetime import timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.common.clock import seconds_until, utc_now
from app.common.config import Settings
from app.common.errors import (
    BadRequestError,
    ConflictError,
    ErrorCode,
    GoneError,
    NotFoundError,
    TooManyRequestsError,
    UnauthenticatedError,
)
from app.common.security.tokens import (
    InvalidTokenError,
    IssuedToken,
    TokenType,
    codes_match,
    decode_token,
    hash_code,
    issue_verification_token,
    new_numeric_code,
)
from app.common.sms import SmsSender
from app.modules.auth.models import PhoneVerification, VerificationPurpose
from app.modules.auth.repository import VerificationRepository
from app.modules.users.repository import UserRepository

SMS_HOURLY_LIMIT_PER_PHONE = 5
SMS_LIMIT_WINDOW = timedelta(hours=1)


def sms_body(code: str) -> str:
    return f"Tu código de equilibrio es {code[:3]} {code[3:]}. No lo compartas con nadie."


class PhoneVerificationService:
    def __init__(self, session: AsyncSession, settings: Settings, sms_sender: SmsSender) -> None:
        self.session = session
        self.settings = settings
        self.sms_sender = sms_sender
        self.verifications = VerificationRepository(session)
        self.users = UserRepository(session)

    async def request(self, phone: str, purpose: VerificationPurpose) -> PhoneVerification:
        phone_registered = await self.users.phone_exists(phone)
        if purpose is VerificationPurpose.REGISTRATION and phone_registered:
            raise ConflictError(ErrorCode.PHONE_ALREADY_REGISTERED, "Phone is already registered.")
        is_deliverable = purpose is VerificationPurpose.REGISTRATION or phone_registered
        if is_deliverable:
            await self._ensure_hourly_quota(phone)

        now = utc_now()
        code = new_numeric_code()
        verification = PhoneVerification(
            id=uuid.uuid4(),
            phone=phone,
            purpose=purpose,
            code_hash="",
            failed_attempts=0,
            is_deliverable=is_deliverable,
            expires_at=now + self.settings.verification_code_ttl,
            resend_available_at=now + self.settings.verification_resend_cooldown,
            created_at=now,
        )
        verification.code_hash = hash_code(code, str(verification.id), self.settings)
        await self.verifications.add(verification)
        await self._deliver(verification, code)
        await self.session.commit()
        return verification

    async def resend(self, verification_id: uuid.UUID) -> PhoneVerification:
        verification = await self._get_pending(verification_id)
        now = utc_now()
        if now < verification.resend_available_at:
            raise TooManyRequestsError(
                ErrorCode.VERIFICATION_RESEND_TOO_SOON,
                "Wait before requesting another code.",
                retry_after_seconds=max(1, seconds_until(verification.resend_available_at)),
            )
        if verification.is_deliverable:
            await self._ensure_hourly_quota(verification.phone)

        code = new_numeric_code()
        verification.code_hash = hash_code(code, str(verification.id), self.settings)
        verification.failed_attempts = 0
        verification.expires_at = now + self.settings.verification_code_ttl
        verification.resend_available_at = now + self.settings.verification_resend_cooldown
        await self._deliver(verification, code)
        await self.session.commit()
        return verification

    async def confirm(self, verification_id: uuid.UUID, code: str) -> IssuedToken:
        verification = await self._get_pending(verification_id)
        max_attempts = self.settings.verification_max_attempts
        if verification.failed_attempts >= max_attempts:
            raise TooManyRequestsError(
                ErrorCode.VERIFICATION_ATTEMPTS_EXCEEDED, "No attempts left for this code."
            )
        valid = verification.is_deliverable and codes_match(
            code, str(verification.id), verification.code_hash, self.settings
        )
        if not valid:
            verification.failed_attempts += 1
            await self.session.commit()
            raise BadRequestError(
                ErrorCode.VERIFICATION_CODE_INVALID,
                "Verification code is incorrect.",
                details={"remaining_attempts": max_attempts - verification.failed_attempts},
            )

        verification.verified_at = utc_now()
        token = issue_verification_token(
            verification.id, verification.phone, verification.purpose.value, self.settings
        )
        await self.session.commit()
        return token

    async def consume_token(self, token: str, purpose: VerificationPurpose) -> str:
        invalid = UnauthenticatedError(
            ErrorCode.INVALID_VERIFICATION_TOKEN, "Verification token is not valid."
        )
        try:
            claims = decode_token(token, TokenType.VERIFICATION, self.settings)
            verification_id = uuid.UUID(str(claims["jti"]))
        except (InvalidTokenError, ValueError) as error:
            raise invalid from error
        if claims.get("purpose") != purpose.value:
            raise invalid

        verification = await self.verifications.get_for_update(verification_id)
        if (
            verification is None
            or verification.purpose is not purpose
            or verification.verified_at is None
            or verification.consumed_at is not None
            or verification.phone != claims["sub"]
        ):
            raise invalid
        verification.consumed_at = utc_now()
        return verification.phone

    async def _get_pending(self, verification_id: uuid.UUID) -> PhoneVerification:
        verification = await self.verifications.get_for_update(verification_id)
        if verification is None:
            raise NotFoundError(ErrorCode.VERIFICATION_NOT_FOUND, "Verification not found.")
        if verification.verified_at is not None or utc_now() >= verification.expires_at:
            raise GoneError(ErrorCode.VERIFICATION_EXPIRED, "Verification has expired.")
        return verification

    async def _ensure_hourly_quota(self, phone: str) -> None:
        now = utc_now()
        sent, oldest = await self.verifications.dispatches_since(phone, now - SMS_LIMIT_WINDOW)
        if sent >= SMS_HOURLY_LIMIT_PER_PHONE and oldest is not None:
            raise TooManyRequestsError(
                retry_after_seconds=max(1, seconds_until(oldest + SMS_LIMIT_WINDOW))
            )

    async def _deliver(self, verification: PhoneVerification, code: str) -> None:
        if not verification.is_deliverable:
            return
        await self.verifications.record_dispatch(verification.phone, utc_now())
        await self.sms_sender.send(verification.phone, sms_body(code))
