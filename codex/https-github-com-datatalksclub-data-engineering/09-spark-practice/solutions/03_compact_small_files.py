from __future__ import annotations

from pathlib import Path

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
IN = ROOT / "data" / "output" / "broken_small_files"
OUT = ROOT / "data" / "output" / "solutions" / "compacted_small_files"


def main() -> None:
    spark = build_spark("solution-compact-small-files")
    df = spark.read.parquet(str(IN))

    # Good pattern:
    # Compact to a reasonable number of files. Do not always coalesce(1).
    df.coalesce(4).write.mode("overwrite").parquet(str(OUT))
    print(f"Compacted output written to {OUT}")
    spark.stop()


if __name__ == "__main__":
    main()

