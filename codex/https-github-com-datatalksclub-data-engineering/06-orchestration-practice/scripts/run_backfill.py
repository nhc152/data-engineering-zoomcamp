from __future__ import annotations

import argparse
import subprocess
import sys
from datetime import date, timedelta


TASKS = [
    "extract_orders.py",
    "load_raw_orders.py",
    "validate_raw_orders.py",
    "build_marts.py",
    "validate_marts.py",
    "notify_success.py",
]


def parse_date(value: str) -> date:
    return date.fromisoformat(value)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--start-date", required=True)
    parser.add_argument("--end-date", required=True)
    args = parser.parse_args()

    current = parse_date(args.start_date)
    end = parse_date(args.end_date)
    while current <= end:
        run_date = current.isoformat()
        print(f"=== Backfill {run_date} ===")
        for task in TASKS:
            command = [sys.executable, f"scripts/{task}", "--run-date", run_date]
            subprocess.run(command, check=True)
        current += timedelta(days=1)


if __name__ == "__main__":
    main()

