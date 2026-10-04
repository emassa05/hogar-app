from datetime import timedelta

import pytest
from httpx import AsyncClient

from app.common.clock import today_in
from tests.factories import RegisteredUser, create_household, create_restriction


async def test_preferences_put_replaces_and_clears(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/members/me"
    await client.put(
        f"{path}/preferences",
        json={"preferred_activity_keys": ["cook", "vacuum"]},
        headers=marta.headers,
    )

    replaced = await client.put(
        f"{path}/preferences", json={"preferred_activity_keys": ["vacuum"]}, headers=marta.headers
    )
    profile = await client.get(f"{path}/profile", headers=marta.headers)
    cleared = await client.put(
        f"{path}/preferences", json={"preferred_activity_keys": []}, headers=marta.headers
    )

    assert replaced.status_code == 200
    assert profile.json()["preferences"] == {"preferred_activity_keys": ["vacuum"]}
    assert cleared.status_code == 200
    assert (await client.get(f"{path}/profile", headers=marta.headers)).json()["preferences"] == {
        "preferred_activity_keys": []
    }


async def test_unknown_preferred_activity_is_validation_error(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)

    response = await client.put(
        f"/households/{household['id']}/members/me/preferences",
        json={"preferred_activity_keys": ["cook", "unknown"]},
        headers=marta.headers,
    )

    assert response.status_code == 422
    assert (
        response.json()["error"]["details"]["fields"][0]["field"]
        == "body.preferred_activity_keys.1"
    )
    assert response.json()["error"]["details"]["fields"][0]["code"] == "unknown_key"


async def test_duplicate_preferred_activities_are_rejected(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)

    response = await client.put(
        f"/households/{household['id']}/members/me/preferences",
        json={"preferred_activity_keys": ["cook", "cook"]},
        headers=marta.headers,
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0]["code"] == "duplicated"


@pytest.mark.parametrize(("target_type", "key"), [("activity", "cook"), ("category", "food")])
async def test_restricted_activity_cannot_be_preferred(
    client: AsyncClient, marta: RegisteredUser, target_type: str, key: str
) -> None:
    household = await create_household(client, marta)
    await create_restriction(client, marta, household["id"], target_type=target_type, key=key)
    path = f"/households/{household['id']}/members/me"
    await client.put(
        f"{path}/preferences", json={"preferred_activity_keys": ["vacuum"]}, headers=marta.headers
    )

    response = await client.put(
        f"{path}/preferences", json={"preferred_activity_keys": ["cook"]}, headers=marta.headers
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0]["code"] == "conflicting_values"
    assert (await client.get(f"{path}/profile", headers=marta.headers)).json()["preferences"] == {
        "preferred_activity_keys": ["vacuum"]
    }


@pytest.mark.parametrize("timing", ["expired", "future", "unrelated"])
async def test_inactive_or_unrelated_restriction_allows_preference(
    client: AsyncClient, marta: RegisteredUser, timing: str
) -> None:
    household = await create_household(client, marta)
    today = today_in(household["timezone"])
    if timing == "expired":
        await create_restriction(
            client,
            marta,
            household["id"],
            kind="temporary",
            starts_on=(today - timedelta(days=2)).isoformat(),
            ends_on=(today - timedelta(days=1)).isoformat(),
        )
    elif timing == "future":
        await create_restriction(
            client, marta, household["id"], starts_on=(today + timedelta(days=1)).isoformat()
        )
    else:
        await create_restriction(client, marta, household["id"], target_type="category", key="pets")

    response = await client.put(
        f"/households/{household['id']}/members/me/preferences",
        json={"preferred_activity_keys": ["cook"]},
        headers=marta.headers,
    )

    assert response.status_code == 200
