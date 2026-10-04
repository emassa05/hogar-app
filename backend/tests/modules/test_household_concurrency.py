import asyncio
import uuid

import pytest
from httpx import AsyncClient

from app.modules.households.models import Household, TemplateApplication
from app.modules.households.repository import HouseholdRepository
from tests.factories import RegisteredUser, create_household, idempotency_headers


async def test_simultaneous_edits_return_version_conflict_for_losing_writer(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    household = await create_household(client, marta)
    barrier = asyncio.Barrier(2)
    original_get = HouseholdRepository.get

    async def read_before_update(
        repository: HouseholdRepository, household_id: uuid.UUID
    ) -> Household | None:
        loaded = await original_get(repository, household_id)
        await barrier.wait()
        return loaded

    with monkeypatch.context() as patch:
        patch.setattr(HouseholdRepository, "get", read_before_update)

        responses = await asyncio.gather(
            client.patch(
                f"/households/{household['id']}",
                json={"version": 1, "name": "First"},
                headers=marta.headers,
            ),
            client.patch(
                f"/households/{household['id']}",
                json={"version": 1, "name": "Second"},
                headers=marta.headers,
            ),
        )

    assert sorted(response.status_code for response in responses) == [200, 412]
    conflict = next(response for response in responses if response.status_code == 412)
    assert conflict.json()["error"]["code"] == "VERSION_CONFLICT"
    assert conflict.json()["error"]["details"] == {"current_version": 2}
    winner = next(response for response in responses if response.status_code == 200)
    detail = await client.get(f"/households/{household['id']}", headers=marta.headers)
    assert detail.json()["name"] == winner.json()["name"]
    assert detail.json()["version"] == 2


async def test_simultaneous_template_decisions_only_commit_one_application(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    household = await create_household(client, marta)
    barrier = asyncio.Barrier(2)
    original_get = HouseholdRepository.template_application

    async def read_before_application(
        repository: HouseholdRepository, household_id: uuid.UUID
    ) -> TemplateApplication | None:
        loaded = await original_get(repository, household_id)
        await barrier.wait()
        return loaded

    path = f"/households/{household['id']}/template-application"
    with monkeypatch.context() as patch:
        patch.setattr(HouseholdRepository, "template_application", read_before_application)

        responses = await asyncio.gather(
            client.post(path, json={"template_keys": ["pets"]}, headers=idempotency_headers(marta)),
            client.post(
                path, json={"template_keys": ["couple"]}, headers=idempotency_headers(marta)
            ),
        )

    assert sorted(response.status_code for response in responses) == [201, 409]
    conflict = next(response for response in responses if response.status_code == 409)
    assert conflict.json()["error"]["code"] == "TEMPLATES_ALREADY_APPLIED"
    winner = next(response for response in responses if response.status_code == 201)
    assert (await client.get(path, headers=marta.headers)).json() == winner.json()
