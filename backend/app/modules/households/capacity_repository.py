import uuid
from datetime import date, datetime

from sqlalchemy import select, tuple_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import aliased

from app.modules.households.capacity_models import CapacityDistribution


class CapacityRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def applicable(
        self, household_id: uuid.UUID, membership_version: int, today: date, *, upcoming: bool
    ) -> CapacityDistribution | None:
        replacement = aliased(CapacityDistribution)
        return await self.session.scalar(
            select(CapacityDistribution)
            .where(
                CapacityDistribution.household_id == household_id,
                CapacityDistribution.membership_version == membership_version,
                ~select(replacement.id)
                .where(replacement.replaces_id == CapacityDistribution.id)
                .exists(),
                CapacityDistribution.effective_from > today
                if upcoming
                else CapacityDistribution.effective_from <= today,
            )
            .order_by(
                CapacityDistribution.effective_from.desc(),
                CapacityDistribution.approved_at.desc(),
                CapacityDistribution.id.desc(),
            )
            .limit(1)
        )

    async def history(
        self, household_id: uuid.UUID, limit: int, position: tuple[datetime, uuid.UUID] | None
    ) -> list[CapacityDistribution]:
        statement = select(CapacityDistribution).where(
            CapacityDistribution.household_id == household_id
        )
        if position is not None:
            statement = statement.where(
                tuple_(CapacityDistribution.approved_at, CapacityDistribution.id) < position
            )
        result = await self.session.scalars(
            statement.order_by(
                CapacityDistribution.approved_at.desc(), CapacityDistribution.id.desc()
            ).limit(limit + 1)
        )
        return list(result)
