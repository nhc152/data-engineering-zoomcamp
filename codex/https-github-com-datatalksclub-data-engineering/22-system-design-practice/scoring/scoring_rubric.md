# System Design Scoring Rubric

Score each answer out of 100.

## 1. Requirement Clarification - 15 points

Strong:

- Asks about latency, volume, consumers, correctness, replay, PII, failure impact.
- States assumptions clearly.

Weak:

- Starts with tools immediately.
- Does not clarify SLA or consumers.

## 2. Architecture Pattern Choice - 15 points

Strong:

- Chooses batch/streaming/CDC/hybrid based on requirements.
- Explains alternatives and trade-offs.

Weak:

- Lists tools without pattern.
- Uses streaming for daily reporting without justification.

## 3. Volume Estimation - 10 points

Strong:

- Estimates events/day, GB/day, peak throughput, retention.
- Uses numbers to justify architecture.

Weak:

- No scale discussion.
- Assumes tools will scale automatically.

## 4. Storage and Modeling - 10 points

Strong:

- Defines raw/staging/marts or bronze/silver/gold.
- Discusses partitioning, retention, schema, grain.

Weak:

- No raw layer.
- No replay source.
- No modeling or metric consistency.

## 5. Processing Design - 10 points

Strong:

- Handles batch/streaming/CDC details.
- Discusses idempotency, dedup, late data, deletes.

Weak:

- Ignores duplicates.
- Ignores deletes for CDC.
- No incremental/backfill strategy.

## 6. Reliability and Operations - 15 points

Strong:

- Includes retry, DLQ/quarantine, replay, backfill, monitoring, runbook.

Weak:

- Says "retry" without idempotency.
- No alerting.
- No recovery plan.

## 7. Data Quality - 10 points

Strong:

- Defines freshness, row count, uniqueness, relationships, reconciliation, anomaly checks.

Weak:

- Only monitors job success.
- No data validation.

## 8. Cost and Performance - 10 points

Strong:

- Discusses scan cost, always-on compute, storage retention, partitioning, aggregate marts.

Weak:

- No cost discussion.
- No bottleneck analysis.

## 9. Communication - 5 points

Strong:

- Clear, structured, trade-off-aware.

Weak:

- Rambling tool list.
- No final summary.

## Score Bands

| Score | Interpretation |
|---:|---|
| 90-100 | Senior-level answer |
| 75-89 | Strong mid-level answer |
| 60-74 | Acceptable but missing depth |
| 40-59 | Too generic |
| 0-39 | Tool shopping, not system design |

