from httpx import AsyncClient

from tests.factories import DEFAULT_PASSWORD, FakeSmsSender, RegisteredUser, verify_phone


async def test_register_returns_session_and_user(
    client: AsyncClient, sms: FakeSmsSender, marta: RegisteredUser
) -> None:
    assert marta.body["user"]["name"] == "Marta"
    assert marta.body["user"]["phone"] == "+56987654321"
    assert marta.body["user"]["avatar"] == "indigo"
    assert marta.body["user"]["active_household_id"] is None
    assert marta.body["tokens"]["token_type"] == "bearer"
    assert marta.body["tokens"]["expires_in"] == 900

    me = await client.get("/users/me", headers=marta.headers)
    assert me.status_code == 200
    assert me.json()["id"] == marta.user_id


async def test_register_without_avatar(client: AsyncClient, sms: FakeSmsSender) -> None:
    token = await verify_phone(client, sms, "+56987652222")

    response = await client.post(
        "/auth/register",
        json={"verification_token": token, "password": DEFAULT_PASSWORD, "name": "  Iván  "},
    )

    assert response.status_code == 201
    assert response.json()["user"]["avatar"] is None
    assert response.json()["user"]["name"] == "Iván"


async def test_register_rejects_weak_password(client: AsyncClient, sms: FakeSmsSender) -> None:
    token = await verify_phone(client, sms, "+56987652222")

    response = await client.post(
        "/auth/register", json={"verification_token": token, "password": "weakpass", "name": "Lu"}
    )

    assert response.status_code == 422
    field = response.json()["error"]["details"]["fields"][0]
    assert field["field"] == "body.password"
    assert field["code"] == "password_missing_uppercase"


async def test_verification_token_is_single_use(client: AsyncClient, sms: FakeSmsSender) -> None:
    token = await verify_phone(client, sms, "+56987652222")
    payload = {"verification_token": token, "password": DEFAULT_PASSWORD, "name": "Lu"}
    await client.post("/auth/register", json=payload)

    reused = await client.post("/auth/register", json=payload)

    assert reused.status_code == 401
    assert reused.json()["error"]["code"] == "INVALID_VERIFICATION_TOKEN"


async def test_reset_token_cannot_register(
    client: AsyncClient, sms: FakeSmsSender, marta: RegisteredUser
) -> None:
    token = await verify_phone(client, sms, marta.phone, purpose="password_reset")

    response = await client.post(
        "/auth/register",
        json={"verification_token": token, "password": DEFAULT_PASSWORD, "name": "Otra"},
    )

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "INVALID_VERIFICATION_TOKEN"


