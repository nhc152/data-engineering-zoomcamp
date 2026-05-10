from __future__ import annotations

import csv
import json
from pathlib import Path
from random import Random


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def write_jsonl(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        for row in rows:
            f.write(json.dumps(row) + "\n")


def main() -> None:
    rng = Random(42)

    products = [
        {"product_id": "P001", "product_name": "Mechanical Keyboard", "category": "electronics", "unit_price": 120.0},
        {"product_id": "P002", "product_name": "Wireless Mouse", "category": "electronics", "unit_price": 40.0},
        {"product_id": "P003", "product_name": "USB-C Hub", "category": "electronics", "unit_price": 75.0},
        {"product_id": "P004", "product_name": "Notebook", "category": "office", "unit_price": 8.0},
        {"product_id": "P005", "product_name": "Desk Lamp", "category": "home", "unit_price": 55.0},
    ]

    orders = []
    order_items = []
    payments = []
    statuses = ["paid", "completed", "cancelled", "refunded"]

    for i in range(1, 501):
        order_id = f"O{i:05d}"
        if i <= 250:
            customer_id = "UNKNOWN"  # intentional skew for join/groupBy demos
        else:
            customer_id = f"C{rng.randint(1, 80):03d}"

        day = 1 + (i % 10)
        status = statuses[i % len(statuses)]
        order_date = f"2026-05-{day:02d}"

        orders.append(
            {
                "order_id": order_id,
                "customer_id": customer_id,
                "order_status": status,
                "order_timestamp": f"{order_date}T10:{i % 60:02d}:00Z",
                "order_date": order_date,
            }
        )

        item_count = 1 + (i % 3)
        gross_total = 0.0
        for item_idx in range(item_count):
            product = products[(i + item_idx) % len(products)]
            quantity = 1 + ((i + item_idx) % 4)
            amount = quantity * float(product["unit_price"])
            gross_total += amount
            order_items.append(
                {
                    "order_item_id": f"OI{i:05d}_{item_idx}",
                    "order_id": order_id,
                    "product_id": product["product_id"],
                    "quantity": quantity,
                    "unit_price": product["unit_price"],
                }
            )

        payment_amount = 0.0 if status in {"cancelled", "refunded"} else round(gross_total, 2)
        payments.append(
            {
                "payment_id": f"PAY{i:05d}",
                "order_id": order_id,
                "payment_status": "captured" if payment_amount > 0 else status,
                "amount": payment_amount,
                "payment_timestamp": f"{order_date}T10:{(i + 1) % 60:02d}:00Z",
            }
        )

    write_csv(RAW / "orders" / "orders.csv", orders, ["order_id", "customer_id", "order_status", "order_timestamp", "order_date"])
    write_csv(RAW / "order_items" / "order_items.csv", order_items, ["order_item_id", "order_id", "product_id", "quantity", "unit_price"])
    write_csv(RAW / "products" / "products.csv", products, ["product_id", "product_name", "category", "unit_price"])
    write_jsonl(RAW / "payments" / "payments.jsonl", payments)

    print(f"Generated sample data under {RAW}")
    print(f"orders={len(orders)}, order_items={len(order_items)}, products={len(products)}, payments={len(payments)}")


if __name__ == "__main__":
    main()

