# Full Prompts de build practice labs

File nay gom prompt day du, co the copy-paste truc tiep sang chat moi de build tung lab. Moi prompt da bao gom role, context, input files, yeu cau, acceptance criteria va output.

Quy tac dung:

- Chi copy prompt cua module dang hoc.
- Khong build nhieu lab cung luc.
- Sau khi build xong, chay theo README va sua loi neu co.
- Neu lab qua lon, yeu cau build theo phase: Level 1 scaffold -> Level 2 runnable -> Level 3 debugging -> Level 4 portfolio.

## Prompt 01 - SQL Practice Lab

```text
# ROLE
You are a Senior Staff Data Engineer and Data Platform Architect.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/01-sql.md`
- Practice folder: `01-sql-practice/`

My background:
- I know ETL, SQL, ODI, Talend, and data migration.
- I want production-style SQL practice, not LeetCode SQL.

# TASK
Upgrade `01-sql-practice/` into a complete production SQL lab.

Before editing:
1. Inspect `de-2026-learning/01-sql.md`.
2. Inspect current `01-sql-practice/`.
3. Preserve useful existing files.
4. Do not modify unrelated folders.

# FOCUS
The lab must teach:
- PostgreSQL Docker setup
- ecommerce schema
- dirty raw data
- duplicate orders/customers/events
- join explosion
- window function deduplication
- grain mindset
- fact/dimension modeling
- incremental append vs merge/upsert
- watermark and late-arriving data
- data quality checks
- reconciliation checks
- interview debugging scenarios

# REQUIRED FOLDER STRUCTURE
Create or complete:

```text
01-sql-practice/
  docker-compose.yml
  README.md
  init/
  staging/
  marts/
  quality/
  incremental/
  exercises/
  interview/
  solutions/
```

# REQUIRED FAILURE SCENARIOS
Include realistic production problems:
- duplicate raw orders
- duplicate customers
- null values
- inconsistent status casing
- payment mismatch
- missing foreign keys
- late-arriving data
- timezone inconsistency
- join explosion
- duplicate append
- broken incremental watermark

# EXERCISE DESIGN
Exercises must progress:
1. Foundation
2. Joins and grain
3. Window functions
4. Modeling
5. Incremental loading
6. Debugging incidents
7. Interview scenarios

# ACCEPTANCE CRITERIA
- Lab runs locally with Docker Compose.
- PostgreSQL auto-loads schema and seed data.
- README has setup, run commands, architecture, grain explanation, debugging workflow.
- Every exercise has clear goal and expected learning.
- Broken queries are intentionally wrong and realistic.
- Solutions are complete.
- No placeholder files.
- Do not summarize instead of creating files.
```

## Prompt 02 - Python Practice Lab

```text
# ROLE
You are a Senior Staff Data Engineer and Python Data Platform Engineer.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/02-python.md`
- Practice folder: `02-python-practice/`

My background:
- I know ETL, SQL, ODI, Talend.
- I need to transition from GUI ETL tools to code-based Python pipelines.

# TASK
Upgrade `02-python-practice/` into a runnable Python ingestion lab.

Before editing:
1. Inspect `de-2026-learning/02-python.md`.
2. Inspect current `02-python-practice/`.
3. Preserve useful existing files.
4. Do not modify unrelated folders.

# FOCUS
The lab must teach:
- CSV ingestion
- JSON/JSONL ingestion
- simulated API ingestion
- config via `.env`
- structured logging
- retry with backoff and jitter
- pagination
- rate limit handling
- raw file write before transform
- validation
- idempotent load into PostgreSQL
- pytest tests
- broken scenarios

# REQUIRED FOLDER STRUCTURE
Create or complete:

```text
02-python-practice/
  docker-compose.yml
  Dockerfile
  README.md
  .env.example
  pyproject.toml or requirements.txt
  src/
    config.py
    extract.py
    transform.py
    validate.py
    load.py
    main.py
    logging_config.py
  tests/
  data/
    raw/
    processed/
  sql/
  exercises/
  broken/
  solutions/
  runbook/
