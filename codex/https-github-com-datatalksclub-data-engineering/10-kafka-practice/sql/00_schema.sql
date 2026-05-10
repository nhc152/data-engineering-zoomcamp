create table if not exists processed_events (
    event_id text primary key,
    event_type text not null,
    order_id text,
    source_topic text,
    source_partition integer,
    source_offset bigint,
    processed_at timestamptz default now()
);

create table if not exists orders_sink (
    order_id text primary key,
    customer_id text,
    order_status text,
    amount numeric(12, 2),
    event_timestamp timestamptz,
    last_event_id text,
    updated_at timestamptz default now()
);

create table if not exists dlq_events (
    dlq_id bigserial primary key,
    event_id text,
    order_id text,
    source_topic text,
    source_partition integer,
    source_offset bigint,
    error_message text,
    raw_payload jsonb,
    failed_at timestamptz default now()
);

create index if not exists idx_dlq_events_event_id on dlq_events(event_id);
create index if not exists idx_orders_sink_customer_id on orders_sink(customer_id);

