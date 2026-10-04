import pytest
from httpx import AsyncClient

from tests.factories import RegisteredUser, create_household, idempotency_headers, join_household


async def test_template_application_is_not_found_before_decision(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)

    response = await client.get(
        f"/households/{household['id']}/template-application", headers=marta.headers
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "NOT_FOUND"


@pytest.mark.parametrize(
    ("keys", "count"), [([], 0), (["pets"], 6), (["family_with_children", "pets"], 25)]
)
async def test_admin_applies_templates_or_starts_empty(
    client: AsyncClient, marta: RegisteredUser, keys: list[str], count: int
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}"

    response = await client.post(
        f"{path}/template-application",
        json={"template_keys": keys},
        headers=idempotency_headers(marta),
    )

    assert response.status_code == 201
    assert response.json()["template_keys"] == keys
    assert response.json()["task_count"] == count
    assert response.json()["applied_by"] == {
        "user_id": marta.user_id,
        "display_name": "Marta",
        "avatar": "indigo",
        "is_active": True,
    }
    assert response.json()["applied_at"]
    assert (
        await client.get(f"{path}/template-application", headers=marta.headers)
    ).json() == response.json()
    assert (await client.get(path, headers=marta.headers)).json()["templates_applied"] is True


async def test_member_cannot_apply_templates(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])

    response = await client.post(
        f"/households/{household['id']}/template-application",
        json={"template_keys": []},
        headers=idempotency_headers(pablo),
    )

    assert response.status_code == 403
    assert response.json()["error"]["code"] == "ADMIN_REQUIRED"


async def test_member_reads_applied_templates(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    path = f"/households/{household['id']}/template-application"
    applied = await client.post(
        path, json={"template_keys": ["pets"]}, headers=idempotency_headers(marta)
    )

    response = await client.get(path, headers=pablo.headers)

    assert response.status_code == 200
    assert response.json() == applied.json()


@pytest.mark.parametrize("keys", [["unknown"], ["pets", "pets"]])
async def test_invalid_templates_do_not_close_decision(
    client: AsyncClient, marta: RegisteredUser, keys: list[str]
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}"

    response = await client.post(
        f"{path}/template-application",
        json={"template_keys": keys},
        headers=idempotency_headers(marta),
    )

    assert response.status_code == 422
    expected = "unknown_key" if keys == ["unknown"] else "duplicated"
    assert response.json()["error"]["details"]["fields"][0]["code"] == expected
    assert (await client.get(path, headers=marta.headers)).json()["templates_applied"] is False


async def test_template_application_requires_idempotency_key(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)

    response = await client.post(
        f"/households/{household['id']}/template-application",
        json={"template_keys": []},
        headers=marta.headers,
    )

    assert response.status_code == 422


@pytest.mark.parametrize("initial_keys", [[], ["pets"]])
async def test_second_template_application_conflicts(
    client: AsyncClient, marta: RegisteredUser, initial_keys: list[str]
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/template-application"
    first = await client.post(
        path, json={"template_keys": initial_keys}, headers=idempotency_headers(marta)
    )

    response = await client.post(
        path, json={"template_keys": ["couple"]}, headers=idempotency_headers(marta)
    )

    assert first.status_code == 201
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "TEMPLATES_ALREADY_APPLIED"
    assert (await client.get(path, headers=marta.headers)).json() == first.json()


async def test_template_application_replays_original_response(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/template-application"
    headers = idempotency_headers(marta)
    first = await client.post(path, json={"template_keys": ["pets"]}, headers=headers)
    await client.patch(
        f"/households/{household['id']}/members/me/profile",
        json={"nickname": "Changed"},
        headers=marta.headers,
    )

    response = await client.post(path, json={"template_keys": ["pets"]}, headers=headers)

    assert first.status_code == response.status_code == 201
    assert response.json() == first.json()


async def test_template_application_rejects_reused_key_with_different_body(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/template-application"
    headers = idempotency_headers(marta)
    await client.post(path, json={"template_keys": []}, headers=headers)

    response = await client.post(path, json={"template_keys": ["pets"]}, headers=headers)

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "IDEMPOTENCY_KEY_REUSED"


async def test_template_replay_requires_current_admin_role(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    path = f"/households/{household['id']}"
    headers = idempotency_headers(marta)
    applied = await client.post(
        f"{path}/template-application", json={"template_keys": []}, headers=headers
    )
    await client.patch(
        f"{path}/members/{pablo.user_id}", json={"role": "admin"}, headers=marta.headers
    )
    await client.patch(
        f"{path}/members/{marta.user_id}", json={"role": "member"}, headers=marta.headers
    )

    response = await client.post(
        f"{path}/template-application", json={"template_keys": []}, headers=headers
    )

    assert applied.status_code == 201
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "ADMIN_REQUIRED"


async def test_template_keys_are_scoped_to_household(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    first = await create_household(client, marta)
    second = await create_household(client, marta)
    headers = idempotency_headers(marta)
    applied = await client.post(
        f"/households/{first['id']}/template-application",
        json={"template_keys": ["pets"]},
        headers=headers,
    )

    response = await client.post(
        f"/households/{second['id']}/template-application",
        json={"template_keys": []},
        headers=headers,
    )

    assert applied.status_code == response.status_code == 201
    assert response.json()["task_count"] == 0


async def test_template_application_retains_author_after_departure(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    path = f"/households/{household['id']}"
    await client.patch(
        f"{path}/members/me/profile", json={"nickname": "Martita"}, headers=marta.headers
    )
    await client.post(
        f"{path}/template-application",
        json={"template_keys": []},
        headers=idempotency_headers(marta),
    )
    await client.patch(
        f"{path}/members/{pablo.user_id}", json={"role": "admin"}, headers=marta.headers
    )
    await client.post(f"{path}/leave", headers=marta.headers)

    response = await client.get(f"{path}/template-application", headers=pablo.headers)

    assert response.status_code == 200
    assert response.json()["applied_by"]["user_id"] == marta.user_id
    assert response.json()["applied_by"]["is_active"] is False
