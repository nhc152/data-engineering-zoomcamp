-- Broken sink pattern.
-- If Kafka redelivers the same event, this table design allows duplicate outputs.

create table if not exists broken_orders_sink (
    row_id bigserial primary key,
    event_id text,
    order_id text,
    amount numeric(12, 2),
    inserted_at timestamptz default now()
);

-- Bad insert pattern:
-- insert into broken_orders_sink(event_id, order_id, amount)
-- values (:event_id, :order_id, :amount);

-- Fix:
-- use processed_events(event_id primary key), or make event_id unique,
-- or upsert by deterministic business key + version.