async def test_login_success(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.post(
        "/auth/login", json={"phone": "+56 9 8765 4321", "password": marta.password}
    )

    assert response.status_code == 200
    assert response.json()["user"]["id"] == marta.user_id


async def test_login_failures_report_remaining_attempts_then_lock(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    credentials = {"phone": marta.phone, "password": "Wrong123"}
    remaining = []
    for _ in range(4):
        response = await client.post("/auth/login", json=credentials)
        assert response.status_code == 401
        assert response.json()["error"]["code"] == "INVALID_CREDENTIALS"
        remaining.append(response.json()["error"]["details"]["remaining_attempts"])

    locking = await client.post("/auth/login", json=credentials)
    while_locked = await client.post(
        "/auth/login", json={"phone": marta.phone, "password": marta.password}
    )

    assert remaining == [4, 3, 2, 1]
    assert locking.status_code == 423
    assert locking.json()["error"]["code"] == "ACCOUNT_LOCKED"
    assert while_locked.status_code == 423
    assert while_locked.json()["error"]["details"]["retry_after_seconds"] > 0
    assert int(while_locked.headers["Retry-After"]) > 0


async def test_login_unknown_phone_looks_like_wrong_password(client: AsyncClient) -> None:
    response = await client.post(
        "/auth/login", json={"phone": "+56987653333", "password": DEFAULT_PASSWORD}
    )

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "INVALID_CREDENTIALS"
    assert response.json()["error"]["details"]["remaining_attempts"] == 4


async def test_successful_login_resets_failures(client: AsyncClient, marta: RegisteredUser) -> None:
    await client.post("/auth/login", json={"phone": marta.phone, "password": "Wrong123"})
    await client.post("/auth/login", json={"phone": marta.phone, "password": marta.password})

    response = await client.post("/auth/login", json={"phone": marta.phone, "password": "Wrong123"})

    assert response.json()["error"]["details"]["remaining_attempts"] == 4


async def test_refresh_rotates_tokens(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.post("/auth/refresh", json={"refresh_token": marta.refresh_token})

    assert response.status_code == 200
    body = response.json()
    assert body["refresh_token"] != marta.refresh_token
    me = await client.get("/users/me", headers={"Authorization": f"Bearer {body['access_token']}"})
    assert me.status_code == 200


async def test_refresh_token_reuse_revokes_session(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    rotated = (
        await client.post("/auth/refresh", json={"refresh_token": marta.refresh_token})
    ).json()

    reuse = await client.post("/auth/refresh", json={"refresh_token": marta.refresh_token})
    after_reuse = await client.post(
        "/auth/refresh", json={"refresh_token": rotated["refresh_token"]}
    )
    access_after_reuse = await client.get(
        "/users/me", headers={"Authorization": f"Bearer {rotated['access_token']}"}
    )

    assert reuse.status_code == 401
    assert reuse.json()["error"]["code"] == "INVALID_REFRESH_TOKEN"
    assert after_reuse.status_code == 401
    assert access_after_reuse.status_code == 401


async def test_unknown_refresh_token(client: AsyncClient) -> None:
    response = await client.post("/auth/refresh", json={"refresh_token": "nope"})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "INVALID_REFRESH_TOKEN"


async def test_logout_revokes_session(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.post(
        "/auth/logout", json={"refresh_token": marta.refresh_token}, headers=marta.headers
    )

    assert response.status_code == 204
    assert (await client.get("/users/me", headers=marta.headers)).status_code == 401
    refreshed = await client.post("/auth/refresh", json={"refresh_token": marta.refresh_token})
    assert refreshed.status_code == 401


async def test_logout_requires_authentication(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.post("/auth/logout", json={"refresh_token": marta.refresh_token})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "UNAUTHENTICATED"


async def test_password_reset_revokes_sessions_and_unlocks(
    client: AsyncClient, sms: FakeSmsSender, marta: RegisteredUser
) -> None:
    for _ in range(5):
        await client.post("/auth/login", json={"phone": marta.phone, "password": "Wrong123"})
    token = await verify_phone(client, sms, marta.phone, purpose="password_reset")

    response = await client.post(
        "/auth/password-reset", json={"verification_token": token, "new_password": "NuevaClave2"}
    )

    assert response.status_code == 200
    assert (await client.get("/users/me", headers=marta.headers)).status_code == 401
    old_password = await client.post(
        "/auth/login", json={"phone": marta.phone, "password": marta.password}
    )
    new_password = await client.post(
        "/auth/login", json={"phone": marta.phone, "password": "NuevaClave2"}
    )
    assert old_password.status_code == 401
    assert new_password.status_code == 200


async def test_protected_route_rejects_invalid_token(client: AsyncClient) -> None:
    response = await client.get("/users/me", headers={"Authorization": "Bearer not-a-jwt"})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "UNAUTHENTICATED"


async def test_login_rate_limit_by_ip(client: AsyncClient) -> None:
    statuses = [
        (
            await client.post(
                "/auth/login", json={"phone": f"+5698765{index:04d}", "password": "Wrong123"}
            )
        ).status_code
        for index in range(11)
    ]

    assert statuses[:10] == [401] * 10
    assert statuses[10] == 429
