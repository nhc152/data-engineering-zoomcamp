from __future__ import annotations

import json
import logging
from collections.abc import Iterable
from typing import Any

import psycopg


logger = logging.getLogger(__name__)


def connect(dsn: str) -> psycopg.Connection:
    return psycopg.connect(dsn)


def start_pipeline_run(
    conn: psycopg.Connection,
    *,
    run_id: str,
    source_name: str,
    run_date: str,
) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into pipeline_runs(run_id, source_name, run_date, status)
            values (%s, %s, %s, 'running')
            on conflict (run_id) do update set
                status = 'running',
                error_message = null,
                started_at = now(),
                finished_at = null
            """,
            (run_id, source_name, run_date),
        )
    conn.commit()


def finish_pipeline_run(
    conn: psycopg.Connection,
    *,
    run_id: str,
    status: str,
    extracted_count: int,
    valid_count: int,
    rejected_count: int,
    loaded_count: int,
    error_message: str | None = None,
) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            update pipeline_runs
            set
                status = %s,
                extracted_count = %s,
                valid_count = %s,
                rejected_count = %s,
                loaded_count = %s,
                finished_at = now(),
                error_message = %s
            where run_id = %s
            """,
            (
                status,
                extracted_count,
                valid_count,
                rejected_count,
                loaded_count,
                error_message,
                run_id,
            ),
        )
    conn.commit()


def load_rejected_records(
    conn: psycopg.Connection,
    *,
    run_id: str,
    source_name: str,
    rejected_records: Iterable[tuple[dict[str, Any], str]],
) -> int:
    rows = [
        (run_id, source_name, reason, json.dumps(raw_record, default=str))
        for raw_record, reason in rejected_records
    ]
    if not rows:
        return 0

    with conn.cursor() as cur:
        cur.executemany(
            """
            insert into rejected_records(run_id, source_name, reason, raw_record)
            values (%s, %s, %s, %s::jsonb)
            """,
            rows,
        )
    conn.commit()
    return len(rows)


def upsert_orders(
    conn: psycopg.Connection,
    records: list[dict[str, Any]],
    *,
    source_name: str,
    run_id: str,
) -> int:
    if not records:
        return 0

    rows = [
        (
            record["order_id"],
            record["customer_id"],
            record["order_timestamp"],
            record["order_date"],
            record["status"],
            record["amount"],
            record["updated_at"],
            source_name,
            run_id,
        )
        for record in records
    ]

    with conn.cursor() as cur:
        cur.executemany(
            """
            insert into orders (
                order_id,
                customer_id,
                order_timestamp,
                order_date,
                status,
                amount,
                updated_at,
                source_name,
                run_id
            )
            values (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            on conflict (order_id) do update set
                customer_id = excluded.customer_id,
                order_timestamp = excluded.order_timestamp,
                order_date = excluded.order_date,
                status = excluded.status,
                amount = excluded.amount,
                updated_at = excluded.updated_at,
                source_name = excluded.source_name,
                run_id = excluded.run_id,
                ingested_at = now()
            where orders.updated_at <= excluded.updated_at
            """,
            rows,
        )
    conn.commit()
    logger.info("orders_upserted", extra={"loaded_count": len(rows), "run_id": run_id})
    return len(rows)

