create table if not exists orders (
    order_id text primary key,
    customer_id text not null,
    order_timestamp timestamptz not null,
    order_date date not null,
    status text not null,
    amount numeric(12, 2) not null,
    updated_at timestamptz not null,
    source_name text not null,
    run_id text not null,
    ingested_at timestamptz not null default now()
);

create table if not exists pipeline_runs (
    run_id text primary key,
    source_name text not null,
    run_date date not null,
    status text not null,
    extracted_count integer not null default 0,
    valid_count integer not null default 0,
    rejected_count integer not null default 0,
    loaded_count integer not null default 0,
    started_at timestamptz not null default now(),
    finished_at timestamptz,
    error_message text
);

create table if not exists rejected_records (
    rejected_record_id bigserial primary key,
    run_id text not null,
    source_name text not null,
    reason text not null,
    raw_record jsonb not null,
    rejected_at timestamptz not null default now()
);

