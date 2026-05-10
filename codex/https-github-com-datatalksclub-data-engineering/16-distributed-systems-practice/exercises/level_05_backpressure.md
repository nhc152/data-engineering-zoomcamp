# Level 05 - Backpressure

## Goal

Understand lag growth when downstream is slower than upstream.

## Run

```bash
python scripts/05_backpressure_simulation.py
```

## Tasks

1. Observe lag in slow downstream scenario.
2. Compare scaling vs throttling.
3. Explain when scaling consumers is unsafe.
4. Connect this to Kafka lag, Spark skew, and queued orchestration tasks.

## Expected Learning

- Backpressure means the system cannot process input as fast as it arrives.
- Lag is a symptom, not root cause.
- Solutions include scaling, throttling, batching, DLQ, and bottleneck removal.

