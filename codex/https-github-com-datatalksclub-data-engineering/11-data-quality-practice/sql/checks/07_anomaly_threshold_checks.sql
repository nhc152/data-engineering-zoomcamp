-- Simple anomaly threshold check.
-- This is a starting point, not a full anomaly detection system.

with daily_revenue as (
    select
        order_date,
        sum(recognized_revenue) as revenue
    from marts.fct_orders
    group by order_date
),

baseline as (
    select
        order_date,
        revenue,
        avg(revenue) over (
            order by order_date
            rows between 7 preceding and 1 preceding
        ) as trailing_avg,
        stddev(revenue) over (
            order by order_date
            rows between 7 preceding and 1 preceding
        ) as trailing_stddev
    from daily_revenue
)

select
    'anomaly_daily_revenue' as check_id,
    order_date,
    revenue,
    trailing_avg,
    trailing_stddev,
    case
        when trailing_avg is null then 'warn_no_baseline'
        when trailing_stddev is null or trailing_stddev = 0 then 'pass'
        when abs(revenue - trailing_avg) > trailing_stddev * 3 then 'fail_anomaly'
        else 'pass'
    end as status
from baseline
order by order_date desc;

