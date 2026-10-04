import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.users.models import Avatar, User


class UserRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get(self, user_id: uuid.UUID) -> User | None:
        return await self.session.get(User, user_id)

    async def get_by_phone(self, phone: str) -> User | None:
        return await self.session.scalar(select(User).where(User.phone == phone))

    async def phone_exists(self, phone: str) -> bool:
        return await self.session.scalar(select(User.id).where(User.phone == phone)) is not None

    async def add(self, phone: str, name: str, avatar: Avatar | None, password_hash: str) -> User:
        user = User(phone=phone, name=name, avatar=avatar, password_hash=password_hash)
        self.session.add(user)
        await self.session.flush()
        await self.session.refresh(user)
        return user
