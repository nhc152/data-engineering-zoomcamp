from __future__ import annotations

from pathlib import Path

from pyspark.sql.functions import count

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"


def main() -> None:
    spark = build_spark("solution-avoid-collect")
    orders = spark.read.parquet(str(PARQUET / "orders"))

    # Good pattern:
    # Keep computation distributed. Aggregate/filter in Spark.
    status_counts = orders.groupBy("order_status").agg(count("*").alias("order_count"))
    status_counts.show(truncate=False)

    # If you need a small sample for debugging, use limit/take intentionally.
    sample_ids = [row["order_id"] for row in orders.select("order_id").limit(10).collect()]
    print("Small sample only:", sample_ids)

    spark.stop()


if __name__ == "__main__":
    main()

