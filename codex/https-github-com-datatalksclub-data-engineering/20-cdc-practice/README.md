# CDC Practice Lab

## Goal

Practice CDC correctness before chasing low latency.

Target architecture:

```text
Debezium-style event files
  -> raw changelog table
  -> current-state table
  -> audit/replay checks
  -> recovery playbook
```

This lab is local and runnable. It simulates CDC events with JSONL files and applies them into PostgreSQL. You do not need Kafka or Debezium installed to learn the correctness model.

## What You Will Learn

- Snapshot vs change stream.
- Insert/update/delete events.
- WAL/binlog position as ordering metadata.
- Debezium-style event envelope.
- Raw changelog table.
- Current-state table.
- Upsert and delete handling.
- Tombstone handling.
- Schema evolution detection.
- Replay and recovery.
- Why older updates must not overwrite newer state.
- Why committing offset before sink write can lose data.

## Prerequisites

- Docker Desktop.
- Python 3.11+.

Install Python dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Start PostgreSQL

```bash
docker compose up -d
```

Connection:

```text
host: localhost
port: 5432
database: cdc_practice
user: cdc_user
password: cdc_password
```

## Quick Start

Apply the initial snapshot:

```bash
python src/apply_cdc_events.py --events events/01_snapshot_orders.jsonl --batch-id snapshot_001
```

Apply change stream:

```bash
python src/apply_cdc_events.py --events events/02_change_stream_orders.jsonl --batch-id stream_001
```

Apply out-of-order events safely:

```bash
python src/apply_cdc_events.py --events events/03_out_of_order_update.jsonl --batch-id stream_002
```

Detect schema drift:

```bash
python src/schema_evolution_check.py --events events/04_schema_drift.jsonl
```

Simulate bad offset commit:

```bash
python src/simulate_offset_failure.py
```

Run validation SQL:

```bash
docker compose exec -T postgres psql -U cdc_user -d cdc_practice < sql/validation_queries.sql
```

## Folder Structure

```text
20-cdc-practice/
  README.md
  docker-compose.yml
  requirements.txt
  events/
  init/
  sql/
  src/
  exercises/
  broken/
  solutions/
  runbook/
```

## Data Model

### `cdc.raw_orders_changelog`

Immutable append-only table. One row per CDC event.

Important columns:

- `event_id`
- `source_lsn`
- `source_ts_ms`
- `op`
- `before_data`
- `after_data`
- `event_payload`
- `ingested_at`

### `cdc.orders_current`

Current-state table. One row per order primary key.

Important columns:

- `order_id`
- business fields
- `is_deleted`
- `deleted_at`
- `last_source_lsn`
- `last_source_ts_ms`

Rule: an older event must not overwrite a newer state.

## Operation Semantics

| Operation | Meaning | Current-state behavior |
|---|---|---|
| `r` | snapshot read | insert/update if newer |
| `c` | create | insert/update if newer |
| `u` | update | update if newer |
| `d` | delete | soft delete if newer |
| tombstone | null payload after delete | ignore for current table, keep broker compaction concept in notes |

## Correctness Rules

- Store raw changelog before applying current state.
- Apply changes idempotently.
- Use primary key for upsert.
- Use source log position or source timestamp to guard ordering.
- Handle deletes explicitly.
- Never commit offset before sink write.
- Keep enough raw changelog retention to replay.

## Exercises

1. `exercises/level_01_event_envelope.md`
2. `exercises/level_02_changelog_current_state.md`
3. `exercises/level_03_deletes_tombstones.md`
4. `exercises/level_04_replay_recovery.md`
5. `exercises/level_05_failure_scenarios.md`

## Broken Scenarios

- `broken/wal_retention_expired.md`
- `broken/delete_events_ignored.md`
- `broken/schema_rename_breaks_downstream.md`
- `broken/offset_committed_before_sink_write.md`
- `broken/older_update_overwrites_newer_state.md`

## GitHub Deliverables

- Event examples.
- SQL schema/models.
- Python apply/replay scripts.
- Validation queries.
- Failure notes.
- Recovery playbook.
- Exercise answers.
