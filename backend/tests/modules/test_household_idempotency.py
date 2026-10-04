import asyncio
from datetime import timedelta
from typing import NoReturn

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select, update

from app.common.clock import utc_now
from app.common.database import get_database
from app.common.idempotency import IdempotencyRecord
from app.modules.households.models import Household, Invitation, Membership, TemplateApplication
from tests.factories import RegisteredUser, create_household, idempotency_headers


async def test_concurrent_creation_with_same_key_runs_once(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    headers = idempotency_headers(marta)

    responses = await asyncio.gather(
        client.post("/households", json={"name": "Casa"}, headers=headers),
        client.post("/households", json={"name": "Casa"}, headers=headers),
    )

    assert [response.status_code for response in responses] == [201, 201]
    assert responses[0].json() == responses[1].json()
    async with get_database().session_factory() as session:
        assert await session.scalar(select(func.count()).select_from(Household)) == 1
        assert await session.scalar(select(func.count()).select_from(IdempotencyRecord)) == 1


async def test_expired_creation_key_can_be_reused_and_new_response_replays(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    headers = idempotency_headers(marta)
    first = await client.post("/households", json={"name": "Casa"}, headers=headers)
    async with get_database().session_factory() as session:
        await session.execute(
            update(IdempotencyRecord).values(created_at=utc_now() - timedelta(hours=25))
        )
        await session.commit()

    second = await client.post("/households", json={"name": "Otra"}, headers=headers)
    replay = await client.post("/households", json={"name": "Otra"}, headers=headers)

    assert first.status_code == second.status_code == replay.status_code == 201
    assert first.json()["id"] != second.json()["id"]
    assert replay.json() == second.json()
    async with get_database().session_factory() as session:
        assert await session.scalar(select(func.count()).select_from(Household)) == 2


async def test_concurrent_template_application_with_same_key_replays(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    headers = idempotency_headers(marta)
    path = f"/households/{household['id']}/template-application"

    responses = await asyncio.gather(
        client.post(path, json={"template_keys": ["pets"]}, headers=headers),
        client.post(path, json={"template_keys": ["pets"]}, headers=headers),
    )

    assert [response.status_code for response in responses] == [201, 201]
    assert responses[0].json() == responses[1].json()
    async with get_database().session_factory() as session:
        assert await session.scalar(select(func.count()).select_from(TemplateApplication)) == 1


async def test_creation_rolls_back_if_idempotency_record_cannot_be_saved(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr("app.common.idempotency.insert", _fail_insert)

    response = await client.post(
        "/households", json={"name": "Casa"}, headers=idempotency_headers(marta)
    )

    assert response.status_code == 500
    async with get_database().session_factory() as session:
        assert await session.scalar(select(func.count()).select_from(Household)) == 0
        assert await session.scalar(select(func.count()).select_from(Membership)) == 0
        assert await session.scalar(select(func.count()).select_from(Invitation)) == 0
    assert (await client.get("/users/me", headers=marta.headers)).json()[
        "active_household_id"
    ] is None


async def test_template_application_rolls_back_if_idempotency_record_cannot_be_saved(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    household = await create_household(client, marta)
    monkeypatch.setattr("app.common.idempotency.insert", _fail_insert)

    response = await client.post(
        f"/households/{household['id']}/template-application",
        json={"template_keys": ["pets"]},
        headers=idempotency_headers(marta),
    )

    assert response.status_code == 500
    async with get_database().session_factory() as session:
        assert await session.scalar(select(func.count()).select_from(TemplateApplication)) == 0
    assert (await client.get(f"/households/{household['id']}", headers=marta.headers)).json()[
        "templates_applied"
    ] is False


def _fail_insert(table: object) -> NoReturn:
    raise RuntimeError("Idempotency storage unavailable")
