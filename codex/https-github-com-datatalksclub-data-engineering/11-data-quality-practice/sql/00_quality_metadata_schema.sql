-- Optional metadata tables for storing quality check results.
-- PostgreSQL-compatible. Adapt types for BigQuery if needed.

create schema if not exists quality;

create table if not exists quality.check_results (
    check_id text not null,
    check_name text not null,
    severity text not null,
    owner text not null,
    table_name text not null,
    business_date date,
    expected_value text,
    actual_value text,
    status text not null,
    impact text,
    runbook_url text,
    checked_at timestamptz default now()
);

create table if not exists quality.source_daily_controls (
    source_name text not null,
    entity_name text not null,
    business_date date not null,
    expected_row_count integer,
    expected_total_amount numeric(18, 2),
    delivered_at timestamptz,
    primary key (source_name, entity_name, business_date)
);

