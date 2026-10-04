from datetime import UTC, date, datetime
from zoneinfo import ZoneInfo


def utc_now() -> datetime:
    return datetime.now(UTC)


def today_in(timezone: str) -> date:
    return utc_now().astimezone(ZoneInfo(timezone)).date()


def seconds_until(moment: datetime) -> int:
    return max(0, int((moment - utc_now()).total_seconds()))
