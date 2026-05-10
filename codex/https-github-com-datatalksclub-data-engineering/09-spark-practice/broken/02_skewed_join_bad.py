from __future__ import annotations

from pathlib import Path

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"


def main() -> None:
    spark = build_spark("bad-skewed-join")

    orders = spark.read.parquet(str(PARQUET / "orders"))
    order_items = spark.read.parquet(str(PARQUET / "order_items"))

    # Bad pattern:
    # Joining and repartitioning by skewed key can create one huge partition for UNKNOWN.
    joined = (
        orders.repartition("customer_id")
        .join(order_items, on="order_id", how="left")
        .groupBy("customer_id")
        .count()
    )

    joined.explain(mode="formatted")
    joined.show(20, truncate=False)
    spark.stop()


if __name__ == "__main__":
    main()

