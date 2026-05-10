import sqlite3

from common import DATA, explain, print_rows, read_jsonl, reset_db


def setup(conn: sqlite3.Connection) -> None:
    conn.executescript(
        """
        create table customer_state_naive (
            customer_id text primary key,
            customer_tier text,
            source_version integer,
            source_updated_at text
        );

        create table customer_state_versioned (
            customer_id text primary key,
            customer_tier text,
            source_version integer,
            source_updated_at text
        );
        """
    )


def main() -> None:
    conn = reset_db("03_out_of_order_cdc.sqlite")
    setup(conn)
    events = read_jsonl(DATA / "cdc_events_out_of_order.jsonl")

    print("Scenario: CDC events arrive out of order.")
    print("Version 3 arrives before version 2. Naive sink applies old version last.")

    for event in events:
        conn.execute(
            """
            insert into customer_state_naive (customer_id, customer_tier, source_version, source_updated_at)
            values (?, ?, ?, ?)
            on conflict(customer_id) do update set
                customer_tier = excluded.customer_tier,
                source_version = excluded.source_version,
                source_updated_at = excluded.source_updated_at
            """,
            (
                event["customer_id"],
                event["customer_tier"],
                event["source_version"],
                event["source_updated_at"],
            ),
        )

        conn.execute(
            """
            insert into customer_state_versioned (customer_id, customer_tier, source_version, source_updated_at)
            values (?, ?, ?, ?)
            on conflict(customer_id) do update set
                customer_tier = case
                    when excluded.source_version > customer_state_versioned.source_version
                    then excluded.customer_tier
                    else customer_state_versioned.customer_tier
                end,
                source_version = max(customer_state_versioned.source_version, excluded.source_version),
                source_updated_at = case
                    when excluded.source_version > customer_state_versioned.source_version
                    then excluded.source_updated_at
                    else customer_state_versioned.source_updated_at
                end
            """,
            (
                event["customer_id"],
                event["customer_tier"],
                event["source_version"],
                event["source_updated_at"],
            ),
        )

    conn.commit()

    print_rows(conn, "Naive current state is stale", "select * from customer_state_naive")
    print_rows(conn, "Version-aware current state is correct", "select * from customer_state_versioned")

    explain(
        "Prevention strategy",
        [
            "Carry source ordering metadata: LSN, binlog position, source_version, or updated_at.",
            "Do not let older updates overwrite newer state.",
            "In Kafka, key by entity to preserve per-entity ordering when possible.",
            "In CDC, compare source version/position before updating current-state tables.",
        ],
    )


if __name__ == "__main__":
    main()

