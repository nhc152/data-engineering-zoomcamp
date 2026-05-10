import argparse
import json
import random
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd


RAW_DIR = Path("data/raw")


def build_orders(row_count: int) -> pd.DataFrame:
    random.seed(20260509)
    start = datetime(2026, 5, 1)
    statuses = ["paid", "completed", "cancelled", "refunded", "shipped"]
    countries = ["VN", "US", "KR", "SG", "JP"]
    categories = ["electronics", "office", "home", "books"]

    rows = []
    for idx in range(1, row_count + 1):
        order_ts = start + timedelta(
            days=random.randint(0, 29),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
        )
        status = random.choices(statuses, weights=[45, 25, 8, 5, 17], k=1)[0]
        quantity = random.randint(1, 5)
        unit_price = round(random.choice([8, 15, 40, 55, 75, 120, 350]) * random.uniform(0.9, 1.2), 2)
        gross_amount = round(quantity * unit_price, 2)
        discount_amount = round(gross_amount * random.choice([0, 0, 0.05, 0.1]), 2)
        tax_amount = round((gross_amount - discount_amount) * 0.08, 2)
        shipping_amount = round(random.choice([0, 3.99, 7.99, 12.99]), 2)
        net_amount = round(gross_amount - discount_amount + tax_amount + shipping_amount, 2)
        if status in ("cancelled", "refunded"):
            recognized_revenue = 0.0
        else:
            recognized_revenue = net_amount

        rows.append(
            {
                "order_id": f"O{idx:08d}",
                "customer_id": f"C{random.randint(1, 4000):06d}",
                "product_id": f"P{random.randint(1, 500):05d}",
                "order_timestamp": order_ts.isoformat(),
                "order_date": order_ts.date().isoformat(),
                "order_status": status,
                "country": random.choice(countries),
                "category": random.choice(categories),
                "quantity": quantity,
                "unit_price": unit_price,
                "gross_amount": gross_amount,
                "discount_amount": discount_amount,
                "tax_amount": tax_amount,
                "shipping_amount": shipping_amount,
                "recognized_revenue": recognized_revenue,
                "payload": json.dumps(
                    {
                        "device": random.choice(["mobile", "desktop", "tablet"]),
                        "campaign": random.choice(["organic", "summer", "email", "paid_search"]),
                    },
                    separators=(",", ":"),
                ),
            }
        )

    return pd.DataFrame(rows)


def write_jsonl(df: pd.DataFrame, path: Path) -> None:
    with path.open("w", encoding="utf-8") as file:
        for record in df.to_dict(orient="records"):
            file.write(json.dumps(record, separators=(",", ":")) + "\n")


def write_schema_drift_jsonl(df: pd.DataFrame, path: Path) -> None:
    drifted = df.head(500).copy()
    drifted["coupon_code"] = ["SUMMER26" if i % 7 == 0 else None for i in range(len(drifted))]
    drifted["recognized_revenue"] = drifted["recognized_revenue"].astype(str)
    write_jsonl(drifted, path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--rows", type=int, default=50000)
    args = parser.parse_args()

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    df = build_orders(args.rows)

    csv_path = RAW_DIR / "orders.csv"
    jsonl_path = RAW_DIR / "orders.jsonl"
    drift_path = RAW_DIR / "orders_schema_drift.jsonl"

    df.to_csv(csv_path, index=False)
    write_jsonl(df, jsonl_path)
    write_schema_drift_jsonl(df, drift_path)

    print(f"Wrote {len(df):,} rows")
    print(f"CSV: {csv_path}")
    print(f"JSONL: {jsonl_path}")
    print(f"Schema drift JSONL: {drift_path}")


if __name__ == "__main__":
    main()

