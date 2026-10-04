import uuid
from datetime import datetime

from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.modules.households.models import (
    Household,
    Invitation,
    Membership,
    Role,
    TemplateApplication,
)
from app.modules.users.models import User


class HouseholdRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def add(self, household: Household) -> Household:
        self.session.add(household)
        await self.session.flush()
        return household

    async def add_membership(self, membership: Membership) -> Membership:
        self.session.add(membership)
        await self.session.flush()
        return membership

    async def get(self, household_id: uuid.UUID) -> Household | None:
        return await self.session.get(Household, household_id)

    async def active_membership(
        self, household_id: uuid.UUID, user_id: uuid.UUID
    ) -> Membership | None:
        return await self.session.scalar(
            select(Membership).where(
                Membership.household_id == household_id,
                Membership.user_id == user_id,
                Membership.left_at.is_(None),
            )
        )

    async def memberships_of_user(
        self, user_id: uuid.UUID
    ) -> list[tuple[Household, Membership, int]]:
        member_count = (
            select(func.count(Membership.id))
            .where(Membership.household_id == Household.id, Membership.left_at.is_(None))
            .correlate(Household)
            .scalar_subquery()
        )
        rows = await self.session.execute(
            select(Household, Membership, member_count)
            .join(Membership, Membership.household_id == Household.id)
            .where(Membership.user_id == user_id, Membership.left_at.is_(None))
            .order_by(Membership.joined_at)
        )
        return [(household, membership, int(count)) for household, membership, count in rows]

    async def active_members(self, household_id: uuid.UUID) -> list[tuple[Membership, User]]:
        rows = await self.session.execute(
            select(Membership, User)
            .join(User, User.id == Membership.user_id)
            .where(Membership.household_id == household_id, Membership.left_at.is_(None))
            .order_by(Membership.joined_at)
        )
        return [(membership, user) for membership, user in rows]

    async def count_active_members(self, household_id: uuid.UUID) -> int:
        count = await self.session.scalar(
            select(func.count(Membership.id)).where(
                Membership.household_id == household_id, Membership.left_at.is_(None)
            )
        )
        return int(count or 0)

    async def lock_admin_ids(self, household_id: uuid.UUID) -> list[uuid.UUID]:
        rows = await self.session.scalars(
            select(Membership.user_id)
            .where(
                Membership.household_id == household_id,
                Membership.left_at.is_(None),
                Membership.role == Role.ADMIN,
            )
            .with_for_update()
        )
        return list(rows)

    async def profile_membership(
        self, household_id: uuid.UUID, user_id: uuid.UUID
    ) -> tuple[Membership, User] | None:
        row = (
            await self.session.execute(
                select(Membership, User)
                .join(User, User.id == Membership.user_id)
                .where(
                    Membership.household_id == household_id,
                    Membership.user_id == user_id,
                    Membership.left_at.is_(None),
                )
                .options(
                    selectinload(Membership.availability_slots),
                    selectinload(Membership.availability_exceptions),
                    selectinload(Membership.restrictions),
                    selectinload(Membership.preferred_activities),
                )
                .execution_options(populate_existing=True)
            )
        ).one_or_none()
        return (row[0], row[1]) if row else None

    async def clear_active_household(self, user_id: uuid.UUID, household_id: uuid.UUID) -> None:
        await self.session.execute(
            update(User)
            .where(User.id == user_id, User.active_household_id == household_id)
            .values(active_household_id=None)
        )

    async def active_invitation(self, household_id: uuid.UUID, now: datetime) -> Invitation | None:
        return await self.session.scalar(
            select(Invitation)
            .where(
                Invitation.household_id == household_id,
                Invitation.revoked_at.is_(None),
                Invitation.expires_at > now,
            )
            .order_by(Invitation.created_at.desc())
            .limit(1)
        )

    async def revoke_invitations(self, household_id: uuid.UUID, now: datetime) -> None:
        await self.session.execute(
            update(Invitation)
            .where(Invitation.household_id == household_id, Invitation.revoked_at.is_(None))
            .values(revoked_at=now)
        )

    async def add_invitation(self, invitation: Invitation) -> Invitation:
        self.session.add(invitation)
        await self.session.flush()
        return invitation

    async def code_exists(self, code: str) -> bool:
        return (
            await self.session.scalar(select(Invitation.id).where(Invitation.code == code))
            is not None
        )

    async def invitation_by_code(self, code: str) -> Invitation | None:
        return await self.session.scalar(select(Invitation).where(Invitation.code == code))

    async def template_application(self, household_id: uuid.UUID) -> TemplateApplication | None:
        return await self.session.get(TemplateApplication, household_id)

    async def add_template_application(self, application: TemplateApplication) -> None:
        self.session.add(application)
        await self.session.flush()

    async def user(self, user_id: uuid.UUID) -> User | None:
        return await self.session.get(User, user_id)
