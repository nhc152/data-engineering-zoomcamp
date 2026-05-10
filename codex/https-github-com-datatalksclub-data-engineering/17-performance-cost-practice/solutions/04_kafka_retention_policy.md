# Solution 04 - Kafka Retention Policy

## Fix

Define retention per topic class:

| Topic class | Example | Retention |
|---|---|---|
| transient stream | clickstream enriched | 1-3 days |
| replay-critical | orders events | 7-30 days |
| audit | payment audit events | policy/compliance-driven |
| compacted latest-state | customer profile updates | compaction + shorter delete retention |

## Trade-off

Long retention improves replay and recovery, but increases broker storage and replication cost.

Short retention reduces cost, but failures may require source resnapshot or raw lake replay.

## Prevention

- Retention owner required.
- Replay requirement documented.
- Alert on topic storage growth.
- Review high-volume topics monthly.

