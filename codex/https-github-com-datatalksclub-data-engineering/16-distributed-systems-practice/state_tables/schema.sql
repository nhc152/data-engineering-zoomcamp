-- Reference state tables used by the simulations.

create table if not exists raw_events (
    event_id text,
    entity_id text,
    event_type text,
    payload text,
    received_at text
);

create table if not exists naive_order_sink (
    sink_row_id integer primary key autoincrement,
    event_id text,
    order_id text,
    amount numeric,
    processed_at text
);

create table if not exists idempotent_order_sink (
    event_id text primary key,
    order_id text,
    amount numeric,
    processed_at text
);

create table if not exists consumer_offsets (
    consumer_name text primary key,
    committed_offset integer not null
);

create table if not exists customer_state_naive (
    customer_id text primary key,
    customer_tier text,
    source_version integer,
    source_updated_at text
);

create table if not exists customer_state_versioned (
    customer_id text primary key,
    customer_tier text,
    source_version integer,
    source_updated_at text
);

create table if not exists published_events (
    event_id text primary key,
    publish_status text,
    published_at text
);

