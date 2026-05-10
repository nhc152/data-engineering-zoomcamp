from __future__ import annotations

import os
import sys

from common import copy_idempotent, log_event, parse_args, raw_partition_dir, source_file_for


def main() -> None:
    args = parse_args()
    source = source_file_for(args.run_date)
    landing = raw_partition_dir(args.run_date) / "landing_orders.csv"

    if os.getenv("SIMULATE_EXTRACT_TRANSIENT_FAILURE") == "1":
        marker = raw_partition_dir(args.run_date) / ".extract_failed_once"
        if not marker.exists():
            marker.parent.mkdir(parents=True, exist_ok=True)
            marker.write_text("failed once", encoding="utf-8")
            log_event("extract_orders", args.run_date, "failed", "simulated transient source failure")
            raise RuntimeError("simulated transient source failure")

    if not source.exists():
        log_event("extract_orders", args.run_date, "failed", f"source file not found: {source}")
        sys.exit(1)

    copy_idempotent(source, landing)
    log_event("extract_orders", args.run_date, "success", "source copied to landing", output=str(landing))


if __name__ == "__main__":
    main()

