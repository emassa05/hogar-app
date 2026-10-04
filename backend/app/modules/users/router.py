from fastapi import APIRouter

from app.common.database import SessionDependency
from app.modules.auth.dependencies import CurrentUser
from app.modules.users.schemas import UpdateUserRequest, UserResponse
from app.modules.users.service import UserService

router = APIRouter(prefix="/users", tags=["Usuarios"])


@router.get("/me")
async def get_current_user_profile(current_user: CurrentUser) -> UserResponse:
    return UserResponse.model_validate(current_user)


@router.patch("/me")
async def update_current_user(
    payload: UpdateUserRequest, current_user: CurrentUser, session: SessionDependency
) -> UserResponse:
    user = await UserService(session).update(current_user, payload)
    return UserResponse.model_validate(user)
