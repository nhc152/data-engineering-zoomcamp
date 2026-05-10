# Practice Labs Roadmap

Ly thuyet trong `de-2026-learning/` phai di kem lab. `01-sql-practice/` la chuan dau tien: co environment, dirty data, exercises, debugging scenarios, incremental examples va interview cases.

Khong nen tao tat ca lab that sau cung luc. Chien luoc dung la:

1. Tao scaffold cho moi cum ky nang.
2. Khi hoc den module nao, mo rong lab do thanh runnable lab.
3. Moi lab phai tao ra GitHub artifact co the demo/phong van.

## Lab maturity levels

### Level 0: Reading module

Chi co markdown. Chua du.

### Level 1: Exercise scaffold

Co README, muc tieu, bai tap, output mong doi.

### Level 2: Runnable local lab

Co Docker/script/data sample, chay duoc local.

### Level 3: Production debugging lab

Co dirty data, failure scenarios, broken examples, solutions, runbook.

### Level 4: Portfolio-ready project

Co architecture, README, run commands, quality checks, CI, failure handling, cost/scaling notes.

`01-sql-practice/` hien dang o Level 3.

## Practice labs can co

### Core path

| Module | Lab | Target level |
|---|---|---|
| `01-sql.md` | `01-sql-practice/` | Level 3 |
| `02-python.md` | `02-python-practice/` | Level 3 |
| `03-git-linux-workflow.md` | `03-engineering-workflow-practice/` | Level 2 |
| `04-docker.md` | `04-docker-practice/` | Level 3 |
| `05-cloud-warehouse-lake.md` | `05-cloud-warehouse-practice/` | Level 3 |

### Modern data stack

| Module | Lab | Target level |
|---|---|---|
| `06-orchestration.md` | `06-orchestration-practice/` | Level 3 |
| `07-dbt.md` | `07-dbt-practice/` | Level 4 |
| `08-data-modeling.md` | `08-data-modeling-practice/` | Level 3 |
| `11-data-quality-observability.md` | `11-data-quality-practice/` | Level 3 |
| `12-cicd-testing-production.md` | `12-cicd-practice/` | Level 3 |

### Scale and streaming

| Module | Lab | Target level |
|---|---|---|
| `09-spark.md` | `09-spark-practice/` | Level 3 |
| `10-kafka-streaming.md` | `10-kafka-practice/` | Level 3 |
| `14-storage-file-format.md` | `14-storage-format-practice/` | Level 2 |
| `15-lakehouse-modern-stack.md` | `15-lakehouse-practice/` | Level 2 |
| `20-cdc-and-real-time-ingestion.md` | `20-cdc-practice/` | Level 3 |

### Production platform

| Module | Lab | Target level |
|---|---|---|
| `16-distributed-systems-for-de.md` | `16-distributed-systems-practice/` | Level 2 |
| `17-performance-cost-optimization.md` | `17-performance-cost-practice/` | Level 3 |
| `18-governance-security.md` | `18-governance-security-practice/` | Level 2 |
| `19-production-operations.md` | `19-production-ops-practice/` | Level 3 |
| `21-data-pipeline-patterns.md` | `21-pipeline-patterns-practice/` | Level 2 |
| `23-infrastructure-as-code.md` | `23-iac-practice/` | Level 3 |

### Portfolio and interview

| Module | Lab | Target level |
|---|---|---|
| `13-portfolio-interview.md` | `13-portfolio-practice/` | Level 4 |
| `22-data-engineering-system-design.md` | `22-system-design-practice/` | Level 3 |

## Build order

Khong build theo so file. Build theo thu tu portfolio value:

1. `01-sql-practice/` - da co.
2. `02-python-practice/`.
3. `04-docker-practice/`.
4. `07-dbt-practice/`.
5. `06-orchestration-practice/`.
6. `05-cloud-warehouse-practice/`.
7. `11-data-quality-practice/`.
8. `09-spark-practice/`.
9. `10-kafka-practice/`.
10. `20-cdc-practice/`.
11. `19-production-ops-practice/`.
12. `23-iac-practice/`.
13. `13-portfolio-practice/`.

## Standard lab structure

Moi lab nen co toi thieu:

```text
<lab-name>/
  README.md
  exercises/
  solutions/
  broken/
  notes/
```

Runnable labs nen co them:

```text
docker-compose.yml
data/
src/
sql/
tests/
runbook/
```

## Standard README sections

Moi lab README nen co:

- Goal.
- Architecture.
- Prerequisites.
- Setup.
- How to run.
- Exercises.
- Failure scenarios.
- Debugging workflow.
- Expected outputs.
- Interview questions.
- GitHub deliverables.

## Rule for future work

Khi bat dau hoc mot module, mentor nen lam theo format:

1. Mo file ly thuyet tuong ung.
2. Mo lab tuong ung.
3. Neu lab moi chi la scaffold, nang cap no len runnable lab.
4. Chay bai tap.
5. Review output.
6. Viet note/debug/runbook.
7. Cap nhat portfolio neu co gia tri.

