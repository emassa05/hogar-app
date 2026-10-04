import uuid
from datetime import timedelta
from typing import Any

import pytest
from httpx import AsyncClient

from app.common.clock import today_in
from tests.factories import RegisteredUser, create_household, create_restriction, join_household


@pytest.mark.parametrize(
    ("target_type", "key", "name"),
    [("activity", "cook", "Cocinar"), ("category", "pets", "Mascotas")],
)
async def test_create_permanent_restriction_defaults_to_household_today(
    client: AsyncClient, marta: RegisteredUser, target_type: str, key: str, name: str
) -> None:
    household = await create_household(client, marta, timezone="Pacific/Auckland")

    response = await client.post(
        f"/households/{household['id']}/members/me/restrictions",
        json={"target": {"type": target_type, "key": key}, "kind": "permanent"},
        headers=marta.headers,
    )

    assert response.status_code == 201
    body = response.json()
    assert body["target"] == {"type": target_type, "key": key}
    assert body["target_name"] == name
    assert body["starts_on"] == today_in("Pacific/Auckland").isoformat()
    assert body["ends_on"] is None
    assert body["is_active"] is True
    assert uuid.UUID(body["id"])
    profile = await client.get(
        f"/households/{household['id']}/members/me/profile", headers=marta.headers
    )
    assert profile.json()["restrictions"] == [body]


