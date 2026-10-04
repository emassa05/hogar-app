import uuid
from dataclasses import dataclass
from typing import Annotated

from fastapi import Depends

from app.common.database import SessionDependency
from app.common.errors import ErrorCode, ForbiddenError, NotFoundError, ValidationFailedError
from app.modules.auth.dependencies import CurrentUser
from app.modules.households.models import Household, Membership, Role
from app.modules.households.repository import HouseholdRepository
from app.modules.users.models import User


@dataclass(frozen=True, slots=True)
class HouseholdContext:
    household: Household
    membership: Membership
    user: User

    @property
    def is_admin(self) -> bool:
        return self.membership.role is Role.ADMIN

    def require_admin(self) -> None:
        if not self.is_admin:
            raise ForbiddenError(ErrorCode.ADMIN_REQUIRED, "Household admin role required.")


def household_not_found() -> NotFoundError:
    return NotFoundError(ErrorCode.HOUSEHOLD_NOT_FOUND, "Household not found.")


async def get_household_context(
    household_id: uuid.UUID, current_user: CurrentUser, session: SessionDependency
) -> HouseholdContext:
    repository = HouseholdRepository(session)
    membership = await repository.active_membership(household_id, current_user.id)
    if membership is None:
        raise household_not_found()
    household = await repository.get(household_id)
    if household is None:
        raise household_not_found()
    return HouseholdContext(household=household, membership=membership, user=current_user)


HouseholdAccess = Annotated[HouseholdContext, Depends(get_household_context)]


def resolve_member_id(raw: str, context: HouseholdContext) -> uuid.UUID:
    if raw == "me":
        return context.user.id
    try:
        return uuid.UUID(raw)
    except ValueError as error:
        raise ValidationFailedError.single(
            "path.user_id", "invalid_format", "Expected a UUID or `me`."
        ) from error
