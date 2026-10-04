from pydantic import BaseModel

from app.modules.catalog.data import (
    ACTIVITIES_BY_KEY,
    Activity,
    Distribution,
    HouseholdTemplate,
    TaskCategory,
)


class TaskCategoryResponse(BaseModel):
    key: str
    name: str

    @classmethod
    def of(cls, category: TaskCategory) -> "TaskCategoryResponse":
        return cls(key=category.key, name=category.name)


class ActivityResponse(BaseModel):
    key: str
    name: str
    category_key: str

    @classmethod
    def of(cls, activity: Activity) -> "ActivityResponse":
        return cls(key=activity.key, name=activity.name, category_key=activity.category_key)


class TemplateSummaryResponse(BaseModel):
    key: str
    name: str
    description: str
    task_count: int

    @classmethod
    def of(cls, template: HouseholdTemplate) -> "TemplateSummaryResponse":
        return cls(
            key=template.key,
            name=template.name,
            description=template.description,
            task_count=len(template.tasks),
        )


class TemplateTaskResponse(BaseModel):
    activity_key: str
    name: str
    category_key: str
    recurrence_label: str
    distribution: Distribution
    estimated_duration_minutes: int
    effort: int
    mental_load: int


class TemplateDetailResponse(TemplateSummaryResponse):
    tasks: list[TemplateTaskResponse]

    @classmethod
    def of(cls, template: HouseholdTemplate) -> "TemplateDetailResponse":
        tasks = []
        for task in template.tasks:
            activity = ACTIVITIES_BY_KEY[task.activity_key]
            tasks.append(
                TemplateTaskResponse(
                    activity_key=activity.key,
                    name=activity.name,
                    category_key=activity.category_key,
                    recurrence_label=task.recurrence_label,
                    distribution=task.distribution,
                    estimated_duration_minutes=activity.estimated_duration_minutes,
                    effort=activity.effort,
                    mental_load=activity.mental_load,
                )
            )
        summary = TemplateSummaryResponse.of(template)
        return cls(**summary.model_dump(), tasks=tasks)
