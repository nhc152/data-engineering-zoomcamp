from __future__ import annotations

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1] / "scripts"))

from common import copy_idempotent, raw_file_for, raw_partition_dir, source_file_for


def load_partition_idempotently(run_date: str) -> None:
    source = source_file_for(run_date)
    target = raw_file_for(run_date)
    copy_idempotent(source, target)


if __name__ == "__main__":
    load_partition_idempotently("2026-05-01")
    load_partition_idempotently("2026-05-01")
    print(f"same partition safely replaced at {raw_partition_dir('2026-05-01')}")