```

# REQUIRED FAILURE SCENARIOS
Include:
- pagination bug misses records
- retry creates duplicates
- API timeout
- partial file write
- missing env var
- bad data type
- invalid required columns
- duplicate business key

# EXERCISE DESIGN
Exercises must progress:
1. Read CSV and validate schema.
2. Read JSON/JSONL and write raw copy.
3. Simulate paginated API extraction.
4. Load into PostgreSQL.
5. Add idempotent upsert.
6. Add retry and logging.
7. Add tests.
8. Debug broken ingestion.

# ACCEPTANCE CRITERIA
- Lab runs locally with Docker Compose.
- README has setup and exact run commands.
- Python code is clean, modular, and testable.
- Tests can be run locally.
- Broken examples are intentionally wrong and explained.
- Solutions are complete.
- No secrets committed.
- No placeholder files.
```

## Prompt 03 - Engineering Workflow Practice Lab

```text
# ROLE
You are a Senior Staff Data Engineer reviewing engineering workflow for data projects.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/03-git-linux-workflow.md`
- Practice folder: `03-engineering-workflow-practice/`

# TASK
Upgrade `03-engineering-workflow-practice/` into a Git/Linux workflow lab for Data Engineering.

Before editing:
1. Inspect the theory file.
2. Inspect the practice folder.
3. Do not modify unrelated folders.

# FOCUS
The lab must teach:
- Git branch workflow
- commit discipline
- reviewing `git diff`
- `.gitignore`
- `.env.example`
- PR template
- CODEOWNERS concept
- data pipeline code review checklist
- Linux commands for data/log inspection
- merge conflict simulation
- secret accidentally committed scenario

# REQUIRED FOLDER STRUCTURE

```text
03-engineering-workflow-practice/
  README.md
  sample-project/
  exercises/
  broken/
  solutions/
  templates/
    PULL_REQUEST_TEMPLATE.md
    CODE_REVIEW_CHECKLIST.md
    RUNBOOK_TEMPLATE.md
```

# REQUIRED FAILURE SCENARIOS
Include:
- secret committed by mistake
- generated data committed into repo
- bad `.gitignore`
- merge conflict in SQL/dbt model
- README missing run commands
- accidental prod config change

# ACCEPTANCE CRITERIA
- Lab is runnable without cloud services.
- Exercises include exact commands.
- Broken scenarios are realistic.
- Solutions include explanation.
- README teaches workflow, not just commands.
```

## Prompt 04 - Docker Practice Lab

```text
# ROLE
You are a Senior Data Platform Engineer specializing in Dockerized local data platforms.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/04-docker.md`
- Practice folder: `04-docker-practice/`

# TASK
Upgrade `04-docker-practice/` into a runnable Docker lab.

Before editing:
1. Inspect theory and folder.
2. Do not modify unrelated folders.

# FOCUS
The lab must teach:
- Dockerfile for Python pipeline
- Docker Compose with PostgreSQL
- service networking
- volumes vs bind mounts
- environment variables
- healthchecks
- container logs
- debugging port and hostname issues
- image build hygiene

# REQUIRED FOLDER STRUCTURE

```text
04-docker-practice/
  docker-compose.yml
  Dockerfile
  README.md
  .env.example
  src/
  sql/
  data/
  exercises/
  broken/
  solutions/
```

# REQUIRED FAILURE SCENARIOS
Include:
- app uses `localhost` inside container
- port 5432 conflict
- missing env var
- database not ready
- volume deleted accidentally
- slow image rebuild due to bad Dockerfile layer order

# ACCEPTANCE CRITERIA
- `docker compose up` starts required services.
- README explains how to run, inspect logs, exec into containers, reset volumes.
- Broken configs are included and fixed in solutions.
- No placeholder files.
```

## Prompt 05 - Cloud Warehouse Practice Lab

```text
# ROLE
You are a Senior Data Warehouse Architect specializing in GCP, GCS, and BigQuery.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/05-cloud-warehouse-lake.md`
- Practice folder: `05-cloud-warehouse-practice/`

# TASK
Upgrade `05-cloud-warehouse-practice/` into a GCP/GCS/BigQuery lab.

Before editing:
1. Inspect theory and folder.
2. Do not modify unrelated folders.
3. Do not include real credentials.

# FOCUS
The lab must teach:
- GCP project setup
- GCS bucket layout
- service account and IAM notes
- raw zone naming
- external vs managed BigQuery tables
- partitioning
- clustering
- query bytes scanned
- cost optimization
- schema drift
- warehouse layers

