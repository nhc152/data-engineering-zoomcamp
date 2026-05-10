from __future__ import annotations

import argparse
import time
from pathlib import Path

from pyspark.sql.functions import count

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sleep-seconds", type=int, default=0)
    args = parser.parse_args()

    spark = build_spark("skew-demo")
    orders = spark.read.parquet(str(PARQUET / "orders"))

    by_customer = (
        orders.repartition("customer_id")
        .groupBy("customer_id")
        .agg(count("*").alias("order_count"))
        .orderBy("order_count", ascending=False)
    )

    by_customer.show(20, truncate=False)
    by_customer.explain(mode="formatted")

    if args.sleep_seconds > 0:
        print(f"Sleeping {args.sleep_seconds}s so you can inspect Spark UI at http://localhost:4040")
        time.sleep(args.sleep_seconds)

    spark.stop()


if __name__ == "__main__":
    main()

