import uuid
from datetime import date, datetime
from typing import Annotated, Self
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import AfterValidator, Field, StringConstraints, model_validator
from pydantic_core import PydanticCustomError

from app.common.schemas import ApiModel, TrimmedName
from app.modules.households.models import (
    DayPeriod,
    RestrictionKind,
    RestrictionTargetType,
    Role,
)
from app.modules.users.models import Avatar

DEFAULT_TIMEZONE = "America/Santiago"


def _validate_timezone(value: str) -> str:
    try:
        ZoneInfo(value)
    except (ZoneInfoNotFoundError, ValueError) as error:
        raise PydanticCustomError("invalid_choice", "Unknown time zone.") from error
    return value


TimeZoneName = Annotated[str, StringConstraints(max_length=64), AfterValidator(_validate_timezone)]
Nickname = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=40)]
Percent = Annotated[int, Field(ge=0, le=100)]
Weekday = Annotated[int, Field(ge=0, le=6)]
CatalogKey = Annotated[str, StringConstraints(min_length=1, max_length=40)]


class UserReference(ApiModel):
    user_id: uuid.UUID
    display_name: str
    avatar: Avatar | None
    is_active: bool


class CreateHouseholdRequest(ApiModel):
    name: TrimmedName
    timezone: TimeZoneName = DEFAULT_TIMEZONE


class UpdateHouseholdRequest(ApiModel):
    version: int
    name: TrimmedName | None = None
    timezone: TimeZoneName | None = None
    imbalance_threshold_percent: Annotated[int, Field(ge=1, le=100)] | None = None

    @model_validator(mode="after")
    def require_changes(self) -> Self:
        changes = self.model_fields_set - {"version"}
        if not changes:
            raise ValueError("At least one field besides version must be provided.")
        for required in ("name", "timezone"):
            if required in changes and getattr(self, required) is None:
                raise ValueError(f"{required} cannot be null.")
        return self


class HouseholdSummaryResponse(ApiModel):
    id: uuid.UUID
    name: str
    my_role: Role
    member_count: int
    created_at: datetime


class MemberResponse(ApiModel):
    user_id: uuid.UUID
    name: str
    nickname: str | None
    avatar: Avatar | None
    role: Role
    joined_at: datetime
    is_me: bool


class HouseholdDetailResponse(ApiModel):
    id: uuid.UUID
    name: str
    timezone: str
    imbalance_threshold_percent: int | None
    my_role: Role
    members: list[MemberResponse]
    templates_applied: bool
    version: int
    created_at: datetime


class ChangeRoleRequest(ApiModel):
    role: Role


class InvitationResponse(ApiModel):
    code: str
    expires_at: datetime
    share_url: str


class InvitationPreviewResponse(ApiModel):
    household_id: uuid.UUID
    household_name: str
    member_count: int
    expires_at: datetime


class UpdateProfileRequest(ApiModel):
    nickname: Nickname | None = None
    proposed_capacity_percent: Percent | None = None

    @model_validator(mode="after")
    def require_changes(self) -> Self:
        if not self.model_fields_set:
            raise ValueError("At least one field must be provided.")
        return self


class AvailabilitySlotSchema(ApiModel):
    weekday: Weekday
    period: DayPeriod


class AvailabilityExceptionSchema(ApiModel):
    date: date
    period: DayPeriod | None
    available: bool


class AvailabilitySchema(ApiModel):
    slots: Annotated[list[AvailabilitySlotSchema], Field(max_length=21)]
    exceptions: Annotated[list[AvailabilityExceptionSchema], Field(max_length=100)]

    @model_validator(mode="after")
    def reject_duplicates(self) -> Self:
        slots = {(slot.weekday, slot.period) for slot in self.slots}
        if len(slots) != len(self.slots):
            raise PydanticCustomError("duplicated", "Availability slots must be unique.")
        seen: dict[date, set[DayPeriod | None]] = {}
        for exception in self.exceptions:
            periods = seen.setdefault(exception.date, set())
            if (
                exception.period in periods
                or None in periods
                or (exception.period is None and periods)
            ):
                raise PydanticCustomError(
                    "conflicting_values", "Exceptions overlap on the same date."
                )
            periods.add(exception.period)
        return self


class RestrictionTarget(ApiModel):
    type: RestrictionTargetType
    key: CatalogKey


class RestrictionInput(ApiModel):
    target: RestrictionTarget
    kind: RestrictionKind
    starts_on: date | None = None
    ends_on: date | None = None

    @model_validator(mode="after")
    def validate_period(self) -> Self:
        if self.kind is RestrictionKind.PERMANENT and self.ends_on is not None:
            raise PydanticCustomError(
                "conflicting_values", "Permanent restrictions cannot have an end date."
            )
        if self.kind is RestrictionKind.TEMPORARY and self.ends_on is None:
            raise PydanticCustomError("required", "Temporary restrictions need an end date.")
        if self.starts_on and self.ends_on and self.ends_on < self.starts_on:
            raise PydanticCustomError("out_of_range", "End date must not precede the start date.")
        return self


class RestrictionResponse(ApiModel):
    id: uuid.UUID
    target: RestrictionTarget
    target_name: str
    kind: RestrictionKind
    starts_on: date
    ends_on: date | None
    is_active: bool
    created_at: datetime


class PreferencesSchema(ApiModel):
    preferred_activity_keys: Annotated[list[CatalogKey], Field(max_length=50)]

    @model_validator(mode="after")
    def reject_duplicates(self) -> Self:
        if len(set(self.preferred_activity_keys)) != len(self.preferred_activity_keys):
            raise PydanticCustomError("duplicated", "Preferred activities must be unique.")
        return self


class MemberProfileResponse(ApiModel):
    user_id: uuid.UUID
    name: str
    nickname: str | None
    avatar: Avatar | None
    role: Role
    is_me: bool
    proposed_capacity_percent: int | None
    approved_capacity_percent: int | None
    availability: AvailabilitySchema
    restrictions: list[RestrictionResponse]
    preferences: PreferencesSchema


class ApplyTemplatesRequest(ApiModel):
    template_keys: Annotated[list[CatalogKey], Field(max_length=10)]

    @model_validator(mode="after")
    def reject_duplicates(self) -> Self:
        if len(set(self.template_keys)) != len(self.template_keys):
            raise PydanticCustomError("duplicated", "Templates must be unique.")
        return self


class TemplateApplicationResponse(ApiModel):
    template_keys: list[str]
    task_count: int
    applied_by: UserReference
    applied_at: datetime
