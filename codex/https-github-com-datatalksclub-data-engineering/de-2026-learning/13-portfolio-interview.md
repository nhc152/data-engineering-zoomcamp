# Portfolio Project va Interview Data Engineer 2026

## Vai tro cua portfolio

Portfolio Data Engineer khong phai noi khoe nhieu tool. No la bang chung rang ban co the thiet ke, build, debug va van hanh mot data pipeline co logic production.

Project tot phai tra loi duoc:

- Du lieu den tu dau?
- Pipeline co layer nao?
- Grain cua output la gi?
- Neu chay lai co duplicate khong?
- Neu source tre/sai schema thi sao?
- Metric co duoc validate khong?
- Chi phi va scaling trade-off la gi?
- Neu production fail thi debug o dau?

Voi background ODI/Talend, ban co loi the: ban da hieu ETL, migration, source-target mapping. Portfolio nen cho thay ban da nang cap sang modern data engineering bang code, cloud, orchestration, quality va reliability.

## Muc tieu can dat

Sau module nay, ban nen:

- Chon project co gia tri interview.
- Viet README theo architecture-first style.
- Giai thich trade-off cua tung tool.
- Ke cau chuyen project theo business problem -> architecture -> failure handling.
- Chuan bi system design interview cho data pipeline.
- Toi uu GitHub profile va resume positioning.
- Tra loi debugging questions nhu engineer co kinh nghiem production.

## Portfolio strategy

Khong can 10 project. Can 2 project manh:

1. Batch ELT production-style project.
2. Streaming hoac Spark/lakehouse mini project.

Mot project manh hon 5 tutorial clone vi no co:

- Data model.
- Orchestration.
- Incremental/backfill.
- Data quality.
- Failure handling.
- README ro.
- Trade-off explanation.

## Good vs bad projects

### Bad project

Dau hieu:

- Chi co notebook.
- Khong co README setup.
- Khong co Docker.
- Khong co data quality.
- Khong co architecture diagram.
- Khong giai thich grain.
- Chi follow tutorial y nguyen.
- Dung nhieu tool nhung khong giai thich ly do.

Example xau:

```text
CSV -> pandas notebook -> chart
```

Neu apply Data Engineer, project nay qua yeu vi khong the hien production concerns.

### Good project

Dau hieu:

- Co pipeline chay lai duoc.
- Co raw/staging/mart.
- Co orchestration.
- Co tests/checks.
- Co incremental logic hoac backfill.
- Co README architecture-first.
- Co runbook/debug section.

Example tot:

```text
API ingestion -> raw storage -> warehouse -> dbt models -> quality checks -> orchestrated daily run -> dashboard/mart
```

## Project 1: Batch ELT pipeline

Architecture:

```text
public API / CSV
        |
        v
Python ingestion
        |
        v
GCS / local data lake raw files
        |
        v
BigQuery / PostgreSQL warehouse
        |
        v
dbt staging + marts
        |
        v
quality checks + dashboard-ready tables
        |
        v
Kestra/Airflow orchestration
```

Required features:

- Raw data preserved.
- Staging layer cleans types/status/names.
- Fact/dimension or mart layer.
- Incremental load or at least idempotent daily load.
- Data tests: unique, not null, accepted values, reconciliation.
- README explains grain.
- Runbook explains failure handling.

Trade-offs to explain:

- Why ELT instead of ETL.
- Why warehouse transform with dbt.
- Why partition by date.
- Why store raw before transform.
- Why orchestration is separate from transformation.

## Project 2: Streaming pipeline

Architecture:

```text
producer
        |
        v
Kafka topic
        |
        v
idempotent consumer
        |
        v
PostgreSQL / BigQuery sink
        |
        v
quality and lag monitoring
```

Required features:

- Event has `event_id`, `event_type`, `event_timestamp`, schema version.
- Producer key chosen intentionally.
- Consumer handles duplicate event.
- Sink uses upsert or processed_events table.
- DLQ or invalid event path.
- README explains at-least-once and idempotency.

Trade-offs to explain:

- Why streaming instead of batch.
- Why key by entity.
- Why duplicates are expected.
- Why exactly-once is hard end-to-end.
- Why DLQ exists.

## Project 3: Spark batch/lake project

Architecture:

```text
raw files
        |
        v
Spark cleaning + dedup
        |
        v
partitioned parquet
        |
        v
aggregated marts
```

Required features:

- Parquet output.
- Partition strategy.
- Dedup with window.
- Join with grain awareness.
- Logs row counts.
- Performance notes: shuffle, partition, small files.

This project is good if targeting big data/lakehouse roles.

## README structure

README nen bat dau bang architecture, khong bat dau bang "This is a project where I learned...".

Suggested structure:

