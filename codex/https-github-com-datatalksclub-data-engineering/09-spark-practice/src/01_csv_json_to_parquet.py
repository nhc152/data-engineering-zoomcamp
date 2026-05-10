from __future__ import annotations

from pathlib import Path

from pyspark.sql.functions import col, to_date, to_timestamp

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
OUT = ROOT / "data" / "output" / "parquet"


def main() -> None:
    spark = build_spark("csv-json-to-parquet")

    orders = (
        spark.read.option("header", True)
        .csv(str(RAW / "orders" / "orders.csv"))
        .withColumn("order_timestamp", to_timestamp("order_timestamp"))
        .withColumn("order_date", to_date("order_date"))
    )

    order_items = (
        spark.read.option("header", True)
        .csv(str(RAW / "order_items" / "order_items.csv"))
        .withColumn("quantity", col("quantity").cast("int"))
        .withColumn("unit_price", col("unit_price").cast("double"))
    )

    products = (
        spark.read.option("header", True)
        .csv(str(RAW / "products" / "products.csv"))
        .withColumn("unit_price", col("unit_price").cast("double"))
    )

    payments = (
        spark.read.json(str(RAW / "payments" / "payments.jsonl"))
        .withColumn("amount", col("amount").cast("double"))
        .withColumn("payment_timestamp", to_timestamp("payment_timestamp"))
    )

    orders.write.mode("overwrite").partitionBy("order_date").parquet(str(OUT / "orders"))
    order_items.write.mode("overwrite").parquet(str(OUT / "order_items"))
    products.write.mode("overwrite").parquet(str(OUT / "products"))
    payments.write.mode("overwrite").parquet(str(OUT / "payments"))

    print(f"Wrote parquet output under {OUT}")
    spark.stop()


if __name__ == "__main__":
    main()

