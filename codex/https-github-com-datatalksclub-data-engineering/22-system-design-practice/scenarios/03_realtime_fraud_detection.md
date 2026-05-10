# Scenario 03 - Realtime Fraud Detection

## Prompt

Design a realtime fraud detection pipeline for payment events. The system must score payments within seconds and write decisions that payment authorization can use.

## Requirements To Clarify

- Required decision latency?
- Peak payment events/sec?
- What happens if fraud pipeline is unavailable?
- Are duplicate events possible?
- What features are needed?
- Is model inference online?
- Do we need audit/replay?

## Suggested Assumptions

- 5,000 events/sec average.
- 25,000 events/sec peak.
- Decision latency target under 2 seconds.
- At-least-once event delivery.
- Duplicate events possible.
- Raw archive retained for 180 days.

## Deliverables

Design:

- event ingestion
- stream processing
- feature/state lookup
- idempotent decision sink
- DLQ
- replay
- monitoring

