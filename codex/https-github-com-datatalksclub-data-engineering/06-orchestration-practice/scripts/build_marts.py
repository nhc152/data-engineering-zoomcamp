from __future__ import annotations

from decimal import Decimal

from common import MARTS_DIR, RAW_DIR, log_event, parse_args, read_csv, write_csv


def recognized_revenue(status: str, amount: str) -> Decimal:
    if status in {"cancelled", "refunded"}:
        return Decimal("0.00")
    return Decimal(amount)


def main() -> None:
    args = parse_args()
    rows_by_date: dict[str, dict[str, object]] = {}

    for raw_file in sorted(RAW_DIR.glob("run_date=*/orders.csv")):
        for row in read_csv(raw_file):
            order_date = row["order_date"]
            current = rows_by_date.setdefault(
                order_date,
                {
                    "order_date": order_date,
                    "order_count": 0,
                    "recognized_revenue": Decimal("0.00"),
                },
            )
            current["order_count"] = int(current["order_count"]) + 1
            current["recognized_revenue"] = Decimal(current["recognized_revenue"]) + recognized_revenue(
                row["order_status"],
                row["amount"],
            )

    output_rows = [
        {
            "order_date": value["order_date"],
            "order_count": value["order_count"],
            "recognized_revenue": f"{Decimal(value['recognized_revenue']):.2f}",
        }
        for value in sorted(rows_by_date.values(), key=lambda item: str(item["order_date"]))
    ]

    mart_path = MARTS_DIR / "daily_revenue.csv"
    write_csv(mart_path, output_rows, ["order_date", "order_count", "recognized_revenue"])
    log_event("build_marts", args.run_date, "success", "daily revenue mart rebuilt", output=str(mart_path), row_count=len(output_rows))


if __name__ == "__main__":
    main()

