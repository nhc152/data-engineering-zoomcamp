# Schema Evolution Policy

## Purpose

Schema evolution controls how tables accept new, changed, or removed fields.

## Allowed Changes

Usually safe:

- Add nullable column.
- Add metadata column.
- Widen type if engine supports safely.

Risky:

- Rename column.
- Change type.
- Remove column.
- Change semantic meaning.
- Add nested field used by downstream logic.

## Policy By Layer

### Bronze

Bronze can be permissive but must preserve source payload and record schema version.

### Silver

Silver must validate expected schema. Breaking changes should fail loudly.

### Gold

Gold should be conservative. Any breaking change requires review and downstream communication.

## Required Metadata

For schema changes:

- table name
- change type
- old schema
- new schema
- reason
- downstream impact
- migration/backfill plan

## Anti-patterns

- Auto-merge every new column into gold tables.
- Treat column rename as harmless.
- Drop columns without checking dashboards.
- Change metric semantics without versioning.

