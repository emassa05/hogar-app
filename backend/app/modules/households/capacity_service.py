import uuid
from datetime import datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.common.clock import today_in, utc_now
from app.common.errors import ErrorCode, UnprocessableError, ValidationFailedError
from app.common.pagination import decode_cursor, encode_cursor
from app.modules.households.capacity_models import CapacityDistribution
from app.modules.households.capacity_repository import CapacityRepository
from app.modules.households.capacity_schemas import (
    ApproveCapacityRequest,
    CapacityDistributionResponse,
    CapacityHistoryResponse,
    CapacityOverviewResponse,
    CapacityProposalResponse,
)
from app.modules.households.dependencies import HouseholdContext, lock_household_context
from app.modules.households.models import Membership
from app.modules.households.repository import HouseholdRepository
from app.modules.households.schemas import UserReference
from app.modules.users.models import User


class CapacityService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.households = HouseholdRepository(session)
        self.capacities = CapacityRepository(session)

    async def overview(self, context: HouseholdContext) -> CapacityOverviewResponse:
        context = await lock_household_context(context, self.session)
        members = await self.households.active_members(context.household.id)
        active_ids = {user.id for _, user in members}
        today = today_in(context.household.timezone)
        current = await self.capacities.applicable(
            context.household.id,
            context.household.capacity_membership_version,
            today,
            upcoming=False,
        )
        upcoming = await self.capacities.applicable(
            context.household.id,
            context.household.capacity_membership_version,
            today,
            upcoming=True,
        )
        return CapacityOverviewResponse(
            status="configured" if current else "not_configured",
            current=distribution_response(current, active_ids) if current else None,
            upcoming=distribution_response(upcoming, active_ids) if upcoming else None,
            proposals=[
                CapacityProposalResponse(
                    member=member_reference(membership, user),
                    proposed_capacity_percent=membership.proposed_capacity_percent,
                )
                for membership, user in members
            ],
        )

    async def approve(
        self, context: HouseholdContext, request: ApproveCapacityRequest
    ) -> CapacityDistributionResponse:
        context = await lock_household_context(context, self.session)
        context.require_admin()
        members = await self.households.active_members(context.household.id)
        active_ids = {user.id for _, user in members}
        requested_ids = [allocation.user_id for allocation in request.allocations]
        total = sum(allocation.percent for allocation in request.allocations)
        if (
            total != 100
            or set(requested_ids) != active_ids
            or len(requested_ids) != len(active_ids)
        ):
            raise UnprocessableError(
                ErrorCode.CAPACITY_SUM_INVALID,
                "Allocations must include every active member exactly once and sum to 100.",
                details={"sum": total},
            )
        references = {user.id: member_reference(membership, user) for membership, user in members}
        today = today_in(context.household.timezone)
        pending = await self.capacities.applicable(
            context.household.id,
            context.household.capacity_membership_version,
            today,
            upcoming=True,
        )
        distribution = CapacityDistribution(
            replaces_id=pending.id if pending else None,
            id=uuid.uuid4(),
            household_id=context.household.id,
            membership_version=context.household.capacity_membership_version,
            effective_from=today + timedelta(days=7 - today.weekday()),
            approved_at=utc_now(),
            approved_by=references[context.user.id].model_dump(mode="json"),
            allocations=[
                {
                    "member": references[allocation.user_id].model_dump(mode="json"),
                    "percent": allocation.percent,
                }
                for allocation in request.allocations
            ],
        )
        self.session.add(distribution)
        await self.session.flush()
        return distribution_response(distribution, active_ids)

    async def history(
        self, context: HouseholdContext, cursor: str | None, limit: int
    ) -> CapacityHistoryResponse:
        position = None
        if cursor is not None:
            try:
                decoded = decode_cursor(cursor)
                if decoded["household_id"] != str(context.household.id):
                    raise ValueError("Cursor belongs to another household.")
                approved_at = datetime.fromisoformat(decoded["approved_at"])
                if approved_at.tzinfo is None:
                    raise ValueError("Cursor timestamp must include a timezone.")
                position = (approved_at, uuid.UUID(decoded["id"]))
            except (KeyError, ValueError, TypeError) as error:
                raise ValidationFailedError.single(
                    "query.cursor", "invalid_format", "Invalid capacity history cursor."
                ) from error
        records = await self.capacities.history(context.household.id, limit, position)
        members = await self.households.active_members(context.household.id)
        active_ids = {user.id for _, user in members}
        items = records[:limit]
        next_cursor = None
        if len(records) > limit:
            last = items[-1]
            next_cursor = encode_cursor(
                {
                    "household_id": context.household.id,
                    "approved_at": last.approved_at,
                    "id": last.id,
                }
            )
        return CapacityHistoryResponse(
            items=[distribution_response(record, active_ids) for record in items],
            next_cursor=next_cursor,
        )

    async def approved_percent(self, context: HouseholdContext, user_id: uuid.UUID) -> int | None:
        current = await self.capacities.applicable(
            context.household.id,
            context.household.capacity_membership_version,
            today_in(context.household.timezone),
            upcoming=False,
        )
        if current is None:
            return None
        response = CapacityDistributionResponse.model_validate(
            {
                "id": current.id,
                "effective_from": current.effective_from,
                "approved_at": current.approved_at,
                "approved_by": current.approved_by,
                "allocations": current.allocations,
            }
        )
        return next(
            (
                allocation.percent
                for allocation in response.allocations
                if allocation.member.user_id == user_id
            ),
            None,
        )


def member_reference(membership: Membership, user: User) -> UserReference:
    return UserReference(
        user_id=user.id,
        display_name=membership.nickname or user.name,
        avatar=user.avatar,
        is_active=membership.left_at is None,
    )


def distribution_response(
    distribution: CapacityDistribution, active_ids: set[uuid.UUID]
) -> CapacityDistributionResponse:
    response = CapacityDistributionResponse.model_validate(
        {
            "id": distribution.id,
            "effective_from": distribution.effective_from,
            "approved_at": distribution.approved_at,
            "approved_by": distribution.approved_by,
            "allocations": distribution.allocations,
        }
    )
    response.approved_by.is_active = response.approved_by.user_id in active_ids
    for allocation in response.allocations:
        allocation.member.is_active = allocation.member.user_id in active_ids
    return response
