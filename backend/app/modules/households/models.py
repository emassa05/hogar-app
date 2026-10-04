import uuid
from datetime import date, datetime
from enum import StrEnum

from sqlalchemy import (
    JSON,
    CheckConstraint,
    Enum,
    ForeignKey,
    Index,
    SmallInteger,
    String,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.common.database import Base, TimestampMixin, UuidPrimaryKeyMixin


def _enum[EnumT: StrEnum](enum_type: type[EnumT], name: str) -> Enum:
    return Enum(enum_type, name=name, values_callable=lambda members: [m.value for m in members])


class Role(StrEnum):
    ADMIN = "admin"
    MEMBER = "member"


class DayPeriod(StrEnum):
    MORNING = "morning"
    AFTERNOON = "afternoon"
    EVENING = "evening"


class RestrictionTargetType(StrEnum):
    CATEGORY = "category"
    ACTIVITY = "activity"


class RestrictionKind(StrEnum):
    PERMANENT = "permanent"
    TEMPORARY = "temporary"


class Household(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "households"
    __table_args__ = (
        CheckConstraint(
            "imbalance_threshold_percent BETWEEN 1 AND 100", name="imbalance_threshold_range"
        ),
    )

    name: Mapped[str] = mapped_column(String(40))
    timezone: Mapped[str] = mapped_column(String(64))
    imbalance_threshold_percent: Mapped[int | None] = mapped_column(SmallInteger)
    version: Mapped[int] = mapped_column(default=1)

    __mapper_args__ = {"version_id_col": version}  # noqa: RUF012


class Membership(UuidPrimaryKeyMixin, Base):
    __tablename__ = "household_memberships"
    __table_args__ = (
        Index(
            "uq_household_memberships_active",
            "household_id",
            "user_id",
            unique=True,
            postgresql_where=text("left_at IS NULL"),
        ),
        CheckConstraint(
            "proposed_capacity_percent BETWEEN 0 AND 100", name="proposed_capacity_range"
        ),
    )

    household_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("households.id", ondelete="CASCADE"), index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    role: Mapped[Role] = mapped_column(_enum(Role, "household_role"))
    nickname: Mapped[str | None] = mapped_column(String(40))
    proposed_capacity_percent: Mapped[int | None] = mapped_column(SmallInteger)
    joined_at: Mapped[datetime]
    left_at: Mapped[datetime | None]

    availability_slots: Mapped[list["AvailabilitySlot"]] = relationship(
        cascade="all, delete-orphan", lazy="raise"
    )
    availability_exceptions: Mapped[list["AvailabilityException"]] = relationship(
        cascade="all, delete-orphan", lazy="raise", order_by="AvailabilityException.date"
    )
    restrictions: Mapped[list["Restriction"]] = relationship(
        cascade="all, delete-orphan", lazy="raise", order_by="Restriction.created_at"
    )
    preferred_activities: Mapped[list["PreferredActivity"]] = relationship(
        cascade="all, delete-orphan", lazy="raise"
    )


class Invitation(UuidPrimaryKeyMixin, Base):
    __tablename__ = "household_invitations"

    household_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("households.id", ondelete="CASCADE"), index=True
    )
    code: Mapped[str] = mapped_column(String(8), unique=True)
    created_by: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    created_at: Mapped[datetime]
    expires_at: Mapped[datetime]
    revoked_at: Mapped[datetime | None]


class AvailabilitySlot(Base):
    __tablename__ = "member_availability_slots"

    membership_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("household_memberships.id", ondelete="CASCADE"), primary_key=True
    )
    weekday: Mapped[int] = mapped_column(SmallInteger, primary_key=True)
    period: Mapped[DayPeriod] = mapped_column(_enum(DayPeriod, "day_period"), primary_key=True)


class AvailabilityException(UuidPrimaryKeyMixin, Base):
    __tablename__ = "member_availability_exceptions"

    membership_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("household_memberships.id", ondelete="CASCADE"), index=True
    )
    date: Mapped[date]
    period: Mapped[DayPeriod | None] = mapped_column(_enum(DayPeriod, "day_period"))
    available: Mapped[bool]


class Restriction(UuidPrimaryKeyMixin, Base):
    __tablename__ = "member_restrictions"

    membership_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("household_memberships.id", ondelete="CASCADE"), index=True
    )
    target_type: Mapped[RestrictionTargetType] = mapped_column(
        _enum(RestrictionTargetType, "restriction_target_type")
    )
    target_key: Mapped[str] = mapped_column(String(40))
    kind: Mapped[RestrictionKind] = mapped_column(_enum(RestrictionKind, "restriction_kind"))
    starts_on: Mapped[date]
    ends_on: Mapped[date | None]
    created_at: Mapped[datetime]


class PreferredActivity(Base):
    __tablename__ = "member_preferred_activities"

    membership_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("household_memberships.id", ondelete="CASCADE"), primary_key=True
    )
    activity_key: Mapped[str] = mapped_column(String(40), primary_key=True)


class TemplateApplication(Base):
    __tablename__ = "household_template_applications"

    household_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("households.id", ondelete="CASCADE"), primary_key=True
    )
    template_keys: Mapped[list[str]] = mapped_column(JSON)
    task_count: Mapped[int]
    applied_by: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    applied_at: Mapped[datetime]
