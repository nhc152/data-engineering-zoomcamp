# Broken Scenario 02 - dbt Deploy Breaks Dashboard

## Symptom

After a dbt deployment, the revenue dashboard drops to zero for refunded and cancelled orders as expected, but also drops to zero for unknown status values that previously contributed to revenue.

## Root Cause

The model changed business logic without a metric owner review.

Possible bad change:

```sql
case
    when order_status in ('paid', 'completed') then captured_amount
    else 0
end as recognized_revenue
```

This excludes `shipped` orders even if business considers them valid revenue.

## Why CI Missed It

- Tests checked not null and uniqueness.
- No reconciliation against expected metric totals.
- No business owner approval gate.

## Prevention

- Add accepted values test.
- Add metric reconciliation test.
- Require owner review for metric logic.
- Deploy to staging schema first.
- Compare old vs new revenue before publishing.

