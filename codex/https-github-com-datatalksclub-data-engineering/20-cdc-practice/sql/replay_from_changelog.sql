-- Rebuild current-state table from immutable changelog.
-- Use when current-state table is corrupted or apply logic changes.

truncate table cdc.orders_current;

select cdc.apply_order_change(
    event_id,
    source_lsn,
    source_ts_ms,
    op,
    primary_key,
    after_data,
    before_data
)
from cdc.raw_orders_changelog
order by source_lsn, changelog_id;

select * from cdc.orders_current order by order_id;

