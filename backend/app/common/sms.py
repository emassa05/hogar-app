import asyncio
import logging
from typing import Protocol

from twilio.base.exceptions import TwilioException
from twilio.rest import Client

from app.common.config import Settings, SmsProvider
from app.common.errors import BadGatewayError, ErrorCode

logger = logging.getLogger(__name__)


class SmsSender(Protocol):
    async def send(self, to: str, body: str) -> None: ...


class ConsoleSmsSender:
    async def send(self, to: str, body: str) -> None:
        logger.warning("sms not sent, console provider: %s", body)


class TwilioSmsSender:
    def __init__(self, settings: Settings) -> None:
        account_sid = (
            settings.twilio_account_sid.get_secret_value() if settings.twilio_account_sid else ""
        )
        auth_token = (
            settings.twilio_auth_token.get_secret_value() if settings.twilio_auth_token else ""
        )
        if not account_sid or not auth_token:
            raise RuntimeError("Twilio credentials are not configured")
        if not settings.twilio_from_number and not settings.twilio_messaging_service_sid:
            raise RuntimeError("Twilio sender number or messaging service is not configured")
        self._client = Client(account_sid, auth_token)
        self._from_number = settings.twilio_from_number
        self._messaging_service_sid = settings.twilio_messaging_service_sid

    def _send_blocking(self, to: str, body: str) -> None:
        if self._messaging_service_sid:
            self._client.messages.create(
                to=to, body=body, messaging_service_sid=self._messaging_service_sid
            )
        else:
            self._client.messages.create(to=to, body=body, from_=self._from_number)

    async def send(self, to: str, body: str) -> None:
        try:
            await asyncio.to_thread(self._send_blocking, to, body)
        except TwilioException as error:
            logger.error("sms delivery failed", extra={"provider_error": type(error).__name__})
            raise BadGatewayError(
                ErrorCode.SMS_DELIVERY_FAILED, "SMS could not be delivered."
            ) from error


def build_sms_sender(settings: Settings) -> SmsSender:
    if settings.sms_provider is SmsProvider.TWILIO:
        return TwilioSmsSender(settings)
    if settings.is_production:
        raise RuntimeError("Console SMS provider cannot be used in production")
    return ConsoleSmsSender()