# REQUIRED FOLDER STRUCTURE

```text
05-cloud-warehouse-practice/
  README.md
  .env.example
  data/
  gcs-layout/
  bigquery/
    ddl/
    queries/
    cost_checks/
  exercises/
  broken/
  solutions/
  runbook/
```

# REQUIRED FAILURE SCENARIOS
Include:
- dataset and bucket location mismatch
- query scans full table due to missing partition filter
- service account has too much permission
- raw file overwritten during backfill
- schema drift breaks load job

# ACCEPTANCE CRITERIA
- README includes setup without exposing credentials.
- SQL is BigQuery-compatible.
- Cost comparison queries are included.
- IAM matrix is included.
- Exercises have expected outputs.
```

## Prompt 06 - Orchestration Practice Lab

```text
# ROLE
You are a Senior Data Platform Engineer specializing in workflow orchestration.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/06-orchestration.md`
- Practice folder: `06-orchestration-practice/`

# TASK
Upgrade `06-orchestration-practice/` into an orchestration lab.

Before editing:
1. Inspect theory and folder.
2. Do not modify unrelated folders.

# FOCUS
The lab must teach:
- DAG/flow design
- task boundaries
- logical date vs current date
- scheduling
- retry policy
- idempotency
- backfill
- dependency failure
- data quality failure
- alerting
- runbook

# TOOLING
Use Kestra or Airflow. Prefer runnable Docker Compose if practical.
If including both is too large, build one runnable tool and include comparison notes.

# REQUIRED FOLDER STRUCTURE

```text
06-orchestration-practice/
  docker-compose.yml
  README.md
  flows/ or dags/
  scripts/
  data/
  exercises/
  broken/
  solutions/
  runbook/
```

# REQUIRED FAILURE SCENARIOS
Include:
- retry storm
- backfill duplicates data
- DAG succeeds but data stale
- task uses `current_date` and breaks backfill
- sensor waits forever
- downstream dependency missing

# ACCEPTANCE CRITERIA
- README has exact run commands.
- Flow/DAG has date parameter.
- Backfill exercise exists.
- Broken and fixed examples exist.
- Runbook explains how to triage failed runs.
```

## Prompt 07 - dbt Practice Lab

```text
# ROLE
You are a Senior Analytics Engineer and Data Warehouse Architect.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/07-dbt.md`
- Practice folder: `07-dbt-practice/`

# TASK
Upgrade `07-dbt-practice/` into a portfolio-grade dbt project.

Before editing:
1. Inspect theory and folder.
2. Do not modify unrelated folders.

# FOCUS
The lab must teach:
- dbt project structure
- sources
- staging/intermediate/marts
- `ref()` and `source()`
- generic tests
- singular reconciliation tests
- docs
- lineage
- incremental model
- snapshot
- macros where useful
- CI-ready commands

# REQUIRED FOLDER STRUCTURE

```text
07-dbt-practice/
  README.md
  docker-compose.yml optional
  dbt_project.yml
  profiles.yml.example
  models/
    staging/
    intermediate/
    marts/
  tests/
  snapshots/
  macros/
  seeds/
  analyses/
  exercises/
  broken/
  solutions/
```

# REQUIRED FAILURE SCENARIOS
Include:
- hard-coded table breaks lineage
- incremental model misses late update
- uniqueness test fails
- accepted values test fails
- nested views become slow
- source schema changes

# ACCEPTANCE CRITERIA
- dbt commands are documented.
- Models use `ref()` and `source()`.
- Tests are meaningful, not decorative.
- Docs/lineage workflow is included.
- Broken examples and solutions exist.
```

## Prompt 08 - Data Modeling Practice Lab

```text
# ROLE
You are a Senior Data Modeler and Staff Data Engineer.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/08-data-modeling.md`
- Practice folder: `08-data-modeling-practice/`

# TASK
Upgrade `08-data-modeling-practice/` into a grain-first data modeling lab.

# FOCUS
The lab must teach:
- grain
- fact tables
- dimension tables
- star schema
- snowflake schema trade-off
- SCD type 1 and type 2
- event modeling
- metric definitions
- semantic consistency
- join explosion
- duplicate metrics

# REQUIRED FOLDER STRUCTURE

```text
08-data-modeling-practice/
  README.md
  docs/
    data_model.md
    metric_definitions.md
    erd.md
  sql/
  exercises/
  broken/
  solutions/
  interview/
