# Prompt Bank de xay practice labs

File nay dung de copy prompt sang chat moi khi can nang cap mot practice folder thanh lab thuc hanh sau hon.

Quy tac chung:

- Chi build lab cho module dang hoc.
- Uu tien runnable local lab.
- Moi lab phai co dirty data hoac failure scenarios.
- Moi lab phai co exercises, broken examples, solutions, debugging workflow.
- Moi lab phai tao ra artifact co the dua len GitHub.

## Base prompt dung cho moi lab

```text
You are a Senior Staff Data Engineer and Data Platform Architect.

I am learning Data Engineering 2026. I already have a theory module and a practice folder scaffold.

Your task is to upgrade the practice folder into a real hands-on lab.

Requirements:
- Vietnamese explanations where useful.
- Production-first mindset.
- Debugging-first mindset.
- No shallow tutorial.
- Include realistic dirty data or broken scenarios.
- Include exercises from beginner -> implement -> debug -> optimize -> interview.
- Include README, setup, run commands, expected outputs, broken examples, solutions, runbook notes.
- Prefer local runnable setup with Docker Compose when suitable.
- Do not modify unrelated folders.

Before editing, inspect the current folder and theory file.
Then implement the lab end to end.
```

## 01 - SQL practice

Folder: `01-sql-practice/`

Theory: `de-2026-learning/01-sql.md`

```text
Upgrade `01-sql-practice/` into a complete production SQL lab.

Focus:
- PostgreSQL Docker setup
- ecommerce schema
- dirty raw data
- duplicate orders/customers/events
- join explosion
- window function dedup
- fact/dimension modeling
- incremental append vs merge/upsert
- watermark and late-arriving data
- data quality checks
- interview debugging scenarios

Required outputs:
- runnable Docker Compose
- init SQL
- staging SQL
- marts SQL
- quality SQL
- incremental SQL
- exercises by level
- broken interview queries
- solutions
- README with architecture and run commands
```

## 02 - Python practice

Folder: `02-python-practice/`

Theory: `de-2026-learning/02-python.md`

```text
Upgrade `02-python-practice/` into a runnable Python ingestion lab.

Focus:
- API ingestion
- CSV/JSON/JSONL ingestion
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

Required failure scenarios:
- pagination misses records
- retry creates duplicates
- API timeout
- partial file write
- missing env var
- bad data type

Required outputs:
- `src/`
- `tests/`
- `data/`
- `docker-compose.yml` with PostgreSQL
- README
- exercises
- solutions
```

## 03 - Engineering workflow practice

Folder: `03-engineering-workflow-practice/`

Theory: `de-2026-learning/03-git-linux-workflow.md`

```text
Upgrade `03-engineering-workflow-practice/` into a Git/Linux workflow lab for Data Engineering.

Focus:
- branch workflow
- commit discipline
- `.gitignore`
- `.env.example`
- PR template
- code review checklist
- shell commands for data/log inspection
- merge conflict simulation
- secret accidentally committed scenario

Required outputs:
- sample repo structure
- exercises
- broken scenarios
- PR templates
- review checklist
- README
```

## 04 - Docker practice

Folder: `04-docker-practice/`

Theory: `de-2026-learning/04-docker.md`

```text
Upgrade `04-docker-practice/` into a runnable Docker lab.

Focus:
- Dockerfile for Python pipeline
- Docker Compose with PostgreSQL
- service networking
- volumes
- bind mounts
- environment variables
- healthchecks
- container logs
- debugging port and hostname issues

Required failure scenarios:
- app uses localhost inside container
- port 5432 conflict
- missing env var
- database not ready
- volume deleted
- slow image rebuild due to bad layer order

Required outputs:
- `docker-compose.yml`
- `Dockerfile`
- Python app
- README
- exercises
- broken configs
- fixed solutions
```

## 05 - Cloud warehouse practice

Folder: `05-cloud-warehouse-practice/`

Theory: `de-2026-learning/05-cloud-warehouse-lake.md`

