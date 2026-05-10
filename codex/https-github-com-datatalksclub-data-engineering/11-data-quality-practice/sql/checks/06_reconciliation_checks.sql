-- Reconciliation checks.
-- Compare source/payment totals to mart totals.

with raw_payment_totals as (
    select
        cast(payment_timestamp as date) as payment_date,
        sum(case when lower(payment_status) = 'captured' then amount else 0 end) as raw_captured_amount
    from raw.payments
    group by cast(payment_timestamp as date)
),

mart_revenue as (
    select
        order_date,
        sum(recognized_revenue) as mart_recognized_revenue
    from marts.fct_orders
    group by order_date
)

select
    'reconcile_payments_to_revenue' as check_id,
    coalesce(raw_payment_totals.payment_date, mart_revenue.order_date) as business_date,
    coalesce(raw_payment_totals.raw_captured_amount, 0) as raw_captured_amount,
    coalesce(mart_revenue.mart_recognized_revenue, 0) as mart_recognized_revenue,
    coalesce(raw_payment_totals.raw_captured_amount, 0) - coalesce(mart_revenue.mart_recognized_revenue, 0) as difference,
    case
        when abs(coalesce(raw_payment_totals.raw_captured_amount, 0) - coalesce(mart_revenue.mart_recognized_revenue, 0)) <= 0.01 then 'pass'
        else 'fail'
    end as status
from raw_payment_totals
full outer join mart_revenue
    on raw_payment_totals.payment_date = mart_revenue.order_date
order by business_date;

