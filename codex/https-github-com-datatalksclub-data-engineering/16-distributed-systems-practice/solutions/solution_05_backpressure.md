# Solution 05 - Backpressure

## Root Cause

Upstream produces 5 events per tick while downstream processes only 2. Queue length grows.

## Fix Options

- scale consumers/workers
- batch writes
- optimize sink
- throttle upstream
- add DLQ for poison events
- prioritize critical topics/jobs

## Caution

Scaling is not always safe:

- external sink may be the bottleneck
- more consumers can increase contention
- hot partitions cannot be solved by adding consumers if one partition is overloaded

## Real System Mapping

- Kafka consumer lag.
- CDC connector lag.
- Spark skew/slow stage.
- Orchestrator queued tasks.

