import uuid
from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Path

from app.common.database import SessionDependency
from app.common.dependencies import SettingsDependency
from app.common.idempotency import IdempotencyKeyHeader, run_idempotent
from app.common.rate_limit import RateLimitKey, rate_limit
from app.modules.auth.dependencies import CurrentUser
from app.modules.households.dependencies import HouseholdAccess, resolve_member_id
from app.modules.households.household_service import HouseholdService
from app.modules.households.profile_service import ProfileService
from app.modules.households.schemas import (
    ApplyTemplatesRequest,
    AvailabilitySchema,
    ChangeRoleRequest,
    CreateHouseholdRequest,
    HouseholdDetailResponse,
    HouseholdSummaryResponse,
    InvitationPreviewResponse,
    InvitationResponse,
    MemberProfileResponse,
    MemberResponse,
    PreferencesSchema,
    RestrictionInput,
    RestrictionResponse,
    TemplateApplicationResponse,
    UpdateHouseholdRequest,
    UpdateProfileRequest,
)
from app.modules.households.template_service import TemplateService

households_router = APIRouter(prefix="/households", tags=["Hogares"])
invitations_router = APIRouter(prefix="/invitations", tags=["Invitaciones"])
profiles_router = APIRouter(prefix="/households/{household_id}/members", tags=["Perfiles"])
templates_router = APIRouter(prefix="/households/{household_id}", tags=["Plantillas"])

InvitationCode = Annotated[str, Path(min_length=8, max_length=12)]
MemberReference = Annotated[str, Path(description="UUID del integrante o `me`.")]
invitation_rate_limit = Depends(rate_limit("10/minute", "invitations", RateLimitKey.USER))


@households_router.get("")
async def list_households(
    current_user: CurrentUser, session: SessionDependency, settings: SettingsDependency
) -> list[HouseholdSummaryResponse]:
    return await HouseholdService(session, settings).list_for_user(current_user)


@households_router.post("", status_code=HTTPStatus.CREATED)
async def create_household(
    payload: CreateHouseholdRequest,
    idempotency_key: IdempotencyKeyHeader,
    current_user: CurrentUser,
    session: SessionDependency,
    settings: SettingsDependency,
) -> HouseholdDetailResponse:
    return await run_idempotent(
        session,
        user_id=current_user.id,
        scope="households.create",
        key=idempotency_key,
        request_payload=payload.model_dump(mode="json"),
        response_model=HouseholdDetailResponse,
        operation=lambda: HouseholdService(session, settings).create(current_user, payload),
    )


@households_router.get("/{household_id}")
async def get_household(
    context: HouseholdAccess, session: SessionDependency, settings: SettingsDependency
) -> HouseholdDetailResponse:
    return await HouseholdService(session, settings).detail(
        context.household, context.membership, context.user
    )


@households_router.patch("/{household_id}")
async def update_household(
    payload: UpdateHouseholdRequest,
    context: HouseholdAccess,
    session: SessionDependency,
    settings: SettingsDependency,
) -> HouseholdDetailResponse:
    return await HouseholdService(session, settings).update(context, payload)


@households_router.get("/{household_id}/invitation")
async def get_invitation(
    context: HouseholdAccess, session: SessionDependency, settings: SettingsDependency
) -> InvitationResponse:
    return await HouseholdService(session, settings).current_invitation(context)


@households_router.post("/{household_id}/invitation/regenerate", status_code=HTTPStatus.CREATED)
async def regenerate_invitation(
    context: HouseholdAccess, session: SessionDependency, settings: SettingsDependency
) -> InvitationResponse:
    return await HouseholdService(session, settings).regenerate_invitation(context)


@households_router.patch("/{household_id}/members/{user_id}")
async def change_member_role(
    user_id: uuid.UUID,
    payload: ChangeRoleRequest,
    context: HouseholdAccess,
    session: SessionDependency,
    settings: SettingsDependency,
) -> MemberResponse:
    return await HouseholdService(session, settings).change_role(context, user_id, payload.role)


