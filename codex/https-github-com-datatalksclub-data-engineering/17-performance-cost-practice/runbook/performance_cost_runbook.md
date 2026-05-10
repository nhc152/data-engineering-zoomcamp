# Performance and Cost Runbook

## Incident: Warehouse Query Cost Spike

### Triage

1. Find top jobs by bytes scanned or credits.
2. Identify owner/service account.
3. Inspect query text.
4. Check partition filters.
5. Check selected columns.
6. Check raw vs mart usage.
7. Check join cardinality.
8. Estimate repeated schedule impact.

### Mitigation

- Stop or reduce dashboard refresh.
- Add partition/date filter.
- Replace raw query with mart.
- Add aggregate mart.
- Add owner alert.

## Incident: Spark Job Too Expensive

### Triage

1. Inspect Spark UI.
2. Find slow stage.
3. Check shuffle read/write.
4. Check task duration skew.
5. Check file counts.
6. Check rerun count.

### Mitigation

- Broadcast small dimension.
- Pre-aggregate.
- Handle skew.
- Compact files.
- Split job into idempotent stages.
- Add checkpoint only where useful.

## Incident: Kafka Storage Cost Growth

### Triage

1. Identify high-volume topics.
2. Check retention.ms and retention.bytes.
3. Check replication factor.
4. Check average event size.
5. Check owner and replay requirement.

### Mitigation

- Adjust retention by topic class.
- Compress events where appropriate.
- Remove unused topics.
- Route audit/replay data to cheaper storage if needed.

