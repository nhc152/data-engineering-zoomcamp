-- dbt singular test example.
-- Expected result: zero rows.

with raw_payment_totals as (
    select
        cast(payment_timestamp as date) as payment_date,
        sum(case when lower(payment_status) = 'captured' then amount else 0 end) as raw_captured_amount
    from {{ source('raw', 'payments') }}
    group by cast(payment_timestamp as date)
),

mart_revenue as (
    select
        order_date,
        sum(recognized_revenue) as mart_recognized_revenue
    from {{ ref('fct_orders') }}
    group by order_date
)

select
    coalesce(raw_payment_totals.payment_date, mart_revenue.order_date) as business_date,
    coalesce(raw_payment_totals.raw_captured_amount, 0) as raw_captured_amount,
    coalesce(mart_revenue.mart_recognized_revenue, 0) as mart_recognized_revenue
from raw_payment_totals
full outer join mart_revenue
    on raw_payment_totals.payment_date = mart_revenue.order_date
where abs(coalesce(raw_payment_totals.raw_captured_amount, 0) - coalesce(mart_revenue.mart_recognized_revenue, 0)) > 0.01

