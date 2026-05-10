from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv


REQUIRED_ENV_VARS = [
    "POSTGRES_HOST",
    "POSTGRES_PORT",
    "POSTGRES_DB",
    "POSTGRES_USER",
    "POSTGRES_PASSWORD",
]


@dataclass(frozen=True)
class PipelineConfig:
    postgres_host: str
    postgres_port: int
    postgres_db: str
    postgres_user: str
    postgres_password: str
    data_dir: Path
    batch_size: int
    max_retries: int
    timeout_seconds: float
    retry_base_seconds: float
    retry_max_seconds: float

    @property
    def postgres_dsn(self) -> str:
        return (
            f"host={self.postgres_host} "
            f"port={self.postgres_port} "
            f"dbname={self.postgres_db} "
            f"user={self.postgres_user} "
            f"password={self.postgres_password}"
        )


def _required_env(name: str) -> str:
    value = os.getenv(name)
    if value is None or value.strip() == "":
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def load_config(env_file: str | None = ".env") -> PipelineConfig:
    if env_file:
        load_dotenv(env_file)

    for name in REQUIRED_ENV_VARS:
        _required_env(name)

    return PipelineConfig(
        postgres_host=_required_env("POSTGRES_HOST"),
        postgres_port=int(_required_env("POSTGRES_PORT")),
        postgres_db=_required_env("POSTGRES_DB"),
        postgres_user=_required_env("POSTGRES_USER"),
        postgres_password=_required_env("POSTGRES_PASSWORD"),
        data_dir=Path(os.getenv("PIPELINE_DATA_DIR", "data")),
        batch_size=int(os.getenv("PIPELINE_BATCH_SIZE", "100")),
        max_retries=int(os.getenv("PIPELINE_MAX_RETRIES", "3")),
        timeout_seconds=float(os.getenv("PIPELINE_TIMEOUT_SECONDS", "5")),
        retry_base_seconds=float(os.getenv("PIPELINE_RETRY_BASE_SECONDS", "0.2")),
        retry_max_seconds=float(os.getenv("PIPELINE_RETRY_MAX_SECONDS", "2.0")),
    )

