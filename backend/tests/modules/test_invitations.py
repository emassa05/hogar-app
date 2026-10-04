import re
from datetime import datetime, timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy import select, update

from app.common.clock import utc_now
from app.common.database import get_database
from app.modules.households.models import Invitation, Membership
from tests.factories import (
    RegisteredUser,
    create_household,
    get_invitation_code,
    join_household,
)


async def test_admin_reads_current_code_and_share_url(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)

    response = await client.get(f"/households/{household['id']}/invitation", headers=marta.headers)

    assert response.status_code == 200
    body = response.json()
    assert re.fullmatch(r"[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}", body["code"])
    assert body["share_url"] == f"https://hogarapp.cl/unirse/{body['code']}"
    assert (
        abs((datetime.fromisoformat(body["expires_at"]) - utc_now()).total_seconds() - 604800) < 30
    )
    assert (
        await client.get(f"/households/{household['id']}/invitation", headers=marta.headers)
    ).json() == body


@pytest.mark.parametrize(("method", "suffix"), [("GET", ""), ("POST", "/regenerate")])
async def test_member_cannot_read_or_regenerate_invitation(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, method: str, suffix: str
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])

    response = await client.request(
        method, f"/households/{household['id']}/invitation{suffix}", headers=pablo.headers
    )

    assert response.status_code == 403
    assert response.json()["error"]["code"] == "ADMIN_REQUIRED"


@pytest.mark.parametrize(("method", "suffix"), [("GET", ""), ("POST", "/accept")])
async def test_regeneration_revokes_previous_code(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, method: str, suffix: str
) -> None:
    household = await create_household(client, marta)
    old_code = await get_invitation_code(client, marta, household["id"])
    regenerated = await client.post(
        f"/households/{household['id']}/invitation/regenerate", headers=marta.headers
    )

    response = await client.request(
        method, f"/invitations/{old_code}{suffix}", headers=pablo.headers
    )

    assert regenerated.status_code == 201
    assert regenerated.json()["code"] != old_code
    assert response.status_code == 404
    assert response.json()["error"]["code"] == "INVITATION_NOT_FOUND"
    assert (
        await client.get(f"/invitations/{regenerated.json()['code']}", headers=pablo.headers)
    ).status_code == 200
    async with get_database().session_factory() as session:
        invitation = await session.scalar(
            select(Invitation).where(Invitation.code == old_code.replace("-", ""))
        )
        assert invitation is not None
        assert invitation.revoked_at is not None


@pytest.mark.parametrize("code", ["0abc-def1", "0ABCDEF1", "oabc-defl", "OABCDEFI"])
async def test_preview_and_accept_normalize_invitation_codes(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, code: str
) -> None:
    household = await create_household(client, marta)
    async with get_database().session_factory() as session:
        await session.execute(
            update(Invitation)
            .where(Invitation.household_id == household["id"])
            .values(code="0ABCDEF1")
        )
        await session.commit()

    preview = await client.get(f"/invitations/{code}", headers=pablo.headers)
    accepted = await client.post(f"/invitations/{code}/accept", headers=pablo.headers)

    assert preview.status_code == 200
    assert preview.json()["household_id"] == household["id"]
    assert preview.json()["household_name"] == household["name"]
    assert preview.json()["member_count"] == 1
    assert accepted.status_code == 201
    assert accepted.json()["my_role"] == "member"
    assert len(accepted.json()["members"]) == 2
    assert (await client.get("/users/me", headers=pablo.headers)).json()[
        "active_household_id"
    ] == household["id"]
    profile = (
        await client.get(f"/households/{household['id']}/members/me/profile", headers=pablo.headers)
    ).json()
    assert profile["nickname"] is None
    assert profile["proposed_capacity_percent"] is None
    assert profile["availability"] == {"slots": [], "exceptions": []}
    assert profile["restrictions"] == []
    assert profile["preferences"] == {"preferred_activity_keys": []}


@pytest.mark.parametrize(("method", "suffix"), [("GET", ""), ("POST", "/accept")])
async def test_expired_invitation_is_gone(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, method: str, suffix: str
) -> None:
    household = await create_household(client, marta)
    code = await get_invitation_code(client, marta, household["id"])
    await _expire_invitation(household["id"])

    response = await client.request(method, f"/invitations/{code}{suffix}", headers=pablo.headers)

    assert response.status_code == 410
    assert response.json()["error"]["code"] == "INVITATION_EXPIRED"


