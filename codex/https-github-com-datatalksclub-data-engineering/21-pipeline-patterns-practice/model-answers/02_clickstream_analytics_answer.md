# Model Answer - Clickstream Analytics

## Recommended Pattern

Micro-batch over raw event logs.

## Why

The requirement is 15-30 minute latency, not real-time user response. Micro-batch is simpler than streaming and still fresh enough for product analytics.

## Architecture

```text
web/mobile events
  -> raw event files/log
  -> micro-batch processor
  -> deduped event fact
  -> session/funnel marts
  -> product dashboard
```

## Quality Checks

- Event_id uniqueness.
- Event timestamp freshness.
- Accepted event names.
- Late event rate.
- Bot/internal traffic exclusion.

## Failure Modes

- Duplicate event IDs.
- Out-of-order events.
- Late arrivals changing funnel counts.
- Schema drift in payload.

## Trade-off Language

Streaming gives lower latency, but micro-batch is easier to replay and cheaper to operate. Since the dashboard tolerance is 15-30 minutes, micro-batch is the pragmatic choice.

