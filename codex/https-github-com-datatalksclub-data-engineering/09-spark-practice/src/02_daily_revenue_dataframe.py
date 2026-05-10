from __future__ import annotations

from pathlib import Path

from pyspark.sql.functions import col, count, sum as spark_sum, when

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"
MARTS = ROOT / "data" / "output" / "marts"


def main() -> None:
    spark = build_spark("daily-revenue-dataframe")

    orders = spark.read.parquet(str(PARQUET / "orders"))
    payments = spark.read.parquet(str(PARQUET / "payments"))

    payments_by_order = (
        payments.groupBy("order_id")
        .agg(
            spark_sum(when(col("payment_status") == "captured", col("amount")).otherwise(0)).alias("captured_amount")
        )
    )

    fact_orders = (
        orders.join(payments_by_order, on="order_id", how="left")
        .withColumn(
            "recognized_revenue",
            when(col("order_status").isin("cancelled", "refunded"), 0).otherwise(col("captured_amount")),
        )
    )

    daily = (
        fact_orders.groupBy("order_date")
        .agg(
            count("*").alias("order_count"),
            spark_sum("recognized_revenue").alias("recognized_revenue"),
        )
        .orderBy("order_date")
    )

    daily.show(20, truncate=False)
    daily.write.mode("overwrite").partitionBy("order_date").parquet(str(MARTS / "daily_revenue_dataframe"))

    spark.stop()


if __name__ == "__main__":
    main()

