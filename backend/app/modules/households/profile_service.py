import uuid
from datetime import date

from sqlalchemy.ext.asyncio import AsyncSession

from app.common.clock import today_in, utc_now
from app.common.errors import ConflictError, ErrorCode, NotFoundError, ValidationFailedError
from app.modules.catalog.data import ACTIVITIES_BY_KEY, CATEGORIES_BY_KEY
from app.modules.households.capacity_service import CapacityService
from app.modules.households.dependencies import HouseholdContext, lock_household_context
from app.modules.households.models import (
    AvailabilityException,
    AvailabilitySlot,
    Membership,
    PreferredActivity,
    Restriction,
    RestrictionTargetType,
)
from app.modules.households.repository import HouseholdRepository
from app.modules.households.schemas import (
    AvailabilityExceptionSchema,
    AvailabilitySchema,
    AvailabilitySlotSchema,
    MemberProfileResponse,
    PreferencesSchema,
    RestrictionInput,
    RestrictionResponse,
    RestrictionTarget,
    UpdateProfileRequest,
)
from app.modules.users.models import User


class ProfileService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.households = HouseholdRepository(session)

    async def get(self, context: HouseholdContext, user_id: uuid.UUID) -> MemberProfileResponse:
        context = await lock_household_context(context, self.session)
        membership, user = await self._load(context, user_id)
        approved_percent = await CapacityService(self.session).approved_percent(context, user_id)
        return self._response(context, membership, user, approved_percent)

    async def update(
        self, context: HouseholdContext, request: UpdateProfileRequest
    ) -> MemberProfileResponse:
        context = await lock_household_context(context, self.session)
        membership = context.membership
        for field, value in request.model_dump(exclude_unset=True).items():
            setattr(membership, field, value)
        await self.session.commit()
        return await self.get(context, context.user.id)

    async def replace_availability(
        self, context: HouseholdContext, availability: AvailabilitySchema
    ) -> AvailabilitySchema:
        membership, _ = await self._load(context, context.user.id)
        membership.availability_slots = [
            AvailabilitySlot(weekday=slot.weekday, period=slot.period)
            for slot in availability.slots
        ]
        membership.availability_exceptions = [
            AvailabilityException(
                date=exception.date, period=exception.period, available=exception.available
            )
            for exception in availability.exceptions
        ]
        await self.session.commit()
        membership, _ = await self._load(context, context.user.id)
        return availability_schema(membership)

    async def create_restriction(
        self, context: HouseholdContext, request: RestrictionInput
    ) -> RestrictionResponse:
        target_name = self._target_name(request.target)
        membership, _ = await self._load(context, context.user.id)
        starts_on = self._start_date(context, request)
        restriction = Restriction(
            target_type=request.target.type,
            target_key=request.target.key,
            kind=request.kind,
            starts_on=starts_on,
            ends_on=request.ends_on,
            created_at=utc_now(),
        )
        self._ensure_no_overlap(context, membership, restriction)
        membership.restrictions.append(restriction)
        await self.session.commit()
        return restriction_response(restriction, target_name, context.household.timezone)

    async def replace_restriction(
        self, context: HouseholdContext, restriction_id: uuid.UUID, request: RestrictionInput
    ) -> RestrictionResponse:
        target_name = self._target_name(request.target)
        membership, _ = await self._load(context, context.user.id)
        restriction = self._owned_restriction(membership, restriction_id)
        starts_on = self._start_date(context, request)
        restriction.target_type = request.target.type
        restriction.target_key = request.target.key
        restriction.kind = request.kind
        restriction.starts_on = starts_on
        restriction.ends_on = request.ends_on
        self._ensure_no_overlap(context, membership, restriction)
        await self.session.commit()
        return restriction_response(restriction, target_name, context.household.timezone)

    async def delete_restriction(
        self, context: HouseholdContext, restriction_id: uuid.UUID
    ) -> None:
        membership, _ = await self._load(context, context.user.id)
        membership.restrictions.remove(self._owned_restriction(membership, restriction_id))
        await self.session.commit()

    async def replace_preferences(
        self, context: HouseholdContext, preferences: PreferencesSchema
    ) -> PreferencesSchema:
        membership, _ = await self._load(context, context.user.id)
        today = today_in(context.household.timezone)
        for index, key in enumerate(preferences.preferred_activity_keys):
            activity = ACTIVITIES_BY_KEY.get(key)
            field = f"body.preferred_activity_keys.{index}"
            if activity is None:
                raise ValidationFailedError.single(field, "unknown_key", "Unknown activity.")
            if any(
                is_active(restriction, today) and restricts_activity(restriction, key)
                for restriction in membership.restrictions
            ):
                raise ValidationFailedError.single(
                    field, "conflicting_values", "Activity is restricted for this member."
                )
        membership.preferred_activities = [
            PreferredActivity(activity_key=key) for key in preferences.preferred_activity_keys
        ]
        await self.session.commit()
        return preferences

    async def _load(self, context: HouseholdContext, user_id: uuid.UUID) -> tuple[Membership, User]:
        loaded = await self.households.profile_membership(context.household.id, user_id)
        if loaded is None:
            raise NotFoundError(ErrorCode.MEMBER_NOT_FOUND, "Member not found.")
        return loaded

    def _response(
        self,
        context: HouseholdContext,
        membership: Membership,
        user: User,
        approved_percent: int | None,
    ) -> MemberProfileResponse:
        timezone = context.household.timezone
        return MemberProfileResponse(
            user_id=user.id,
            name=user.name,
            nickname=membership.nickname,
            avatar=user.avatar,
            role=membership.role,
            is_me=user.id == context.user.id,
            proposed_capacity_percent=membership.proposed_capacity_percent,
            approved_capacity_percent=approved_percent,
            availability=availability_schema(membership),
            restrictions=[
                restriction_response(
                    restriction,
                    self._target_name(
                        RestrictionTarget(type=restriction.target_type, key=restriction.target_key)
                    ),
                    timezone,
                )
                for restriction in membership.restrictions
            ],
            preferences=PreferencesSchema(
                preferred_activity_keys=sorted(
                    preferred.activity_key for preferred in membership.preferred_activities
                )
            ),
        )

    @staticmethod
    def _target_name(target: RestrictionTarget) -> str:
        catalog = (
            CATEGORIES_BY_KEY
            if target.type is RestrictionTargetType.CATEGORY
            else ACTIVITIES_BY_KEY
        )
        entry = catalog.get(target.key)
        if entry is None:
            raise ValidationFailedError.single(
                "body.target.key", "unknown_key", "Unknown catalog key."
            )
        return entry.name

    @staticmethod
    def _start_date(context: HouseholdContext, request: RestrictionInput) -> date:
        starts_on = request.starts_on or today_in(context.household.timezone)
        if request.ends_on is not None and request.ends_on < starts_on:
            raise ValidationFailedError.single(
                "body.ends_on", "out_of_range", "End date must not precede the start date."
            )
        return starts_on

    @staticmethod
    def _owned_restriction(membership: Membership, restriction_id: uuid.UUID) -> Restriction:
        for restriction in membership.restrictions:
            if restriction.id == restriction_id:
                return restriction
        raise NotFoundError(message="Restriction not found.")

    @staticmethod
    def _ensure_no_overlap(
        context: HouseholdContext, membership: Membership, candidate: Restriction
    ) -> None:
        today = today_in(context.household.timezone)
        for existing in membership.restrictions:
            if (
                existing is not candidate
                and existing.target_type is candidate.target_type
                and existing.target_key == candidate.target_key
                and is_active(existing, today)
            ):
                raise ConflictError(message="An active restriction already targets this item.")