```

# REQUIRED FAILURE SCENARIOS
Include:
- SCD2 join duplicates rows
- product revenue calculated from order-level payment
- dashboard A and B use different revenue definitions
- timezone changes DAU
- refunds missing from LTV

# ACCEPTANCE CRITERIA
- Every model has grain.
- Metric dictionary is explicit.
- Broken scenarios include diagnostic queries.
- Solutions explain why the fix preserves grain.
```

## Prompt 09 - Spark Practice Lab

```text
# ROLE
You are a Senior Big Data Engineer specializing in Spark performance and reliability.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/09-spark.md`
- Practice folder: `09-spark-practice/`

# TASK
Upgrade `09-spark-practice/` into a runnable Spark batch lab.

# FOCUS
The lab must teach:
- PySpark DataFrame API
- Spark SQL
- CSV/JSON to Parquet
- partitioned output
- lazy evaluation
- shuffle
- join strategies
- skew
- small files
- Spark UI debugging

# REQUIRED FOLDER STRUCTURE

```text
09-spark-practice/
  README.md
  docker-compose.yml optional
  requirements.txt or pyproject.toml
  src/
  data/
    raw/
    output/
  exercises/
  broken/
  solutions/
  runbook/
```

# REQUIRED FAILURE SCENARIOS
Include:
- `collect()` crashes driver
- skewed join
- too many small files
- wrong overwrite mode deletes output
- executor OOM

# ACCEPTANCE CRITERIA
- Lab can run locally.
- README explains Spark UI inspection if available.
- Broken jobs are realistic.
- Solutions include performance explanation.
```

## Prompt 10 - Kafka Practice Lab

```text
# ROLE
You are a Senior Streaming Data Engineer specializing in Kafka correctness.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/10-kafka-streaming.md`
- Practice folder: `10-kafka-practice/`

# TASK
Upgrade `10-kafka-practice/` into a runnable Kafka streaming lab.

# FOCUS
The lab must teach:
- Kafka Docker Compose
- producer
- consumer
- topics and partitions
- producer keys
- consumer groups
- offset commit
- at-least-once behavior
- idempotent PostgreSQL sink
- DLQ
- replay
- lag debugging

# REQUIRED FOLDER STRUCTURE

```text
10-kafka-practice/
  docker-compose.yml
  README.md
  src/
    producer.py
    consumer.py
    dlq_consumer.py
  sql/
  data/
  exercises/
  broken/
  solutions/
  runbook/
```

# REQUIRED FAILURE SCENARIOS
Include:
- poison pill event
- offset committed before sink write causes data loss
- sink write before offset commit causes duplicate
- rebalance duplicate processing
- hot partition lag
- DLQ exists but nobody replays

# ACCEPTANCE CRITERIA
- `docker compose up` starts Kafka and PostgreSQL if needed.
- Producer and consumer run locally.
- Duplicate handling uses `event_id` or business key.
- README includes replay and DLQ instructions.
```

## Prompt 11 - Data Quality Practice Lab

```text
# ROLE
You are a Senior Data Reliability Engineer.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/11-data-quality-observability.md`
- Practice folder: `11-data-quality-practice/`

# TASK
Upgrade `11-data-quality-practice/` into a data quality and observability lab.

# FOCUS
The lab must teach:
- freshness
- completeness
- uniqueness
- validity
- referential integrity
- reconciliation
- anomaly thresholds
- alert design
- incident notes
- runbooks

# REQUIRED FOLDER STRUCTURE

```text
11-data-quality-practice/
  README.md
  sql/
  dbt_tests/ optional
  incidents/
  runbook/
  exercises/
  broken/
  solutions/
```

# REQUIRED FAILURE SCENARIOS
Include:
- pipeline success but dashboard wrong
- source stops sending one partition
- new status value breaks metric
- duplicate append inflates revenue
- alert has no owner

