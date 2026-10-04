from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.clock import utc_now
from app.common.errors import ConflictError, ErrorCode, NotFoundError, ValidationFailedError
from app.modules.catalog.data import TEMPLATES_BY_KEY
from app.modules.households.dependencies import HouseholdContext
from app.modules.households.models import Membership, TemplateApplication
from app.modules.households.repository import HouseholdRepository
from app.modules.households.schemas import (
    ApplyTemplatesRequest,
    TemplateApplicationResponse,
    UserReference,
)
from app.modules.users.models import User


def templates_already_applied() -> ConflictError:
    return ConflictError(
        ErrorCode.TEMPLATES_ALREADY_APPLIED, "Templates were already decided for this household."
    )


class TemplateService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.households = HouseholdRepository(session)

    async def get(self, context: HouseholdContext) -> TemplateApplicationResponse:
        application = await self.households.template_application(context.household.id)
        if application is None:
            raise NotFoundError(message="Templates have not been decided yet.")
        return await self._response(context, application)

    async def apply(
        self, context: HouseholdContext, request: ApplyTemplatesRequest
    ) -> TemplateApplicationResponse:
        context.require_admin()
        for index, key in enumerate(request.template_keys):
            if key not in TEMPLATES_BY_KEY:
                raise ValidationFailedError.single(
                    f"body.template_keys.{index}", "unknown_key", "Unknown template."
                )
        if await self.households.template_application(context.household.id) is not None:
            raise templates_already_applied()

        application = TemplateApplication(
            household_id=context.household.id,
            template_keys=list(request.template_keys),
            task_count=sum(len(TEMPLATES_BY_KEY[key].tasks) for key in request.template_keys),
            applied_by=context.user.id,
            applied_at=utc_now(),
        )
        try:
            await self.households.add_template_application(application)
        except IntegrityError as error:
            raise templates_already_applied() from error
        await self.session.commit()
        return await self._response(context, application)

    async def _response(
        self, context: HouseholdContext, application: TemplateApplication
    ) -> TemplateApplicationResponse:
        applied_by = await self.households.user(application.applied_by)
        membership = await self.households.active_membership(
            context.household.id, application.applied_by
        )
        return TemplateApplicationResponse(
            template_keys=application.template_keys,
            task_count=application.task_count,
            applied_by=user_reference(applied_by, membership),
            applied_at=application.applied_at,
        )


def user_reference(user: User | None, membership: Membership | None) -> UserReference:
    if user is None:
        raise NotFoundError(ErrorCode.MEMBER_NOT_FOUND, "Member not found.")
    return UserReference(
        user_id=user.id,
        display_name=(membership.nickname if membership and membership.nickname else user.name),
        avatar=user.avatar,
        is_active=membership is not None,
    )
