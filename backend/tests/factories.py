import re
from dataclasses import dataclass, field
from typing import Any

from httpx import AsyncClient

DEFAULT_PASSWORD = "Equilibrio1"
_CODE_PATTERN = re.compile(r"(\d{3}) (\d{3})")


@dataclass
class FakeSmsSender:
    messages: list[tuple[str, str]] = field(default_factory=list)

    async def send(self, to: str, body: str) -> None:
        self.messages.append((to, body))

    def last_code_for(self, phone: str) -> str:
        for recipient, body in reversed(self.messages):
            if recipient == phone:
                match = _CODE_PATTERN.search(body)
                if match:
                    return match.group(1) + match.group(2)
        raise AssertionError(f"No SMS sent to {phone}")


@dataclass
class RegisteredUser:
    phone: str
    password: str
    body: dict[str, Any]

    @property
    def access_token(self) -> str:
        return str(self.body["tokens"]["access_token"])

    @property
    def refresh_token(self) -> str:
        return str(self.body["tokens"]["refresh_token"])

    @property
    def user_id(self) -> str:
        return str(self.body["user"]["id"])

    @property
    def headers(self) -> dict[str, str]:
        return {"Authorization": f"Bearer {self.access_token}"}


async def verify_phone(
    client: AsyncClient, sms: FakeSmsSender, phone: str, purpose: str = "registration"
) -> str:
    requested = await client.post(
        "/auth/phone-verifications", json={"phone": phone, "purpose": purpose}
    )
    assert requested.status_code == 202, requested.text
    verification_id = requested.json()["verification_id"]
    confirmed = await client.post(
        f"/auth/phone-verifications/{verification_id}/confirm",
        json={"code": sms.last_code_for(phone)},
    )
    assert confirmed.status_code == 200, confirmed.text
    return str(confirmed.json()["verification_token"])


async def register_user(
    client: AsyncClient,
    sms: FakeSmsSender,
    phone: str = "+56987654321",
    name: str = "Marta",
    password: str = DEFAULT_PASSWORD,
) -> RegisteredUser:
    token = await verify_phone(client, sms, phone)
    response = await client.post(
        "/auth/register",
        json={"verification_token": token, "password": password, "name": name, "avatar": "indigo"},
    )
    assert response.status_code == 201, response.text
    return RegisteredUser(phone=phone, password=password, body=response.json())
