drop schema if exists cdc cascade;
create schema cdc;

create table cdc.raw_orders_changelog (
    changelog_id bigserial primary key,
    event_id text not null unique,
    batch_id text not null,
    source_db text not null,
    source_schema text not null,
    source_table text not null,
    source_lsn bigint not null,
    source_tx_id text,
    source_ts_ms bigint not null,
    op text not null,
    primary_key text,
    before_data jsonb,
    after_data jsonb,
    event_payload jsonb not null,
    ingested_at timestamptz not null default now()
);

create table cdc.orders_current (
    order_id text primary key,
    customer_id text,
    order_status text,
    order_amount numeric(12, 2),
    updated_at timestamptz,
    is_deleted boolean not null default false,
    deleted_at timestamptz,
    last_event_id text not null,
    last_source_lsn bigint not null,
    last_source_ts_ms bigint not null,
    applied_at timestamptz not null default now()
);

create table cdc.consumer_offsets (
    consumer_name text primary key,
    last_source_lsn bigint not null,
    last_event_id text,
    committed_at timestamptz not null default now()
);

create table cdc.dlq_events (
    dlq_id bigserial primary key,
    event_id text,
    reason text not null,
    event_payload jsonb,
    created_at timestamptz not null default now()
);

insert into cdc.consumer_offsets (consumer_name, last_source_lsn, last_event_id)
values ('orders_current_applier', 0, null);

