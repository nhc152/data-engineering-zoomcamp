# Data Engineering System Design Practice Lab

## Goal

Practice Data Engineering system design interviews like a senior engineer:

- clarify requirements
- estimate volume
- choose architecture pattern
- draw data flow
- identify bottlenecks
- design reliability
- design replay/backfill
- control cost
- define data quality
- explain trade-offs

This lab is not about naming many tools. It is about making defensible architecture decisions.

## Folder Structure

```text
22-system-design-practice/
  README.md
  templates/
  scoring/
  estimation/
  diagrams/
  scenarios/
  model-answers/
  follow-ups/
```

## How To Use

For each scenario:

1. Read the scenario.
2. Fill the estimation worksheet.
3. Write requirements and assumptions.
4. Draw architecture.
5. Identify bottlenecks.
6. Define failure handling.
7. Define replay/backfill.
8. Define data quality checks.
9. Explain cost trade-offs.
10. Compare with model answer.
11. Practice follow-up questions.

## Standard Answer Flow

Use this structure in interviews:

```text
1. Clarify requirements.
2. Define sources and consumers.
3. Estimate volume and latency.
4. Choose pattern.
5. Design ingestion.
6. Design storage layers.
7. Design processing.
8. Design serving layer.
9. Add data quality and contracts.
10. Add reliability, replay, backfill.
11. Add monitoring and operations.
12. Discuss bottlenecks and cost.
13. Explain trade-offs.
```

## Scenarios Included

- Ecommerce warehouse.
- Clickstream analytics.
- Realtime fraud detection.
- CDC ingestion platform.
- Metrics platform.

## What Good Looks Like

A strong answer says:

```text
Given daily reporting requirements and finance-grade correctness, I would choose Batch ELT with immutable raw storage, dbt transformations, partitioned warehouse facts, reconciliation checks, and partition-level backfill. Streaming would add operational complexity without meeting a real latency need.
```

A weak answer says:

```text
I will use Kafka, Spark, Airflow, Snowflake, and dbt.
```

Tool names are not architecture. Requirements and trade-offs are architecture.

