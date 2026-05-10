from __future__ import annotations

import csv
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[1]
TARGET = BASE_DIR / "data" / "raw" / "orders_append_bad.csv"


def append_bad(run_date: str) -> None:
    source = BASE_DIR / "data" / "source" / f"orders_{run_date}.csv"
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    with source.open("r", encoding="utf-8", newline="") as source_fp:
        reader = csv.DictReader(source_fp)
        exists = TARGET.exists()
        with TARGET.open("a", encoding="utf-8", newline="") as target_fp:
            writer = csv.DictWriter(target_fp, fieldnames=reader.fieldnames)
            if not exists:
                writer.writeheader()
            writer.writerows(reader)


if __name__ == "__main__":
    append_bad("2026-05-01")
    append_bad("2026-05-01")
    print(f"duplicated rows written to {TARGET}")

