from __future__ import annotations

from pathlib import Path

from spark_session import build_spark


ROOT = Path(__file__).resolve().parents[1]
PARQUET = ROOT / "data" / "output" / "parquet"
OUT = ROOT / "data" / "output" / "broken_oom"


def main() -> None:
    spark = build_spark("bad-executor-oom")
    orders = spark.read.parquet(str(PARQUET / "orders"))

    # Bad pattern:
    # coalesce(1) forces one task to write the whole dataset.
    # On large data this can make one executor run out of memory or become a bottleneck.
    orders.coalesce(1).write.mode("overwrite").parquet(str(OUT))
    print(f"Wrote single-file-ish output to {OUT}")
    spark.stop()


if __name__ == "__main__":
    main()

