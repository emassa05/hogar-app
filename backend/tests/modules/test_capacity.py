import asyncio
import uuid
from datetime import UTC, date, datetime
from typing import Any

import pytest
from httpx import AsyncClient
from sqlalchemy import select

from app.common.database import get_database
from app.modules.households.capacity_models import CapacityDistribution
from app.modules.households.capacity_service import CapacityService
from app.modules.households.repository import HouseholdRepository
from tests.factories import RegisteredUser, create_household, idempotency_headers, join_household


def allocations(*members: tuple[RegisteredUser, Any]) -> dict[str, Any]:
    return {
        "allocations": [{"user_id": user.user_id, "percent": percent} for user, percent in members]
    }


def freeze_day(monkeypatch: pytest.MonkeyPatch, day: date) -> None:
    monkeypatch.setattr("app.modules.households.capacity_service.today_in", lambda _: day)


async def test_empty_and_upcoming_do_not_fake_current_capacity(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/capacity"
    empty = (await client.get(path, headers=marta.headers)).json()
    assert empty["status"] == "not_configured"
    assert empty["current"] is empty["upcoming"] is None
    assert empty["proposals"][0]["proposed_capacity_percent"] is None
    freeze_day(monkeypatch, date(2026, 10, 7))
    response = await client.post(
        f"{path}/distributions", json=allocations((marta, 100)), headers=idempotency_headers(marta)
    )
    assert response.status_code == 201, response.text
    assert response.json()["effective_from"] == "2026-10-12"
    upcoming = (await client.get(path, headers=marta.headers)).json()
    assert upcoming["status"] == "not_configured"
    assert upcoming["current"] is None
    assert upcoming["upcoming"] == response.json()
    profile = (
        await client.get(f"/households/{household['id']}/members/me/profile", headers=marta.headers)
    ).json()
    assert profile["approved_capacity_percent"] is None
    freeze_day(monkeypatch, date(2026, 10, 12))
    current = (await client.get(path, headers=marta.headers)).json()
    assert current["status"] == "configured"
    assert current["current"] == response.json()
    assert current["upcoming"] is None
    profile = (
        await client.get(f"/households/{household['id']}/members/me/profile", headers=marta.headers)
    ).json()
    assert profile["approved_capacity_percent"] == 100


@pytest.mark.parametrize(
    ("moment", "timezone", "expected"),
    [
        (datetime(2026, 10, 12, 2, 59, tzinfo=UTC), "America/Santiago", "2026-10-12"),
        (datetime(2026, 10, 12, 3, 0, tzinfo=UTC), "America/Santiago", "2026-10-19"),
        (datetime(2026, 10, 11, 12, 0, tzinfo=UTC), "Pacific/Kiritimati", "2026-10-19"),
        (datetime(2026, 11, 2, 4, 59, tzinfo=UTC), "America/New_York", "2026-11-02"),
        (datetime(2026, 11, 2, 5, 0, tzinfo=UTC), "America/New_York", "2026-11-09"),
    ],
)
async def test_next_monday_uses_local_day_including_dst(
    client: AsyncClient,
    marta: RegisteredUser,
    monkeypatch: pytest.MonkeyPatch,
    moment: datetime,
    timezone: str,
    expected: str,
) -> None:
    household = await create_household(client, marta, timezone=timezone)
    monkeypatch.setattr("app.common.clock.utc_now", lambda: moment)
    response = await client.post(
        f"/households/{household['id']}/capacity/distributions",
        json=allocations((marta, 100)),
        headers=idempotency_headers(marta),
    )
    assert response.status_code == 201, response.text
    assert response.json()["effective_from"] == expected


@pytest.mark.parametrize("percent", [-1, 101, 30.5, "100", True, None])
async def test_approval_rejects_non_integer_or_out_of_range_percent(
    client: AsyncClient, marta: RegisteredUser, percent: Any
) -> None:
    household = await create_household(client, marta)
    response = await client.post(
        f"/households/{household['id']}/capacity/distributions",
        json=allocations((marta, percent)),
        headers=idempotency_headers(marta),
    )
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


@pytest.mark.parametrize("case", ["zero", "sum", "missing", "duplicate", "foreign", "empty"])
async def test_approval_requires_exact_active_set_and_100(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser, case: str
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    payloads = {
        "zero": allocations((marta, 0), (pablo, 0)),
        "sum": allocations((marta, 30), (pablo, 60)),
        "missing": allocations((marta, 100)),
        "duplicate": allocations((marta, 30), (marta, 30), (pablo, 40)),
        "foreign": {"allocations": [{"user_id": str(uuid.uuid4()), "percent": 100}]},
        "empty": {"allocations": []},
    }
    response = await client.post(
        f"/households/{household['id']}/capacity/distributions",
        json=payloads[case],
        headers=idempotency_headers(marta),
    )
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "CAPACITY_SUM_INVALID"
    assert "sum" in response.json()["error"]["details"]
    history = await client.get(
        f"/households/{household['id']}/capacity/distributions", headers=marta.headers
    )
    assert history.json()["items"] == []


async def test_admin_approval_is_separate_from_own_proposals_and_other_profiles(
    client: AsyncClient,
    marta: RegisteredUser,
    pablo: RegisteredUser,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    await client.patch(
        f"/households/{household['id']}/members/me/profile",
        json={"nickname": "P", "proposed_capacity_percent": 80},
        headers=pablo.headers,
    )
    path = f"/households/{household['id']}/capacity"
    payload = allocations((marta, 100), (pablo, 0))
    denied = await client.post(
        f"{path}/distributions", json=payload, headers=idempotency_headers(pablo)
    )
    assert denied.status_code == 403
    assert denied.json()["error"]["code"] == "ADMIN_REQUIRED"
    freeze_day(monkeypatch, date(2026, 10, 7))
    approved = await client.post(
        f"{path}/distributions", json=payload, headers=idempotency_headers(marta)
    )
    assert approved.status_code == 201
    freeze_day(monkeypatch, date(2026, 10, 12))
    profile = (
        await client.get(
            f"/households/{household['id']}/members/{pablo.user_id}/profile", headers=marta.headers
        )
    ).json()
    assert profile["approved_capacity_percent"] == 0
    assert profile["proposed_capacity_percent"] == 80
    assert profile["nickname"] == "P"
    proposals = (await client.get(path, headers=pablo.headers)).json()["proposals"]
    assert (
        next(item for item in proposals if item["member"]["user_id"] == pablo.user_id)[
            "proposed_capacity_percent"
        ]
        == 80
    )
    own = await client.patch(
        f"/households/{household['id']}/members/me/profile",
        json={"proposed_capacity_percent": 50},
        headers=pablo.headers,
    )
    assert own.json()["approved_capacity_percent"] == 0
    assert own.json()["proposed_capacity_percent"] == 50
    denied_profile = await client.patch(
        f"/households/{household['id']}/members/{pablo.user_id}/profile",
        json={"proposed_capacity_percent": 10},
        headers=marta.headers,
    )
    assert denied_profile.status_code == 405


async def test_household_isolation_for_all_capacity_endpoints_and_profiles(
    client: AsyncClient,
    marta: RegisteredUser,
    pablo: RegisteredUser,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    first = await create_household(client, marta)
    second = await create_household(client, pablo)
    path = f"/households/{first['id']}/capacity"
    for suffix in ("", "/distributions"):
        denied = await client.get(path + suffix, headers=pablo.headers)
        assert denied.status_code == 404
        assert denied.json()["error"]["code"] == "HOUSEHOLD_NOT_FOUND"
    denied = await client.post(
        f"{path}/distributions", json=allocations((pablo, 100)), headers=idempotency_headers(pablo)
    )
    assert denied.status_code == 404
    freeze_day(monkeypatch, date(2026, 10, 7))
    await client.post(
        f"{path}/distributions", json=allocations((marta, 100)), headers=idempotency_headers(marta)
    )
    freeze_day(monkeypatch, date(2026, 10, 12))
    second_profile = await client.get(
        f"/households/{second['id']}/members/me/profile", headers=pablo.headers
    )
    assert second_profile.json()["approved_capacity_percent"] is None


async def test_replacement_preserves_current_and_immutable_approval_history(
    client: AsyncClient,
    marta: RegisteredUser,
    pablo: RegisteredUser,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    path = f"/households/{household['id']}/capacity"
    freeze_day(monkeypatch, date(2026, 10, 7))
    first = (
        await client.post(
            f"{path}/distributions",
            json=allocations((marta, 30), (pablo, 70)),
            headers=idempotency_headers(marta),
        )
    ).json()
    replaced = (
        await client.post(
            f"{path}/distributions",
            json=allocations((marta, 40), (pablo, 60)),
            headers=idempotency_headers(marta),
        )
    ).json()
    assert (await client.get(path, headers=marta.headers)).json()["upcoming"] == replaced
    freeze_day(monkeypatch, date(2026, 10, 12))
    third = (
        await client.post(
            f"{path}/distributions",
            json=allocations((marta, 50), (pablo, 50)),
            headers=idempotency_headers(marta),
        )
    ).json()
    overview = (await client.get(path, headers=marta.headers)).json()
    assert overview["current"] == replaced
    assert overview["upcoming"] == third
    history = (await client.get(f"{path}/distributions?limit=1", headers=marta.headers)).json()
    assert history["items"] == [third]
    page2 = (
        await client.get(
            f"{path}/distributions",
            params={"limit": 1, "cursor": history["next_cursor"]},
            headers=marta.headers,
        )
    ).json()
    assert page2["items"] == [replaced]
    page3 = (
        await client.get(
            f"{path}/distributions",
            params={"limit": 1, "cursor": page2["next_cursor"]},
            headers=marta.headers,
        )
    ).json()
    assert page3 == {"items": [first], "next_cursor": None}
    freeze_day(monkeypatch, date(2026, 10, 19))
    assert (await client.get(path, headers=marta.headers)).json()["current"] == third
    assert (await client.get(f"{path}/distributions", headers=marta.headers)).json()["items"] == [
        third,
        replaced,
        first,
    ]


@pytest.mark.parametrize("change", ["join", "leave", "remove", "rejoin"])
async def test_membership_changes_invalidate_without_restoring_old_capacity(
    client: AsyncClient,
    marta: RegisteredUser,
    pablo: RegisteredUser,
    monkeypatch: pytest.MonkeyPatch,
    change: str,
) -> None:
    household = await create_household(client, marta)
    if change != "join":
        await join_household(client, pablo, marta, household["id"])
    path = f"/households/{household['id']}/capacity"
    freeze_day(monkeypatch, date(2026, 10, 7))
    payload = (
        allocations((marta, 100)) if change == "join" else allocations((marta, 40), (pablo, 60))
    )
    first = (
        await client.post(f"{path}/distributions", json=payload, headers=idempotency_headers(marta))
    ).json()
    freeze_day(monkeypatch, date(2026, 10, 12))
    upcoming = (
        await client.post(f"{path}/distributions", json=payload, headers=idempotency_headers(marta))
    ).json()
    if change == "join":
        await join_household(client, pablo, marta, household["id"])
    elif change == "remove":
        assert (
            await client.delete(
                f"/households/{household['id']}/members/{pablo.user_id}", headers=marta.headers
            )
        ).status_code == 204
    else:
        assert (
            await client.post(f"/households/{household['id']}/leave", headers=pablo.headers)
        ).status_code == 204
        if change == "rejoin":
            await join_household(client, pablo, marta, household["id"])
    overview = (await client.get(path, headers=marta.headers)).json()
    assert overview["status"] == "not_configured"
    assert overview["current"] is overview["upcoming"] is None
    profile = (
        await client.get(f"/households/{household['id']}/members/me/profile", headers=marta.headers)
    ).json()
    assert profile["approved_capacity_percent"] is None
    history = (await client.get(f"{path}/distributions", headers=marta.headers)).json()["items"]
    assert [record["id"] for record in history] == [upcoming["id"], first["id"]]
    assert [allocation["percent"] for allocation in history[1]["allocations"]] == [
        allocation["percent"] for allocation in first["allocations"]
    ]
    if change in ("leave", "remove"):
        assert history[0]["allocations"][1]["member"]["is_active"] is False
    if change == "join":
        await client.post(f"/households/{household['id']}/leave", headers=pablo.headers)
        assert (await client.get(path, headers=marta.headers)).json()["current"] is None
    active_two = change == "rejoin"
    new_payload = allocations((marta, 50), (pablo, 50)) if active_two else allocations((marta, 100))
    renewed = await client.post(
        f"{path}/distributions", json=new_payload, headers=idempotency_headers(marta)
    )
    assert renewed.status_code == 201
    assert (await client.get(path, headers=marta.headers)).json()["status"] == "not_configured"
    freeze_day(monkeypatch, date(2026, 10, 19))
    assert (await client.get(path, headers=marta.headers)).json()["current"][
        "id"
    ] == renewed.json()["id"]


async def test_idempotency_same_key_is_one_approval_and_changed_payload_conflicts(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    path = f"/households/{household['id']}/capacity/distributions"
    headers = idempotency_headers(marta)
    payload = allocations((marta, 30), (pablo, 70))
    responses = await asyncio.gather(
        *[client.post(path, json=payload, headers=headers) for _ in range(2)]
    )
    assert all(response.status_code == 201 for response in responses)
    assert responses[0].json() == responses[1].json()
    reused = await client.post(path, json=allocations((marta, 40), (pablo, 60)), headers=headers)
    assert reused.status_code == 409
    assert reused.json()["error"]["code"] == "IDEMPOTENCY_KEY_REUSED"
    assert len((await client.get(path, headers=marta.headers)).json()["items"]) == 1


async def test_concurrent_distinct_approvals_serialize_and_keep_both_history_rows(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    path = f"/households/{household['id']}/capacity"
    responses = await asyncio.gather(
        *[
            client.post(
                f"{path}/distributions",
                json=allocations((marta, percent), (pablo, 100 - percent)),
                headers=idempotency_headers(marta),
            )
            for percent in (30, 40)
        ]
    )
    assert all(response.status_code == 201 for response in responses)
    history = (await client.get(f"{path}/distributions", headers=marta.headers)).json()["items"]
    assert len(history) == 2
    assert (await client.get(path, headers=marta.headers)).json()["upcoming"] == history[0]


async def test_membership_change_serializes_with_approval_on_actual_database(
    client: AsyncClient,
    marta: RegisteredUser,
    pablo: RegisteredUser,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    locked = asyncio.Event()
    release = asyncio.Event()
    original = HouseholdRepository.lock

    async def hold_lock(repository: HouseholdRepository, household_id: uuid.UUID) -> Any:
        result = await original(repository, household_id)
        if not locked.is_set():
            locked.set()
            await release.wait()
        return result

    monkeypatch.setattr(HouseholdRepository, "lock", hold_lock)
    path = f"/households/{household['id']}/capacity"
    approval = asyncio.create_task(
        client.post(
            f"{path}/distributions",
            json=allocations((marta, 40), (pablo, 60)),
            headers=idempotency_headers(marta),
        )
    )
    await asyncio.wait_for(locked.wait(), timeout=5)
    departure = asyncio.create_task(
        client.post(f"/households/{household['id']}/leave", headers=pablo.headers)
    )
    await asyncio.sleep(0.05)
    assert not departure.done()
    release.set()
    approved, left = await asyncio.wait_for(asyncio.gather(approval, departure), timeout=10)
    assert approved.status_code == 201
    assert left.status_code == 204
    assert (await client.get(path, headers=marta.headers)).json()["upcoming"] is None
    async with get_database().session_factory() as session:
        record = await session.scalar(select(CapacityDistribution))
        assert record is not None
        assert len(record.allocations) == 2


@pytest.mark.parametrize("cursor", ["invalid", "e30", "W10"])
async def test_history_rejects_invalid_cursor(
    client: AsyncClient, marta: RegisteredUser, cursor: str
) -> None:
    household = await create_household(client, marta)
    response = await client.get(
        f"/households/{household['id']}/capacity/distributions",
        params={"cursor": cursor},
        headers=marta.headers,
    )
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


async def test_failed_validation_does_not_persist_idempotency_or_partial_approval(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/capacity/distributions"
    headers = idempotency_headers(marta)
    failed = await client.post(path, json=allocations((marta, 0)), headers=headers)
    assert failed.status_code == 422
    success = await client.post(path, json=allocations((marta, 100)), headers=headers)
    assert success.status_code == 201
    assert len((await client.get(path, headers=marta.headers)).json()["items"]) == 1


async def test_approval_rechecks_admin_after_context_was_read(
    client: AsyncClient,
    marta: RegisteredUser,
    pablo: RegisteredUser,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    await client.patch(
        f"/households/{household['id']}/members/{pablo.user_id}",
        json={"role": "admin"},
        headers=marta.headers,
    )
    original = CapacityService.approve

    async def demote_before_approval(service: CapacityService, context: Any, request: Any) -> Any:
        response = await client.patch(
            f"/households/{household['id']}/members/{marta.user_id}",
            json={"role": "member"},
            headers=pablo.headers,
        )
        assert response.status_code == 200
        return await original(service, context, request)

    monkeypatch.setattr(CapacityService, "approve", demote_before_approval)
    response = await client.post(
        f"/households/{household['id']}/capacity/distributions",
        json=allocations((marta, 30), (pablo, 70)),
        headers=idempotency_headers(marta),
    )
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "ADMIN_REQUIRED"


async def test_concurrent_proposal_and_approval_do_not_overwrite_each_other(
    client: AsyncClient, marta: RegisteredUser, pablo: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    await join_household(client, pablo, marta, household["id"])
    base = f"/households/{household['id']}"
    proposed, approved = await asyncio.gather(
        client.patch(
            f"{base}/members/me/profile",
            json={"proposed_capacity_percent": 80},
            headers=pablo.headers,
        ),
        client.post(
            f"{base}/capacity/distributions",
            json=allocations((marta, 40), (pablo, 60)),
            headers=idempotency_headers(marta),
        ),
    )
    assert proposed.status_code == 200
    assert approved.status_code == 201
    overview = (await client.get(f"{base}/capacity", headers=marta.headers)).json()
    assert overview["proposals"][1]["proposed_capacity_percent"] == 80
    assert overview["upcoming"]["allocations"][1]["percent"] == 60


async def test_history_cursor_cannot_be_reused_across_households(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    first = await create_household(client, marta)
    second = await create_household(client, marta)
    path = f"/households/{first['id']}/capacity/distributions"
    for _ in range(2):
        await client.post(path, json=allocations((marta, 100)), headers=idempotency_headers(marta))
    cursor = (await client.get(path, params={"limit": 1}, headers=marta.headers)).json()[
        "next_cursor"
    ]
    response = await client.get(
        f"/households/{second['id']}/capacity/distributions",
        params={"cursor": cursor},
        headers=marta.headers,
    )
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


async def test_approval_failure_after_flush_rolls_back_every_effect(
    client: AsyncClient, marta: RegisteredUser, monkeypatch: pytest.MonkeyPatch
) -> None:
    from app.common.errors import ConflictError

    household = await create_household(client, marta)
    path = f"/households/{household['id']}/capacity/distributions"
    headers = idempotency_headers(marta)
    original = CapacityService.approve

    async def fail_after_flush(service: CapacityService, context: Any, request: Any) -> Any:
        await original(service, context, request)
        raise ConflictError(message="Injected transaction failure.")

    with monkeypatch.context() as patch:
        patch.setattr(CapacityService, "approve", fail_after_flush)
        response = await client.post(path, json=allocations((marta, 100)), headers=headers)
    assert response.status_code == 409
    assert (await client.get(path, headers=marta.headers)).json()["items"] == []
    retry = await client.post(path, json=allocations((marta, 100)), headers=headers)
    assert retry.status_code == 201


async def test_approval_requires_idempotency_key(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    response = await client.post(
        f"/households/{household['id']}/capacity/distributions",
        json=allocations((marta, 100)),
        headers=marta.headers,
    )
    assert response.status_code == 422
