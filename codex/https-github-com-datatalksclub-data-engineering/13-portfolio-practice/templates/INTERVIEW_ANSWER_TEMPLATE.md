# Interview Answer Template

Use this to explain a project concisely.

## 60-Second Version

```text
I built a <batch/streaming/Spark> data pipeline for <business problem>. Data comes from <source>, lands in <raw storage>, and is transformed into <warehouse/lake marts>. The core model is <fact/dimension/mart> with grain <grain>. I added checks for <quality checks> and designed the pipeline to handle <failure modes>. The main trade-off was <trade-off>. If I scaled it further, I would <next improvement>.
```

## 5-Minute Version

### 1. Problem

What business/data problem did this solve?

### 2. Architecture

Walk through:

```text
source -> ingestion -> raw -> warehouse -> models -> quality -> serving
```

### 3. Data Model

Mention:

- fact table grain
- dimensions
- marts
- metric definitions

### 4. Reliability

Mention:

- idempotency
- retries
- backfill
- late-arriving data
- quality checks

### 5. Cost and Scale

Mention:

- partitioning
- clustering/indexing
- file format
- query cost
- expected bottleneck

### 6. Trade-offs

Mention 2-3:

- batch vs streaming
- full refresh vs incremental
- warehouse transform vs Python transform
- managed service vs self-hosted

### 7. Improvement

Pick realistic next step:

- Terraform
- CI/CD
- dashboard
- CDC
- observability

## Debugging Answer Format

When asked "pipeline succeeded but metric is wrong":

```text
I would first identify the expected grain and metric definition. Then I would compare row counts and distinct keys across raw, staging, fact, and mart layers. I would check duplicate keys, join cardinality, status filters, refunds/cancellations, timezone, and late-arriving data. After fixing the root cause, I would add a quality check or reconciliation test to prevent recurrence.
```

## Bad Interview Signs

- Only listing tools.
- Cannot explain grain.
- Cannot explain why a tool was chosen.
- Cannot describe a failure mode.
- Cannot rerun the project.
- Cannot explain data quality checks.

