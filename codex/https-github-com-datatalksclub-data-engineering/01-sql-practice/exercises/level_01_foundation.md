# Level 01 - Foundation

Goal: get comfortable reading raw ecommerce tables and writing basic SQL that Data Engineers use every day.

## Tasks

1. Count rows in each raw table.
2. List all order statuses from `raw.orders`.
3. Normalize order status casing in a query.
4. Count orders by UTC order date.
5. Calculate total payment amount by payment status.
6. Find customers with missing email or phone.
7. Find products with price greater than 100.
8. Compare `count(*)` and `count(email)` on `raw.customers`.

## Expected Learning

- Raw data is not clean.
- Casing and whitespace matter.
- NULL handling matters.
- Basic profiling queries are part of real DE work.

## Starter Queries

```sql
select count(*) from raw.orders;

select distinct order_status from raw.orders;

select
    lower(trim(order_status)) as normalized_status,
    count(*) as row_count
from raw.orders
group by lower(trim(order_status))
order by row_count desc;
```

## Done When

You can explain the difference between raw row count and business entity count, for example raw order rows vs distinct order IDs.

