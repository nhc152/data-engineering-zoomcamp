from __future__ import annotations

from pathlib import Path

from pyspark.sql.functions import broadcast, col, count, when

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"


def main() -> None:
    spark = build_spark("solution-handle-skew")
    orders = spark.read.parquet(str(PARQUET / "orders"))
    order_items = spark.read.parquet(str(PARQUET / "order_items"))

    # Technique 1: identify skew before optimizing.
    orders.groupBy("customer_id").agg(count("*").alias("order_count")).orderBy(col("order_count").desc()).show(10)

    # Technique 2: reduce data before join where possible.
    items_by_order = order_items.groupBy("order_id").agg(count("*").alias("item_count"))

    # Technique 3: isolate hot key for separate handling.
    hot = orders.filter(col("customer_id") == "UNKNOWN")
    normal = orders.filter(col("customer_id") != "UNKNOWN")

    normal_joined = normal.join(items_by_order, on="order_id", how="left")
    hot_joined = hot.join(broadcast(items_by_order), on="order_id", how="left")

    result = (
        normal_joined.unionByName(hot_joined)
        .withColumn("customer_group", when(col("customer_id") == "UNKNOWN", "hot_key").otherwise("normal"))
        .groupBy("customer_group")
        .count()
    )

    result.show(truncate=False)
    spark.stop()


if __name__ == "__main__":
    main()

