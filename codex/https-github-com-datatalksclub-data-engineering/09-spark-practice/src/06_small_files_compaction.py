from __future__ import annotations

from pathlib import Path

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"
OUT = ROOT / "data" / "output" / "small_files_demo"


def main() -> None:
    spark = build_spark("small-files-compaction")
    orders = spark.read.parquet(str(PARQUET / "orders"))

    small_files_path = OUT / "bad_many_files"
    compacted_path = OUT / "compacted"

    orders.repartition(80).write.mode("overwrite").parquet(str(small_files_path))
    print(f"Wrote many small files to {small_files_path}")

    compacted = spark.read.parquet(str(small_files_path)).coalesce(4)
    compacted.write.mode("overwrite").parquet(str(compacted_path))
    print(f"Wrote compacted files to {compacted_path}")

    spark.stop()


if __name__ == "__main__":
    main()

