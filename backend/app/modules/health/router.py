from typing import Literal

from fastapi import APIRouter
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from app.common.database import SessionDependency
from app.common.errors import ServiceUnavailableError

router = APIRouter(prefix="/health", tags=["Salud"])


class HealthStatus(BaseModel):
    status: Literal["ok"] = "ok"


@router.get("/live", response_model=HealthStatus)
async def live() -> HealthStatus:
    return HealthStatus()


@router.get("/ready", response_model=HealthStatus)
async def ready(session: SessionDependency) -> HealthStatus:
    try:
        await session.execute(text("SELECT 1"))
    except SQLAlchemyError as error:
        raise ServiceUnavailableError() from error
    return HealthStatus()
