from datetime import timedelta
from typing import Any

from httpx import AsyncClient
from sqlalchemy import update

from app.common.clock import utc_now
from app.common.database import get_database
from app.modules.auth.models import PhoneVerification
from tests.factories import FakeSmsSender, RegisteredUser

PHONE = "+56987654321"


async def _request(
    client: AsyncClient, phone: str = PHONE, purpose: str = "registration"
) -> dict[str, Any]:
    response = await client.post(
        "/auth/phone-verifications", json={"phone": phone, "purpose": purpose}
    )
    assert response.status_code == 202, response.text
    return dict(response.json())


async def test_request_sends_six_digit_code(client: AsyncClient, sms: FakeSmsSender) -> None:
    body = await _request(client, "+56 9 8765 4321")

    assert body["phone"] == PHONE
    assert body["purpose"] == "registration"
    assert len(sms.last_code_for(PHONE)) == 6
    assert "Tu código de equilibrio es" in sms.messages[-1][1]


async def test_registration_with_existing_phone_conflicts(
    client: AsyncClient, sms: FakeSmsSender, marta: RegisteredUser
) -> None:
    response = await client.post(
        "/auth/phone-verifications", json={"phone": marta.phone, "purpose": "registration"}
    )

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "PHONE_ALREADY_REGISTERED"


async def test_password_reset_for_unknown_phone_hides_existence(
    client: AsyncClient, sms: FakeSmsSender
) -> None:
    body = await _request(client, purpose="password_reset")

    assert body["phone"] == PHONE
    assert sms.messages == []
    wrong = await client.post(
        f"/auth/phone-verifications/{body['verification_id']}/confirm", json={"code": "000000"}
    )
    assert wrong.json()["error"]["code"] == "VERIFICATION_CODE_INVALID"


async def test_invalid_phone_is_validation_error(client: AsyncClient, sms: FakeSmsSender) -> None:
    response = await client.post(
        "/auth/phone-verifications", json={"phone": "123", "purpose": "registration"}
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0] == {
        "field": "body.phone",
        "code": "invalid_format",
        "message": "Phone number is not valid.",
    }


async def test_wrong_code_counts_attempts_until_exhausted(
    client: AsyncClient, sms: FakeSmsSender
) -> None:
    verification_id = (await _request(client))["verification_id"]
    wrong_code = "000000" if sms.last_code_for(PHONE) != "000000" else "111111"
    url = f"/auth/phone-verifications/{verification_id}/confirm"

    remaining = []
    for _ in range(5):
        response = await client.post(url, json={"code": wrong_code})
        assert response.status_code == 400
        remaining.append(response.json()["error"]["details"]["remaining_attempts"])
    exhausted = await client.post(url, json={"code": sms.last_code_for(PHONE)})

    assert remaining == [4, 3, 2, 1, 0]
    assert exhausted.status_code == 429
    assert exhausted.json()["error"]["code"] == "VERIFICATION_ATTEMPTS_EXCEEDED"


async def test_resend_requires_cooldown(client: AsyncClient, sms: FakeSmsSender) -> None:
    verification_id = (await _request(client))["verification_id"]

    response = await client.post(f"/auth/phone-verifications/{verification_id}/resend")

    assert response.status_code == 429
    assert response.json()["error"]["code"] == "VERIFICATION_RESEND_TOO_SOON"
    assert int(response.headers["Retry-After"]) >= 1


async def test_resend_after_cooldown_issues_new_code(
    client: AsyncClient, sms: FakeSmsSender
) -> None:
    verification_id = (await _request(client))["verification_id"]
    first_code = sms.last_code_for(PHONE)
    await _shift_verification(verification_id, resend_available_at=utc_now() - timedelta(seconds=1))

    response = await client.post(f"/auth/phone-verifications/{verification_id}/resend")

    assert response.status_code == 202
    assert len(sms.messages) == 2
    old_code = await client.post(
        f"/auth/phone-verifications/{verification_id}/confirm", json={"code": first_code}
    )
    if first_code != sms.last_code_for(PHONE):
        assert old_code.status_code == 400


async def test_expired_verification_is_gone(client: AsyncClient, sms: FakeSmsSender) -> None:
    verification_id = (await _request(client))["verification_id"]
    await _shift_verification(verification_id, expires_at=utc_now() - timedelta(seconds=1))

    response = await client.post(
        f"/auth/phone-verifications/{verification_id}/confirm",
        json={"code": sms.last_code_for(PHONE)},
    )

    assert response.status_code == 410
    assert response.json()["error"]["code"] == "VERIFICATION_EXPIRED"


async def test_unknown_verification_is_not_found(client: AsyncClient, sms: FakeSmsSender) -> None:
    response = await client.post(
        "/auth/phone-verifications/3f6c2a4e-8b1d-4c2a-9a57-1e2f3d4c5b6a/confirm",
        json={"code": "123456"},
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "VERIFICATION_NOT_FOUND"


async def test_hourly_sms_quota_per_phone(client: AsyncClient, sms: FakeSmsSender) -> None:
    for _ in range(5):
        await _request(client)

    response = await client.post(
        "/auth/phone-verifications", json={"phone": PHONE, "purpose": "registration"}
    )

    assert response.status_code == 429
    assert response.json()["error"]["code"] == "RATE_LIMITED"


async def _shift_verification(verification_id: str, **values: object) -> None:
    async with get_database().session_factory() as session:
        await session.execute(
            update(PhoneVerification)
            .where(PhoneVerification.id == verification_id)
            .values(**values)
        )
        await session.commit()
