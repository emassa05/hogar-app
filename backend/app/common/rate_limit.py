import time
from collections.abc import Awaitable, Callable
from enum import StrEnum

from fastapi import Request, Response
from limits import RateLimitItem, parse
from limits.aio.storage import Storage
from limits.aio.strategies import MovingWindowRateLimiter
from limits.storage import storage_from_string

from app.common.config import Settings
from app.common.errors import TooManyRequestsError
from app.common.security.tokens import read_access_subject


class RateLimitKey(StrEnum):
    IP = "ip"
    USER = "user"


class RateLimiter:
    def __init__(self, settings: Settings) -> None:
        uri = settings.rate_limit_storage_uri
        self.enabled = settings.rate_limit_enabled
        normalized_uri = uri if uri.startswith("async+") else f"async+{uri}"
        self.storage: Storage = storage_from_string(normalized_uri)  # type: ignore[assignment]
        self.strategy = MovingWindowRateLimiter(self.storage)
        self.default_limit = settings.rate_limit_default
        self._jwt_settings = settings

    async def reset(self) -> None:
        await self.storage.reset()

    async def hit(
        self, item: RateLimitItem, scope: str, identifier: str, response: Response
    ) -> None:
        if not self.enabled:
            return
        allowed = await self.strategy.hit(item, scope, identifier)
        reset_at, remaining = await self.strategy.get_window_stats(item, scope, identifier)
        retry_after = max(1, int(reset_at - time.time()))
        response.headers["X-RateLimit-Limit"] = str(item.amount)
        response.headers["X-RateLimit-Remaining"] = str(max(0, remaining))
        response.headers["X-RateLimit-Reset"] = str(retry_after)
        if not allowed:
            raise TooManyRequestsError(retry_after_seconds=retry_after)

    def identify(self, request: Request, key: RateLimitKey) -> str:
        if key is RateLimitKey.USER:
            subject = read_access_subject(request.headers.get("Authorization"), self._jwt_settings)
            if subject:
                return f"user:{subject}"
        client = request.client.host if request.client else "unknown"
        return f"ip:{client}"


_rate_limiter: RateLimiter | None = None


def init_rate_limiter(settings: Settings) -> RateLimiter:
    global _rate_limiter
    _rate_limiter = RateLimiter(settings)
    return _rate_limiter


def get_rate_limiter() -> RateLimiter:
    if _rate_limiter is None:
        raise RuntimeError("Rate limiter has not been initialised")
    return _rate_limiter


def rate_limit(
    limit: str, scope: str, key: RateLimitKey = RateLimitKey.IP
) -> Callable[[Request, Response], Awaitable[None]]:
    item = parse(limit)

    async def dependency(request: Request, response: Response) -> None:
        limiter = get_rate_limiter()
        await limiter.hit(item, scope, limiter.identify(request, key), response)

    return dependency


async def default_rate_limit(request: Request, response: Response) -> None:
    limiter = get_rate_limiter()
    key = RateLimitKey.USER if request.headers.get("Authorization") else RateLimitKey.IP
    await limiter.hit(
        parse(limiter.default_limit), "default", limiter.identify(request, key), response
    )
