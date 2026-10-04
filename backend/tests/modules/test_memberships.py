import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy import select

from app.common.database import get_database
from app.modules.households.models import Membership
from tests.factories import RegisteredUser, create_household, join_household


async def test_admin_promotes_member_then_demotes_self(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    path = f"/households/{household['id']}/members"

    promoted = await client.patch(
        f"{path}/{pablo.user_id}", json={"role": "admin"}, headers=marta.headers
    )
    demoted = await client.patch(
        f"{path}/{marta.user_id}", json={"role": "member"}, headers=marta.headers
    )

    assert promoted.status_code == demoted.status_code == 200
    assert promoted.json()["role"] == "admin"
    assert promoted.json()["is_me"] is False
    assert demoted.json()["role"] == "member"
    assert demoted.json()["is_me"] is True
    assert (await client.get(f"/households/{household['id']}", headers=pablo.headers)).json()[
        "my_role"
    ] == "admin"


async def test_last_admin_cannot_demote_self(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)

    response = await client.patch(
        f"/households/{household['id']}/members/{marta.user_id}",
        json={"role": "member"},
        headers=marta.headers,
    )

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "LAST_ADMIN_MUST_TRANSFER"
    assert (await client.get(f"/households/{household['id']}", headers=marta.headers)).json()[
        "my_role"
    ] == "admin"


@pytest.mark.parametrize("method", ["PATCH", "DELETE"])
async def test_member_cannot_manage_roles_or_remove_members(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, method: str
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])

    response = await client.request(
        method,
        f"/households/{household['id']}/members/{marta.user_id}",
        json={"role": "member"} if method == "PATCH" else None,
        headers=pablo.headers,
    )

    assert response.status_code == 403
    assert response.json()["error"]["code"] == "ADMIN_REQUIRED"


@pytest.mark.parametrize("method", ["PATCH", "DELETE"])
async def test_admin_cannot_manage_nonmember(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, method: str
) -> None:
    household = await create_household(client, marta)

    response = await client.request(
        method,
        f"/households/{household['id']}/members/{pablo.user_id}",
        json={"role": "admin"} if method == "PATCH" else None,
        headers=marta.headers,
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "MEMBER_NOT_FOUND"


async def test_admin_cannot_remove_self(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)

    response = await client.delete(
        f"/households/{household['id']}/members/{marta.user_id}", headers=marta.headers
    )

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "CONFLICT"


async def test_removing_member_revokes_access_and_preserves_history(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    await client.patch(
        f"/households/{household['id']}/members/me/profile",
        json={"nickname": "Pablito"},
        headers=pablo.headers,
    )

    response = await client.delete(
        f"/households/{household['id']}/members/{pablo.user_id}", headers=marta.headers
    )

    assert response.status_code == 204
    assert response.content == b""
    denied = await client.get(f"/households/{household['id']}", headers=pablo.headers)
    assert denied.status_code == 404
    assert denied.json()["error"]["code"] == "HOUSEHOLD_NOT_FOUND"
    assert (await client.get("/households", headers=pablo.headers)).json() == []
    assert (await client.get("/users/me", headers=pablo.headers)).json()[
        "active_household_id"
    ] is None
    remaining = (await client.get(f"/households/{household['id']}", headers=marta.headers)).json()[
        "members"
    ]
    assert [member["user_id"] for member in remaining] == [marta.user_id]
    async with get_database().session_factory() as session:
        membership = await session.scalar(
            select(Membership).where(
                Membership.household_id == household["id"], Membership.user_id == pablo.user_id
            )
        )
        assert membership is not None
        assert membership.left_at is not None
        assert membership.nickname == "Pablito"


@pytest.mark.parametrize("alone", [True, False])
async def test_last_admin_cannot_leave_even_when_alone(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, alone: bool
) -> None:
    household = await create_household(client, marta)
    if not alone:
        await join_household(client, pablo, marta, household["id"])

    response = await client.post(f"/households/{household['id']}/leave", headers=marta.headers)

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "LAST_ADMIN_MUST_TRANSFER"


async def test_member_leaves_and_active_household_is_cleared(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])

    response = await client.post(f"/households/{household['id']}/leave", headers=pablo.headers)

    assert response.status_code == 204
    assert response.content == b""
    assert (await client.get("/users/me", headers=pablo.headers)).json()[
        "active_household_id"
    ] is None
    assert (await client.get("/households", headers=pablo.headers)).json() == []
    assert (
        await client.get(f"/households/{household['id']}", headers=pablo.headers)
    ).status_code == 404
    async with get_database().session_factory() as session:
        membership = await session.scalar(
            select(Membership).where(Membership.user_id == pablo.user_id)
        )
        assert membership is not None
        assert membership.left_at is not None


async def test_admin_can_leave_after_transfer(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    await client.patch(
        f"/households/{household['id']}/members/{pablo.user_id}",
        json={"role": "admin"},
        headers=marta.headers,
    )

    response = await client.post(f"/households/{household['id']}/leave", headers=marta.headers)

    assert response.status_code == 204
    assert (await client.get(f"/households/{household['id']}", headers=pablo.headers)).json()[
        "my_role"
    ] == "admin"


async def test_leaving_does_not_clear_another_active_household(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    own = await create_household(client, pablo)

    response = await client.post(f"/households/{household['id']}/leave", headers=pablo.headers)

    assert response.status_code == 204
    assert (await client.get("/users/me", headers=pablo.headers)).json()[
        "active_household_id"
    ] == own["id"]


@pytest.mark.parametrize("role", ["owner", None])
async def test_role_must_be_valid(
    client: AsyncClient, marta: RegisteredUser, role: str | None
) -> None:
    household = await create_household(client, marta)

    response = await client.patch(
        f"/households/{household['id']}/members/{marta.user_id}",
        json={"role": role},
        headers=marta.headers,
    )

    assert response.status_code == 422


async def test_removed_member_cannot_be_promoted_again(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    await client.delete(
        f"/households/{household['id']}/members/{pablo.user_id}", headers=marta.headers
    )

    response = await client.patch(
        f"/households/{household['id']}/members/{pablo.user_id}",
        json={"role": "admin"},
        headers=marta.headers,
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "MEMBER_NOT_FOUND"


async def test_missing_member_id_is_not_found(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)

    response = await client.delete(
        f"/households/{household['id']}/members/{uuid.uuid4()}", headers=marta.headers
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "MEMBER_NOT_FOUND"
