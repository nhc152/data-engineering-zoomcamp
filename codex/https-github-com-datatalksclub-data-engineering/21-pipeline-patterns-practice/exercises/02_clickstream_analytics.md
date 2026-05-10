# Exercise 02 - Clickstream Analytics

## Scenario

Product team wants clickstream analytics: page views, sessions, funnels, conversion rate. Dashboard can be delayed by 15-30 minutes. Some events arrive late or out of order.

## Requirements

- Latency: 15-30 minutes.
- Volume: high.
- Ordering: not guaranteed.
- Replay: required for metric correction.
- Consumers: product analytics, experimentation, ML.

## Tasks

1. Choose between micro-batch, streaming, Lambda, or Kappa.
2. Define raw event archive.
3. Define event deduplication key.
4. Define late event handling.
5. Design session/funnel processing.
6. Define DLQ/quarantine.
7. Explain trade-off between micro-batch and streaming.

## Expected Direction

For 15-30 minute latency:

```text
Micro-batch over raw event logs is often enough.
```

If product needs realtime personalization:

```text
Event streaming or Kappa may be justified.
```

## Deliverable

Write:

```text
clickstream_analytics_design.md
```

