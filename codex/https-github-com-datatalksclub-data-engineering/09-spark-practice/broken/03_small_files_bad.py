from __future__ import annotations

from pathlib import Path

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"
OUT = ROOT / "data" / "output" / "broken_small_files"


def main() -> None:
    spark = build_spark("bad-small-files")
    orders = spark.read.parquet(str(PARQUET / "orders"))

    # Bad pattern:
    # Excessive repartition creates many tiny output files for a small dataset.
    orders.repartition(200).write.mode("overwrite").parquet(str(OUT))
    print(f"Wrote too many files to {OUT}")
    spark.stop()


if __name__ == "__main__":
    main()

