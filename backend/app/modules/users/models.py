import uuid
from enum import StrEnum

from sqlalchemy import Enum, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.common.database import Base, TimestampMixin, UuidPrimaryKeyMixin


class Avatar(StrEnum):
    INDIGO = "indigo"
    GREEN = "green"
    PEACH = "peach"
    YELLOW = "yellow"
    SKY = "sky"
    PINK = "pink"


class User(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "users"

    phone: Mapped[str] = mapped_column(String(20), unique=True)
    name: Mapped[str] = mapped_column(String(40))
    avatar: Mapped[Avatar | None] = mapped_column(
        Enum(Avatar, name="avatar", values_callable=lambda members: [m.value for m in members])
    )
    password_hash: Mapped[str] = mapped_column(String(255))
    active_household_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("households.id", ondelete="SET NULL")
    )
