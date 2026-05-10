# Storage Format Runbook

## Incident: Query Suddenly Slow

### Triage

1. Check file format: CSV/JSON/Parquet.
2. Check whether query selects unnecessary columns.
3. Check partition filter.
4. Count files per partition.
5. Check recent writer changes.
6. Compare compacted vs small-files dataset.

### Mitigation

- Rewrite query to select fewer columns.
- Add partition filter.
- Compact small files.
- Convert curated data to Parquet.

## Incident: Curated Load Fails After Source Change

### Triage

1. Compare raw schema with expected schema.
2. Check added/missing fields.
3. Check type changes.
4. Check parser/staging code.

### Mitigation

- Keep raw batch.
- Quarantine if breaking change.
- Update schema deliberately.
- Backfill curated partitions.

## Incident: Backfill Deletes Data

### Triage

1. Identify output path used by backfill.
2. Check whether table root was overwritten.
3. Check available raw files.
4. Identify affected partitions.

### Mitigation

- Restore/rebuild from raw.
- Add partition overwrite guard.
- Require backfill dry run.

