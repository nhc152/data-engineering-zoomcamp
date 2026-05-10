# Distributed Systems Practice Lab

## Goal

Practice deterministic distributed failure simulations that Data Engineers face in Kafka, CDC, Spark, orchestration, object storage, and warehouse pipelines.

This lab does not try to run a real Kafka cluster. It simulates the core failure boundaries:

```text
producer -> log/broker -> consumer -> sink/state table -> downstream publish
```

The purpose is to make failure modes concrete:

- lost acknowledgement
- retry duplicate
- sink write before offset commit
- out-of-order updates
- replay duplicate
- backpressure from slow downstream
- exactly-once boundary confusion

## Why This Matters

Production data systems rarely fail as total outages. They fail as partial success:

- producer wrote event, but did not receive acknowledgement
- consumer wrote to database, but crashed before committing offset
- replay reprocessed events already published
- older CDC update arrived after a newer update
- downstream became slow and lag grew

The right response is not "avoid all failure". The right response is:

- make keys explicit
- make sinks idempotent
- track offsets/checkpoints
- preserve raw logs
- handle replay safely
- monitor lag/backpressure
- document ordering guarantees

## Folder Structure

```text
16-distributed-systems-practice/
  README.md
  data/
    events.jsonl
    cdc_events_out_of_order.jsonl
    replay_events.jsonl
  scripts/
    common.py
    01_producer_retry_duplicate.py
    02_consumer_crash_before_offset_commit.py
    03_out_of_order_cdc.py
    04_replay_duplicates.py
    05_backpressure_simulation.py
    06_exactly_once_boundary.py
  state_tables/
    schema.sql
  exercises/
  solutions/
  runbook/
```

## Prerequisites

Only Python standard library is required.

Recommended:

```bash
python --version
```

Python 3.10+ is enough.

## How to Run

From this folder:

```bash
cd 16-distributed-systems-practice
python scripts/01_producer_retry_duplicate.py
python scripts/02_consumer_crash_before_offset_commit.py
python scripts/03_out_of_order_cdc.py
python scripts/04_replay_duplicates.py
python scripts/05_backpressure_simulation.py
python scripts/06_exactly_once_boundary.py
```

Each script resets its own SQLite database under:

```text
tmp/
```

## Simulation Summary

| Script | Failure | Core Lesson |
|---|---|---|
| `01_producer_retry_duplicate.py` | producer retry duplicates event | idempotent producer/sink keys matter |
| `02_consumer_crash_before_offset_commit.py` | sink write succeeds, offset commit fails | at-least-once creates duplicate processing |
| `03_out_of_order_cdc.py` | older update overwrites newer value | compare source version/LSN/timestamp |
| `04_replay_duplicates.py` | replay republishes already processed data | replay must be idempotent |
| `05_backpressure_simulation.py` | downstream slower than upstream | lag grows unless throttled/scaled |
| `06_exactly_once_boundary.py` | exactly-once claim stops at boundary | end-to-end correctness needs sink semantics |

## Concepts Mapped to Real Tools

| Lab Concept | Kafka | CDC | Spark | Orchestration |
|---|---|---|---|---|
| event log | topic partition | changelog | input files | task inputs |
| offset/checkpoint | committed offset | LSN/binlog position | checkpoint | task state |
| duplicate | producer/consumer retry | snapshot + stream overlap | task retry output | DAG retry |
| ordering | per partition | per table/key if preserved | partition/order not global | dependency order |
| replay | reset offset | resnapshot/reconsume log | rerun job | backfill |
| backpressure | consumer lag | connector lag | slow stage/skew | queued tasks |

## Learning Workflow

For each scenario:

1. Run the broken simulation.
2. Observe wrong output.
3. Read the state table.
4. Explain the failure boundary.
5. Read corresponding solution.
6. Write prevention strategy.

## Acceptance Checklist

- [ ] I can explain why retry creates duplicates.
- [ ] I can explain why at-least-once is normal.
- [ ] I can design an idempotent sink.
- [ ] I can explain why ordering is only guaranteed inside a partition/key boundary.
- [ ] I can explain replay safety.
- [ ] I can explain backpressure and lag.
- [ ] I can explain why exactly-once is not magic end-to-end.

