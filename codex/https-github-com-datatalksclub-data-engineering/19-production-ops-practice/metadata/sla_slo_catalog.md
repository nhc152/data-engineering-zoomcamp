# SLA/SLO Catalog

## Pipeline: ecommerce_daily_revenue

### Business Purpose

Publish daily revenue numbers for finance and leadership dashboards.

### Owner

Data Engineering: `de-platform@example.com`

Business owner:

Finance Analytics: `finance-analytics@example.com`

### SLA

```text
mart_daily_revenue is available by 07:00 Asia/Saigon every day
for the previous business day.
```

### SLIs

| SLI | Definition |
|---|---|
| Freshness | Max `order_timestamp` represented in mart |
| Publish time | Timestamp when mart partition is published |
| Duplicate order rate | Duplicate `order_id` count in fact table |
| Revenue reconciliation delta | Difference between payments source and mart revenue |
| Row count anomaly | Current partition row count vs trailing 7-day median |

### SLOs

| SLO | Target |
|---|---:|
| Daily publish before SLA | 99% monthly |
| Duplicate order count | 0 |
| Revenue reconciliation delta | < 0.1% |
| Severe data incident | <= 1 per quarter |

### Publish Gate

Block publish if:

- duplicate `order_id` > 0
- freshness older than 24 hours
- reconciliation delta >= 0.1%
- row count drops below 70% of trailing median without override

Warn only if:

- cost is 20-50% above normal
- row count is 70-85% of trailing median
- non-critical dimension missing optional attributes

