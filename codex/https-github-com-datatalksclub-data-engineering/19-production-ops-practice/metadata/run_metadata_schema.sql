-- Run metadata schema for a production data pipeline.
-- This SQL is warehouse-style and may need small syntax adjustments by engine.

create table if not exists ops.pipeline_runs (
    run_id string not null,
    pipeline_name string not null,
    environment string not null,
    run_type string not null, -- scheduled, manual, backfill, replay
    data_interval_start timestamp not null,
    data_interval_end timestamp not null,
    status string not null, -- running, success, failed, partial, blocked
    started_at timestamp not null,
    finished_at timestamp,
    triggered_by string,
    code_version string,
    orchestrator_run_url string,
    cost_estimate_usd numeric,
    created_at timestamp not null
);

create table if not exists ops.pipeline_task_runs (
    run_id string not null,
    task_name string not null,
    status string not null,
    attempt_number int64 not null,
    started_at timestamp not null,
    finished_at timestamp,
    error_type string,
    error_message string,
    input_row_count int64,
    output_row_count int64,
    bytes_processed int64,
    retryable bool,
    task_log_url string
);

create table if not exists ops.data_quality_results (
    run_id string not null,
    check_name string not null,
    table_name string not null,
    severity string not null, -- warn, block
    status string not null, -- pass, fail
    measured_value string,
    threshold_value string,
    sample_rows_query string,
    created_at timestamp not null
);

create table if not exists ops.publish_events (
    run_id string not null,
    table_name string not null,
    partition_date date,
    publish_status string not null, -- published, blocked, rolled_back
    published_at timestamp,
    blocked_reason string,
    approver string
);

create table if not exists ops.incidents (
    incident_id string not null,
    severity string not null,
    title string not null,
    owner string not null,
    status string not null, -- open, mitigated, resolved
    started_at timestamp not null,
    detected_at timestamp not null,
    resolved_at timestamp,
    impact_summary string,
    root_cause string,
    prevention string
);

