from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "8c4a1b9d2e70"
down_revision: str | None = "3f570a949faf"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "households",
        sa.Column("capacity_membership_version", sa.Integer(), server_default="0", nullable=False),
    )
    op.create_table(
        "capacity_distributions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("household_id", sa.Uuid(), nullable=False),
        sa.Column("membership_version", sa.Integer(), nullable=False),
        sa.Column("effective_from", sa.Date(), nullable=False),
        sa.Column("approved_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("approved_by", sa.JSON(), nullable=False),
        sa.Column("allocations", sa.JSON(), nullable=False),
        sa.ForeignKeyConstraint(
            ["household_id"],
            ["households.id"],
            name=op.f("fk_capacity_distributions_household_id_households"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_capacity_distributions")),
    )
    op.create_index(
        "ix_capacity_distributions_history",
        "capacity_distributions",
        ["household_id", "approved_at", "id"],
    )


def downgrade() -> None:
    op.drop_index("ix_capacity_distributions_history", table_name="capacity_distributions")
    op.drop_table("capacity_distributions")
    op.drop_column("households", "capacity_membership_version")