async def test_replace_restriction_updates_same_id(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    restriction = await create_restriction(client, marta, household["id"])
    today = today_in(household["timezone"])
    payload = {
        "target": {"type": "category", "key": "pets"},
        "kind": "temporary",
        "starts_on": today.isoformat(),
        "ends_on": (today + timedelta(days=7)).isoformat(),
    }

    response = await client.put(
        f"/households/{household['id']}/members/me/restrictions/{restriction['id']}",
        json=payload,
        headers=marta.headers,
    )

    assert response.status_code == 200
    assert response.json()["id"] == restriction["id"]
    assert response.json()["created_at"] == restriction["created_at"]
    assert response.json()["target"] == payload["target"]
    assert response.json()["kind"] == "temporary"
    assert response.json()["ends_on"] == payload["ends_on"]


async def test_delete_restriction_removes_it_from_profile(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    restriction = await create_restriction(client, marta, household["id"])

    response = await client.delete(
        f"/households/{household['id']}/members/me/restrictions/{restriction['id']}",
        headers=marta.headers,
    )

    assert response.status_code == 204
    assert response.content == b""
    assert (
        await client.get(f"/households/{household['id']}/members/me/profile", headers=marta.headers)
    ).json()["restrictions"] == []


@pytest.mark.parametrize("target_type", ["category", "activity"])
@pytest.mark.parametrize("method", ["POST", "PUT"])
async def test_unknown_restriction_target_is_validation_error(
    client: AsyncClient, marta: RegisteredUser, target_type: str, method: str
) -> None:
    household = await create_household(client, marta)
    restriction = await create_restriction(client, marta, household["id"])
    path = f"/households/{household['id']}/members/me/restrictions"
    if method == "PUT":
        path += f"/{restriction['id']}"

    response = await client.request(
        method,
        path,
        json={"target": {"type": target_type, "key": "unknown"}, "kind": "permanent"},
        headers=marta.headers,
    )

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"
    assert response.json()["error"]["details"]["fields"][0]["code"] == "unknown_key"
    assert response.json()["error"]["details"]["fields"][0]["field"] == "body.target.key"


@pytest.mark.parametrize(
    ("values", "code"),
    [
        ({"kind": "temporary"}, "required"),
        ({"kind": "permanent", "ends_on": "2027-01-01"}, "conflicting_values"),
        ({"kind": "temporary", "starts_on": "2027-01-02", "ends_on": "2027-01-01"}, "out_of_range"),
    ],
)
@pytest.mark.parametrize("method", ["POST", "PUT"])
async def test_restriction_validates_kind_and_date_range(
    client: AsyncClient, marta: RegisteredUser, values: dict[str, Any], code: str, method: str
) -> None:
    household = await create_household(client, marta)
    restriction = await create_restriction(client, marta, household["id"])
    path = f"/households/{household['id']}/members/me/restrictions"
    if method == "PUT":
        path += f"/{restriction['id']}"

    response = await client.request(
        method,
        path,
        json={"target": {"type": "activity", "key": "cook"}, **values},
        headers=marta.headers,
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0]["code"] == code


@pytest.mark.parametrize("method", ["POST", "PUT"])
async def test_temporary_end_cannot_precede_default_start_date(
    client: AsyncClient, marta: RegisteredUser, method: str
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/members/me/restrictions"
    if method == "PUT":
        restriction = await create_restriction(client, marta, household["id"])
        path += f"/{restriction['id']}"
    yesterday = today_in(household["timezone"]) - timedelta(days=1)

    response = await client.request(
        method,
        path,
        json={
            "target": {"type": "activity", "key": "cook"},
            "kind": "temporary",
            "ends_on": yesterday.isoformat(),
        },
        headers=marta.headers,
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0]["code"] == "out_of_range"


async def test_restriction_put_defaults_start_to_today(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    today = today_in(household["timezone"])
    restriction = await create_restriction(
        client, marta, household["id"], starts_on=(today - timedelta(days=10)).isoformat()
    )

    response = await client.put(
        f"/households/{household['id']}/members/me/restrictions/{restriction['id']}",
        json={"target": {"type": "activity", "key": "cook"}, "kind": "permanent"},
        headers=marta.headers,
    )

    assert response.status_code == 200
    assert response.json()["starts_on"] == today.isoformat()


@pytest.mark.parametrize("method", ["POST", "PUT"])
async def test_duplicate_active_target_conflicts_and_preserves_original_restrictions(
    client: AsyncClient, marta: RegisteredUser, method: str
) -> None:
    household = await create_household(client, marta)
    first = await create_restriction(client, marta, household["id"])
    path = f"/households/{household['id']}/members/me/restrictions"
    expected = [first]
    if method == "PUT":
        second = await create_restriction(client, marta, household["id"], key="vacuum")
        path += f"/{second['id']}"
        expected.append(second)

    response = await client.request(
        method,
        path,
        json={"target": {"type": "activity", "key": "cook"}, "kind": "permanent"},
        headers=marta.headers,
    )

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "CONFLICT"
    assert (
        await client.get(f"/households/{household['id']}/members/me/profile", headers=marta.headers)
    ).json()["restrictions"] == expected


async def test_expired_restriction_does_not_block_new_restriction(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    today = today_in(household["timezone"])
    expired = await create_restriction(
        client,
        marta,
        household["id"],
        kind="temporary",
        starts_on=(today - timedelta(days=2)).isoformat(),
        ends_on=(today - timedelta(days=1)).isoformat(),
    )

    response = await client.post(
        f"/households/{household['id']}/members/me/restrictions",
        json={"target": {"type": "activity", "key": "cook"}, "kind": "permanent"},
        headers=marta.headers,
    )

    assert expired["is_active"] is False
    assert response.status_code == 201
    assert response.json()["is_active"] is True


async def test_future_restriction_does_not_count_as_active_duplicate(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    tomorrow = today_in(household["timezone"]) + timedelta(days=1)
    future = await create_restriction(
        client, marta, household["id"], starts_on=tomorrow.isoformat()
    )

    response = await client.post(
        f"/households/{household['id']}/members/me/restrictions",
        json={"target": {"type": "activity", "key": "cook"}, "kind": "permanent"},
        headers=marta.headers,
    )

    assert future["is_active"] is False
    assert response.status_code == 201
    assert response.json()["is_active"] is True


@pytest.mark.parametrize("method", ["PUT", "DELETE"])
@pytest.mark.parametrize("owner", ["other_member", "other_household", "missing"])
async def test_restriction_ids_are_scoped_to_member_and_household(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, method: str, owner: str
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    restriction_id = str(uuid.uuid4())
    if owner == "other_member":
        restriction_id = (await create_restriction(client, marta, household["id"]))["id"]
    elif owner == "other_household":
        other = await create_household(client, pablo)
        restriction_id = (await create_restriction(client, pablo, other["id"]))["id"]

    response = await client.request(
        method,
        f"/households/{household['id']}/members/me/restrictions/{restriction_id}",
        json={"target": {"type": "activity", "key": "vacuum"}, "kind": "permanent"}
        if method == "PUT"
        else None,
        headers=pablo.headers,
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "NOT_FOUND"
