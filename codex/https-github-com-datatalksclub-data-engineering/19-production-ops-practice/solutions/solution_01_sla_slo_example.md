# Solution Example - SLA/SLO Design

## SLA

`mart_daily_revenue` must be published by 07:00 Asia/Saigon every day for previous business day.

## SLIs

- latest source order timestamp
- mart publish timestamp
- duplicate `order_id` count
- revenue reconciliation delta
- row count vs trailing 7-day median

## SLOs

- 99% daily runs published before 07:00 monthly.
- duplicate `order_id` count is zero.
- revenue reconciliation delta < 0.1%.

## Publish Gate

Block publish if:

- duplicate order IDs > 0
- freshness > 24 hours
- revenue reconciliation delta >= 0.1%
- missing partition

Warn only if:

- row count is slightly below normal but approved
- cost is moderately above baseline

