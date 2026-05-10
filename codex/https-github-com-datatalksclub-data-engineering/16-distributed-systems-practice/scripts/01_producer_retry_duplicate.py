import sqlite3
from pathlib import Path

from common import DATA, explain, now_iso, print_rows, read_jsonl, reset_db


def setup(conn: sqlite3.Connection) -> None:
    conn.executescript(
        """
        create table naive_order_sink (
            sink_row_id integer primary key autoincrement,
            event_id text,
            order_id text,
            amount numeric,
            processed_at text
        );

        create table idempotent_order_sink (
            event_id text primary key,
            order_id text,
            amount numeric,
            processed_at text
        );
        """
    )


def main() -> None:
    conn = reset_db("01_producer_retry_duplicate.sqlite")
    setup(conn)
    events = read_jsonl(DATA / "events.jsonl")

    print("Scenario: producer retries after lost acknowledgement.")
    print("`evt-001` appears twice with producer_attempt 1 and 2.")

    for event in events:
        conn.execute(
            """
            insert into naive_order_sink (event_id, order_id, amount, processed_at)
            values (?, ?, ?, ?)
            """,
            (event["event_id"], event["order_id"], event["amount"], now_iso()),
        )

        conn.execute(
            """
            insert or ignore into idempotent_order_sink (event_id, order_id, amount, processed_at)
            values (?, ?, ?, ?)
            """,
            (event["event_id"], event["order_id"], event["amount"], now_iso()),
        )

    conn.commit()

    print_rows(
        conn,
        "Naive sink has duplicate writes",
        "select event_id, order_id, amount, count(*) as row_count from naive_order_sink group by event_id, order_id, amount",
    )
    print_rows(
        conn,
        "Idempotent sink keeps one row per event_id",
        "select event_id, order_id, amount from idempotent_order_sink order by event_id",
    )

    explain(
        "Prevention strategy",
        [
            "Use stable event_id or business key.",
            "Make sink idempotent with unique key and upsert/insert-ignore semantics.",
            "In Kafka, idempotent producer helps inside Kafka, but sink still needs idempotency.",
            "In orchestration, retrying a task must not append duplicate output.",
        ],
    )


if __name__ == "__main__":
    main()

