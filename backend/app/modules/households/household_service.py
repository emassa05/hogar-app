import uuid

from sqlalchemy.ext.asyncio import AsyncSession

from app.common.clock import utc_now
from app.common.config import Settings
from app.common.errors import (
    ConflictError,
    ErrorCode,
    GoneError,
    NotFoundError,
    PreconditionFailedError,
)
from app.modules.households.dependencies import HouseholdContext
from app.modules.households.invitation_codes import display_code, generate_code, normalize_code
from app.modules.households.models import Household, Invitation, Membership, Role
from app.modules.households.repository import HouseholdRepository
from app.modules.households.schemas import (
    CreateHouseholdRequest,
    HouseholdDetailResponse,
    HouseholdSummaryResponse,
    InvitationPreviewResponse,
    InvitationResponse,
    MemberResponse,
    UpdateHouseholdRequest,
)
from app.modules.users.models import User

MAX_CODE_ATTEMPTS = 5


class HouseholdService:
    def __init__(self, session: AsyncSession, settings: Settings) -> None:
        self.session = session
        self.settings = settings
        self.households = HouseholdRepository(session)

    async def list_for_user(self, user: User) -> list[HouseholdSummaryResponse]:
        return [
            HouseholdSummaryResponse(
                id=household.id,
                name=household.name,
                my_role=membership.role,
                member_count=member_count,
                created_at=household.created_at,
            )
            for household, membership, member_count in await self.households.memberships_of_user(
                user.id
            )
        ]

    async def create(self, user: User, request: CreateHouseholdRequest) -> HouseholdDetailResponse:
        household = await self.households.add(
            Household(id=uuid.uuid4(), name=request.name, timezone=request.timezone)
        )
        membership = await self.households.add_membership(
            Membership(
                household_id=household.id, user_id=user.id, role=Role.ADMIN, joined_at=utc_now()
            )
        )
        await self._new_invitation(household.id, user.id)
        user.active_household_id = household.id
        await self.session.commit()
        await self.session.refresh(household)
        return await self.detail(household, membership, user)

    async def detail(
        self, household: Household, membership: Membership, user: User
    ) -> HouseholdDetailResponse:
        members = await self.households.active_members(household.id)
        application = await self.households.template_application(household.id)
        return HouseholdDetailResponse(
            id=household.id,
            name=household.name,
            timezone=household.timezone,
            imbalance_threshold_percent=household.imbalance_threshold_percent,
            my_role=membership.role,
            members=[
                member_response(member, member_user, user.id) for member, member_user in members
            ],
            templates_applied=application is not None,
            version=household.version,
            created_at=household.created_at,
        )

    async def update(
        self, context: HouseholdContext, request: UpdateHouseholdRequest
    ) -> HouseholdDetailResponse:
        context.require_admin()
        household = context.household
        if request.version != household.version:
            raise PreconditionFailedError(
                ErrorCode.VERSION_CONFLICT,
                "Household was modified by someone else.",
                details={"current_version": household.version},
            )
        for field, value in request.model_dump(exclude_unset=True, exclude={"version"}).items():
            setattr(household, field, value)
        await self.session.commit()
        await self.session.refresh(household)
        return await self.detail(household, context.membership, context.user)

    async def current_invitation(self, context: HouseholdContext) -> InvitationResponse:
        context.require_admin()
        invitation = await self.households.active_invitation(context.household.id, utc_now())
        if invitation is None:
            invitation = await self._new_invitation(context.household.id, context.user.id)
            await self.session.commit()
        return self._invitation_response(invitation)

    async def regenerate_invitation(self, context: HouseholdContext) -> InvitationResponse:
        context.require_admin()
        await self.households.revoke_invitations(context.household.id, utc_now())
        invitation = await self._new_invitation(context.household.id, context.user.id)
        await self.session.commit()
        return self._invitation_response(invitation)

    async def preview_invitation(self, raw_code: str) -> InvitationPreviewResponse:
        invitation, household = await self._valid_invitation(raw_code)
        return InvitationPreviewResponse(
            household_id=household.id,
            household_name=household.name,
            member_count=await self.households.count_active_members(household.id),
            expires_at=invitation.expires_at,
        )

    async def accept_invitation(self, user: User, raw_code: str) -> HouseholdDetailResponse:
        _, household = await self._valid_invitation(raw_code)
        if await self.households.active_membership(household.id, user.id) is not None:
            raise ConflictError(
                ErrorCode.ALREADY_MEMBER,
                "User already belongs to this household.",
                details={"household_id": str(household.id)},
            )
        membership = await self.households.add_membership(
            Membership(
                household_id=household.id, user_id=user.id, role=Role.MEMBER, joined_at=utc_now()
            )
        )
        user.active_household_id = household.id
        await self.session.commit()
        return await self.detail(household, membership, user)

    async def change_role(
        self, context: HouseholdContext, target_user_id: uuid.UUID, role: Role
    ) -> MemberResponse:
        context.require_admin()
        admin_ids = await self.households.lock_admin_ids(context.household.id)
        target = await self._target_member(context, target_user_id)
        if role is Role.MEMBER and admin_ids == [target_user_id]:
            raise last_admin_error()
        target.role = role
        await self.session.commit()
        target_user = await self.households.user(target_user_id)
        if target_user is None:
            raise member_not_found()
        return member_response(target, target_user, context.user.id)

    async def remove_member(self, context: HouseholdContext, target_user_id: uuid.UUID) -> None:
        context.require_admin()
        if target_user_id == context.user.id:
            raise ConflictError(message="Use the leave endpoint to exit the household.")
        target = await self._target_member(context, target_user_id)
        await self._end_membership(target)
        await self.session.commit()

    async def leave(self, context: HouseholdContext) -> None:
        admin_ids = await self.households.lock_admin_ids(context.household.id)
        if context.is_admin and admin_ids == [context.user.id]:
            raise last_admin_error()
        await self._end_membership(context.membership)
        await self.session.commit()

    async def _end_membership(self, membership: Membership) -> None:
        membership.left_at = utc_now()
        await self.households.clear_active_household(membership.user_id, membership.household_id)

    async def _target_member(self, context: HouseholdContext, user_id: uuid.UUID) -> Membership:
        target = await self.households.active_membership(context.household.id, user_id)
        if target is None:
            raise member_not_found()
        return target

    async def _valid_invitation(self, raw_code: str) -> tuple[Invitation, Household]:
        code = normalize_code(raw_code)
        invitation = await self.households.invitation_by_code(code) if code else None
        if invitation is None or invitation.revoked_at is not None:
            raise NotFoundError(ErrorCode.INVITATION_NOT_FOUND, "Invitation not found.")
        if invitation.expires_at <= utc_now():
            raise GoneError(ErrorCode.INVITATION_EXPIRED, "Invitation has expired.")
        household = await self.households.get(invitation.household_id)
        if household is None:
            raise NotFoundError(ErrorCode.INVITATION_NOT_FOUND, "Invitation not found.")
        return invitation, household

    async def _new_invitation(self, household_id: uuid.UUID, created_by: uuid.UUID) -> Invitation:
        now = utc_now()
        for _ in range(MAX_CODE_ATTEMPTS):
            code = generate_code()
            if not await self.households.code_exists(code):
                return await self.households.add_invitation(
                    Invitation(
                        household_id=household_id,
                        code=code,
                        created_by=created_by,
                        created_at=now,
                        expires_at=now + self.settings.invitation_ttl,
                    )
                )
        raise ConflictError(message="Could not allocate an invitation code.")

    def _invitation_response(self, invitation: Invitation) -> InvitationResponse:
        code = display_code(invitation.code)
        return InvitationResponse(
            code=code,
            expires_at=invitation.expires_at,
            share_url=f"{self.settings.public_base_url.rstrip('/')}/unirse/{code}",
        )


def member_response(membership: Membership, user: User, viewer_id: uuid.UUID) -> MemberResponse:
    return MemberResponse(
        user_id=user.id,
        name=user.name,
        nickname=membership.nickname,
        avatar=user.avatar,
        role=membership.role,
        joined_at=membership.joined_at,
        is_me=user.id == viewer_id,
    )


def last_admin_error() -> ConflictError:
    return ConflictError(
        ErrorCode.LAST_ADMIN_MUST_TRANSFER,
        "The last admin must transfer the role before stepping down.",
    )


def member_not_found() -> NotFoundError:
    return NotFoundError(ErrorCode.MEMBER_NOT_FOUND, "Member not found.")
