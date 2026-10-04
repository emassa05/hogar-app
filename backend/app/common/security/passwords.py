import re
from typing import Annotated

from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError
from pydantic import AfterValidator
from pydantic_core import PydanticCustomError

_hasher = PasswordHasher()
_UPPERCASE = re.compile(r"[A-ZÁÉÍÓÚÑÜ]")
_DIGIT_OR_SYMBOL = re.compile(r"[\d\W_]")
_DUMMY_HASH = _hasher.hash("dummy-password-for-timing")

MIN_PASSWORD_LENGTH = 8
MAX_PASSWORD_LENGTH = 128


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password: str, password_hash: str | None) -> bool:
    try:
        return _hasher.verify(password_hash or _DUMMY_HASH, password) and password_hash is not None
    except (VerificationError, InvalidHashError):
        return False


def needs_rehash(password_hash: str) -> bool:
    return _hasher.check_needs_rehash(password_hash)


def validate_password_strength(password: str) -> str:
    if len(password) < MIN_PASSWORD_LENGTH:
        raise PydanticCustomError("password_too_short", "Password must have at least 8 characters.")
    if len(password) > MAX_PASSWORD_LENGTH:
        raise PydanticCustomError("too_long", "Password must have at most 128 characters.")
    if not _UPPERCASE.search(password):
        raise PydanticCustomError(
            "password_missing_uppercase", "Password must contain an uppercase letter."
        )
    if not _DIGIT_OR_SYMBOL.search(password):
        raise PydanticCustomError(
            "password_missing_digit_or_symbol", "Password must contain a digit or a symbol."
        )
    return password


StrongPassword = Annotated[str, AfterValidator(validate_password_strength)]
