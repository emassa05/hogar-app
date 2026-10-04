import os
from collections.abc import AsyncIterator

import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

from app.common.config import Environment, Settings
from app.common.dependencies import get_sms_sender
from app.common.rate_limit import get_rate_limiter
from app.main import create_app
from app.models import metadata
from tests.factories import FakeSmsSender, RegisteredUser, register_user

TEST_DATABASE_URL = os.environ.get(
    "TEST_DATABASE_URL", "postgresql+asyncpg://hogar:hogar@localhost:5432/hogar_test"
)


@pytest.fixture(scope="session")
def settings() -> Settings:
    return Settings(
        environment=Environment.TEST,
        database_url=TEST_DATABASE_URL,
        jwt_secret="test-secret-with-enough-length-for-hs256-signing",
        log_level="WARNING",
        rate_limit_storage_uri="memory://",
    )


@pytest.fixture(scope="session", autouse=True)
async def database_schema(settings: Settings) -> AsyncIterator[None]:
    engine = create_async_engine(str(settings.database_url))
    async with engine.begin() as connection:
        await connection.run_sync(metadata.drop_all)
        await connection.run_sync(metadata.create_all)
    yield
    async with engine.begin() as connection:
        await connection.run_sync(metadata.drop_all)
    await engine.dispose()


@pytest.fixture(scope="session")
async def app(settings: Settings) -> AsyncIterator[FastAPI]:
    application = create_app(settings)
    async with application.router.lifespan_context(application):
        yield application


@pytest.fixture(autouse=True)
async def clean_state(app: FastAPI, settings: Settings) -> AsyncIterator[None]:
    yield
    engine = create_async_engine(str(settings.database_url))
    async with engine.begin() as connection:
        tables = ", ".join(f'"{table.name}"' for table in metadata.sorted_tables)
        await connection.execute(text(f"TRUNCATE {tables} RESTART IDENTITY CASCADE"))
    await engine.dispose()
    await get_rate_limiter().reset()
    app.dependency_overrides.clear()


@pytest.fixture
async def client(app: FastAPI) -> AsyncIterator[AsyncClient]:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test/api/v1") as http_client:
        yield http_client


@pytest.fixture
def sms(app: FastAPI) -> FakeSmsSender:
    sender = FakeSmsSender()
    app.dependency_overrides[get_sms_sender] = lambda: sender
    return sender


@pytest.fixture
async def marta(client: AsyncClient, sms: FakeSmsSender) -> RegisteredUser:
    return await register_user(client, sms, phone="+56987654321", name="Marta")


@pytest.fixture
async def pablo(client: AsyncClient, sms: FakeSmsSender) -> RegisteredUser:
    return await register_user(client, sms, phone="+56987651111", name="Pablo")
