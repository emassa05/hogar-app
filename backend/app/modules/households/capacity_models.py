import uuid
from datetime import date, datetime
from typing import Any

from sqlalchemy import JSON, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column

from app.common.database import Base, UuidPrimaryKeyMixin


class CapacityDistribution(UuidPrimaryKeyMixin, Base):
    __tablename__ = "capacity_distributions"
    __table_args__ = (
        Index("ix_capacity_distributions_history", "household_id", "approved_at", "id"),
    )

    household_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("households.id", ondelete="CASCADE"))
    membership_version: Mapped[int]
    replaces_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("capacity_distributions.id"))
    effective_from: Mapped[date]
    approved_at: Mapped[datetime]
    approved_by: Mapped[dict[str, Any]] = mapped_column(JSON)
    allocations: Mapped[list[dict[str, Any]]] = mapped_column(JSON)
