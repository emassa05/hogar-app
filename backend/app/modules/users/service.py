from sqlalchemy.ext.asyncio import AsyncSession

from app.common.errors import ErrorCode, NotFoundError
from app.modules.users.models import User
from app.modules.users.schemas import UpdateUserRequest


class UserService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def update(self, user: User, request: UpdateUserRequest) -> User:
        changes = request.model_dump(exclude_unset=True)
        if changes.get("active_household_id") is not None:
            raise NotFoundError(ErrorCode.HOUSEHOLD_NOT_FOUND, "Household not found.")
        for field, value in changes.items():
            setattr(user, field, value)
        await self.session.commit()
        await self.session.refresh(user)
        return user
