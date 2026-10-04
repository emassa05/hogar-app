from datetime import timedelta
from enum import StrEnum
from functools import lru_cache

from pydantic import Field, PostgresDsn, SecretStr, computed_field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

MIN_JWT_SECRET_LENGTH = 32


class Environment(StrEnum):
    DEVELOPMENT = "development"
    TEST = "test"
    PRODUCTION = "production"


class SmsProvider(StrEnum):
    TWILIO = "twilio"
    CONSOLE = "console"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    environment: Environment = Environment.DEVELOPMENT
    app_name: str = "hogar-app"
    api_prefix: str = "/api/v1"
    log_level: str = "INFO"
    cors_origins: list[str] = Field(default_factory=list)
    public_base_url: str = "https://hogarapp.cl"

    database_url: PostgresDsn
    database_pool_size: int = 10
    database_echo: bool = False

    jwt_secret: SecretStr
    jwt_algorithm: str = "HS256"
    access_token_ttl_minutes: int = 15
    refresh_token_ttl_days: int = 30
    verification_token_ttl_minutes: int = 15

    verification_code_ttl_minutes: int = 10
    verification_max_attempts: int = 5
    verification_resend_cooldown_seconds: int = 60

    login_max_failed_attempts: int = 5
    login_lockout_minutes: int = 15

    invitation_ttl_days: int = 7

    rate_limit_enabled: bool = True
    rate_limit_storage_uri: str = "memory://"
    rate_limit_default: str = "120/minute"

    sms_provider: SmsProvider = SmsProvider.CONSOLE
    twilio_account_sid: SecretStr | None = None
    twilio_auth_token: SecretStr | None = None
    twilio_from_number: str | None = None
    twilio_messaging_service_sid: str | None = None

    @model_validator(mode="after")
    def validate_secrets(self) -> "Settings":
        if len(self.jwt_secret.get_secret_value()) < MIN_JWT_SECRET_LENGTH:
            raise ValueError("JWT_SECRET must have at least 32 characters")
        if self.is_production and self.sms_provider is not SmsProvider.TWILIO:
            raise ValueError("Production requires SMS_PROVIDER=twilio")
        return self

    @computed_field  # type: ignore[prop-decorator]
    @property
    def is_production(self) -> bool:
        return self.environment is Environment.PRODUCTION

    @property
    def access_token_ttl(self) -> timedelta:
        return timedelta(minutes=self.access_token_ttl_minutes)

    @property
    def refresh_token_ttl(self) -> timedelta:
        return timedelta(days=self.refresh_token_ttl_days)

    @property
    def verification_token_ttl(self) -> timedelta:
        return timedelta(minutes=self.verification_token_ttl_minutes)

    @property
    def verification_code_ttl(self) -> timedelta:
        return timedelta(minutes=self.verification_code_ttl_minutes)

    @property
    def verification_resend_cooldown(self) -> timedelta:
        return timedelta(seconds=self.verification_resend_cooldown_seconds)

    @property
    def login_lockout(self) -> timedelta:
        return timedelta(minutes=self.login_lockout_minutes)

    @property
    def invitation_ttl(self) -> timedelta:
        return timedelta(days=self.invitation_ttl_days)


@lru_cache
def get_settings() -> Settings:
    return Settings()