```text
Upgrade `05-cloud-warehouse-practice/` into a GCP/GCS/BigQuery lab.

Focus:
- GCP project setup
- GCS bucket layout
- service account and IAM notes
- external vs managed BigQuery tables
- partitioning
- clustering
- query bytes scanned
- cost optimization
- schema drift

Required outputs:
- README with architecture
- SQL for BigQuery tables
- sample data
- load scripts
- cost comparison queries
- exercises
- failure scenarios

Do not require real credentials in repo. Use `.env.example` and setup instructions.
```

## 06 - Orchestration practice

Folder: `06-orchestration-practice/`

Theory: `de-2026-learning/06-orchestration.md`

```text
Upgrade `06-orchestration-practice/` into an orchestration lab.

Focus:
- DAG/flow design
- logical date vs current date
- retry policy
- backfill
- idempotency
- dependency failure
- data quality failure
- runbook

Use either Kestra or Airflow. If possible, include both minimal examples.

Required failure scenarios:
- retry storm
- backfill duplicates data
- DAG succeeds but data stale
- task uses current_date and breaks backfill
- sensor waits forever

Required outputs:
- DAG/flow file
- docker-compose if needed
- README
- runbook
- exercises
- broken and fixed examples
```

## 07 - dbt practice

Folder: `07-dbt-practice/`

Theory: `de-2026-learning/07-dbt.md`

```text
Upgrade `07-dbt-practice/` into a portfolio-grade dbt project.

Focus:
- sources
- staging/intermediate/marts
- `ref()` and `source()`
- tests
- singular reconciliation test
- docs
- lineage
- incremental model
- snapshot
- CI-ready commands

Required failure scenarios:
- hard-coded table breaks lineage
- incremental misses late update
- uniqueness test fails
- accepted values test fails
- nested views become slow

Required outputs:
- `dbt_project.yml`
- models
- tests
- snapshots
- macros if useful
- README
- exercises
- solutions
```

## 08 - Data modeling practice

Folder: `08-data-modeling-practice/`

Theory: `de-2026-learning/08-data-modeling.md`

```text
Upgrade `08-data-modeling-practice/` into a data modeling lab.

Focus:
- grain
- fact tables
- dimension tables
- star schema
- SCD type 1 and type 2
- event modeling
- metric definitions
- join explosion
- duplicate metrics

Required failure scenarios:
- SCD2 join duplicates rows
- product revenue calculated from order-level payment
- dashboard A and B use different revenue definitions
- timezone changes DAU
- refunds missing from LTV

Required outputs:
- SQL/dbt models or SQL-only models
- ERD/mermaid diagram
- metric dictionary
- data dictionary
- exercises
- solutions
```

## 09 - Spark practice

Folder: `09-spark-practice/`

Theory: `de-2026-learning/09-spark.md`

```text
Upgrade `09-spark-practice/` into a runnable Spark batch lab.

Focus:
- PySpark DataFrame API
- Spark SQL
- CSV/JSON to Parquet
- partitioned output
- shuffle
- join strategies
- skew
- small files
- Spark UI debugging

Required failure scenarios:
- `collect()` crashes driver
- skewed join
- too many small files
- wrong overwrite mode deletes data
- executor OOM

Required outputs:
- Docker or local setup instructions
- `src/` PySpark jobs
- sample data generator
- exercises
- broken jobs
- solutions
- README
```

## 10 - Kafka practice

Folder: `10-kafka-practice/`

Theory: `de-2026-learning/10-kafka-streaming.md`

```text
Upgrade `10-kafka-practice/` into a runnable Kafka streaming lab.

Focus:
- Docker Compose Kafka
- producer
- consumer
- topic partitions
- keys
- consumer groups
- offset commit
- idempotent PostgreSQL sink
- DLQ
- replay
- lag debugging

Required failure scenarios:
- poison pill event
- offset committed before sink write
- sink write before offset commit causes duplicate
- rebalance duplicate processing
- hot partition lag

Required outputs:
- docker-compose
- producer code
- consumer code
- PostgreSQL sink
- DLQ topic
- exercises
- solutions
- README
```

## 11 - Data quality practice

Folder: `11-data-quality-practice/`

