from __future__ import annotations

import sys

from common import copy_idempotent, log_event, parse_args, raw_file_for, raw_partition_dir


def main() -> None:
    args = parse_args()
    landing = raw_partition_dir(args.run_date) / "landing_orders.csv"
    target = raw_file_for(args.run_date)

    if not landing.exists():
        log_event("load_raw_orders", args.run_date, "failed", f"landing file not found: {landing}")
        sys.exit(1)

    copy_idempotent(landing, target)
    log_event("load_raw_orders", args.run_date, "success", "raw partition loaded idempotently", output=str(target))


if __name__ == "__main__":
    main()

