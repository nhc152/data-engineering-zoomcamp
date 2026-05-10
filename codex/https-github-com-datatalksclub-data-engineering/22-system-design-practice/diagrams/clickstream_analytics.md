# Diagram - Clickstream Analytics

```mermaid
flowchart LR
  A["Web/Mobile Apps"] --> B["Event Collector"]
  B --> C["Raw Event Log / Object Storage"]
  C --> D["Micro-batch Processor"]
  D --> E["Deduped Event Fact"]
  E --> F["Session and Funnel Marts"]
  F --> G["Product Analytics Dashboard"]
  D --> H["DLQ / Quarantine"]
```

## Bottlenecks

- Event volume spikes.
- Late/out-of-order events.
- Sessionization state.
- Small files if micro-batch writes too often.

## Reliability

- Event ID deduplication.
- Raw archive for replay.
- DLQ for malformed events.
- Late event correction window.

