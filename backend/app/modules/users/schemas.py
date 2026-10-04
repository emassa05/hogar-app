import uuid
from datetime import datetime

from pydantic import model_validator

from app.common.schemas import ApiModel, TrimmedName
from app.modules.users.models import Avatar


class UserResponse(ApiModel):
    id: uuid.UUID
    phone: str
    name: str
    avatar: Avatar | None
    active_household_id: uuid.UUID | None
    created_at: datetime


class UpdateUserRequest(ApiModel):
    name: TrimmedName | None = None
    avatar: Avatar | None = None
    active_household_id: uuid.UUID | None = None

    @model_validator(mode="after")
    def require_at_least_one_field(self) -> "UpdateUserRequest":
        if not self.model_fields_set:
            raise ValueError("At least one field must be provided.")
        if "name" in self.model_fields_set and self.name is None:
            raise ValueError("Name cannot be null.")
        return self
