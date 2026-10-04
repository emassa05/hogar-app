from typing import Annotated, Any

from pydantic import BaseModel, ConfigDict, Field, StringConstraints

from app.common.errors import ErrorCode

TrimmedName = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=40)]


class ApiModel(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra="forbid", populate_by_name=True)


class ErrorPayload(BaseModel):
    code: ErrorCode
    message: str
    details: dict[str, Any] = Field(default_factory=dict)
    request_id: str


class ErrorResponse(BaseModel):
    error: ErrorPayload


class CursorPage[ItemT](BaseModel):
    items: list[ItemT]
    next_cursor: str | None
