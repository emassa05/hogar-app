from fastapi import APIRouter, Depends

from app.common.rate_limit import default_rate_limit
from app.modules.health.router import router as health_router

api_router = APIRouter(dependencies=[Depends(default_rate_limit)])
api_router.include_router(health_router)