# ACCEPTANCE CRITERIA
- Checks are actionable.
- Every alert has owner, impact, and runbook.
- Incidents include root cause and prevention.
- Cost of checks is discussed.
```

## Prompt 12 - CI/CD Practice Lab

```text
# ROLE
You are a Senior DevOps/Data Platform Engineer for Data Engineering CI/CD.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/12-cicd-testing-production.md`
- Practice folder: `12-cicd-practice/`

# TASK
Upgrade `12-cicd-practice/` into a CI/CD lab for data projects.

# FOCUS
The lab must teach:
- pytest
- dbt build/test
- GitHub Actions
- environment separation
- secrets management
- deployment gates
- rollback thinking
- data vs code rollback

# REQUIRED FOLDER STRUCTURE

```text
12-cicd-practice/
  README.md
  .github/
    workflows/
  src/
  tests/
  dbt_sample/
  exercises/
  broken/
  solutions/
  runbook/
```

# REQUIRED FAILURE SCENARIOS
Include:
- CI uses production credentials
- dbt deploy breaks dashboard
- rollback code does not rollback data
- secret committed
- test data too different from prod

# ACCEPTANCE CRITERIA
- Workflow YAML is complete.
- README explains local and CI commands.
- Failure scenarios include prevention.
- No real secrets.
```

## Prompt 13 - Portfolio Practice Lab

```text
# ROLE
You are a Senior Data Engineering hiring manager and portfolio reviewer.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/13-portfolio-interview.md`
- Practice folder: `13-portfolio-practice/`

# TASK
Upgrade `13-portfolio-practice/` into a portfolio packaging lab.

# FOCUS
The lab must teach:
- architecture diagram
- README quality
- data model documentation
- run commands
- data quality checks
- failure handling
- cost/scaling notes
- trade-off explanation
- project storytelling
- interview Q&A

# REQUIRED OUTPUTS
Create:
- README template
- project scoring rubric
- architecture diagram template
- data model template
- runbook template
- failure handling template
- interview answer template
- checklist

# ACCEPTANCE CRITERIA
- Templates are specific to Data Engineering.
- Rubric identifies weak portfolio signs.
- Interview template teaches concise storytelling.
- No generic resume advice.
```

## Prompt 14 - Storage Format Practice Lab

```text
# ROLE
You are a Senior Data Platform Engineer specializing in storage layout and file formats.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/14-storage-file-format.md`
- Practice folder: `14-storage-format-practice/`

# TASK
Upgrade `14-storage-format-practice/` into a storage and file format lab.

# FOCUS
The lab must teach:
- CSV vs JSON vs Parquet
- row vs columnar
- compression
- partitioning
- small files
- schema evolution
- predicate pushdown
- column pruning

# REQUIRED FAILURE SCENARIOS
Include:
- wrong partition overwrite
- small files slow query planning
- schema drift
- raw JSON deleted before reprocessing
- compression trade-off

# REQUIRED OUTPUTS
- data generator
- conversion scripts
- query examples
- exercises
- broken scenarios
- solutions
- README

# ACCEPTANCE CRITERIA
- Lab can be run locally if practical.
- Size/query comparisons are included.
- README explains trade-offs.
```

## Prompt 15 - Lakehouse Practice Lab

```text
# ROLE
You are a Senior Lakehouse Architect.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/15-lakehouse-modern-stack.md`
- Practice folder: `15-lakehouse-practice/`

# TASK
Upgrade `15-lakehouse-practice/` into a lakehouse design lab.

# FOCUS
The lab must teach:
- medallion architecture
- Delta/Iceberg/Hudi comparison
- table metadata
- ACID table concept
- time travel
- merge/upsert
- compaction
- vacuum/retention
- schema evolution
- catalog concerns

# REQUIRED FAILURE SCENARIOS
Include:
- vacuum deletes rollback files
- concurrent writer conflict
- streaming creates small files
- schema evolution allows bad column
- metadata/catalog stale

# REQUIRED OUTPUTS
- design docs
- sample table layout
- policy docs
- exercises
- incident scenarios
- interview cases

