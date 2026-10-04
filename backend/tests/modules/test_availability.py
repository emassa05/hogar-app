from typing import Any

import pytest
from httpx import AsyncClient

from tests.factories import RegisteredUser, create_household


async def test_availability_put_replaces_slots_and_exceptions(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/members/me"
    first = {
        "slots": [{"weekday": 0, "period": "morning"}, {"weekday": 6, "period": "evening"}],
        "exceptions": [{"date": "2026-10-12", "period": None, "available": False}],
    }
    replacement = {
        "slots": [{"weekday": 0, "period": "morning"}],
        "exceptions": [{"date": "2026-10-13", "period": "afternoon", "available": True}],
    }
    saved = await client.put(f"{path}/availability", json=first, headers=marta.headers)

    response = await client.put(f"{path}/availability", json=replacement, headers=marta.headers)

    assert saved.status_code == response.status_code == 200
    assert response.json() == replacement
    assert (await client.get(f"{path}/profile", headers=marta.headers)).json()[
        "availability"
    ] == replacement


async def test_availability_can_be_cleared(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)
    path = f"/households/{household['id']}/members/me"
    await client.put(
        f"{path}/availability",
        json={"slots": [{"weekday": 0, "period": "morning"}], "exceptions": []},
        headers=marta.headers,
    )

    response = await client.put(
        f"{path}/availability", json={"slots": [], "exceptions": []}, headers=marta.headers
    )

    assert response.status_code == 200
    assert (await client.get(f"{path}/profile", headers=marta.headers)).json()["availability"] == {
        "slots": [],
        "exceptions": [],
    }


async def test_duplicate_slots_are_rejected(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)
    slot = {"weekday": 0, "period": "morning"}

    response = await client.put(
        f"/households/{household['id']}/members/me/availability",
        json={"slots": [slot, slot], "exceptions": []},
        headers=marta.headers,
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0]["code"] == "duplicated"


@pytest.mark.parametrize(
    "periods", [[None, "morning"], ["morning", None], ["morning", "morning"], [None, None]]
)
async def test_overlapping_exceptions_are_rejected(
    client: AsyncClient, marta: RegisteredUser, periods: list[str | None]
) -> None:
    household = await create_household(client, marta)
    exceptions = [
        {"date": "2026-10-12", "period": period, "available": False} for period in periods
    ]

    response = await client.put(
        f"/households/{household['id']}/members/me/availability",
        json={"slots": [], "exceptions": exceptions},
        headers=marta.headers,
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"]["fields"][0]["code"] == "conflicting_values"


async def test_distinct_periods_on_same_day_are_allowed(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    household = await create_household(client, marta)
    payload = {
        "slots": [],
        "exceptions": [
            {"date": "2026-10-12", "period": "morning", "available": False},
            {"date": "2026-10-12", "period": "evening", "available": True},
        ],
    }

    response = await client.put(
        f"/households/{household['id']}/members/me/availability",
        json=payload,
        headers=marta.headers,
    )

    assert response.status_code == 200
    assert response.json() == payload


@pytest.mark.parametrize(
    "slot",
    [
        {"weekday": -1, "period": "morning"},
        {"weekday": 7, "period": "morning"},
        {"weekday": 0, "period": "night"},
    ],
)
async def test_availability_validates_weekday_and_period(
    client: AsyncClient, marta: RegisteredUser, slot: dict[str, Any]
) -> None:
    household = await create_household(client, marta)

    response = await client.put(
        f"/households/{household['id']}/members/me/availability",
        json={"slots": [slot], "exceptions": []},
        headers=marta.headers,
    )

    assert response.status_code == 422


async def test_all_weekly_slots_are_allowed(client: AsyncClient, marta: RegisteredUser) -> None:
    household = await create_household(client, marta)
    slots = [
        {"weekday": day, "period": period}
        for day in range(7)
        for period in ("morning", "afternoon", "evening")
    ]

    response = await client.put(
        f"/households/{household['id']}/members/me/availability",
        json={"slots": slots, "exceptions": []},
        headers=marta.headers,
    )

    assert response.status_code == 200
    assert len(response.json()["slots"]) == 21
