import argparse
import json
from pathlib import Path

import psycopg
from psycopg.types.json import Jsonb


DSN = "host=localhost port=5432 dbname=cdc_practice user=cdc_user password=cdc_password"


def extract_event_fields(event: dict) -> dict:
    payload = event.get("payload")
    if payload is None:
        return {
            "event_id": event["event_id"],
            "source_db": "unknown",
            "source_schema": "unknown",
            "source_table": "unknown",
            "source_lsn": -1,
            "source_tx_id": None,
            "source_ts_ms": 0,
            "op": "tombstone",
            "primary_key": None,
            "before_data": None,
            "after_data": None,
        }

    source = payload["source"]
    before = payload.get("before")
    after = payload.get("after")
    primary_key = None
    if after and after.get("order_id"):
        primary_key = after["order_id"]
    elif before and before.get("order_id"):
        primary_key = before["order_id"]

    return {
        "event_id": event["event_id"],
        "source_db": source["db"],
        "source_schema": source["schema"],
        "source_table": source["table"],
        "source_lsn": int(source["lsn"]),
        "source_tx_id": source.get("txId"),
        "source_ts_ms": int(source["ts_ms"]),
        "op": payload["op"],
        "primary_key": primary_key,
        "before_data": before,
        "after_data": after,
    }


def insert_changelog(cur: psycopg.Cursor, fields: dict, event: dict, batch_id: str) -> bool:
    try:
        cur.execute(
            """
            insert into cdc.raw_orders_changelog (
                event_id,
                batch_id,
                source_db,
                source_schema,
                source_table,
                source_lsn,
                source_tx_id,
                source_ts_ms,
                op,
                primary_key,
                before_data,
                after_data,
                event_payload
            )
            values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            on conflict (event_id) do nothing
            """,
            (
                fields["event_id"],
                batch_id,
                fields["source_db"],
                fields["source_schema"],
                fields["source_table"],
                fields["source_lsn"],
                fields["source_tx_id"],
                fields["source_ts_ms"],
                fields["op"],
                fields["primary_key"],
                Jsonb(fields["before_data"]),
                Jsonb(fields["after_data"]),
                Jsonb(event),
            ),
        )
        return cur.rowcount == 1
    except Exception:
        cur.execute(
            """
            insert into cdc.dlq_events (event_id, reason, event_payload)
            values (%s, %s, %s)
            """,
            (event.get("event_id"), "failed to insert changelog", Jsonb(event)),
        )
        return False


def apply_current_state(cur: psycopg.Cursor, fields: dict) -> None:
    if fields["op"] == "tombstone":
        return

    cur.execute(
        """
        select cdc.apply_order_change(%s, %s, %s, %s, %s, %s, %s)
        """,
        (
            fields["event_id"],
            fields["source_lsn"],
            fields["source_ts_ms"],
            fields["op"],
            fields["primary_key"],
            Jsonb(fields["after_data"]),
            Jsonb(fields["before_data"]),
        ),
    )


def update_offset(cur: psycopg.Cursor, fields: dict) -> None:
    if fields["source_lsn"] < 0:
        return
    cur.execute(
        """
        update cdc.consumer_offsets
        set
            last_source_lsn = greatest(last_source_lsn, %s),
            last_event_id = %s,
            committed_at = now()
        where consumer_name = 'orders_current_applier'
        """,
        (fields["source_lsn"], fields["event_id"]),
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--events", required=True)
    parser.add_argument("--batch-id", required=True)
    args = parser.parse_args()

    event_path = Path(args.events)
    applied = 0
    duplicates = 0

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            with event_path.open("r", encoding="utf-8") as file:
                for line in file:
                    event = json.loads(line)
                    fields = extract_event_fields(event)
                    inserted = insert_changelog(cur, fields, event, args.batch_id)
                    if not inserted:
                        duplicates += 1
                        continue
                    apply_current_state(cur, fields)
                    update_offset(cur, fields)
                    applied += 1

        conn.commit()

    print(f"Applied events: {applied}")
    print(f"Skipped duplicate/failed events: {duplicates}")


if __name__ == "__main__":
    main()

