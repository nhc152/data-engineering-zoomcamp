-- Completeness and volume checks.
-- Compare daily row count to a trailing baseline.

with daily_counts as (
    select
        order_date,
        count(*) as order_count
    from marts.fct_orders
    group by order_date
),

baseline as (
    select
        order_date,
        order_count,
        avg(order_count) over (
            order by order_date
            rows between 7 preceding and 1 preceding
        ) as trailing_7_day_avg
    from daily_counts
)

select
    'volume_fct_orders_daily' as check_id,
    order_date,
    order_count,
    trailing_7_day_avg,
    case
        when trailing_7_day_avg is null then 'warn_no_baseline'
        when order_count < trailing_7_day_avg * 0.5 then 'fail_low_volume'
        when order_count > trailing_7_day_avg * 2.0 then 'warn_high_volume'
        else 'pass'
    end as status
from baseline
order by order_date desc;

-- Missing partition check for a specific expected date.
-- Replace the date during practice.
select
    'partition_presence_orders' as check_id,
    date '2026-05-04' as expected_order_date,
    count(*) as actual_rows,
    case
        when count(*) > 0 then 'pass'
        else 'fail_missing_partition'
    end as status
from marts.fct_orders
where order_date = date '2026-05-04';

