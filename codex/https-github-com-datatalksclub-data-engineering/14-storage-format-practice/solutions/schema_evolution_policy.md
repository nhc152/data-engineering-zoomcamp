# Solution - Schema Evolution Policy

## Raw Layer

Raw JSON/JSONL may accept new fields, but changes must be detected.

## Curated Layer

Curated Parquet should have stable, typed schema.

Rules:

- New nullable fields require review.
- Type changes require migration plan.
- Dropped fields require downstream impact analysis.
- Metric fields changing type should block publish.

## Operational Response

1. Detect schema drift.
2. Quarantine affected batch if needed.
3. Keep raw files.
4. Update parser/staging model.
5. Backfill curated output.
6. Add test for the schema rule.

