import uuid
from typing import Any

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select

from app.common.database import get_database
from app.modules.households.models import Household, Invitation, Membership
from tests.factories import RegisteredUser, create_household, idempotency_headers, join_household


async def test_create_household_sets_admin_invitation_and_active_household(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    response = await client.post(
        "/households", json={"name": "  Casa Los Robles  "}, headers=idempotency_headers(marta)
    )

    assert response.status_code == 201
    body = response.json()
    assert body["name"] == "Casa Los Robles"
    assert body["timezone"] == "America/Santiago"
    assert body["my_role"] == "admin"
    assert body["version"] == 1
    assert body["templates_applied"] is False
    assert body["imbalance_threshold_percent"] is None
    assert len(body["members"]) == 1
    assert body["members"][0] == {
        "user_id": marta.user_id,
        "name": "Marta",
        "nickname": None,
        "avatar": "indigo",
        "role": "admin",
        "joined_at": body["members"][0]["joined_at"],
        "is_me": True,
    }
    assert (await client.get("/users/me", headers=marta.headers)).json()[
        "active_household_id"
    ] == body["id"]
    async with get_database().session_factory() as session:
        assert await session.scalar(select(func.count()).select_from(Invitation)) == 1
        assert await session.scalar(select(func.count()).select_from(Membership)) == 1


@pytest.mark.parametrize("key", [None, "invalid"])
async def test_create_requires_uuid_idempotency_key(
    client: AsyncClient, marta: RegisteredUser, key: str | None
) -> None:
    headers = marta.headers if key is None else idempotency_headers(marta, key)

    response = await client.post("/households", json={"name": "Casa"}, headers=headers)

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"
    assert response.json()["error"]["details"]["fields"][0]["field"] == "header.Idempotency-Key"


async def test_create_replays_without_duplicating_household(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    headers = idempotency_headers(marta)
    first = await client.post("/households", json={"name": "Casa"}, headers=headers)

    replay = await client.post("/households", json={"name": "Casa"}, headers=headers)

    assert first.status_code == replay.status_code == 201
    assert replay.json() == first.json()
    async with get_database().session_factory() as session:
        assert await session.scalar(select(func.count()).select_from(Household)) == 1
        assert await session.scalar(select(func.count()).select_from(Membership)) == 1
        assert await session.scalar(select(func.count()).select_from(Invitation)) == 1


async def test_create_rejects_reused_key_with_different_body(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    headers = idempotency_headers(marta)
    first = await client.post("/households", json={"name": "Casa"}, headers=headers)

    response = await client.post("/households", json={"name": "Otra casa"}, headers=headers)

    assert first.status_code == 201
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "IDEMPOTENCY_KEY_REUSED"
    assert len((await client.get("/households", headers=marta.headers)).json()) == 1


async def test_creation_keys_are_scoped_to_user(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    key = str(uuid.uuid4())
    first = await client.post(
        "/households", json={"name": "Casa"}, headers=idempotency_headers(marta, key)
    )

    second = await client.post(
        "/households", json={"name": "Casa"}, headers=idempotency_headers(pablo, key)
    )

    assert first.status_code == second.status_code == 201
    assert first.json()["id"] != second.json()["id"]


async def test_list_only_active_households_with_role_and_member_count(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    shared = await create_household(client, marta)
    await join_household(client, pablo, marta, shared["id"])
    own = await create_household(client, pablo, name="Casa Pablo")
    await create_household(client, marta, name="Casa privada")

    response = await client.get("/households", headers=pablo.headers)

    assert response.status_code == 200
    assert [(item["id"], item["my_role"], item["member_count"]) for item in response.json()] == [
        (shared["id"], "member", 2),
        (own["id"], "admin", 1),
    ]
    assert all(
        set(item) == {"id", "name", "my_role", "member_count", "created_at"}
        for item in response.json()
    )


async def test_list_without_memberships_is_empty(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    response = await client.get("/households", headers=marta.headers)

    assert response.status_code == 200
    assert response.json() == []


async def test_detail_reports_members_from_requesting_users_perspective(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])

    response = await client.get(f"/households/{household['id']}", headers=pablo.headers)

    assert response.status_code == 200
    assert response.json()["my_role"] == "member"
    assert [(member["user_id"], member["is_me"]) for member in response.json()["members"]] == [
        (marta.user_id, False),
        (pablo.user_id, True),
    ]


async def test_admin_updates_household_and_increments_version(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)

    response = await client.patch(
        f"/households/{household['id']}",
        json={
            "version": 1,
            "name": "Casa nueva",
            "timezone": "Europe/Madrid",
            "imbalance_threshold_percent": 15,
        },
        headers=marta.headers,
    )

    assert response.status_code == 200
    assert response.json()["version"] == 2
    assert response.json()["name"] == "Casa nueva"
    assert response.json()["timezone"] == "Europe/Madrid"
    assert response.json()["imbalance_threshold_percent"] == 15
    assert (
        await client.get(f"/households/{household['id']}", headers=marta.headers)
    ).json() == response.json()


async def test_stale_update_returns_current_version_without_overwriting(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    url = f"/households/{household['id']}"
    await client.patch(url, json={"version": 1, "name": "Actual"}, headers=marta.headers)

    response = await client.patch(url, json={"version": 1, "name": "Stale"}, headers=marta.headers)

    assert response.status_code == 412
    assert response.json()["error"]["code"] == "VERSION_CONFLICT"
    assert response.json()["error"]["details"] == {"current_version": 2}
    assert (await client.get(url, headers=marta.headers)).json()["name"] == "Actual"


async def test_member_cannot_update_household(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])

    response = await client.patch(
        f"/households/{household['id']}", json={"version": 1, "name": "Otra"}, headers=pablo.headers
    )

    assert response.status_code == 403
    assert response.json()["error"]["code"] == "ADMIN_REQUIRED"


@pytest.mark.parametrize("method", ["POST", "PATCH"])
@pytest.mark.parametrize("timezone", ["Mars/Olympus", "", "../UTC"])
async def test_household_rejects_invalid_timezone(
    client: AsyncClient, marta: RegisteredUser, method: str, timezone: str
) -> None:
    household = await create_household(client, marta)
    path = "/households" if method == "POST" else f"/households/{household['id']}"
    payload = (
        {"name": "Casa", "timezone": timezone}
        if method == "POST"
        else {"version": 1, "timezone": timezone}
    )

    response = await client.request(method, path, json=payload, headers=idempotency_headers(marta))

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0]["code"] == "invalid_choice"


@pytest.mark.parametrize(
    "payload",
    [
        {},
        {"version": 1},
        {"name": "Casa"},
        {"version": 1, "name": None},
        {"version": 1, "timezone": None},
        {"version": 1, "imbalance_threshold_percent": 0},
        {"version": 1, "imbalance_threshold_percent": 101},
    ],
)
async def test_household_update_validates_required_changes_and_threshold(
    client: AsyncClient, marta: RegisteredUser, payload: dict[str, Any]
) -> None:
    household = await create_household(client, marta)

    response = await client.patch(
        f"/households/{household['id']}", json=payload, headers=marta.headers
    )

    assert response.status_code == 422


async def test_threshold_can_be_cleared(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)
    url = f"/households/{household['id']}"
    await client.patch(
        url, json={"version": 1, "imbalance_threshold_percent": 20}, headers=marta.headers
    )

    response = await client.patch(
        url, json={"version": 2, "imbalance_threshold_percent": None}, headers=marta.headers
    )

    assert response.status_code == 200
    assert response.json()["imbalance_threshold_percent"] is None


HOUSEHOLD_ROUTES: list[tuple[str, str, dict[str, Any] | None]] = [
    ("GET", "", None),
    ("PATCH", "", {"version": 1, "name": "Casa"}),
    ("GET", "/invitation", None),
    ("POST", "/invitation/regenerate", None),
    ("PATCH", "/members/{user_id}", {"role": "admin"}),
    ("DELETE", "/members/{user_id}", None),
    ("POST", "/leave", None),
    ("GET", "/members/me/profile", None),
    ("GET", "/members/{user_id}/profile", None),
    ("PATCH", "/members/me/profile", {"nickname": "Otro"}),
    ("PUT", "/members/me/availability", {"slots": [], "exceptions": []}),
    (
        "POST",
        "/members/me/restrictions",
        {"target": {"type": "activity", "key": "cook"}, "kind": "permanent"},
    ),
    (
        "PUT",
        "/members/me/restrictions/{restriction_id}",
        {"target": {"type": "activity", "key": "cook"}, "kind": "permanent"},
    ),
    ("DELETE", "/members/me/restrictions/{restriction_id}", None),
    ("PUT", "/members/me/preferences", {"preferred_activity_keys": []}),
    ("GET", "/template-application", None),
    ("POST", "/template-application", {"template_keys": []}),
]


@pytest.mark.parametrize(("method", "suffix", "payload"), HOUSEHOLD_ROUTES)
@pytest.mark.parametrize("existing", [True, False])
async def test_every_household_route_hides_foreign_and_missing_households(
    client: AsyncClient,
    marta: RegisteredUser,
    pablo: RegisteredUser,
    method: str,
    suffix: str,
    payload: dict[str, Any] | None,
    existing: bool,
) -> None:
    household = await create_household(client, marta)
    household_id = household["id"] if existing else str(uuid.uuid4())
    path = suffix.format(user_id=marta.user_id, restriction_id=str(uuid.uuid4()))

    response = await client.request(
        method,
        f"/households/{household_id}{path}",
        json=payload,
        headers=idempotency_headers(pablo),
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "HOUSEHOLD_NOT_FOUND"
    assert response.json()["error"]["details"] == {}
    assert response.json()["error"]["request_id"] == response.headers["X-Request-ID"]


@pytest.mark.parametrize(("method", "suffix", "payload"), HOUSEHOLD_ROUTES)
async def test_household_routes_require_authentication(
    client: AsyncClient, method: str, suffix: str, payload: dict[str, Any] | None
) -> None:
    path = suffix.format(user_id=str(uuid.uuid4()), restriction_id=str(uuid.uuid4()))

    response = await client.request(
        method,
        f"/households/{uuid.uuid4()}{path}",
        json=payload,
        headers={"Idempotency-Key": str(uuid.uuid4())},
    )

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "UNAUTHENTICATED"


@pytest.mark.parametrize("method", ["GET", "POST"])
async def test_household_collection_requires_authentication(
    client: AsyncClient, method: str
) -> None:
    response = await client.request(
        method, "/households", json={"name": "Casa"}, headers={"Idempotency-Key": str(uuid.uuid4())}
    )

    assert response.status_code == 401
