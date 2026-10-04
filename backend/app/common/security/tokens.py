import hashlib
import hmac
import secrets
import uuid
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from typing import Any

import jwt

from app.common.clock import utc_now
from app.common.config import Settings


class TokenType(StrEnum):
    ACCESS = "access"
    VERIFICATION = "verification"


class InvalidTokenError(Exception):
    pass


@dataclass(frozen=True, slots=True)
class IssuedToken:
    value: str
    expires_at: datetime


def _encode(claims: dict[str, Any], settings: Settings) -> str:
    return jwt.encode(
        claims, settings.jwt_secret.get_secret_value(), algorithm=settings.jwt_algorithm
    )


def issue_access_token(
    user_id: uuid.UUID, session_id: uuid.UUID, settings: Settings
) -> IssuedToken:
    issued_at = utc_now()
    expires_at = issued_at + settings.access_token_ttl
    claims = {
        "sub": str(user_id),
        "sid": str(session_id),
        "type": TokenType.ACCESS.value,
        "iat": issued_at,
        "exp": expires_at,
        "jti": str(uuid.uuid4()),
    }
    return IssuedToken(_encode(claims, settings), expires_at)


def issue_verification_token(
    verification_id: uuid.UUID, phone: str, purpose: str, settings: Settings
) -> IssuedToken:
    issued_at = utc_now()
    expires_at = issued_at + settings.verification_token_ttl
    claims = {
        "sub": phone,
        "purpose": purpose,
        "type": TokenType.VERIFICATION.value,
        "iat": issued_at,
        "exp": expires_at,
        "jti": str(verification_id),
    }
    return IssuedToken(_encode(claims, settings), expires_at)


def decode_token(token: str, expected_type: TokenType, settings: Settings) -> dict[str, Any]:
    try:
        claims: dict[str, Any] = jwt.decode(
            token,
            settings.jwt_secret.get_secret_value(),
            algorithms=[settings.jwt_algorithm],
            options={"require": ["sub", "type", "exp", "iat", "jti"]},
        )
    except jwt.PyJWTError as error:
        raise InvalidTokenError from error
    if claims.get("type") != expected_type.value:
        raise InvalidTokenError
    return claims


def bearer_token(authorization_header: str | None) -> str | None:
    if not authorization_header:
        return None
    scheme, _, token = authorization_header.partition(" ")
    if scheme.lower() != "bearer" or not token:
        return None
    return token.strip()


def read_access_subject(authorization_header: str | None, settings: Settings) -> str | None:
    token = bearer_token(authorization_header)
    if token is None:
        return None
    try:
        return str(decode_token(token, TokenType.ACCESS, settings)["sub"])
    except InvalidTokenError:
        return None


def new_opaque_token() -> str:
    return secrets.token_urlsafe(48)


def hash_opaque_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def new_numeric_code(length: int = 6) -> str:
    return "".join(secrets.choice("0123456789") for _ in range(length))


def hash_code(code: str, salt: str, settings: Settings) -> str:
    key = settings.jwt_secret.get_secret_value().encode()
    return hmac.new(key, f"{salt}:{code}".encode(), hashlib.sha256).hexdigest()


def codes_match(code: str, salt: str, expected_hash: str, settings: Settings) -> bool:
    return hmac.compare_digest(hash_code(code, salt, settings), expected_hash)
