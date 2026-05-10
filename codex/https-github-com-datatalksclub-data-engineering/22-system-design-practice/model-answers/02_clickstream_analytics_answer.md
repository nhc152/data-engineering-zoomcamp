# Model Answer - Clickstream Analytics

## Pattern Choice

Micro-batch over raw event logs.

The requirement is 15-30 minute latency. True streaming is not required unless product decisions need second-level response.

## Architecture

```text
web/mobile apps
  -> event collector
  -> raw event archive
  -> micro-batch processor
  -> deduped event fact
  -> session/funnel marts
  -> product analytics dashboards
```

## Volume Estimate

Assume:

- 5M DAU.
- 40 events/user/day.
- 200M events/day.
- 1 KB average event.
- Around 200 GB/day raw before compression.
- Peak 5x average.

This justifies partitioned raw storage and micro-batch processing with deduplication.

## Bottlenecks

- Event collector throughput.
- Small files from frequent micro-batches.
- Sessionization state.
- Late and out-of-order events.

## Reliability

- Raw archive for replay.
- Event ID deduplication.
- DLQ/quarantine for malformed events.
- Late event correction window.

## Data Quality

- Event schema validation.
- Accepted event names.
- Freshness by event type.
- Duplicate event rate.
- Bot/internal traffic filtering.

## Cost

- Avoid per-event warehouse writes.
- Use micro-batch files.
- Compact small files.
- Pre-aggregate funnel metrics.

## Trade-offs

Micro-batch is simpler and cheaper than true streaming while meeting 15-30 minute latency. If the product later needs realtime personalization, evolve to streaming/Kappa.

