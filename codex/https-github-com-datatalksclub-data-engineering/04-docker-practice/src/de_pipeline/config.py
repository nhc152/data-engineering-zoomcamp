from dataclasses import dataclass
import os


@dataclass(frozen=True)
class Settings:
    database_host: str
    database_port: int
    database_name: str
    database_user: str
    database_password: str
    input_file: str


def _required(name: str) -> str:
    value = os.getenv(name)
    if value is None or value.strip() == "":
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def load_settings() -> Settings:
    return Settings(
        database_host=_required("DATABASE_HOST"),
        database_port=int(_required("DATABASE_PORT")),
        database_name=_required("DATABASE_NAME"),
        database_user=_required("DATABASE_USER"),
        database_password=_required("DATABASE_PASSWORD"),
        input_file=_required("INPUT_FILE"),
    )

