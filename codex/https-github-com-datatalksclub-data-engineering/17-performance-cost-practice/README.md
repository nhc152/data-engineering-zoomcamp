# Performance and Cost Practice Lab

## Goal

Practice investigating slow and expensive data workloads like a production Data Platform Engineer.

This lab is not about random tuning tips. It teaches a repeatable investigation workflow:

```text
symptom
  -> evidence
  -> bottleneck hypothesis
  -> before metrics
  -> optimization
  -> after metrics
  -> trade-off
  -> prevention guardrail
```

## What You Will Learn

- Bytes scanned.
- Partition pruning.
- Column pruning.
- Join cardinality.
- Aggregate marts.
- dbt full refresh cost.
- Spark shuffle and skew.
- Kafka lag and retention cost.
- Cost attribution.
- Owner labels and chargeback/showback.
- Before/after performance report writing.

## Folder Structure

```text
17-performance-cost-practice/
  README.md
  sql/
  templates/
  exercises/
  broken/
  solutions/
  reports/
  ownership/
  runbook/
```

## How To Use This Lab

Most files are platform-neutral or BigQuery-style SQL. You can adapt them to Snowflake, Redshift, Databricks SQL, or Postgres.

The point is not to run every query against a huge table. The point is to learn the review pattern:

- Does the query scan more data than necessary?
- Does it select unnecessary columns?
- Does the join change grain?
- Does a dashboard query raw data instead of a mart?
- Does a full refresh rebuild too much?
- Is cost attributed to an owner?
- Is there a guardrail to prevent repeat incidents?

## Investigation Workflow

1. Identify workload:
   - dashboard
   - dbt model
   - Spark job
   - Kafka pipeline
   - ad hoc query

2. Capture baseline:
   - bytes scanned
   - rows read/written
   - duration
   - shuffle read/write
   - output file count
   - lag
   - cost estimate

3. Identify bottleneck:
   - partition pruning missing
   - column pruning missing
   - join explosion
   - full refresh
   - skew
   - too many small files
   - Kafka retention/lag

4. Apply one optimization at a time.

5. Record before/after metrics.

6. Explain trade-off.

7. Add prevention:
   - code review rule
   - CI test
   - query guardrail
   - owner labels
   - alert
   - runbook

## Key Principle

Optimization without evidence is guessing.

Every solution in this lab must answer:

- What changed?
- Why does it reduce cost or runtime?
- What trade-off did we introduce?
- How do we prevent the same issue from coming back?

## Recommended Learning Order

1. `exercises/level_01_warehouse_query_cost.md`
2. `exercises/level_02_join_cardinality.md`
3. `exercises/level_03_aggregate_marts.md`
4. `exercises/level_04_spark_kafka_cost.md`
5. `exercises/level_05_cost_ownership.md`
6. `exercises/level_06_incident_review.md`

## Required Deliverables

After finishing this lab, you should have:

- One before/after query optimization report.
- One cost incident report.
- One ownership/labeling matrix.
- One dashboard cost prevention checklist.
- One Spark skew/shuffle investigation note.
- One Kafka lag/retention investigation note.

