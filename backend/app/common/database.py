import uuid
from collections.abc import AsyncIterator
from datetime import datetime
from typing import Annotated, Any, ClassVar

from fastapi import Depends
from sqlalchemy import DateTime, MetaData, func
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

from app.common.config import Settings

NAMING_CONVENTION = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_N_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}


class Base(DeclarativeBase):
    metadata = MetaData(naming_convention=NAMING_CONVENTION)
    type_annotation_map: ClassVar[dict[Any, Any]] = {datetime: DateTime(timezone=True)}


class UuidPrimaryKeyMixin:
    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)


class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now(), onupdate=func.now())


class Database:
    def __init__(self, settings: Settings) -> None:
        self.engine: AsyncEngine = create_async_engine(
            str(settings.database_url),
            pool_size=settings.database_pool_size,
            pool_pre_ping=True,
            echo=settings.database_echo,
        )
        self.session_factory = async_sessionmaker(self.engine, expire_on_commit=False)

    async def dispose(self) -> None:
        await self.engine.dispose()


_database: Database | None = None


def init_database(settings: Settings) -> Database:
    global _database
    _database = Database(settings)
    return _database


def get_database() -> Database:
    if _database is None:
        raise RuntimeError("Database has not been initialised")
    return _database


async def get_session() -> AsyncIterator[AsyncSession]:
    async with get_database().session_factory() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise


SessionDependency = Annotated[AsyncSession, Depends(get_session)]
