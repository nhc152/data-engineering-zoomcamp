from __future__ import annotations

from pathlib import Path

from pyspark.sql.functions import col, count

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"


def assert_zero(label: str, value: int) -> None:
    if value != 0:
        raise ValueError(f"{label} failed: expected 0, got {value}")
    print(f"{label}: OK")


def main() -> None:
    spark = build_spark("quality-checks")
    orders = spark.read.parquet(str(PARQUET / "orders"))
    payments = spark.read.parquet(str(PARQUET / "payments"))

    duplicate_orders = (
        orders.groupBy("order_id")
        .agg(count("*").alias("row_count"))
        .filter(col("row_count") > 1)
        .count()
    )

    null_order_ids = orders.filter(col("order_id").isNull()).count()
    payments_without_order = payments.join(orders.select("order_id"), on="order_id", how="left_anti").count()

    assert_zero("duplicate order_id", duplicate_orders)
    assert_zero("null order_id", null_order_ids)
    assert_zero("payments without order", payments_without_order)

    spark.stop()


if __name__ == "__main__":
    main()

