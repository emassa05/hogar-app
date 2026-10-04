from typing import Annotated

import phonenumbers
from pydantic import BeforeValidator
from pydantic_core import PydanticCustomError

DEFAULT_REGION = "CL"


def normalize_phone(raw: object) -> str:
    if not isinstance(raw, str):
        raise PydanticCustomError("invalid_type", "Phone number must be a string.")
    try:
        parsed = phonenumbers.parse(raw.strip(), DEFAULT_REGION)
    except phonenumbers.NumberParseException as error:
        raise PydanticCustomError("invalid_format", "Phone number is not valid.") from error
    if not phonenumbers.is_valid_number(parsed):
        raise PydanticCustomError("invalid_format", "Phone number is not valid.")
    return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)


PhoneNumber = Annotated[str, BeforeValidator(normalize_phone)]
