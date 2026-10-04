import secrets

ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
CODE_LENGTH = 8
_AMBIGUOUS = str.maketrans({"I": "1", "L": "1", "O": "0"})


def generate_code() -> str:
    return "".join(secrets.choice(ALPHABET) for _ in range(CODE_LENGTH))


def normalize_code(raw: str) -> str | None:
    cleaned = raw.replace("-", "").replace(" ", "").upper().translate(_AMBIGUOUS)
    if len(cleaned) != CODE_LENGTH or any(character not in ALPHABET for character in cleaned):
        return None
    return cleaned


def display_code(code: str) -> str:
    return f"{code[:4]}-{code[4:]}"
