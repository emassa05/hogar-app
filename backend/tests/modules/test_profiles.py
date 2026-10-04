from typing import Any

import pytest
from httpx import AsyncClient

from tests.factories import RegisteredUser, create_household, create_restriction, join_household


async def test_member_reads_another_members_profile(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    await client.patch(
        f"/households/{household['id']}/members/me/profile",
        json={"nickname": "Martita", "proposed_capacity_percent": 30},
        headers=marta.headers,
    )

    response = await client.get(
        f"/households/{household['id']}/members/{marta.user_id}/profile", headers=pablo.headers
    )

    assert response.status_code == 200
    assert response.json()["is_me"] is False
    assert response.json()["user_id"] == marta.user_id
    assert response.json()["nickname"] == "Martita"
    assert response.json()["proposed_capacity_percent"] == 30
    assert response.json()["approved_capacity_percent"] is None
    assert response.json()["role"] == "admin"


async def test_me_alias_matches_own_uuid(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/members"

    alias = await client.get(f"{path}/me/profile", headers=marta.headers)
    explicit = await client.get(f"{path}/{marta.user_id}/profile", headers=marta.headers)

    assert alias.status_code == explicit.status_code == 200
    assert alias.json() == explicit.json()
    assert alias.json()["is_me"] is True


async def test_profile_of_nonmember_is_not_found(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)

    response = await client.get(
        f"/households/{household['id']}/members/{pablo.user_id}/profile", headers=marta.headers
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "MEMBER_NOT_FOUND"


async def test_invalid_member_reference_is_validation_error(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)

    response = await client.get(
        f"/households/{household['id']}/members/invalid/profile", headers=marta.headers
    )

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"
    assert response.json()["error"]["details"]["fields"][0]["field"] == "path.user_id"
    assert response.json()["error"]["details"]["fields"][0]["code"] == "invalid_format"


@pytest.mark.parametrize("capacity", [0, 30, 100, None])
async def test_update_own_nickname_and_capacity(
    client: AsyncClient, marta: RegisteredUser, capacity: int | None
) -> None:
    household = await create_household(client, marta)

    response = await client.patch(
        f"/households/{household['id']}/members/me/profile",
        json={"nickname": "  Martita  ", "proposed_capacity_percent": capacity},
        headers=marta.headers,
    )

    assert response.status_code == 200
    assert response.json()["nickname"] == "Martita"
    assert response.json()["proposed_capacity_percent"] == capacity
    assert response.json()["approved_capacity_percent"] is None
    detail = await client.get(f"/households/{household['id']}", headers=marta.headers)
    assert detail.json()["members"][0]["nickname"] == "Martita"


async def test_nickname_can_be_cleared(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/members/me/profile"
    await client.patch(
        path, json={"nickname": "Martita", "proposed_capacity_percent": 30}, headers=marta.headers
    )

    response = await client.patch(path, json={"nickname": None}, headers=marta.headers)

    assert response.status_code == 200
    assert response.json()["nickname"] is None
    assert response.json()["proposed_capacity_percent"] == 30


@pytest.mark.parametrize(
    "payload",
    [
        {},
        {"nickname": ""},
        {"nickname": " "},
        {"nickname": "a" * 41},
        {"proposed_capacity_percent": -1},
        {"proposed_capacity_percent": 101},
        {"approved_capacity_percent": 20},
    ],
)
async def test_profile_update_rejects_invalid_fields(
    client: AsyncClient, marta: RegisteredUser, payload: dict[str, Any]
) -> None:
    household = await create_household(client, marta)

    response = await client.patch(
        f"/households/{household['id']}/members/me/profile", json=payload, headers=marta.headers
    )

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


@pytest.mark.parametrize("admin", [True, False])
async def test_neither_admin_nor_member_can_patch_another_profile(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, admin: bool
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    actor, target = (marta, pablo) if admin else (pablo, marta)

    response = await client.patch(
        f"/households/{household['id']}/members/{target.user_id}/profile",
        json={"nickname": "Changed"},
        headers=actor.headers,
    )

    assert response.status_code == 405
    profile = await client.get(
        f"/households/{household['id']}/members/{target.user_id}/profile", headers=actor.headers
    )
    assert profile.json()["nickname"] is None


async def test_profile_data_is_independent_in_each_household(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    first = await create_household(client, marta)
    second = await create_household(client, pablo)
    await join_household(client, marta, pablo, second["id"])
    first_path = f"/households/{first['id']}/members/me"
    second_path = f"/households/{second['id']}/members/me"
    await client.patch(
        f"{first_path}/profile",
        json={"nickname": "Casa", "proposed_capacity_percent": 20},
        headers=marta.headers,
    )
    await client.put(
        f"{first_path}/availability",
        json={"slots": [{"weekday": 0, "period": "morning"}], "exceptions": []},
        headers=marta.headers,
    )
    await create_restriction(client, marta, first["id"], key="cook")
    await client.put(
        f"{first_path}/preferences",
        json={"preferred_activity_keys": ["vacuum"]},
        headers=marta.headers,
    )
    empty = (await client.get(f"{second_path}/profile", headers=marta.headers)).json()
    assert empty["nickname"] is None
    assert empty["proposed_capacity_percent"] is None
    assert empty["availability"] == {"slots": [], "exceptions": []}
    assert empty["restrictions"] == []
    assert empty["preferences"] == {"preferred_activity_keys": []}
    await client.patch(
        f"{second_path}/profile",
        json={"nickname": "Piso", "proposed_capacity_percent": 80},
        headers=marta.headers,
    )
    await client.put(
        f"{second_path}/availability",
        json={"slots": [{"weekday": 6, "period": "evening"}], "exceptions": []},
        headers=marta.headers,
    )
    await create_restriction(client, marta, second["id"], target_type="category", key="pets")
    await client.put(
        f"{second_path}/preferences",
        json={"preferred_activity_keys": ["cook"]},
        headers=marta.headers,
    )

    profiles = [
        (await client.get(f"{path}/profile", headers=marta.headers)).json()
        for path in (first_path, second_path)
    ]

    assert [profile["nickname"] for profile in profiles] == ["Casa", "Piso"]
    assert [profile["proposed_capacity_percent"] for profile in profiles] == [20, 80]
    assert [profile["availability"]["slots"] for profile in profiles] == [
        [{"weekday": 0, "period": "morning"}],
        [{"weekday": 6, "period": "evening"}],
    ]
    assert [profile["restrictions"][0]["target"]["key"] for profile in profiles] == ["cook", "pets"]
    assert [profile["preferences"]["preferred_activity_keys"] for profile in profiles] == [
        ["vacuum"],
        ["cook"],
    ]
