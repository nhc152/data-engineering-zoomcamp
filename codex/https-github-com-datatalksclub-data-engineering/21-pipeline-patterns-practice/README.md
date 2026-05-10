# Data Pipeline Patterns Practice Lab

## Goal

Practice choosing the right data pipeline pattern for real business scenarios.

This lab is not about memorizing tool names. It teaches how to reason from requirements:

- latency
- data mutability
- correctness
- replay/backfill
- cost
- operational complexity
- team skill
- failure modes

## Patterns Covered

- Batch ELT.
- Batch ETL.
- CDC.
- Event streaming.
- Micro-batch.
- Medallion architecture.
- Lambda architecture.
- Kappa architecture.
- Outbox pattern.
- DLQ/quarantine.
- Fan-in.
- Fan-out.

## Folder Structure

```text
21-pipeline-patterns-practice/
  README.md
  decision-matrix/
  diagrams/
  exercises/
  failure-scenarios/
  model-answers/
  interview/
```

## How to Use This Lab

For each scenario:

1. Read the business problem.
2. Write requirements before choosing tools.
3. Choose a pattern.
4. Draw architecture.
5. Identify failure modes.
6. Define replay/backfill.
7. Define quality checks.
8. Explain trade-offs as if in an interview.
9. Compare with model answer.

## Decision Rule

Do not start with:

```text
I will use Kafka, Spark, Airflow, dbt...
```

Start with:

```text
The problem needs daily accuracy, low operational complexity, and replayable historical reporting. Batch ELT is enough.
```

or:

```text
The problem needs sub-second fraud decisions and can tolerate duplicate events only if the sink is idempotent. This requires event streaming with DLQ, replay, and state handling.
```

## Core Trade-off Language

Use this language in interviews:

- Batch ELT is simpler and easier to replay, but latency is higher.
- Streaming lowers latency but increases operational and correctness risk.
- CDC is good for database changes, but delete handling, schema drift, and ordering must be designed explicitly.
- Semantic events are cleaner for business meaning, but require application engineering work.
- Micro-batch is often the pragmatic middle ground when minute-level latency is enough.
- Medallion architecture improves layer boundaries and data quality, but creates more tables and jobs.
- Lambda gives low latency plus batch correctness, but duplicate logic can drift.
- Kappa simplifies the architecture around an event log, but replay cost and stream correctness become central.
- Outbox avoids dual-write inconsistency, but consumers still need idempotency.
- DLQ keeps good data moving, but becomes data loss if nobody owns replay.
- Fan-in needs canonical modeling and identity resolution.
- Fan-out needs contracts and consumer isolation.

## Recommended Learning Order

1. `decision-matrix/pattern_decision_matrix.md`
2. `decision-matrix/decision_tree.md`
3. `diagrams/architecture_diagrams.md`
4. `exercises/01_finance_reporting.md`
5. `exercises/02_clickstream_analytics.md`
6. `exercises/03_realtime_fraud.md`
7. `exercises/04_oltp_replication.md`
8. `exercises/05_customer_360_fan_in.md`
9. `exercises/06_order_paid_outbox.md`
10. `failure-scenarios/failure_catalog.md`
11. Compare with `model-answers/`.
12. Practice `interview/interview_questions.md`.

## GitHub Deliverables

After finishing this lab, your portfolio should include:

- A pipeline pattern catalog.
- A decision matrix.
- Architecture diagrams.
- Failure mode analysis.
- Replay/backfill strategy.
- Interview-ready trade-off explanations.

