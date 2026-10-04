import uuid
from http import HTTPStatus

from fastapi import APIRouter, Depends

from app.common.database import SessionDependency
from app.common.dependencies import SettingsDependency, SmsSenderDependency
from app.common.rate_limit import rate_limit
from app.modules.auth.auth_service import AuthenticatedUser, AuthService
from app.modules.auth.dependencies import CurrentUser
from app.modules.auth.models import PhoneVerification
from app.modules.auth.schemas import (
    AuthSessionResponse,
    ConfirmVerificationRequest,
    LoginRequest,
    PasswordResetRequest,
    PhoneVerificationRequest,
    PhoneVerificationResponse,
    RefreshRequest,
    RegisterRequest,
    TokenPairResponse,
    VerificationTokenResponse,
)
from app.modules.auth.session_service import SessionService, TokenPair
from app.modules.auth.verification_service import PhoneVerificationService
from app.modules.users.schemas import UserResponse

router = APIRouter(prefix="/auth", tags=["Autenticación"])


def _verification_response(verification: PhoneVerification) -> PhoneVerificationResponse:
    return PhoneVerificationResponse(
        verification_id=verification.id,
        phone=verification.phone,
        purpose=verification.purpose,
        expires_at=verification.expires_at,
        resend_available_at=verification.resend_available_at,
    )


def _token_response(tokens: TokenPair) -> TokenPairResponse:
    return TokenPairResponse(
        access_token=tokens.access_token,
        refresh_token=tokens.refresh_token,
        expires_in=tokens.expires_in,
    )


def _session_response(authenticated: AuthenticatedUser) -> AuthSessionResponse:
    return AuthSessionResponse(
        user=UserResponse.model_validate(authenticated.user),
        tokens=_token_response(authenticated.tokens),
    )


@router.post(
    "/phone-verifications",
    status_code=HTTPStatus.ACCEPTED,
    dependencies=[Depends(rate_limit("20/hour", "phone-verifications"))],
)
async def request_phone_verification(
    payload: PhoneVerificationRequest,
    session: SessionDependency,
    settings: SettingsDependency,
    sms_sender: SmsSenderDependency,
) -> PhoneVerificationResponse:
    service = PhoneVerificationService(session, settings, sms_sender)
    return _verification_response(await service.request(payload.phone, payload.purpose))


@router.post(
    "/phone-verifications/{verification_id}/resend",
    status_code=HTTPStatus.ACCEPTED,
    dependencies=[Depends(rate_limit("20/hour", "phone-verifications"))],
)
async def resend_phone_verification(
    verification_id: uuid.UUID,
    session: SessionDependency,
    settings: SettingsDependency,
    sms_sender: SmsSenderDependency,
) -> PhoneVerificationResponse:
    service = PhoneVerificationService(session, settings, sms_sender)
    return _verification_response(await service.resend(verification_id))


@router.post(
    "/phone-verifications/{verification_id}/confirm",
    dependencies=[Depends(rate_limit("30/hour", "phone-verification-confirm"))],
)
async def confirm_phone_verification(
    verification_id: uuid.UUID,
    payload: ConfirmVerificationRequest,
    session: SessionDependency,
    settings: SettingsDependency,
    sms_sender: SmsSenderDependency,
) -> VerificationTokenResponse:
    service = PhoneVerificationService(session, settings, sms_sender)
    token = await service.confirm(verification_id, payload.code)
    return VerificationTokenResponse(verification_token=token.value, expires_at=token.expires_at)


@router.post(
    "/register",
    status_code=HTTPStatus.CREATED,
    dependencies=[Depends(rate_limit("10/hour", "register"))],
)
async def register(
    payload: RegisterRequest,
    session: SessionDependency,
    settings: SettingsDependency,
    sms_sender: SmsSenderDependency,
) -> AuthSessionResponse:
    service = AuthService(session, settings, sms_sender)
    return _session_response(await service.register(payload))


@router.post("/login", dependencies=[Depends(rate_limit("10/minute", "login"))])
async def login(
    payload: LoginRequest,
    session: SessionDependency,
    settings: SettingsDependency,
    sms_sender: SmsSenderDependency,
) -> AuthSessionResponse:
    service = AuthService(session, settings, sms_sender)
    return _session_response(await service.login(payload))


@router.post("/refresh", dependencies=[Depends(rate_limit("30/minute", "refresh"))])
async def refresh_tokens(
    payload: RefreshRequest, session: SessionDependency, settings: SettingsDependency
) -> TokenPairResponse:
    return _token_response(await SessionService(session, settings).refresh(payload.refresh_token))


@router.post("/logout", status_code=HTTPStatus.NO_CONTENT)
async def logout(
    payload: RefreshRequest,
    current_user: CurrentUser,
    session: SessionDependency,
    settings: SettingsDependency,
) -> None:
    await SessionService(session, settings).logout(payload.refresh_token, current_user.id)


@router.post("/password-reset", dependencies=[Depends(rate_limit("10/hour", "password-reset"))])
async def reset_password(
    payload: PasswordResetRequest,
    session: SessionDependency,
    settings: SettingsDependency,
    sms_sender: SmsSenderDependency,
) -> AuthSessionResponse:
    service = AuthService(session, settings, sms_sender)
    return _session_response(await service.reset_password(payload))
