# Table Metadata and ACID Concept

## Raw Parquet Folder

Example:

```text
orders/
  part-0001.parquet
  part-0002.parquet
  part-0003.parquet
```

Problem:

- Which files are active?
- Was write successful?
- What schema is current?
- Can readers ignore partial writes?
- Can you time travel?
- Can you safely delete old files?

Raw files alone cannot answer these questions.

## Lakehouse Table

A lakehouse table adds metadata:

```text
orders/
  data/
    part-0001.parquet
    part-0002.parquet
    part-0003.parquet
  metadata/
    snapshot-001.json
    snapshot-002.json
    manifest-list.avro
```

Exact layout depends on Delta/Iceberg/Hudi, but the concept is similar:

- Table has versions/snapshots.
- A snapshot points to active data files.
- Writes commit metadata atomically.
- Readers choose a consistent snapshot.
- Old snapshots allow time travel if files are retained.

## ACID On Object Storage

Object storage is not a traditional database. ACID-like behavior comes from table format protocol and metadata management.

Important properties:

- Atomic commit: readers see old or new snapshot, not half-written table.
- Consistent schema: table metadata defines valid schema.
- Isolation: concurrent writes are controlled by commit protocol.
- Durability: committed files and metadata remain in storage.

## Snapshot Isolation

Snapshot isolation means a query reads a consistent table version.

Without snapshot isolation:

- A reader can see some files from old write and some from new write.
- Metrics may be inconsistent.

With snapshot isolation:

- Reader reads snapshot N.
- Writer commits snapshot N+1.
- Reader still sees snapshot N until next query/session.

## Time Travel

Time travel means reading a previous table version.

Use cases:

- Recover from bad deploy.
- Compare before/after logic.
- Audit changes.
- Reproduce historical reports.

Risk:

- Time travel only works if old files were not vacuumed/deleted.

