from httpx import AsyncClient

from tests.factories import RegisteredUser, create_household


async def test_update_name_and_avatar(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.patch(
        "/users/me", json={"name": "Marta Núñez", "avatar": "sky"}, headers=marta.headers
    )

    assert response.status_code == 200
    assert response.json()["name"] == "Marta Núñez"
    assert response.json()["avatar"] == "sky"


async def test_clear_avatar(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.patch("/users/me", json={"avatar": None}, headers=marta.headers)

    assert response.json()["avatar"] is None


async def test_update_requires_a_field(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.patch("/users/me", json={}, headers=marta.headers)

    assert response.status_code == 422


async def test_name_cannot_be_null(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.patch("/users/me", json={"name": None}, headers=marta.headers)

    assert response.status_code == 422


async def test_unknown_fields_are_rejected(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.patch(
        "/users/me", json={"phone": "+56987650000"}, headers=marta.headers
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0]["code"] == "unknown_field"


async def test_foreign_active_household_is_not_found(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    response = await client.patch(
        "/users/me",
        json={"active_household_id": "3f6c2a4e-8b1d-4c2a-9a57-1e2f3d4c5b6a"},
        headers=marta.headers,
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "HOUSEHOLD_NOT_FOUND"


async def test_update_active_household_to_own_household(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    first = await create_household(client, marta)
    await create_household(client, marta, name="Otra casa")

    response = await client.patch(
        "/users/me", json={"active_household_id": first["id"]}, headers=marta.headers
    )

    assert response.status_code == 200
    assert response.json()["active_household_id"] == first["id"]
    assert (await client.get("/users/me", headers=marta.headers)).json()[
        "active_household_id"
    ] == first["id"]


async def test_update_active_household_rejects_existing_foreign_household(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, pablo)

    response = await client.patch(
        "/users/me", json={"active_household_id": household["id"]}, headers=marta.headers
    )

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "HOUSEHOLD_NOT_FOUND"
    assert (await client.get("/users/me", headers=marta.headers)).json()[
        "active_household_id"
    ] is None
