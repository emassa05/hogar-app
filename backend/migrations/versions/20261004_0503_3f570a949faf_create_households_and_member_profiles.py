"""create households and member profiles

Revision ID: 3f570a949faf
Revises: a536c7ba7874
Create Date: 2026-10-04 05:03:37.895406+00:00

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "3f570a949faf"
down_revision: str | None = "a536c7ba7874"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "households",
        sa.Column("name", sa.String(length=40), nullable=False),
        sa.Column("timezone", sa.String(length=64), nullable=False),
        sa.Column("imbalance_threshold_percent", sa.SmallInteger(), nullable=True),
        sa.Column("version", sa.Integer(), nullable=False),
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "imbalance_threshold_percent BETWEEN 1 AND 100",
            name=op.f("ck_households_imbalance_threshold_range"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_households")),
    )
    op.create_table(
        "household_invitations",
        sa.Column("household_id", sa.Uuid(), nullable=False),
        sa.Column("code", sa.String(length=8), nullable=False),
        sa.Column("created_by", sa.Uuid(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(
            ["created_by"],
            ["users.id"],
            name=op.f("fk_household_invitations_created_by_users"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["household_id"],
            ["households.id"],
            name=op.f("fk_household_invitations_household_id_households"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_household_invitations")),
        sa.UniqueConstraint("code", name=op.f("uq_household_invitations_code")),
    )
    op.create_index(
        op.f("ix_household_invitations_household_id"),
        "household_invitations",
        ["household_id"],
        unique=False,
    )
    op.create_table(
        "household_memberships",
        sa.Column("household_id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("role", sa.Enum("admin", "member", name="household_role"), nullable=False),
        sa.Column("nickname", sa.String(length=40), nullable=True),
        sa.Column("proposed_capacity_percent", sa.SmallInteger(), nullable=True),
        sa.Column("joined_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("left_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.CheckConstraint(
            "proposed_capacity_percent BETWEEN 0 AND 100",
            name=op.f("ck_household_memberships_proposed_capacity_range"),
        ),
        sa.ForeignKeyConstraint(
            ["household_id"],
            ["households.id"],
            name=op.f("fk_household_memberships_household_id_households"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_household_memberships_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_household_memberships")),
    )
    op.create_index(
        op.f("ix_household_memberships_household_id"),
        "household_memberships",
        ["household_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_household_memberships_user_id"), "household_memberships", ["user_id"], unique=False
    )
    op.create_index(
        "uq_household_memberships_active",
        "household_memberships",
        ["household_id", "user_id"],
        unique=True,
        postgresql_where=sa.text("left_at IS NULL"),
    )
    op.create_table(
        "household_template_applications",
        sa.Column("household_id", sa.Uuid(), nullable=False),
        sa.Column("template_keys", sa.JSON(), nullable=False),
        sa.Column("task_count", sa.Integer(), nullable=False),
        sa.Column("applied_by", sa.Uuid(), nullable=False),
        sa.Column("applied_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["applied_by"],
            ["users.id"],
            name=op.f("fk_household_template_applications_applied_by_users"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["household_id"],
            ["households.id"],
            name=op.f("fk_household_template_applications_household_id_households"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("household_id", name=op.f("pk_household_template_applications")),
    )
    op.create_table(
        "member_availability_exceptions",
        sa.Column("membership_id", sa.Uuid(), nullable=False),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column(
            "period", sa.Enum("morning", "afternoon", "evening", name="day_period"), nullable=True
        ),
        sa.Column("available", sa.Boolean(), nullable=False),
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(
            ["membership_id"],
            ["household_memberships.id"],
            name=op.f("fk_member_availability_exceptions_membership_id_household_memberships"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_member_availability_exceptions")),
    )
    op.create_index(
        op.f("ix_member_availability_exceptions_membership_id"),
        "member_availability_exceptions",
        ["membership_id"],
        unique=False,
    )
    op.create_table(
        "member_availability_slots",
        sa.Column("membership_id", sa.Uuid(), nullable=False),
        sa.Column("weekday", sa.SmallInteger(), nullable=False),
        sa.Column(
            "period", sa.Enum("morning", "afternoon", "evening", name="day_period"), nullable=False
        ),
        sa.ForeignKeyConstraint(
            ["membership_id"],
            ["household_memberships.id"],
            name=op.f("fk_member_availability_slots_membership_id_household_memberships"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint(
            "membership_id", "weekday", "period", name=op.f("pk_member_availability_slots")
        ),
    )
    op.create_table(
        "member_preferred_activities",
        sa.Column("membership_id", sa.Uuid(), nullable=False),
        sa.Column("activity_key", sa.String(length=40), nullable=False),
        sa.ForeignKeyConstraint(
            ["membership_id"],
            ["household_memberships.id"],
            name=op.f("fk_member_preferred_activities_membership_id_household_memberships"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint(
            "membership_id", "activity_key", name=op.f("pk_member_preferred_activities")
        ),
    )
    op.create_table(
        "member_restrictions",
        sa.Column("membership_id", sa.Uuid(), nullable=False),
        sa.Column(
            "target_type",
            sa.Enum("category", "activity", name="restriction_target_type"),
            nullable=False,
        ),
        sa.Column("target_key", sa.String(length=40), nullable=False),
        sa.Column(
            "kind", sa.Enum("permanent", "temporary", name="restriction_kind"), nullable=False
        ),
        sa.Column("starts_on", sa.Date(), nullable=False),
        sa.Column("ends_on", sa.Date(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(
            ["membership_id"],
            ["household_memberships.id"],
            name=op.f("fk_member_restrictions_membership_id_household_memberships"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_member_restrictions")),
    )
    op.create_index(
        op.f("ix_member_restrictions_membership_id"),
        "member_restrictions",
        ["membership_id"],
        unique=False,
    )
    op.create_foreign_key(
        op.f("fk_users_active_household_id_households"),
        "users",
        "households",
        ["active_household_id"],
        ["id"],
        ondelete="SET NULL",
    )


def downgrade() -> None:
    op.drop_constraint(op.f("fk_users_active_household_id_households"), "users", type_="foreignkey")
    op.drop_index(op.f("ix_member_restrictions_membership_id"), table_name="member_restrictions")
    op.drop_table("member_restrictions")
    op.drop_table("member_preferred_activities")
    op.drop_table("member_availability_slots")
    op.drop_index(
        op.f("ix_member_availability_exceptions_membership_id"),
        table_name="member_availability_exceptions",
    )
    op.drop_table("member_availability_exceptions")
    op.drop_table("household_template_applications")
    op.drop_index(
        "uq_household_memberships_active",
        table_name="household_memberships",
        postgresql_where=sa.text("left_at IS NULL"),
    )
    op.drop_index(op.f("ix_household_memberships_user_id"), table_name="household_memberships")
    op.drop_index(op.f("ix_household_memberships_household_id"), table_name="household_memberships")
    op.drop_table("household_memberships")
    op.drop_index(op.f("ix_household_invitations_household_id"), table_name="household_invitations")
    op.drop_table("household_invitations")
    op.drop_table("households")
    for enum_name in (
        "household_role",
        "day_period",
        "restriction_target_type",
        "restriction_kind",
    ):
        op.execute(f"DROP TYPE IF EXISTS {enum_name}")
