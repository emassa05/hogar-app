import uuid

from httpx import AsyncClient

from app.common.request_context import REQUEST_ID_HEADER


async def test_live_returns_ok_with_generated_request_id(client: AsyncClient) -> None:
    response = await client.get("/health/live")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
    uuid.UUID(response.headers[REQUEST_ID_HEADER])


async def test_ready_checks_database(client: AsyncClient) -> None:
    response = await client.get("/health/ready")

    assert response.status_code == 200


async def test_request_id_is_echoed_when_valid(client: AsyncClient) -> None:
    response = await client.get("/health/live", headers={REQUEST_ID_HEADER: "mobile-123"})

    assert response.headers[REQUEST_ID_HEADER] == "mobile-123"


async def test_request_id_is_replaced_when_malformed(client: AsyncClient) -> None:
    response = await client.get("/health/live", headers={REQUEST_ID_HEADER: "bad id with spaces"})

    assert response.headers[REQUEST_ID_HEADER] != "bad id with spaces"


async def test_unknown_route_uses_error_envelope(client: AsyncClient) -> None:
    response = await client.get("/does-not-exist", headers={REQUEST_ID_HEADER: "trace-1"})

    assert response.status_code == 404
    assert response.json() == {
        "error": {
            "code": "NOT_FOUND",
            "message": "Not Found",
            "details": {},
            "request_id": "trace-1",
        }
    }


async def test_responses_include_rate_limit_headers(client: AsyncClient) -> None:
    response = await client.get("/health/live")

    assert response.headers["X-RateLimit-Limit"] == "120"
    assert int(response.headers["X-RateLimit-Remaining"]) == 119