```text
# Project Name

## Problem
## Architecture
## Tech Stack
## Data Source
## Data Model and Grain
## Pipeline Flow
## Setup
## How to Run
## Data Quality Checks
## Incremental and Backfill Strategy
## Failure Handling
## Cost and Scaling Considerations
## Trade-offs
## Future Improvements
```

Architecture section nen co diagram text hoac Mermaid.

## Project storytelling

Interview story format:

1. Business problem.
2. Data source and constraints.
3. Architecture.
4. Modeling decisions.
5. Reliability decisions.
6. Debugging/failure scenarios.
7. Trade-offs.
8. Improvements.

Example:

> I built a daily ecommerce ELT pipeline. Raw orders and payments are ingested with Python and stored before transformation. dbt builds staging models, a one-row-per-order fact table, and daily revenue marts. The pipeline is orchestrated with Kestra. I added uniqueness, not-null, accepted-values, and reconciliation checks because the most likely failures are duplicate appends, status changes, and payment mismatches.

## Architecture explanation mindset

Khi giai thich architecture, dung cau hoi:

- Source system co reliability nhu the nao?
- Raw data co duoc giu khong?
- Transform o dau va vi sao?
- Output grain la gi?
- Job co idempotent khong?
- Data quality nam o layer nao?
- Backfill chay ra sao?
- Cost bi anh huong boi gi?
- Monitoring/alerting o dau?

Dung "I chose X because..." thay vi chi liet ke tool.

## Trade-offs can noi duoc

### Batch vs streaming

Batch don gian hon, de debug, reprocess tot. Streaming latency thap hon nhung phuc tap ve ordering, duplicate, replay, lag.

### Warehouse vs Spark

Warehouse de van hanh analytics SQL. Spark phu hop xu ly file/lake quy mo lon, custom compute, large joins/aggregations ngoai warehouse.

### Full refresh vs incremental

Full refresh don gian va dung neu data nho. Incremental nhanh hon nhung can watermark, merge key, late-arriving handling va reconciliation.

### Airflow/Kestra vs dbt

Orchestrator quan ly workflow, schedule, retry, backfill. dbt quan ly SQL transformations, tests, docs, lineage. Chon dung vai tro, khong tron.

## Debugging interview questions

### Pipeline success but dashboard wrong

Answer structure:

- Check freshness.
- Trace row count raw -> staging -> fact -> mart.
- Check duplicate keys.
- Check join grain.
- Check business filters.
- Reconcile source vs target.
- Check recent deploy/source changes.

### Revenue increased after a join

Likely join explosion. Check input grain, row counts before/after join, distinct order IDs, duplicate keys in dimension, and whether order-level metrics are repeated on item-level rows.

### Incremental missed records

Likely watermark problem. Check whether filter uses event date instead of updated_at, whether late-arriving data exists, whether lookback window is sufficient, and whether merge/upsert key is correct.

### Kafka consumer duplicated rows

Expected under at-least-once. Check offset commit timing, consumer crash logs, replay history, event_id, and sink unique constraints. Fix with idempotent consumer.

### Spark job suddenly slow

Check stage duration, shuffle size, skew, input file count, partition count, recent data distribution changes, and whether a broadcast join stopped happening.

## System design interview prep

Practice designs:

1. Design daily sales reporting pipeline.
2. Design real-time order event ingestion.
3. Design customer 360 data mart.
4. Design data quality platform for warehouse.
5. Design backfill strategy for 2 years of order data.

For each design, cover:

- Requirements.
- Sources.
- Latency.
- Volume.
- Architecture.
- Storage.
- Processing.
- Data model.
- Orchestration.
- Quality.
- Monitoring.
- Failure handling.
- Cost.
- Trade-offs.

Senior-level signal:

- You ask about SLA, volume, schema ownership, downstream users, backfill, and failure modes before choosing tools.

## Real interview patterns

### Pattern 1: Deep dive your project

They will ask:

- Why this architecture?
- What failed?
- How did you test it?
- How would it scale 10x?
- What would you change?

Prepare real answers. "I followed tutorial" is weak. "I chose partition by date because most queries filter by date and it limits scan cost" is strong.

### Pattern 2: Debugging scenario

They give broken metric/pipeline. They evaluate whether you debug systematically:

- isolate layer
- check grain
- check duplicates
- reconcile
- inspect recent changes
- propose prevention

### Pattern 3: SQL/modeling

Expect:

- fact/dimension
- grain
- window dedup
- incremental logic
- join explosion

### Pattern 4: Platform/reliability

Expect:

- orchestration failure
- backfill
- retry/idempotency
- data quality
- CI/CD
- secrets

## Resume positioning

Bad bullet:

```text
Built data pipeline using Python, Airflow, BigQuery, dbt.
```

Better bullet:

```text
Built an idempotent daily ELT pipeline ingesting ecommerce orders into BigQuery, modeling one-row-per-order facts with dbt, and adding uniqueness, freshness, and payment reconciliation checks to prevent duplicate revenue reporting.
```

Strong bullet structure:

