import uuid

import pytest
from pydantic import TypeAdapter, ValidationError

from app.common.config import Settings
from app.common.phone import PhoneNumber
from app.common.security.passwords import StrongPassword, hash_password, verify_password
from app.common.security.tokens import (
    InvalidTokenError,
    TokenType,
    bearer_token,
    codes_match,
    decode_token,
    hash_code,
    issue_access_token,
    issue_verification_token,
    new_numeric_code,
    read_access_subject,
)

password_adapter = TypeAdapter(StrongPassword)
phone_adapter = TypeAdapter(PhoneNumber)


def test_password_hash_roundtrip() -> None:
    password_hash = hash_password("Equilibrio1")

    assert password_hash != "Equilibrio1"
    assert verify_password("Equilibrio1", password_hash)
    assert not verify_password("equilibrio1", password_hash)


def test_verify_password_without_hash_is_false() -> None:
    assert not verify_password("dummy-password-for-timing", None)


@pytest.mark.parametrize(
    ("password", "expected_code"),
    [
        ("Short1", "password_too_short"),
        ("lowercase1", "password_missing_uppercase"),
        ("NoDigitsHere", "password_missing_digit_or_symbol"),
    ],
)
def test_password_rules(password: str, expected_code: str) -> None:
    with pytest.raises(ValidationError) as error:
        password_adapter.validate_python(password)

    assert error.value.errors()[0]["type"] == expected_code


@pytest.mark.parametrize("password", ["Equilibrio1", "Equilibrio!", "ÑandúFeliz_"])
def test_valid_passwords(password: str) -> None:
    assert password_adapter.validate_python(password) == password


@pytest.mark.parametrize("raw", ["+56987654321", "+56 9 8765 4321", "987654321"])
def test_phone_is_normalized_to_e164(raw: str) -> None:
    assert phone_adapter.validate_python(raw) == "+56987654321"


@pytest.mark.parametrize("raw", ["123", "+56 1", "abc"])
def test_invalid_phone_is_rejected(raw: str) -> None:
    with pytest.raises(ValidationError) as error:
        phone_adapter.validate_python(raw)

    assert error.value.errors()[0]["type"] == "invalid_format"


def test_access_token_roundtrip(settings: Settings) -> None:
    user_id, session_id = uuid.uuid4(), uuid.uuid4()
    issued = issue_access_token(user_id, session_id, settings)

    claims = decode_token(issued.value, TokenType.ACCESS, settings)

    assert claims["sub"] == str(user_id)
    assert claims["sid"] == str(session_id)
    assert read_access_subject(f"Bearer {issued.value}", settings) == str(user_id)


def test_token_type_is_enforced(settings: Settings) -> None:
    issued = issue_verification_token(uuid.uuid4(), "+56987654321", "registration", settings)

    with pytest.raises(InvalidTokenError):
        decode_token(issued.value, TokenType.ACCESS, settings)


def test_tampered_token_is_rejected(settings: Settings) -> None:
    issued = issue_access_token(uuid.uuid4(), uuid.uuid4(), settings)

    with pytest.raises(InvalidTokenError):
        decode_token(issued.value[:-2] + "xx", TokenType.ACCESS, settings)


@pytest.mark.parametrize("header", [None, "", "Basic abc", "Bearer"])
def test_bearer_token_rejects_malformed_headers(header: str | None) -> None:
    assert bearer_token(header) is None


def test_numeric_code_and_hash(settings: Settings) -> None:
    code = new_numeric_code()
    code_hash = hash_code(code, "salt", settings)

    assert len(code) == 6
    assert code.isdigit()
    assert codes_match(code, "salt", code_hash, settings)
    assert not codes_match(code, "other-salt", code_hash, settings)
