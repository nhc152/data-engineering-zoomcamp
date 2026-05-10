from __future__ import annotations

from pathlib import Path

from pyspark.sql.functions import col

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"
OUT = ROOT / "data" / "output" / "solutions" / "safe_orders"


def main() -> None:
    spark = build_spark("solution-safe-partition-overwrite")
    spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic")

    orders = spark.read.parquet(str(PARQUET / "orders"))

    # First write full table.
    orders.write.mode("overwrite").partitionBy("order_date").parquet(str(OUT))

    # Then safely overwrite only one partition.
    may_02 = orders.filter(col("order_date") == "2026-05-02")
    may_02.write.mode("overwrite").partitionBy("order_date").parquet(str(OUT))

    print("Safe partition overwrite completed")
    print("Total rows still available:", spark.read.parquet(str(OUT)).count())
    spark.stop()


if __name__ == "__main__":
    main()