Theory: `de-2026-learning/11-data-quality-observability.md`

```text
Upgrade `11-data-quality-practice/` into a data quality and observability lab.

Focus:
- freshness
- completeness
- uniqueness
- validity
- referential integrity
- reconciliation
- alert design
- incident notes

Required failure scenarios:
- pipeline success but dashboard wrong
- source stops sending one partition
- new status breaks metric
- duplicate append inflates revenue
- alert has no owner

Required outputs:
- SQL checks
- dbt tests if useful
- incident templates
- runbook
- exercises
- solutions
```

## 12 - CI/CD practice

Folder: `12-cicd-practice/`

Theory: `de-2026-learning/12-cicd-testing-production.md`

```text
Upgrade `12-cicd-practice/` into a CI/CD lab for data projects.

Focus:
- pytest
- dbt build/test
- GitHub Actions
- env separation
- secrets
- deployment gates
- rollback thinking

Required failure scenarios:
- CI uses production credentials
- dbt deploy breaks dashboard
- rollback code does not rollback data
- secret committed
- test data too different from prod

Required outputs:
- `.github/workflows/`
- sample Python tests
- sample dbt commands
- README
- deployment checklist
- rollback notes
```

## 13 - Portfolio practice

Folder: `13-portfolio-practice/`

Theory: `de-2026-learning/13-portfolio-interview.md`

```text
Upgrade `13-portfolio-practice/` into a portfolio packaging lab.

Focus:
- architecture diagram
- README quality
- data model documentation
- run commands
- quality checks
- failure handling
- cost/scaling notes
- trade-off explanation
- interview storytelling

Required outputs:
- README template
- project scoring rubric
- architecture diagram template
- failure handling template
- interview answer template
- checklist
```

## 14 - Storage format practice

Folder: `14-storage-format-practice/`

Theory: `de-2026-learning/14-storage-file-format.md`

```text
Upgrade `14-storage-format-practice/` into a storage and file format lab.

Focus:
- CSV vs JSON vs Parquet
- row vs columnar
- compression
- partitioning
- small files
- schema evolution
- predicate pushdown
- column pruning

Required failure scenarios:
- wrong partition overwrite
- small files slow query planning
- schema drift
- raw JSON deleted before reprocessing
- compression trade-off

Required outputs:
- data generator
- conversion scripts
- query examples
- exercises
- README
```

## 15 - Lakehouse practice

Folder: `15-lakehouse-practice/`

Theory: `de-2026-learning/15-lakehouse-modern-stack.md`

```text
Upgrade `15-lakehouse-practice/` into a lakehouse design lab.

Focus:
- medallion architecture
- Delta/Iceberg/Hudi comparison
- table metadata
- ACID table concept
- time travel
- merge/upsert
- compaction
- vacuum/retention
- schema evolution

Required failure scenarios:
- vacuum deletes rollback files
- concurrent writer conflict
- streaming creates small files
- schema evolution allows bad column
- metadata/catalog stale

Required outputs:
- design docs
- sample table layout
- policy docs
- exercises
- interview cases
```

## 16 - Distributed systems practice

Folder: `16-distributed-systems-practice/`

Theory: `de-2026-learning/16-distributed-systems-for-de.md`

```text
Upgrade `16-distributed-systems-practice/` into a distributed failure simulation lab.

Focus:
- partial failure
- timeout
- retry
- duplicate writes
- out-of-order events
- backpressure
- idempotency
- replay
- ordering guarantees

Required failure scenarios:
- producer retry duplicates event
- consumer crashes after sink write before offset commit
- older update overwrites newer value
- replay duplicates published data
- downstream slow causes backpressure

Required outputs:
- simulation scripts
- event examples
- state tables
- exercises
- solutions
- README
```

## 17 - Performance cost practice

Folder: `17-performance-cost-practice/`

Theory: `de-2026-learning/17-performance-cost-optimization.md`

