-- O1010 is late-arriving: order_date is 2026-05-01, but updated_at/ingestion_timestamp is 2026-05-06.

select
    order_id,
    order_date,
    updated_at,
    ingestion_timestamp
from marts.fct_orders
where order_id = 'O1010';

-- This bad incremental filter misses late-arriving data if the pipeline only filters order_date.
select
    order_id,
    order_date,
    updated_at
from marts.fct_orders
where order_date > date '2026-05-04';

-- This better filter catches late-arriving changes by updated_at.
select
    order_id,
    order_date,
    updated_at
from marts.fct_orders
where updated_at > timestamptz '2026-05-04 00:00:00+00';

