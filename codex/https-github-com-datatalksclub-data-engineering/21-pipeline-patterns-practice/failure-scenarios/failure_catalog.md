# Failure Scenario Catalog

## 1. Batch ELT Incremental Bug

Symptom:

- Daily revenue misses old orders updated today.

Cause:

- Incremental filter uses `created_at` instead of `updated_at`.

Prevention:

- Use updated watermark.
- Add lookback window.
- Reconcile daily source vs target.

## 2. Micro-batch Window Overlap Duplicate

Symptom:

- Events around minute boundary are counted twice.

Cause:

- Two micro-batch windows overlap without deduplication.

Prevention:

- Use event_id dedup.
- Define closed/open window boundaries.
- Make sink idempotent.

## 3. CDC Delete Ignored

Symptom:

- Deleted users still appear active in warehouse.

Cause:

- CDC consumer handles insert/update but ignores delete/tombstone.

Prevention:

- Model operation type.
- Apply deletes to current-state table.
- Keep changelog for audit.

## 4. Streaming Poison Pill

Symptom:

- Consumer stops progressing.
- Lag increases.

Cause:

- One malformed event causes repeated processing failure.

Prevention:

- Validate schema.
- Send bad event to DLQ.
- Track DLQ count.
- Replay after fix.

## 5. Lambda Logic Drift

Symptom:

- Realtime dashboard and batch-corrected dashboard show different numbers.

Cause:

- Batch path and streaming path implement metric differently.

Prevention:

- Shared metric definitions.
- Reconciliation job.
- Prefer Kappa or batch reconciliation if possible.

## 6. Outbox Duplicate Publish

Symptom:

- Customer receives duplicate email.

Cause:

- Relay publishes event but crashes before marking outbox row as sent.

Prevention:

- Consumers idempotent by event_id.
- Relay can republish safely.
- Track sent status carefully.

## 7. DLQ Without Owner

Symptom:

- Thousands of events sit in DLQ for weeks.

Cause:

- DLQ exists but no alert, owner, or replay process.

Prevention:

- DLQ owner.
- Alert threshold.
- Replay runbook.
- Error reason classification.

## 8. Fan-in Identity Merge Error

Symptom:

- Two different people are merged into one customer profile.

Cause:

- Weak matching rule, for example same phone/email reused.

Prevention:

- Confidence score.
- Human review for ambiguous matches.
- Source priority rules.
- Audit merge decisions.

## 9. Fan-out Schema Breaks Consumers

Symptom:

- One upstream schema change breaks three downstream teams.

Cause:

- Shared event without schema contract/versioning.

Prevention:

- Schema registry.
- Backward-compatible changes.
- Consumer contract tests.
- Deprecation process.

