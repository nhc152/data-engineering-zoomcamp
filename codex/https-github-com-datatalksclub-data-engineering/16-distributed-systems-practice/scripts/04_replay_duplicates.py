import sqlite3

from common import DATA, explain, now_iso, print_rows, read_jsonl, reset_db


def setup(conn: sqlite3.Connection) -> None:
    conn.executescript(
        """
        create table published_events_naive (
            publish_row_id integer primary key autoincrement,
            event_id text,
            publish_status text,
            published_at text
        );

        create table published_events_idempotent (
            event_id text primary key,
            publish_status text,
            published_at text
        );
        """
    )


def publish_events(conn: sqlite3.Connection, events: list[dict], run_name: str) -> None:
    print(f"Publishing run: {run_name}")
    for event in events:
        conn.execute(
            """
            insert into published_events_naive (event_id, publish_status, published_at)
            values (?, 'published', ?)
            """,
            (event["event_id"], now_iso()),
        )
        conn.execute(
            """
            insert or ignore into published_events_idempotent (event_id, publish_status, published_at)
            values (?, 'published', ?)
            """,
            (event["event_id"], now_iso()),
        )
    conn.commit()


def main() -> None:
    conn = reset_db("04_replay_duplicates.sqlite")
    setup(conn)
    events = read_jsonl(DATA / "replay_events.jsonl")

    first_run = events[:2]
    replay_run = events

    print("Scenario: replay reprocesses events already published.")
    publish_events(conn, first_run, "initial")
    publish_events(conn, replay_run, "replay from raw log")

    print_rows(
        conn,
        "Naive publish table duplicates events",
        "select event_id, count(*) as publish_count from published_events_naive group by event_id order by event_id",
    )
    print_rows(
        conn,
        "Idempotent publish table has one row per event",
        "select event_id, publish_status from published_events_idempotent order by event_id",
    )

    explain(
        "Prevention strategy",
        [
            "Replay is required for recovery, but replay must be safe.",
            "Publish tables need idempotent keys or versioned outputs.",
            "For Spark backfills, write to temp path and atomically swap/overwrite intended partitions.",
            "For orchestration, backfill should not blindly append into current marts.",
        ],
    )


if __name__ == "__main__":
    main()

