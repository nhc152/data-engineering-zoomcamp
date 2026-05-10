import sqlite3

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

        create table consumer_offsets (
            consumer_name text primary key,
            committed_offset integer not null
        );

        insert into consumer_offsets (consumer_name, committed_offset)
        values ('orders_consumer', -1);
        """
    )


def process_event(conn: sqlite3.Connection, event: dict, offset: int, commit_offset: bool) -> None:
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

    if commit_offset:
        conn.execute(
            """
            update consumer_offsets
            set committed_offset = ?
            where consumer_name = 'orders_consumer'
            """,
            (offset,),
        )
    conn.commit()


def main() -> None:
    conn = reset_db("02_consumer_crash.sqlite")
    setup(conn)
    events = read_jsonl(DATA / "replay_events.jsonl")[:2]

    print("Scenario: consumer writes to sink, then crashes before offset commit.")
    print("On restart, same event is processed again because committed offset did not advance.")

    process_event(conn, events[0], offset=0, commit_offset=False)
    print("Crash simulated after sink write before offset commit for offset 0.")

    committed_offset = conn.execute(
        "select committed_offset from consumer_offsets where consumer_name = 'orders_consumer'"
    ).fetchone()["committed_offset"]
    print(f"Committed offset after crash: {committed_offset}")

    print("Restart: consumer reads offset 0 again.")
    process_event(conn, events[0], offset=0, commit_offset=True)
    process_event(conn, events[1], offset=1, commit_offset=True)

    print_rows(
        conn,
        "Naive sink duplicates event after restart",
        "select event_id, order_id, count(*) as row_count from naive_order_sink group by event_id, order_id",
    )
    print_rows(
        conn,
        "Idempotent sink avoids duplicate final state",
        "select event_id, order_id, amount from idempotent_order_sink order by event_id",
    )
    print_rows(conn, "Committed offset", "select * from consumer_offsets")

    explain(
        "Prevention strategy",
        [
            "Expect at-least-once processing when sink write and offset commit are separate.",
            "Use idempotent sink writes keyed by event_id or business key.",
            "For Kafka, transactions can help for Kafka-to-Kafka, but external sinks still need correctness design.",
            "For CDC, store source LSN/version and ignore stale duplicate changes.",
        ],
    )


if __name__ == "__main__":
    main()

