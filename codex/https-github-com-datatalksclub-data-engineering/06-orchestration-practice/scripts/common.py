from __future__ import annotations

import argparse
import csv
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data"
SOURCE_DIR = DATA_DIR / "source"
RAW_DIR = DATA_DIR / "raw" / "orders"
MARTS_DIR = DATA_DIR / "marts"
STATE_DIR = DATA_DIR / "state"
RUN_LOG = STATE_DIR / "run_log.jsonl"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-date", required=True, help="Logical business date, YYYY-MM-DD")
    return parser.parse_args()


def ensure_dirs() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    MARTS_DIR.mkdir(parents=True, exist_ok=True)
    STATE_DIR.mkdir(parents=True, exist_ok=True)


def log_event(task: str, run_date: str, status: str, message: str, **extra: object) -> None:
    ensure_dirs()
    event = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "task": task,
        "run_date": run_date,
        "status": status,
        "message": message,
        **extra,
    }
    with RUN_LOG.open("a", encoding="utf-8") as fp:
        fp.write(json.dumps(event, sort_keys=True) + "\n")
    print(json.dumps(event, sort_keys=True))


def source_file_for(run_date: str) -> Path:
    return SOURCE_DIR / f"orders_{run_date}.csv"


def raw_partition_dir(run_date: str) -> Path:
    return RAW_DIR / f"run_date={run_date}"


def raw_file_for(run_date: str) -> Path:
    return raw_partition_dir(run_date) / "orders.csv"


def copy_idempotent(source: Path, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    temp = target.with_suffix(".tmp")
    shutil.copyfile(source, temp)
    temp.replace(target)


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as fp:
        return list(csv.DictReader(fp))


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(".tmp")
    with temp.open("w", encoding="utf-8", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    temp.replace(path)

