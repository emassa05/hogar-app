from http import HTTPStatus

from fastapi import APIRouter

from app.common.database import SessionDependency
from app.common.idempotency import IdempotencyKeyHeader, run_idempotent
from app.common.pagination import CursorQuery, LimitQuery
from app.modules.households.capacity_schemas import (
    ApproveCapacityRequest,
    CapacityDistributionResponse,
    CapacityHistoryResponse,
    CapacityOverviewResponse,
)
from app.modules.households.capacity_service import CapacityService
from app.modules.households.dependencies import HouseholdAccess

router = APIRouter(prefix="/households/{household_id}/capacity", tags=["Capacity"])


@router.get("")
async def get_capacity(
    context: HouseholdAccess, session: SessionDependency
) -> CapacityOverviewResponse:
    return await CapacityService(session).overview(context)


@router.post("/distributions", status_code=HTTPStatus.CREATED)
async def approve_capacity(
    payload: ApproveCapacityRequest,
    idempotency_key: IdempotencyKeyHeader,
    context: HouseholdAccess,
    session: SessionDependency,
) -> CapacityDistributionResponse:
    context.require_admin()
    return await run_idempotent(
        session,
        user_id=context.user.id,
        scope=f"households.{context.household.id}.capacity",
        key=idempotency_key,
        request_payload=payload.model_dump(mode="json"),
        response_model=CapacityDistributionResponse,
        operation=lambda: CapacityService(session).approve(context, payload),
    )


@router.get("/distributions")
async def get_capacity_history(
    context: HouseholdAccess,
    session: SessionDependency,
    cursor: CursorQuery = None,
    limit: LimitQuery = 20,
) -> CapacityHistoryResponse:
    return await CapacityService(session).history(context, cursor, limit)
