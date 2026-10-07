from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "c3f8a6b2d901"
down_revision: str | None = "8c4a1b9d2e70"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column("capacity_distributions", sa.Column("replaces_id", sa.Uuid(), nullable=True))
    op.create_foreign_key(
        op.f("fk_capacity_distributions_replaces_id_capacity_distributions"),
        "capacity_distributions",
        "capacity_distributions",
        ["replaces_id"],
        ["id"],
    )


def downgrade() -> None:
    op.drop_constraint(
        op.f("fk_capacity_distributions_replaces_id_capacity_distributions"),
        "capacity_distributions",
        type_="foreignkey",
    )
    op.drop_column("capacity_distributions", "replaces_id")
