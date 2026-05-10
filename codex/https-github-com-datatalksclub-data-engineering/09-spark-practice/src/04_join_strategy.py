from __future__ import annotations

from pathlib import Path

from pyspark.sql.functions import broadcast

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"


def main() -> None:
    spark = build_spark("join-strategy")

    order_items = spark.read.parquet(str(PARQUET / "order_items"))
    products = spark.read.parquet(str(PARQUET / "products"))

    normal_join = order_items.join(products, on="product_id", how="left")
    broadcast_join = order_items.join(broadcast(products), on="product_id", how="left")

    print("Normal join physical plan:")
    normal_join.explain(mode="formatted")

    print("Broadcast join physical plan:")
    broadcast_join.explain(mode="formatted")

    print("Normal join count:", normal_join.count())
    print("Broadcast join count:", broadcast_join.count())

    spark.stop()


if __name__ == "__main__":
    main()

