from typing import Annotated

from fastapi import APIRouter, Query

from app.common.errors import NotFoundError
from app.modules.auth.dependencies import CurrentUser
from app.modules.catalog.data import ACTIVITIES, CATEGORIES, TEMPLATES, TEMPLATES_BY_KEY
from app.modules.catalog.schemas import (
    ActivityResponse,
    TaskCategoryResponse,
    TemplateDetailResponse,
    TemplateSummaryResponse,
)

router = APIRouter()


@router.get("/catalog/task-categories", tags=["Catálogo"])
async def list_task_categories(_: CurrentUser) -> list[TaskCategoryResponse]:
    return [TaskCategoryResponse.of(category) for category in CATEGORIES]


@router.get("/catalog/activities", tags=["Catálogo"])
async def list_activities(
    _: CurrentUser, category_key: Annotated[str | None, Query(max_length=40)] = None
) -> list[ActivityResponse]:
    return [
        ActivityResponse.of(activity)
        for activity in ACTIVITIES
        if category_key is None or activity.category_key == category_key
    ]


@router.get("/household-templates", tags=["Plantillas"])
async def list_household_templates(_: CurrentUser) -> list[TemplateSummaryResponse]:
    return [TemplateSummaryResponse.of(template) for template in TEMPLATES]


@router.get("/household-templates/{template_key}", tags=["Plantillas"])
async def get_household_template(_: CurrentUser, template_key: str) -> TemplateDetailResponse:
    template = TEMPLATES_BY_KEY.get(template_key)
    if template is None:
        raise NotFoundError(message="Template not found.")
    return TemplateDetailResponse.of(template)
