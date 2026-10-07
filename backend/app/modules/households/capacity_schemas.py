import uuid
from datetime import date, datetime
from typing import Annotated, Literal

from pydantic import Field

from app.common.schemas import ApiModel
from app.modules.households.schemas import UserReference

CapacityPercent = Annotated[int, Field(strict=True, ge=0, le=100)]


class CapacityAllocationInput(ApiModel):
    user_id: uuid.UUID
    percent: CapacityPercent


class ApproveCapacityRequest(ApiModel):
    allocations: list[CapacityAllocationInput]


class CapacityAllocationResponse(ApiModel):
    member: UserReference
    percent: CapacityPercent


class CapacityDistributionResponse(ApiModel):
    id: uuid.UUID
    effective_from: date
    approved_by: UserReference
    approved_at: datetime
    allocations: list[CapacityAllocationResponse]


class CapacityProposalResponse(ApiModel):
    member: UserReference
    proposed_capacity_percent: CapacityPercent | None


class CapacityOverviewResponse(ApiModel):
    status: Literal["configured", "not_configured"]
    current: CapacityDistributionResponse | None
    upcoming: CapacityDistributionResponse | None
    proposals: list[CapacityProposalResponse]


class CapacityHistoryResponse(ApiModel):
    items: list[CapacityDistributionResponse]
    next_cursor: str | None
