from fastapi import APIRouter, Depends

from app.common.rate_limit import default_rate_limit
from app.modules.auth.router import router as auth_router
from app.modules.health.router import router as health_router
from app.modules.users.router import router as users_router

api_router = APIRouter(dependencies=[Depends(default_rate_limit)])
api_router.include_router(health_router)
api_router.include_router(auth_router)
api_router.include_router(users_router)