# ACCEPTANCE CRITERIA
- Explains when not to use lakehouse.
- Compares Delta/Iceberg/Hudi clearly.
- Includes production policies.
```

## Prompt 16 - Distributed Systems Practice Lab

```text
# ROLE
You are a Senior Distributed Systems Engineer focused on Data Engineering reliability.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/16-distributed-systems-for-de.md`
- Practice folder: `16-distributed-systems-practice/`

# TASK
Upgrade `16-distributed-systems-practice/` into a distributed failure simulation lab.

# FOCUS
The lab must teach:
- partial failure
- timeout
- retry
- duplicate writes
- out-of-order events
- backpressure
- idempotency
- replay
- ordering guarantees
- exactly-once myth

# REQUIRED FAILURE SCENARIOS
Include:
- producer retry duplicates event
- consumer crashes after sink write before offset commit
- older update overwrites newer value
- replay duplicates published data
- downstream slow causes backpressure

# REQUIRED OUTPUTS
- simulation scripts
- event examples
- state tables
- exercises
- solutions
- README

# ACCEPTANCE CRITERIA
- Failures are deterministic enough to reproduce.
- Each scenario includes prevention strategy.
- Explanations connect to Kafka/Spark/CDC/orchestration.
```

## Prompt 17 - Performance Cost Practice Lab

```text
# ROLE
You are a Senior Data Platform Performance Engineer.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/17-performance-cost-optimization.md`
- Practice folder: `17-performance-cost-practice/`

# TASK
Upgrade `17-performance-cost-practice/` into a performance and cost investigation lab.

# FOCUS
The lab must teach:
- bytes scanned
- partition pruning
- column pruning
- join cardinality
- aggregate marts
- Spark shuffle/skew
- Kafka lag
- cost attribution
- owner labels

# REQUIRED FAILURE SCENARIOS
Include:
- dashboard scans raw events every minute
- dbt full refresh scans too much
- Spark job reruns and doubles compute
- Kafka retention too long
- no owner labels on expensive jobs

# REQUIRED OUTPUTS
- investigation templates
- SQL examples
- cost report template
- exercises
- broken examples
- solutions

# ACCEPTANCE CRITERIA
- Each optimization explains trade-off.
- Includes before/after metrics format.
- Includes cost ownership model.
```

## Prompt 18 - Governance Security Practice Lab

```text
# ROLE
You are a Senior Data Governance and Security Architect.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/18-governance-security.md`
- Practice folder: `18-governance-security-practice/`

# TASK
Upgrade `18-governance-security-practice/` into a governance and security lab.

# FOCUS
The lab must teach:
- data classification
- PII handling
- IAM matrix
- least privilege
- row-level access
- column-level masking
- tokenization/masking concepts
- audit logs
- retention
- incident response

# REQUIRED FAILURE SCENARIOS
Include:
- public bucket exposes PII
- analyst gets raw access unnecessarily
- service account has owner role
- retention deletes audit data
- dashboard leaks customer email

# REQUIRED OUTPUTS
- classification matrix
- IAM matrix
- access workflow
- masking policy
- retention policy
- incident response runbook
- exercises

# ACCEPTANCE CRITERIA
- Security decisions are concrete.
- Least privilege is explicit.
- Includes trade-off between self-service and control.
- No generic security slogans.
```

## Prompt 19 - Production Operations Practice Lab

```text
# ROLE
You are a Senior Data Reliability Engineer responsible for production operations.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/19-production-operations.md`
- Practice folder: `19-production-ops-practice/`

# TASK
Upgrade `19-production-ops-practice/` into a production operations lab.

# FOCUS
The lab must teach:
- SLA/SLO
- freshness
- run metadata
- runbooks
- incident severity
- backfill operations
- retry storm prevention
- postmortem
- publish gates

# REQUIRED FAILURE SCENARIOS
Include:
- DAG success but data stale
- backfill corrupts mart
- retry storm overloads API
- cost spike during reprocessing
- no owner receives alert

# REQUIRED OUTPUTS
- run metadata schema
- runbook templates
- incident templates
- backfill plan
- alert templates
- exercises
- solutions

