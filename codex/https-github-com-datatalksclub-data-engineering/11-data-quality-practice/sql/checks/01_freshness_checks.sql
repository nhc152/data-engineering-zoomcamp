-- Freshness checks.
-- Expected: latest data should satisfy the SLA for each table.

-- Raw orders freshness.
select
    'freshness_raw_orders' as check_id,
    'raw.orders latest ingestion_timestamp' as check_name,
    'P1' as severity,
    'data-platform' as owner,
    'raw.orders' as table_name,
    max(ingestion_timestamp) as latest_timestamp,
    now() - max(ingestion_timestamp) as data_age,
    case
        when max(ingestion_timestamp) >= now() - interval '24 hours' then 'pass'
        else 'fail'
    end as status,
    'runbook/freshness_breach.md' as runbook
from raw.orders;

-- Mart orders freshness by business date.
select
    'freshness_mart_fct_orders' as check_id,
    'marts.fct_orders latest order_date' as check_name,
    'P1' as severity,
    'analytics-finance' as owner,
    'marts.fct_orders' as table_name,
    max(order_date) as latest_order_date,
    current_date - max(order_date) as days_behind,
    case
        when max(order_date) >= current_date - interval '1 day' then 'pass'
        else 'fail'
    end as status,
    'runbook/freshness_breach.md' as runbook
from marts.fct_orders;

