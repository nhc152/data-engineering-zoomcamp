from __future__ import annotations

from pathlib import Path

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"
OUT = ROOT / "data" / "output" / "solutions" / "balanced_output"


def main() -> None:
    spark = build_spark("solution-avoid-single-partition-write")
    orders = spark.read.parquet(str(PARQUET / "orders"))

    # Better pattern:
    # Choose a small but parallel number of output partitions for local data.
    orders.repartition(4).write.mode("overwrite").parquet(str(OUT))
    print(f"Wrote balanced output to {OUT}")
    spark.stop()


if __name__ == "__main__":
    main()