# ACCEPTANCE CRITERIA
- Runbooks are actionable.
- Incidents include timeline, impact, root cause, prevention.
- Backfill plan includes safety checks.
```

## Prompt 20 - CDC Practice Lab

```text
# ROLE
You are a Senior CDC and Real-Time Ingestion Engineer.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/20-cdc-and-real-time-ingestion.md`
- Practice folder: `20-cdc-practice/`

# TASK
Upgrade `20-cdc-practice/` into a CDC correctness lab.

# FOCUS
The lab must teach:
- snapshot vs change stream
- insert/update/delete events
- WAL/binlog position
- Debezium-style event envelope
- raw changelog table
- current-state table
- schema evolution
- deletes/tombstones
- replay/recovery

# REQUIRED FAILURE SCENARIOS
Include:
- WAL/binlog retention expires
- delete events ignored
- schema rename breaks downstream
- offset committed before sink write
- older update overwrites newer state

# REQUIRED OUTPUTS
- event examples
- SQL models
- upsert/delete logic
- recovery playbook
- exercises
- broken examples
- solutions

# ACCEPTANCE CRITERIA
- Correctness is prioritized over low latency.
- Delete handling is explicit.
- Replay strategy is documented.
```

## Prompt 21 - Pipeline Patterns Practice Lab

```text
# ROLE
You are a Senior Data Platform Architect teaching pipeline architecture patterns.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/21-data-pipeline-patterns.md`
- Practice folder: `21-pipeline-patterns-practice/`

# TASK
Upgrade `21-pipeline-patterns-practice/` into a pipeline pattern decision lab.

# FOCUS
The lab must teach:
- Batch ELT
- Batch ETL
- CDC
- event streaming
- micro-batch
- medallion
- Lambda vs Kappa
- outbox pattern
- DLQ/quarantine
- fan-in/fan-out

# REQUIRED OUTPUTS
- decision matrix
- architecture diagrams
- scenario exercises
- failure scenarios
- model answers
- interview questions
- README

# REQUIRED SCENARIOS
Include:
- finance reporting
- clickstream analytics
- realtime fraud
- OLTP replication
- customer 360 fan-in
- order paid event outbox

# ACCEPTANCE CRITERIA
- Each pattern includes when to use, when not to use, cost, reliability, latency, complexity.
- Includes concrete trade-off language for interviews.
```

## Prompt 22 - System Design Practice Lab

```text
# ROLE
You are a Senior Staff Data Engineer conducting Data Engineering system design interview training.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/22-data-engineering-system-design.md`
- Practice folder: `22-system-design-practice/`

# TASK
Upgrade `22-system-design-practice/` into a Data Engineering system design interview lab.

# FOCUS
The lab must teach:
- requirement clarification
- volume estimation
- architecture diagrams
- bottleneck analysis
- scaling strategy
- reliability design
- replay/backfill
- cost
- data quality
- trade-offs

# REQUIRED SCENARIOS
Include:
- ecommerce warehouse
- clickstream analytics
- realtime fraud detection
- CDC ingestion platform
- metrics platform

# REQUIRED OUTPUTS
- answer templates
- scoring rubric
- diagrams
- follow-up questions
- model answers
- estimation worksheets

# ACCEPTANCE CRITERIA
- Answers are not generic.
- Each scenario includes requirements, architecture, bottlenecks, failure modes, cost, data quality, trade-offs.
- Includes interviewer follow-up traps.
```

## Prompt 23 - IaC Practice Lab

```text
# ROLE
You are a Senior Data Platform Infrastructure Engineer specializing in Terraform and IaC.

# CONTEXT
I am learning Data Engineering 2026. I already have:
- Theory file: `de-2026-learning/23-infrastructure-as-code.md`
- Practice folder: `23-iac-practice/`

# TASK
Upgrade `23-iac-practice/` into a Terraform/IaC lab for data platform resources.

# FOCUS
The lab must teach:
- GCS buckets
- BigQuery datasets
- service accounts
- IAM bindings
- lifecycle policies
- labels
- remote state
- state locking
- drift detection
- plan review
- cost controls

# REQUIRED FOLDER STRUCTURE

```text
23-iac-practice/
  README.md
  terraform/
    envs/
    modules/
  policies/
  docs/
  exercises/
  broken/
  solutions/
```

# REQUIRED FAILURE SCENARIOS
Include:
- Terraform plan wants to destroy production bucket
- manual change causes drift
- IAM binding removed pipeline access
- dev writes to prod bucket
- public bucket risk
- state lock stuck

# ACCEPTANCE CRITERIA
- Terraform examples are realistic.
- No real project IDs or secrets.
- Plan review checklist exists.
- IAM matrix exists.
- README explains safe apply workflow.
```

