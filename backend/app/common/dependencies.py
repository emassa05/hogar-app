from typing import Annotated, cast

from fastapi import Depends, Request

from app.common.config import Settings
from app.common.sms import SmsSender


def get_app_settings(request: Request) -> Settings:
    return cast(Settings, request.app.state.settings)


def get_sms_sender(request: Request) -> SmsSender:
    return cast(SmsSender, request.app.state.sms_sender)


SettingsDependency = Annotated[Settings, Depends(get_app_settings)]
SmsSenderDependency = Annotated[SmsSender, Depends(get_sms_sender)]
