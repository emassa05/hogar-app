import uuid
from datetime import datetime
from typing import Annotated, Literal

from pydantic import Field, StringConstraints

from app.common.phone import PhoneNumber
from app.common.schemas import ApiModel, TrimmedName
from app.common.security.passwords import StrongPassword
from app.modules.auth.models import VerificationPurpose
from app.modules.users.models import Avatar
from app.modules.users.schemas import UserResponse

VerificationCode = Annotated[str, StringConstraints(pattern=r"^\d{6}$")]
OpaqueToken = Annotated[str, StringConstraints(min_length=1, max_length=4096)]


class PhoneVerificationRequest(ApiModel):
    phone: PhoneNumber
    purpose: VerificationPurpose


class PhoneVerificationResponse(ApiModel):
    verification_id: uuid.UUID
    phone: str
    purpose: VerificationPurpose
    expires_at: datetime
    resend_available_at: datetime


class ConfirmVerificationRequest(ApiModel):
    code: VerificationCode


class VerificationTokenResponse(ApiModel):
    verification_token: str
    expires_at: datetime


class RegisterRequest(ApiModel):
    verification_token: OpaqueToken
    password: StrongPassword
    name: TrimmedName
    avatar: Avatar | None = None


class LoginRequest(ApiModel):
    phone: PhoneNumber
    password: Annotated[str, Field(min_length=1, max_length=128)]


class RefreshRequest(ApiModel):
    refresh_token: OpaqueToken


class PasswordResetRequest(ApiModel):
    verification_token: OpaqueToken
    new_password: StrongPassword


class TokenPairResponse(ApiModel):
    access_token: str
    refresh_token: str
    token_type: Literal["bearer"] = "bearer"
    expires_in: int


class AuthSessionResponse(ApiModel):
    user: UserResponse
    tokens: TokenPairResponse
