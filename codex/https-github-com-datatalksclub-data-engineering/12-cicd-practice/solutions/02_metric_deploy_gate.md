# Solution 02 - Metric Deployment Gate

Before publishing new dbt metric logic:

1. Build into staging schema.
2. Compare row counts with current prod.
3. Compare key metrics by date.
4. Check accepted status values.
5. Run reconciliation tests.
6. Require review from metric owner.
7. Publish only after checks pass.

Example comparison:

```sql
select
    old.order_date,
    old.recognized_revenue as old_revenue,
    new.recognized_revenue as new_revenue,
    new.recognized_revenue - old.recognized_revenue as difference
from prod.mart_daily_revenue as old
join staging.mart_daily_revenue as new
    on old.order_date = new.order_date
where abs(new.recognized_revenue - old.recognized_revenue) > 0.01;
```