def is_active(restriction: Restriction, today: date) -> bool:
    return restriction.starts_on <= today and (
        restriction.ends_on is None or restriction.ends_on >= today
    )


def restricts_activity(restriction: Restriction, activity_key: str) -> bool:
    if restriction.target_type is RestrictionTargetType.ACTIVITY:
        return restriction.target_key == activity_key
    activity = ACTIVITIES_BY_KEY.get(activity_key)
    return activity is not None and activity.category_key == restriction.target_key


def availability_schema(membership: Membership) -> AvailabilitySchema:
    return AvailabilitySchema(
        slots=[
            AvailabilitySlotSchema(weekday=slot.weekday, period=slot.period)
            for slot in sorted(
                membership.availability_slots, key=lambda slot: (slot.weekday, slot.period.value)
            )
        ],
        exceptions=[
            AvailabilityExceptionSchema(
                date=exception.date, period=exception.period, available=exception.available
            )
            for exception in membership.availability_exceptions
        ],
    )


def restriction_response(
    restriction: Restriction, target_name: str, timezone: str
) -> RestrictionResponse:
    return RestrictionResponse(
        id=restriction.id,
        target=RestrictionTarget(type=restriction.target_type, key=restriction.target_key),
        target_name=target_name,
        kind=restriction.kind,
        starts_on=restriction.starts_on,
        ends_on=restriction.ends_on,
        is_active=is_active(restriction, today_in(timezone)),
        created_at=restriction.created_at,
    )
