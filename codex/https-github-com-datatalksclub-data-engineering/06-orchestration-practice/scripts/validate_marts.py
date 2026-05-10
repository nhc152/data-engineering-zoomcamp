from __future__ import annotations

import sys

from common import MARTS_DIR, log_event, parse_args, read_csv


def main() -> None:
    args = parse_args()
    mart_path = MARTS_DIR / "daily_revenue.csv"

    if not mart_path.exists():
        log_event("validate_marts", args.run_date, "failed", "mart file missing")
        sys.exit(1)

    rows = read_csv(mart_path)
    matching = [row for row in rows if row["order_date"] == args.run_date]
    if not matching:
        log_event("validate_marts", args.run_date, "failed", "mart is stale or missing run_date")
        sys.exit(1)

    revenue = float(matching[0]["recognized_revenue"])
    if revenue < 0:
        log_event("validate_marts", args.run_date, "failed", "negative recognized revenue")
        sys.exit(1)

    log_event("validate_marts", args.run_date, "success", "mart validation passed", order_date=args.run_date, revenue=revenue)


if __name__ == "__main__":
    main()

