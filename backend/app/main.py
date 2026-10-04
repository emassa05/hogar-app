from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import api_router
from app.common.config import Settings, get_settings
from app.common.database import init_database
from app.common.error_handlers import UnhandledErrorMiddleware, register_error_handlers
from app.common.logging import configure_logging
from app.common.rate_limit import init_rate_limiter
from app.common.request_context import REQUEST_ID_HEADER, RequestIdMiddleware
from app.common.schemas import ErrorResponse
from app.common.sms import build_sms_sender


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = settings or get_settings()
    configure_logging(settings.log_level)

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncIterator[None]:
        database = init_database(settings)
        init_rate_limiter(settings)
        app.state.settings = settings
        app.state.sms_sender = build_sms_sender(settings)
        try:
            yield
        finally:
            await database.dispose()

    docs_enabled = not settings.is_production
    app = FastAPI(
        title="hogar-app API",
        version="1.0.0",
        lifespan=lifespan,
        openapi_url=f"{settings.api_prefix}/openapi.json" if docs_enabled else None,
        docs_url="/docs" if docs_enabled else None,
        redoc_url=None,
        responses={"default": {"model": ErrorResponse, "description": "Error"}},
    )

    app.add_middleware(UnhandledErrorMiddleware)
    if settings.cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins,
            allow_methods=["*"],
            allow_headers=["*"],
            expose_headers=[REQUEST_ID_HEADER, "Retry-After"],
        )
    app.add_middleware(RequestIdMiddleware)

    register_error_handlers(app)
    app.include_router(api_router, prefix=settings.api_prefix)
    return app
