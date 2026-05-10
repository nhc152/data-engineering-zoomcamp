from __future__ import annotations

import sys

from common import log_event, parse_args, raw_file_for, read_csv


REQUIRED_COLUMNS = {"order_id", "customer_id", "order_status", "order_date", "amount"}
VALID_STATUSES = {"paid", "shipped", "completed", "cancelled", "refunded"}


def main() -> None:
    args = parse_args()
    path = raw_file_for(args.run_date)

    if not path.exists():
        log_event("validate_raw_orders", args.run_date, "failed", f"raw file not found: {path}")
        sys.exit(1)

    rows = read_csv(path)
    if not rows:
        log_event("validate_raw_orders", args.run_date, "failed", "raw file has zero rows")
        sys.exit(1)

    missing_columns = REQUIRED_COLUMNS - set(rows[0].keys())
    if missing_columns:
        log_event("validate_raw_orders", args.run_date, "failed", "missing required columns", missing_columns=sorted(missing_columns))
        sys.exit(1)

    bad_rows = []
    for row in rows:
        if not row["order_id"] or not row["customer_id"]:
            bad_rows.append({"order_id": row.get("order_id"), "reason": "missing key"})
        if row["order_status"] not in VALID_STATUSES:
            bad_rows.append({"order_id": row.get("order_id"), "reason": "invalid status"})

    if bad_rows:
        log_event("validate_raw_orders", args.run_date, "failed", "data quality failure", bad_rows=bad_rows)
        sys.exit(1)

    log_event("validate_raw_orders", args.run_date, "success", "raw validation passed", row_count=len(rows))


if __name__ == "__main__":
    main()

