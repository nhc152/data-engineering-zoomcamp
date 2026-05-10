# Solution - Alert Templates

## Freshness Breach Alert

```text
Severity: P1
Check: freshness_mart_fct_orders
Owner: analytics-finance
Table: marts.fct_orders
Business date: 2026-05-09
Expected: latest order_date >= 2026-05-09
Actual: latest order_date = 2026-05-08
Impact: finance dashboard stale; daily revenue not reliable
Runbook: runbook/freshness_breach.md
```

## Duplicate Key Alert

```text
Severity: P1
Check: unique_fct_orders_order_id
Owner: data-platform
Table: marts.fct_orders
Expected: duplicate_key_count = 0
Actual: duplicate_key_count = 12
Impact: revenue and order counts may be inflated
Runbook: runbook/duplicate_inflated_metric.md
```

## New Status Alert

```text
Severity: P2
Check: accepted_values_order_status
Owner: analytics-engineering
Table: marts.fct_orders
Expected: only approved statuses
Actual: status 'partially_refunded' found
Impact: revenue recognition may be wrong until mapped
Runbook: runbook/new_status_value.md
```