async def test_admin_get_creates_code_when_current_invitation_expired(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    old_code = await get_invitation_code(client, marta, household["id"])
    await _expire_invitation(household["id"])

    response = await client.get(f"/households/{household['id']}/invitation", headers=marta.headers)

    assert response.status_code == 200
    assert response.json()["code"] != old_code
    assert (
        await client.get(f"/invitations/{response.json()['code']}", headers=pablo.headers)
    ).status_code == 200


@pytest.mark.parametrize("code", ["ZZZZ-ZZZZ", "!!!!!!!!", "ABCDEFGU", "ABC-DEFG"])
@pytest.mark.parametrize(("method", "suffix"), [("GET", ""), ("POST", "/accept")])
async def test_unknown_or_malformed_invitation_is_not_found(
    client: AsyncClient, marta: RegisteredUser, code: str, method: str, suffix: str
) -> None:
    response = await client.request(method, f"/invitations/{code}{suffix}", headers=marta.headers)

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "INVITATION_NOT_FOUND"


async def test_accept_twice_conflicts_without_adding_membership(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    code = await get_invitation_code(client, marta, household["id"])
    first = await client.post(f"/invitations/{code}/accept", headers=pablo.headers)

    response = await client.post(f"/invitations/{code}/accept", headers=pablo.headers)

    assert first.status_code == 201
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "ALREADY_MEMBER"
    assert response.json()["error"]["details"] == {"household_id": household["id"]}
    async with get_database().session_factory() as session:
        memberships = list(
            await session.scalars(select(Membership).where(Membership.user_id == pablo.user_id))
        )
        assert len(memberships) == 1


async def test_rejoin_after_leaving_creates_new_empty_membership(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    code = await get_invitation_code(client, marta, household["id"])
    await join_household(client, pablo, marta, household["id"])
    await client.patch(
        f"/households/{household['id']}/members/me/profile",
        json={"nickname": "Anterior"},
        headers=pablo.headers,
    )
    left = await client.post(f"/households/{household['id']}/leave", headers=pablo.headers)

    response = await client.post(f"/invitations/{code}/accept", headers=pablo.headers)

    assert left.status_code == 204
    assert response.status_code == 201
    profile = await client.get(
        f"/households/{household['id']}/members/me/profile", headers=pablo.headers
    )
    assert profile.json()["nickname"] is None
    async with get_database().session_factory() as session:
        memberships = list(
            await session.scalars(
                select(Membership)
                .where(Membership.user_id == pablo.user_id)
                .order_by(Membership.joined_at)
            )
        )
        assert len(memberships) == 2
        assert memberships[0].left_at is not None
        assert memberships[0].nickname == "Anterior"
        assert memberships[1].left_at is None


async def test_invitation_rate_limit_is_shared_between_preview_and_accept_per_user(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    code = await get_invitation_code(client, marta, household["id"])
    accepted = await client.post(f"/invitations/{code}/accept", headers=pablo.headers)
    previews = [await client.get(f"/invitations/{code}", headers=pablo.headers) for _ in range(9)]

    limited = await client.post(f"/invitations/{code}/accept", headers=pablo.headers)
    other_user = await client.get(f"/invitations/{code}", headers=marta.headers)

    assert accepted.status_code == 201
    assert [response.status_code for response in previews] == [200] * 9
    assert previews[-1].headers["X-RateLimit-Limit"] == "10"
    assert previews[-1].headers["X-RateLimit-Remaining"] == "0"
    assert limited.status_code == 429
    assert limited.json()["error"]["code"] == "RATE_LIMITED"
    assert int(limited.headers["Retry-After"]) >= 1
    assert limited.json()["error"]["details"]["retry_after_seconds"] >= 1
    assert other_user.status_code == 200


@pytest.mark.parametrize(("method", "suffix"), [("GET", ""), ("POST", "/accept")])
async def test_invitations_require_authentication(
    client: AsyncClient, method: str, suffix: str
) -> None:
    response = await client.request(method, f"/invitations/ABCD-EFGH{suffix}")

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "UNAUTHENTICATED"


async def test_invitation_generation_retries_a_code_collision(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    household = await create_household(client, marta)
    original = await get_invitation_code(client, marta, household["id"])
    codes = iter([original.replace("-", ""), "0123ABCD"])
    monkeypatch.setattr(
        "app.modules.households.household_service.generate_code", lambda: next(codes)
    )

    response = await client.post(
        f"/households/{household['id']}/invitation/regenerate", headers=marta.headers
    )

    assert response.status_code == 201
    assert response.json()["code"] == "0123-ABCD"


async def test_exhausted_code_collisions_roll_back_revocation(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    household = await create_household(client, marta)
    original = await get_invitation_code(client, marta, household["id"])
    monkeypatch.setattr(
        "app.modules.households.household_service.generate_code", lambda: original.replace("-", "")
    )

    response = await client.post(
        f"/households/{household['id']}/invitation/regenerate", headers=marta.headers
    )

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "CONFLICT"
    assert await get_invitation_code(client, marta, household["id"]) == original
    assert (await client.get(f"/invitations/{original}", headers=marta.headers)).status_code == 200


async def _expire_invitation(household_id: str) -> None:
    async with get_database().session_factory() as session:
        await session.execute(
            update(Invitation)
            .where(Invitation.household_id == household_id)
            .values(expires_at=utc_now() - timedelta(seconds=1))
        )
        await session.commit()