@households_router.delete("/{household_id}/members/{user_id}", status_code=HTTPStatus.NO_CONTENT)
async def remove_member(
    user_id: uuid.UUID,
    context: HouseholdAccess,
    session: SessionDependency,
    settings: SettingsDependency,
) -> None:
    await HouseholdService(session, settings).remove_member(context, user_id)


@households_router.post("/{household_id}/leave", status_code=HTTPStatus.NO_CONTENT)
async def leave_household(
    context: HouseholdAccess, session: SessionDependency, settings: SettingsDependency
) -> None:
    await HouseholdService(session, settings).leave(context)


@invitations_router.get("/{code}", dependencies=[invitation_rate_limit])
async def preview_invitation(
    code: InvitationCode,
    _: CurrentUser,
    session: SessionDependency,
    settings: SettingsDependency,
) -> InvitationPreviewResponse:
    return await HouseholdService(session, settings).preview_invitation(code)


@invitations_router.post(
    "/{code}/accept", status_code=HTTPStatus.CREATED, dependencies=[invitation_rate_limit]
)
async def accept_invitation(
    code: InvitationCode,
    current_user: CurrentUser,
    session: SessionDependency,
    settings: SettingsDependency,
) -> HouseholdDetailResponse:
    return await HouseholdService(session, settings).accept_invitation(current_user, code)


@profiles_router.get("/{user_id}/profile")
async def get_member_profile(
    user_id: MemberReference, context: HouseholdAccess, session: SessionDependency
) -> MemberProfileResponse:
    return await ProfileService(session).get(context, resolve_member_id(user_id, context))


@profiles_router.patch("/me/profile")
async def update_my_profile(
    payload: UpdateProfileRequest, context: HouseholdAccess, session: SessionDependency
) -> MemberProfileResponse:
    return await ProfileService(session).update(context, payload)


@profiles_router.put("/me/availability")
async def replace_my_availability(
    payload: AvailabilitySchema, context: HouseholdAccess, session: SessionDependency
) -> AvailabilitySchema:
    return await ProfileService(session).replace_availability(context, payload)


@profiles_router.post("/me/restrictions", status_code=HTTPStatus.CREATED)
async def create_my_restriction(
    payload: RestrictionInput, context: HouseholdAccess, session: SessionDependency
) -> RestrictionResponse:
    return await ProfileService(session).create_restriction(context, payload)


@profiles_router.put("/me/restrictions/{restriction_id}")
async def replace_my_restriction(
    restriction_id: uuid.UUID,
    payload: RestrictionInput,
    context: HouseholdAccess,
    session: SessionDependency,
) -> RestrictionResponse:
    return await ProfileService(session).replace_restriction(context, restriction_id, payload)


@profiles_router.delete("/me/restrictions/{restriction_id}", status_code=HTTPStatus.NO_CONTENT)
async def delete_my_restriction(
    restriction_id: uuid.UUID, context: HouseholdAccess, session: SessionDependency
) -> None:
    await ProfileService(session).delete_restriction(context, restriction_id)


@profiles_router.put("/me/preferences")
async def replace_my_preferences(
    payload: PreferencesSchema, context: HouseholdAccess, session: SessionDependency
) -> PreferencesSchema:
    return await ProfileService(session).replace_preferences(context, payload)


@templates_router.get("/template-application")
async def get_template_application(
    context: HouseholdAccess, session: SessionDependency
) -> TemplateApplicationResponse:
    return await TemplateService(session).get(context)


@templates_router.post("/template-application", status_code=HTTPStatus.CREATED)
async def apply_templates(
    payload: ApplyTemplatesRequest,
    idempotency_key: IdempotencyKeyHeader,
    context: HouseholdAccess,
    session: SessionDependency,
) -> TemplateApplicationResponse:
    context.require_admin()
    return await run_idempotent(
        session,
        user_id=context.user.id,
        scope=f"households.{context.household.id}.templates",
        key=idempotency_key,
        request_payload=payload.model_dump(mode="json"),
        response_model=TemplateApplicationResponse,
        operation=lambda: TemplateService(session).apply(context, payload),
    )
