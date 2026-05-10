# Level 02 - Changelog and Current-State Tables

## Goal

Apply CDC events into raw changelog and current-state tables.

## Tasks

1. Start PostgreSQL.
2. Apply `events/01_snapshot_orders.jsonl`.
3. Apply `events/02_change_stream_orders.jsonl`.
4. Query `cdc.raw_orders_changelog`.
5. Query `cdc.orders_current`.
6. Run `sql/validation_queries.sql`.

## Expected Output

- Changelog contains every non-duplicate CDC event.
- Current-state contains one row per order.
- Deleted order is marked `is_deleted = true`.

## Questions

- Why keep changelog if current table exists?
- Why current-state table needs `last_source_lsn`?
- Should marts filter `is_deleted`?
