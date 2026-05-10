import shutil
from pathlib import Path

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq


RAW_DIR = Path("data/raw")
LAKE_DIR = Path("data/lake")
REPORT_DIR = Path("data/reports")


def reset_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def file_size_mb(path: Path) -> float:
    return path.stat().st_size / 1024 / 1024


def directory_size_mb(path: Path) -> float:
    return sum(file.stat().st_size for file in path.rglob("*") if file.is_file()) / 1024 / 1024


def write_partitioned_dataset(table: pa.Table, output_dir: Path) -> None:
    reset_dir(output_dir)
    df = table.to_pandas()
    for order_date, group in df.groupby("order_date"):
        date_dir = output_dir / f"order_date={order_date}"
        date_dir.mkdir(parents=True, exist_ok=True)
        pq.write_table(pa.Table.from_pandas(group, preserve_index=False), date_dir / "part-00000.parquet", compression="snappy")


def write_small_files(df: pd.DataFrame, output_dir: Path, chunk_size: int = 200) -> None:
    reset_dir(output_dir)
    for order_date, group in df.groupby("order_date"):
        date_dir = output_dir / f"order_date={order_date}"
        date_dir.mkdir(parents=True, exist_ok=True)
        for i, start in enumerate(range(0, len(group), chunk_size)):
            chunk = group.iloc[start : start + chunk_size]
            pq.write_table(pa.Table.from_pandas(chunk, preserve_index=False), date_dir / f"part-{i:05d}.parquet")


def compact_small_files(input_dir: Path, output_dir: Path) -> None:
    reset_dir(output_dir)
    for date_dir in sorted(input_dir.glob("order_date=*")):
        if not date_dir.is_dir():
            continue
        target_dir = output_dir / date_dir.name
        target_dir.mkdir(parents=True, exist_ok=True)
        table = pq.read_table(date_dir)
        pq.write_table(table, target_dir / "part-00000.parquet", compression="snappy")


def main() -> None:
    csv_path = RAW_DIR / "orders.csv"
    if not csv_path.exists():
        raise FileNotFoundError("Run `python src/generate_data.py --rows 50000` first.")

    LAKE_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_DIR.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(csv_path, parse_dates=["order_timestamp"])
    df["order_date"] = df["order_date"].astype(str)
    table = pa.Table.from_pandas(df, preserve_index=False)

    outputs = []

    parquet_dir = LAKE_DIR / "orders_parquet"
    reset_dir(parquet_dir)
    parquet_path = parquet_dir / "orders.parquet"
    pq.write_table(table, parquet_path, compression=None)
    outputs.append(("parquet_uncompressed", file_size_mb(parquet_path)))

    for compression in ["snappy", "gzip", "zstd"]:
        out_dir = LAKE_DIR / f"orders_parquet_{compression}"
        reset_dir(out_dir)
        out_path = out_dir / "orders.parquet"
        pq.write_table(table, out_path, compression=compression)
        outputs.append((f"parquet_{compression}", file_size_mb(out_path)))

    partitioned_dir = LAKE_DIR / "orders_partitioned"
    write_partitioned_dataset(table, partitioned_dir)
    outputs.append(("parquet_partitioned", directory_size_mb(partitioned_dir)))

    small_files_dir = LAKE_DIR / "orders_small_files"
    write_small_files(df, small_files_dir)
    outputs.append(("parquet_small_files", directory_size_mb(small_files_dir)))

    compacted_dir = LAKE_DIR / "orders_compacted"
    compact_small_files(small_files_dir, compacted_dir)
    outputs.append(("parquet_compacted", directory_size_mb(compacted_dir)))

    outputs.append(("csv_raw", file_size_mb(csv_path)))
    outputs.append(("jsonl_raw", file_size_mb(RAW_DIR / "orders.jsonl")))

    report_path = REPORT_DIR / "file_size_report.csv"
    pd.DataFrame(outputs, columns=["artifact", "size_mb"]).sort_values("artifact").to_csv(report_path, index=False)

    print("Wrote lake datasets under data/lake")
    print(f"Wrote size report: {report_path}")
    print(pd.read_csv(report_path).to_string(index=False))


if __name__ == "__main__":
    main()
