from __future__ import annotations

import csv
import json
import logging
import random
import tempfile
import time
from collections.abc import Callable
from pathlib import Path
from typing import Any


logger = logging.getLogger(__name__)


class SimulatedApiTimeoutError(RuntimeError):
    pass


class SimulatedRateLimitError(RuntimeError):
    pass


def read_csv_records(path: Path) -> list[dict[str, Any]]:
    logger.info("read_csv_started", extra={"path": str(path)})
    with path.open("r", encoding="utf-8", newline="") as file:
        rows = list(csv.DictReader(file))
    logger.info("read_csv_finished", extra={"path": str(path), "row_count": len(rows)})
    return rows


def read_json_records(path: Path) -> list[dict[str, Any]]:
    logger.info("read_json_started", extra={"path": str(path)})
    with path.open("r", encoding="utf-8") as file:
        payload = json.load(file)

    if isinstance(payload, list):
        records = payload
    elif isinstance(payload, dict) and isinstance(payload.get("data"), list):
        records = payload["data"]
    else:
        raise ValueError("JSON file must contain a list or an object with a data list")

    logger.info("read_json_finished", extra={"path": str(path), "row_count": len(records)})
    return records


def read_jsonl_records(path: Path) -> list[dict[str, Any]]:
    logger.info("read_jsonl_started", extra={"path": str(path)})
    records: list[dict[str, Any]] = []

    with path.open("r", encoding="utf-8") as file:
        for line_number, line in enumerate(file, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                payload = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"Malformed JSONL at line {line_number}") from exc
            if not isinstance(payload, dict):
                raise ValueError(f"JSONL line {line_number} is not an object")
            records.append(payload)

    logger.info("read_jsonl_finished", extra={"path": str(path), "row_count": len(records)})
    return records


def write_raw_copy(records: list[dict[str, Any]], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    temp_path = output_path.with_suffix(output_path.suffix + ".tmp")

    with temp_path.open("w", encoding="utf-8") as file:
        for record in records:
            file.write(json.dumps(record, default=str) + "\n")

    temp_path.replace(output_path)
    logger.info("raw_copy_written", extra={"path": str(output_path), "row_count": len(records)})


def retry_call(
    operation: Callable[[], dict[str, Any]],
    *,
    max_attempts: int,
    base_seconds: float,
    max_seconds: float,
) -> dict[str, Any]:
    for attempt in range(1, max_attempts + 1):
        try:
            return operation()
        except (SimulatedApiTimeoutError, SimulatedRateLimitError) as exc:
            if attempt == max_attempts:
                logger.exception("retry_exhausted", extra={"attempt": attempt})
                raise
            sleep_seconds = min(max_seconds, base_seconds * (2 ** (attempt - 1)))
            sleep_seconds += random.uniform(0, base_seconds)
            logger.warning(
                "retryable_api_error",
                extra={
                    "attempt": attempt,
                    "sleep_seconds": round(sleep_seconds, 3),
                    "error_type": type(exc).__name__,
                },
            )
            time.sleep(sleep_seconds)

    raise RuntimeError("unreachable retry state")


def _load_api_page(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        payload = json.load(file)

    simulate = payload.get("simulate")
    if simulate == "timeout_once":
        marker = Path(tempfile.gettempdir()) / f"{path.stem}_timeout_seen"
        if not marker.exists():
            marker.write_text("seen", encoding="utf-8")
            raise SimulatedApiTimeoutError(f"Simulated timeout for {path.name}")
    if simulate == "rate_limit_once":
        marker = Path(tempfile.gettempdir()) / f"{path.stem}_rate_limit_seen"
        if not marker.exists():
            marker.write_text("seen", encoding="utf-8")
            raise SimulatedRateLimitError(f"Simulated rate limit for {path.name}")

    return payload


def fetch_simulated_api_pages(
    pages_dir: Path,
    *,
    max_attempts: int,
    base_seconds: float,
    max_seconds: float,
) -> list[dict[str, Any]]:
    logger.info("api_extract_started", extra={"pages_dir": str(pages_dir)})
    page_name: str | None = "page_1.json"
    records: list[dict[str, Any]] = []
    page_count = 0

    while page_name:
        page_path = pages_dir / page_name
        payload = retry_call(
            lambda path=page_path: _load_api_page(path),
            max_attempts=max_attempts,
            base_seconds=base_seconds,
            max_seconds=max_seconds,
        )
        page_records = payload.get("data", [])
        if not isinstance(page_records, list):
            raise ValueError(f"API page {page_name} has non-list data")

        page_count += 1
        records.extend(page_records)
        logger.info(
            "api_page_fetched",
            extra={
                "page_name": page_name,
                "page_record_count": len(page_records),
                "total_records": len(records),
            },
        )
        page_name = payload.get("next_page")

    logger.info(
        "api_extract_finished",
        extra={"page_count": page_count, "row_count": len(records)},
    )
    return records
