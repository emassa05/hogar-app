import uuid
from typing import Annotated

from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.common.clock import utc_now
from app.common.database import SessionDependency
from app.common.dependencies import SettingsDependency
from app.common.errors import UnauthenticatedError
from app.common.security.tokens import InvalidTokenError, TokenType, decode_token
from app.modules.auth.repository import SessionRepository
from app.modules.users.models import User
from app.modules.users.repository import UserRepository

bearer_scheme = HTTPBearer(auto_error=False, description="Access token JWT.")


async def get_current_user(
    request: Request,
    session: SessionDependency,
    settings: SettingsDependency,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
) -> User:
    if credentials is None:
        raise UnauthenticatedError()
    try:
        claims = decode_token(credentials.credentials, TokenType.ACCESS, settings)
        user_id = uuid.UUID(str(claims["sub"]))
        session_id = uuid.UUID(str(claims["sid"]))
    except (InvalidTokenError, KeyError, ValueError) as error:
        raise UnauthenticatedError() from error

    if await SessionRepository(session).get_active_session(session_id, utc_now()) is None:
        raise UnauthenticatedError()
    user = await UserRepository(session).get(user_id)
    if user is None:
        raise UnauthenticatedError()
    request.state.user_id = user.id
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]
