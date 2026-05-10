import time
from pathlib import Path

import duckdb
import pandas as pd


REPORT_DIR = Path("data/reports")


def timed_query(con: duckdb.DuckDBPyConnection, name: str, sql: str) -> dict:
    start = time.perf_counter()
    result = con.execute(sql).fetchall()
    elapsed_ms = (time.perf_counter() - start) * 1000
    return {
        "query_name": name,
        "elapsed_ms": round(elapsed_ms, 2),
        "result_rows": len(result),
    }


def main() -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect()

    queries = {
        "csv_selected_columns": """
            select order_date, sum(recognized_revenue) as revenue
            from read_csv_auto('data/raw/orders.csv')
            where order_date between '2026-05-01' and '2026-05-07'
            group by order_date
        """,
        "parquet_selected_columns": """
            select order_date, sum(recognized_revenue) as revenue
            from read_parquet('data/lake/orders_parquet_snappy/orders.parquet')
            where order_date between '2026-05-01' and '2026-05-07'
            group by order_date
        """,
        "parquet_select_star_bad": """
            select *
            from read_parquet('data/lake/orders_parquet_snappy/orders.parquet')
            where order_date = '2026-05-01'
        """,
        "partitioned_parquet_filter": """
            select order_date, sum(recognized_revenue) as revenue
            from read_parquet('data/lake/orders_partitioned/order_date=2026-05-01/*.parquet')
            group by order_date
        """,
        "small_files_one_month": """
            select order_date, sum(recognized_revenue) as revenue
            from read_parquet('data/lake/orders_small_files/**/*.parquet')
            group by order_date
        """,
        "compacted_one_month": """
            select order_date, sum(recognized_revenue) as revenue
            from read_parquet('data/lake/orders_compacted/**/*.parquet')
            group by order_date
        """,
    }

    rows = []
    for name, sql in queries.items():
        rows.append(timed_query(con, name, sql))

    report = pd.DataFrame(rows)
    report_path = REPORT_DIR / "query_timing_report.csv"
    report.to_csv(report_path, index=False)
    print(report.to_string(index=False))
    print(f"Wrote query timing report: {report_path}")

    explain_sql = """
        explain
        select order_date, sum(recognized_revenue) as revenue
        from read_parquet('data/lake/orders_parquet_snappy/orders.parquet')
        where order_date = '2026-05-01'
        group by order_date
    """
    explain_path = REPORT_DIR / "duckdb_explain_predicate_pushdown.txt"
    explain_text = con.execute(explain_sql).fetchall()
    explain_path.write_text("\n".join(str(row) for row in explain_text), encoding="utf-8")
    print(f"Wrote explain output: {explain_path}")


if __name__ == "__main__":
    main()

