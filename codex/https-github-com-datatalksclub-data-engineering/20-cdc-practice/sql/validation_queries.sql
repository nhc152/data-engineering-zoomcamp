-- Current state.
select * from cdc.orders_current order by order_id;

-- Changelog count by operation.
select
    op,
    count(*) as event_count
from cdc.raw_orders_changelog
group by op
order by op;

-- Deleted records in current state.
select
    order_id,
    is_deleted,
    deleted_at,
    last_source_lsn
from cdc.orders_current
where is_deleted;

-- Check for duplicate events ignored by unique event_id.
select
    event_id,
    count(*) as row_count
from cdc.raw_orders_changelog
group by event_id
having count(*) > 1;

-- Current offset.
select * from cdc.consumer_offsets;

