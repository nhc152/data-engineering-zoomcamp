-- Cost-aware quality check patterns.

-- Bad pattern on huge partitioned table:
-- select count(*) from marts.fct_orders;

-- Better: check recent partition only.
select
    'recent_partition_row_count' as check_id,
    order_date,
    count(*) as row_count
from marts.fct_orders
where order_date >= current_date - interval '2 days'
group by order_date;

-- Better: store daily metrics once and compare from metadata table.
insert into quality.check_results (
    check_id,
    check_name,
    severity,
    owner,
    table_name,
    business_date,
    expected_value,
    actual_value,
    status,
    impact,
    runbook_url
)
select
    'daily_fct_orders_row_count',
    'Daily fct_orders row count captured for trend analysis',
    'P3',
    'data-platform',
    'marts.fct_orders',
    order_date,
    'not_null',
    count(*)::text,
    'captured',
    'Used for trend baseline and anomaly checks',
    'runbook/freshness_breach.md'
from marts.fct_orders
where order_date >= current_date - interval '2 days'
group by order_date;

