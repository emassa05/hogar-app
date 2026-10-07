from fastapi import APIRouter, Depends

from app.common.rate_limit import default_rate_limit
from app.modules.auth.router import router as auth_router
from app.modules.catalog.router import router as catalog_router
from app.modules.health.router import router as health_router
from app.modules.households.capacity_router import router as capacity_router
from app.modules.households.router import (
    households_router,
    invitations_router,
    profiles_router,
    templates_router,
)
from app.modules.users.router import router as users_router

api_router = APIRouter(dependencies=[Depends(default_rate_limit)])
api_router.include_router(health_router)
api_router.include_router(auth_router)
api_router.include_router(users_router)
api_router.include_router(households_router)
api_router.include_router(invitations_router)
api_router.include_router(profiles_router)
api_router.include_router(templates_router)
api_router.include_router(catalog_router)
api_router.include_router(capacity_router)
