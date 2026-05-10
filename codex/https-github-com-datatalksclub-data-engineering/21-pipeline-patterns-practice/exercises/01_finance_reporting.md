# Exercise 01 - Finance Reporting

## Scenario

Finance needs daily revenue reporting by 8 AM every morning. Accuracy matters more than low latency. Reports must reconcile with payments. Backfills are expected when business rules change.

## Requirements

- Latency: daily.
- Correctness: high.
- Reconciliation: required.
- Replay: required.
- Cost: should be controlled.
- Users: finance analysts and executives.

## Tasks

1. Choose a pipeline pattern.
2. Draw architecture.
3. Define raw, staging, marts.
4. Define quality checks.
5. Define backfill strategy.
6. Identify failure modes.
7. Explain why streaming is not the first choice.

## Expected Direction

Likely pattern:

```text
Batch ELT
```

Optional:

```text
CDC if finance needs intraday current-state updates from OLTP.
```

## Deliverable

Write:

```text
finance_reporting_design.md
```

Include:

- chosen pattern
- architecture
- quality checks
- replay/backfill
- cost risks
- trade-offs

