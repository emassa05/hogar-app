import pytest
from httpx import AsyncClient

from tests.factories import RegisteredUser


async def test_categories_have_unique_keys_and_display_names(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    response = await client.get("/catalog/task-categories", headers=marta.headers)

    assert response.status_code == 200
    categories = response.json()
    assert {"key": "food", "name": "Alimentación"} in categories
    assert {"key": "pets", "name": "Mascotas"} in categories
    assert len({category["key"] for category in categories}) == len(categories)
    assert all(set(category) == {"key", "name"} and category["name"] for category in categories)


async def test_activities_reference_existing_categories(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    categories = (await client.get("/catalog/task-categories", headers=marta.headers)).json()

    response = await client.get("/catalog/activities", headers=marta.headers)

    assert response.status_code == 200
    activities = response.json()
    assert {
        "key": "laundry_load",
        "name": "Poner la lavadora",
        "category_key": "laundry",
    } in activities
    assert len({activity["key"] for activity in activities}) == len(activities)
    assert all(
        activity["category_key"] in {category["key"] for category in categories}
        for activity in activities
    )
    assert all(set(activity) == {"key", "name", "category_key"} for activity in activities)


async def test_activities_can_be_filtered_by_category(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    all_activities = (await client.get("/catalog/activities", headers=marta.headers)).json()

    response = await client.get(
        "/catalog/activities", params={"category_key": "laundry"}, headers=marta.headers
    )

    assert response.status_code == 200
    assert response.json() == [
        activity for activity in all_activities if activity["category_key"] == "laundry"
    ]
    assert len(response.json()) == 4


async def test_unknown_category_filter_returns_empty_list(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    response = await client.get(
        "/catalog/activities", params={"category_key": "unknown"}, headers=marta.headers
    )

    assert response.status_code == 200
    assert response.json() == []


async def test_templates_list_has_expected_counts(
    client: AsyncClient, marta: RegisteredUser
) -> None:
    response = await client.get("/household-templates", headers=marta.headers)

    assert response.status_code == 200
    assert {template["key"]: template["task_count"] for template in response.json()} == {
        "family_with_children": 19,
        "shared_flat": 14,
        "couple": 10,
        "care": 12,
        "pets": 6,
    }
    assert all(
        set(template) == {"key", "name", "description", "task_count"}
        for template in response.json()
    )


@pytest.mark.parametrize(
    ("key", "count"),
    [("family_with_children", 19), ("shared_flat", 14), ("couple", 10), ("care", 12), ("pets", 6)],
)
async def test_template_detail_has_displayable_tasks(
    client: AsyncClient, marta: RegisteredUser, key: str, count: int
) -> None:
    activities = {
        activity["key"]: activity
        for activity in (await client.get("/catalog/activities", headers=marta.headers)).json()
    }

    response = await client.get(f"/household-templates/{key}", headers=marta.headers)

    assert response.status_code == 200
    body = response.json()
    assert body["key"] == key
    assert body["task_count"] == len(body["tasks"]) == count
    for task in body["tasks"]:
        assert task["category_key"] == activities[task["activity_key"]]["category_key"]
        assert task["name"] == activities[task["activity_key"]]["name"]
        assert task["recurrence_label"]
        assert task["distribution"] in {"fixed", "rotating"}
        assert task["estimated_duration_minutes"] > 0
        assert 1 <= task["effort"] <= 5
        assert 1 <= task["mental_load"] <= 5


async def test_unknown_template_is_not_found(client: AsyncClient, marta: RegisteredUser) -> None:
    response = await client.get("/household-templates/unknown", headers=marta.headers)

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "NOT_FOUND"


@pytest.mark.parametrize(
    "path",
    [
        "/catalog/task-categories",
        "/catalog/activities",
        "/household-templates",
        "/household-templates/pets",
    ],
)
async def test_catalog_and_templates_require_authentication(client: AsyncClient, path: str) -> None:
    response = await client.get(path)

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "UNAUTHENTICATED"
