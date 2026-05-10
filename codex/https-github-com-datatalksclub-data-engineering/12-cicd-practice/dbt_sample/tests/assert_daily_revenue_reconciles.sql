with fact as (
    select
        order_date,
        sum(recognized_revenue) as revenue_from_fact
    from {{ ref('fct_orders') }}
    group by order_date
),

mart as (
    select
        order_date,
        recognized_revenue as revenue_from_mart
    from {{ ref('mart_daily_revenue') }}
)

select
    fact.order_date,
    fact.revenue_from_fact,
    mart.revenue_from_mart
from fact
left join mart
    on fact.order_date = mart.order_date
where fact.revenue_from_fact != mart.revenue_from_mart