```text
Action + system + scale/constraint + reliability/result
```

Examples:

- Designed a batch ELT pipeline with raw/staging/mart layers and dbt tests for order revenue reporting.
- Implemented incremental upsert logic with updated_at watermark and 2-day lookback to handle late-arriving order updates.
- Added reconciliation checks between payment source totals and revenue marts to detect metric drift.
- Built idempotent Kafka consumer using event_id deduplication and PostgreSQL upsert semantics.

## GitHub optimization

Profile should show:

- 2 pinned DE projects.
- Clean README.
- Architecture diagrams.
- Reproducible setup.
- No secrets.
- Small sample data.
- Run commands.
- Data model docs.
- Quality checks.
- Runbook.

Repository names:

- `ecommerce-elt-data-platform`
- `kafka-orders-streaming-pipeline`
- `spark-lakehouse-batch-processing`

Avoid:

- `test-project`
- `data-engineering-practice`
- `zoomcamp-homework-copy`

## Good portfolio checklist

- [ ] Project solves a business-like problem.
- [ ] Architecture diagram exists.
- [ ] Pipeline can run locally or with clear cloud steps.
- [ ] Raw/staging/mart layers exist.
- [ ] Grain documented.
- [ ] Incremental/idempotency explained.
- [ ] Data quality checks included.
- [ ] Debugging/runbook section included.
- [ ] Trade-offs explained.
- [ ] Future improvements realistic.

## Mini project

Create final portfolio project:

```text
Ecommerce Orders Data Platform

Sources:
  - orders API or CSV
  - payments CSV
  - customers CSV

Pipeline:
  - Python ingestion
  - raw storage
  - warehouse tables
  - dbt staging/facts/marts
  - orchestration
  - quality checks
  - dashboard-ready output
```

Required README sections:

- Problem.
- Architecture.
- Data model and grain.
- Incremental strategy.
- Data quality.
- Failure handling.
- Cost/scaling considerations.
- Interview talking points.

## Interview questions

- Walk me through your project architecture.
- Why did you choose this stack?
- What is the grain of your fact table?
- How do you prevent duplicate data?
- How do you handle late-arriving records?
- What happens if the source sends bad data?
- How would you backfill 2 years?
- How would this scale 10x?
- How do you monitor freshness?
- How do you reconcile revenue?
- What was the hardest bug?
- What would you improve?

## Senior-level mindset

Senior signal khong phai biet nhieu tool. Senior signal la:

- Biet noi "khong can streaming neu batch du".
- Biet hoi SLA va volume truoc khi chon architecture.
- Biet grain truoc khi join.
- Biet duplicate la normal failure mode.
- Biet incremental can reprocess strategy.
- Biet dashboard sai co the do definition, khong chi code.
- Biet production system can runbook, owner, alert va rollback.

## GitHub outputs

Portfolio nen co:

- `README.md` architecture-first.
- `docs/architecture.md`.
- `docs/data_model.md`.
- `docs/runbook.md`.
- `docs/interview_talking_points.md`.
- `sql/` hoac `dbt/`.
- `src/`.
- `tests/`.
- `quality/`.
- `.env.example`.
- `docker-compose.yml`.
- GitHub Actions workflow neu co.

## Production upgrade: portfolio scoring rubric

### 100-point DE portfolio rubric

| Area | Points | What interviewers look for |
| --- | ---: | --- |
| Clear problem statement | 10 | Realistic business/data problem, not just "I used tools" |
| Architecture | 15 | Source -> storage -> warehouse -> transform -> quality -> serving |
| Reproducibility | 15 | Docker/setup/run commands, `.env.example`, sample data |
| Data modeling | 15 | Grain, facts/dimensions, metrics definitions |
| Reliability | 10 | Idempotency, retry/backfill, failure handling |
| Data quality | 10 | Tests, reconciliation, freshness, duplicate checks |
| Cost/scaling | 10 | Partitioning, batching, query cost, bottlenecks |
| Code quality | 10 | Clean structure, config, logging, tests |
| Storytelling | 5 | Can explain trade-offs and improvements |

Minimum impressive project: 75+ points.

### Red flags

- Only notebooks, no runnable pipeline.
- README has screenshots but no run commands.
- No data quality checks.
- No grain/metric definitions.
- No failure handling.
- Too many tools with shallow explanation.
- Secrets committed.
- Dashboard query directly from raw messy tables.

### Minimum impressive project

Build one strong batch ELT project before adding many weak projects:

```text
API/CSV
  -> Python ingestion
  -> raw storage/Postgres/BigQuery
  -> dbt or SQL staging
  -> fact/dim/mart
  -> quality checks
  -> orchestration
  -> README/runbook
```

Interview value comes from explaining decisions:

- Why this grain?
- Why this incremental strategy?
- How do you detect duplicate data?
- What happens if the API returns partial data?
- What would break at 100x scale?
