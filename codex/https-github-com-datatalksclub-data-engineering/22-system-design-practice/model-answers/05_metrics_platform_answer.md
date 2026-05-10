# Model Answer - Metrics Platform

## Pattern Choice

Metric/semantic layer on top of governed warehouse facts and dimensions.

## Architecture

```text
warehouse facts and dimensions
  -> metric definitions
  -> semantic layer / metrics store
  -> BI, experiments, reverse ETL, apps
```

## Requirements

Metrics need:

- ownership
- definition
- grain
- dimensions
- filters
- tests
- lineage
- versioning
- approval workflow

## Bottlenecks

- Conflicting definitions.
- Expensive repeated queries.
- Metric changes without downstream awareness.
- Lack of ownership.

## Reliability

- Metric tests.
- Reconciliation for finance metrics.
- Versioned definitions.
- Change approval.
- Downstream impact analysis.

## Data Quality

- Metric-level tests.
- Source freshness.
- Fact uniqueness.
- Accepted dimensions.
- Anomaly detection.

## Cost

- Precompute common metrics.
- Cache semantic layer queries.
- Use aggregate marts.
- Avoid repeated raw fact scans.

## Trade-offs

A metrics platform adds governance overhead, but it prevents every dashboard and team from redefining core KPIs differently. For critical finance/product metrics, consistency is worth the process.

