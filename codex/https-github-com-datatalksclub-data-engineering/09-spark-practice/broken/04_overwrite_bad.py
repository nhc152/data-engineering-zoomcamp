from __future__ import annotations

from pathlib import Path

from pyspark.sql.functions import col

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"
OUT = ROOT / "data" / "output" / "broken_overwrite" / "orders"


def main() -> None:
    spark = build_spark("bad-overwrite")
    orders = spark.read.parquet(str(PARQUET / "orders"))

    # Bad pattern:
    # A backfill for one date overwrites the whole output table path.
    may_01 = orders.filter(col("order_date") == "2026-05-01")
    may_01.write.mode("overwrite").parquet(str(OUT))
    print("Wrote May 01")

    may_02 = orders.filter(col("order_date") == "2026-05-02")
    may_02.write.mode("overwrite").parquet(str(OUT))
    print("Wrote May 02 and accidentally replaced May 01")

    print("Final row count:", spark.read.parquet(str(OUT)).count())
    spark.stop()


if __name__ == "__main__":
    main()

