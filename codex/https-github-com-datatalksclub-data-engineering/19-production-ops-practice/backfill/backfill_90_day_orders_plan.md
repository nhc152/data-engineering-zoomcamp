# Backfill Plan - 90 Day Orders Rebuild

## Reason

Revenue logic changed to exclude cancelled and refunded orders from recognized revenue.

## Scope

Date range:

```text
2026-02-01 to 2026-04-30
```

Affected tables:

- `marts.fct_orders`
- `marts.mart_daily_revenue`
- finance dashboard

## Cost and Runtime Estimate

Estimate before running:

- bytes scanned from raw/staging
- partitions rebuilt
- expected runtime
- warehouse slot/compute impact

## Safety Strategy

Use temp tables:

```text
marts_backfill.fct_orders_20260201_20260430
marts_backfill.mart_daily_revenue_20260201_20260430
```

Do not write directly to published marts.

## Execution Plan

1. Build backfill temp fact table.
2. Build backfill temp daily revenue.
3. Run duplicate checks.
4. Run reconciliation checks.
5. Compare old vs new revenue by day.
6. Get finance approval.
7. Replace affected partitions.
8. Record publish events.
9. Monitor dashboard.

## Rollback Plan

Keep old partitions for rollback window.

If issue found:

- restore previous partitions
- mark publish event as rolled back
- open incident

