# Level 02 - Joins and Grain

Goal: understand how joins change grain and create duplicated metrics.

## Tasks

1. Count rows and distinct `order_id` in `staging.stg_orders`.
2. Count rows and distinct `order_id` in `staging.stg_order_items`.
3. Join orders to order items and observe row count.
4. Explain why the joined result is no longer one row per order.
5. Aggregate `staging.stg_order_items` to one row per order.
6. Join aggregated item totals back to orders.
7. Check whether customer dimension has one row per customer.

## Broken Query to Study

Open:

```text
interview/broken_join.sql
```

Explain why summing payment amount after joining item-level rows overstates revenue.

## Diagnostic Queries

```sql
select
    count(*) as rows,
    count(distinct order_id) as distinct_orders
from staging.stg_orders;

select
    order_id,
    count(*) as item_rows
from staging.stg_order_items
group by order_id
having count(*) > 1;
```

## Done When

You can say clearly:

- input grain
- output grain
- why revenue gets duplicated
- how to fix it by aggregating before joining