```text
Upgrade `17-performance-cost-practice/` into a performance and cost investigation lab.

Focus:
- bytes scanned
- partition pruning
- column pruning
- join cardinality
- aggregate marts
- Spark shuffle/skew
- Kafka lag
- cost attribution

Required failure scenarios:
- dashboard scans raw events every minute
- dbt full refresh scans too much
- Spark job reruns and doubles compute
- Kafka retention too long
- no owner labels on expensive jobs

Required outputs:
- investigation templates
- SQL examples
- cost report template
- exercises
- solutions
```

## 18 - Governance security practice

Folder: `18-governance-security-practice/`

Theory: `de-2026-learning/18-governance-security.md`

```text
Upgrade `18-governance-security-practice/` into a governance and security lab.

Focus:
- data classification
- PII
- IAM matrix
- least privilege
- row/column access
- masking/tokenization
- audit logs
- retention
- incident response

Required failure scenarios:
- public bucket exposes PII
- analyst gets raw access unnecessarily
- service account has owner role
- retention deletes audit data
- dashboard leaks customer email

Required outputs:
- classification matrix
- IAM matrix
- access workflow
- incident response runbook
- exercises
```

## 19 - Production operations practice

Folder: `19-production-ops-practice/`

Theory: `de-2026-learning/19-production-operations.md`

```text
Upgrade `19-production-ops-practice/` into a production operations lab.

Focus:
- SLA/SLO
- freshness
- run metadata
- runbooks
- incident severity
- backfill operations
- retry storm prevention
- postmortem

Required failure scenarios:
- DAG success but data stale
- backfill corrupts mart
- retry storm overloads API
- cost spike during reprocessing
- no owner receives alert

Required outputs:
- run metadata schema
- runbook templates
- incident templates
- backfill plan
- exercises
- solutions
```

## 20 - CDC practice

Folder: `20-cdc-practice/`

Theory: `de-2026-learning/20-cdc-and-real-time-ingestion.md`

```text
Upgrade `20-cdc-practice/` into a CDC correctness lab.

Focus:
- snapshot vs change stream
- insert/update/delete events
- WAL/binlog position
- changelog table
- current-state table
- schema evolution
- deletes/tombstones
- replay/recovery

Required failure scenarios:
- WAL/binlog retention expires
- delete events ignored
- schema rename breaks downstream
- offset committed before sink write
- older update overwrites newer state

Required outputs:
- event examples
- SQL models
- upsert/delete logic
- recovery playbook
- exercises
- solutions
```

## 21 - Pipeline patterns practice

Folder: `21-pipeline-patterns-practice/`

Theory: `de-2026-learning/21-data-pipeline-patterns.md`

```text
Upgrade `21-pipeline-patterns-practice/` into a pipeline pattern decision lab.

Focus:
- Batch ELT
- Batch ETL
- CDC
- event streaming
- micro-batch
- medallion
- Lambda vs Kappa
- outbox
- DLQ/quarantine
- fan-in/fan-out

Required outputs:
- decision matrix
- scenario exercises
- architecture diagrams
- failure scenarios
- interview questions
- README
```

## 22 - System design practice

Folder: `22-system-design-practice/`

Theory: `de-2026-learning/22-data-engineering-system-design.md`

```text
Upgrade `22-system-design-practice/` into a Data Engineering system design interview lab.

Focus:
- requirement clarification
- volume estimation
- architecture diagrams
- bottleneck analysis
- reliability
- replay/backfill
- cost
- data quality
- trade-offs

Required scenarios:
- ecommerce warehouse
- clickstream analytics
- realtime fraud
- CDC ingestion platform
- metrics platform

Required outputs:
- answer templates
- scoring rubric
- diagrams
- follow-up questions
- model answers
```

## 23 - IaC practice

Folder: `23-iac-practice/`

Theory: `de-2026-learning/23-infrastructure-as-code.md`

```text
Upgrade `23-iac-practice/` into a Terraform/IaC lab for data platform resources.

Focus:
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

Required failure scenarios:
- plan wants to destroy production bucket
- manual change causes drift
- IAM binding removed pipeline access
- dev writes to prod bucket
- public bucket risk

Required outputs:
- Terraform folder structure
- sample modules
- plan review checklist
- IAM matrix
- README
- exercises
```

