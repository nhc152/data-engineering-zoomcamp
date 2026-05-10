from __future__ import annotations

from pathlib import Path

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"


def main() -> None:
    spark = build_spark("bad-collect-crash")
    orders = spark.read.parquet(str(PARQUET / "orders"))

    # Bad pattern:
    # In production, this can pull millions/billions of rows into the driver.
    # The local sample is small, but the pattern is intentionally wrong.
    all_order_ids = [row["order_id"] for row in orders.select("order_id").collect()]
    print(f"Collected {len(all_order_ids)} order IDs into driver memory")

    spark.stop()


if __name__ == "__main__":
    main()

