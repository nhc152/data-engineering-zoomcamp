# Production Operations cho Data Engineering

## Vai tro

Production Data Engineering la noi pipeline gap thuc te: source delay, schema drift, duplicate, warehouse het quota, backfill loi, dashboard sai luc 8 gio sang, va khong ai nho metric duoc tinh o dau.

Mot Data Engineer senior khong chi build pipeline. Ho phai thiet ke system co the van hanh:

- observable
- debuggable
- recoverable
- idempotent
- cost-controlled
- documented
- co owner va SLA

## Muc tieu can dat

- Hieu production readiness cho data pipeline.
- Biet monitoring job va monitoring data khac nhau.
- Biet incident response va runbook.
- Biet thiet ke retry, alert, SLA, backfill.
- Biet release/deploy pipeline an toan.
- Biet debug failed pipeline theo layer.
- Biet operational anti-patterns.

## Khai niem can nam

- SLA/SLO/SLI.
- On-call.
- Runbook.
- Incident.
- Postmortem.
- Retry policy.
- Idempotency.
- Backfill.
- Replay.
- Dead-letter queue.
- Freshness.
- Data volume anomaly.
- Lineage.
- Rollback.
- Change management.

## Architecture mindset

Production pipeline can 3 control planes:

```text
Data plane: source -> processing -> storage -> serving
Control plane: orchestration -> metadata -> deployment -> access
Observability plane: logs -> metrics -> lineage -> alerts -> runbooks
```

Neu chi build data plane, system se chay trong demo nhung kho song trong production.

## Production readiness checklist

Moi pipeline production can co:

- owner
- SLA
- schedule/trigger
- retry policy
- idempotent writes
- input contract
- output contract
- data quality checks
- logs
- metrics
- alert routing
- runbook
- backfill procedure
- cost expectation
- rollback/recovery plan

## Monitoring job vs monitoring data

Job monitoring:

- task success/failure
- duration
- retries
- queue time
- resource usage

Data monitoring:

- freshness
- row count
- duplicate keys
- null rate
- accepted values
- referential integrity
- metric reconciliation
- distribution drift

Pipeline success ma data sai van la incident.

## SLA/SLO design

Example:

- `mart_daily_revenue` available by 07:00 Asia/Saigon every day.
- Freshness must be less than 24 hours.
- Duplicate `order_id` must be zero.
- Revenue reconciliation difference must be less than 0.1%.

SLI:

- latest partition timestamp
- successful run time
- row count
- quality check status
- reconciliation difference

SLO:

- 99% daily runs finish before 07:00.
- Less than 1 severe data quality incident per quarter.

## Failure handling

### Transient failure

Examples:

- network timeout
- temporary warehouse error
- API 503

Response:

- retry with backoff
- alert only after repeated failure
- keep task idempotent

### Deterministic failure

Examples:

- SQL syntax error
- schema missing column
- invalid credentials

Response:

- fail fast
- alert owner
- no blind retries

### Data quality failure

Examples:

- row count drops 90%
- duplicate primary keys
- stale source
- reconciliation mismatch

Response:

- block publish if severe
- quarantine bad records if possible
- alert with sample rows
- document business impact

## Retry design

Retry chi an toan neu task idempotent.

Bad retry:

- append same rows again
- call external API that creates side effect
- send duplicate notifications

Good retry:

- overwrite partition
- merge by primary key
- write to temp then swap
- use idempotency key

Retry policy:

- max attempts
- exponential backoff
- timeout
- alert threshold
- DLQ/quarantine for bad records

## Backfill operations

Backfill can duoc thiet ke nhu first-class workflow, khong phai "chay lai tay".

Backfill plan:

1. Define date range.
2. Identify affected tables.
3. Estimate cost and runtime.
4. Run in isolated compute.
5. Write to temp/partition.
6. Validate.
7. Publish.
8. Monitor downstream.
9. Record metadata.

Backfill disasters:

- overwrite current partitions
- use current dimensions for historical facts incorrectly
- trigger alerts for every historical day
- saturate warehouse
- skip late-arriving data

## Deployment and release

Production changes need:

- code review
- CI tests
- dbt build on changed models
- staging run if possible
- backward-compatible schema changes
- rollback plan
- communication for breaking changes

Safe deployment pattern:

- build new table/model
- compare old vs new
- dual-run if critical
- switch consumers
- keep old table during rollback window

## Debugging mindset

When pipeline fails:

1. Is it code, infra, source, data, credential, or capacity?
2. Which task failed first?
3. What changed recently?
4. Is data partially written?
5. Can rerun safely?
6. Who consumes this output?
7. Is SLA breached?

When dashboard is wrong:

1. Is source fresh?
2. Did raw row count change?
3. Did staging dedup change?
4. Did fact grain change?
5. Did metric definition change?
6. Did BI filter change?
7. Did late data arrive?

## Real-world failures

- Airflow retries append task 3 lan, revenue triple.
- dbt test fail nhung dashboard van refresh bang old partial data.
- Source schema them NOT NULL column khien CDC connector dung.
- Backfill chay ban ngay lam BI warehouse queue 2 gio.
- Alert gui vao channel khong ai ownership.
- Data freshness check dung ingestion time thay vi event time nen false healthy.

## Trade-offs

- Alert nhay qua nhieu gay fatigue; alert it qua thi miss incident.
- Block publish dam bao quality nhung co the lam stale dashboard.
- Quarantine cho phep pipeline tiep tuc nhung can theo doi bad record.
- Full rollback de hon nhung ton storage.
- Blue/green data tables an toan hon nhung complexity cao hon.

## Cost considerations

Operations cost den tu:

- retries
- backfills
- duplicate jobs
- long-running queries
- over-alerting
- manual debugging
- lack of runbooks

Control:

- backfill approval
- warehouse isolation
- job timeout
- cost alert
- run metadata
- SLA-based prioritization

## Exercises

1. Viet runbook cho failed daily revenue pipeline.
2. Thiet ke retry policy cho API ingestion.
3. Thiet ke data quality gate truoc khi publish mart.
4. Gia lap duplicate append do retry va fix bang merge.
5. Thiet ke backfill plan 2 nam khong pha production.
6. Viet postmortem cho metric sai 3 ngay.

## Mini project

Productionize ecommerce pipeline:

- add run metadata table
- add freshness check
- add duplicate check
- add reconciliation check
- define SLA
- write runbook
- define alert routing
- define backfill procedure

## Interview questions

- Pipeline success nhung data sai, ban debug sao?
- Idempotency la gi?
- Retry storm la gi?
- Backfill an toan can nhung buoc nao?
- SLA va freshness khac nhau ra sao?
- Khi nao block publish?
- Runbook nen gom gi?
- Lam sao deploy data model change an toan?

## GitHub outputs

- `ops/runbook_daily_revenue.md`
- `ops/incident_postmortem_template.md`
- `ops/backfill_plan.md`
- `ops/sla.md`
- `ops/quality_gate.sql`

## Production operations handbook upgrade

### Severity levels

Production operations can khung severity ro, khong phai loi nao cung xu ly nhu nhau.

```text
SEV1: data platform outage, nhieu business-critical dashboards/data products sai hoac khong co du lieu.
SEV2: mot domain quan trong bi stale/sai, co business impact ro nhung co workaround.
SEV3: loi pipeline rieng le, impact han che, co the xu ly trong gio lam viec.
SEV4: warning, tech debt, data quality issue chua co impact truc tiep.
```

Operational lesson:

- Severity quyet dinh toc do response, ai bi page, co can incident commander khong.
- Khong nen page on-call luc nua dem cho SEV4.
- Khong nen de SEV1 chi nam trong Slack message khong owner.

### On-call workflow

Mot incident data nen co vai tro:

- Incident commander: dieu phoi, giu timeline, quyet dinh escalation.
- Investigator: debug pipeline/data.
- Communicator: update stakeholders.
- Domain owner: xac nhan business impact.

Timeline toi thieu:

```text
T+0: alert fired
T+5: acknowledge
T+15: identify scope
T+30: workaround or mitigation plan
T+60: stakeholder update
T+24h: postmortem draft for SEV1/SEV2
```

### Error budget cho data

Data SLO khong chi la uptime. Vi du:

```text
orders_mart freshness SLO: 99% of daily runs available by 07:00 Asia/Saigon.
correctness SLO: less than 0.1% row-count variance unless source incident is declared.
```

Error budget giup quyet dinh:

- Co duoc deploy change lon trong tuan nay khong?
- Co can dung feature work de fix reliability khong?
- Co can dau tu vao observability/backfill automation khong?

### Runbook: stale mart

Symptom:

- Dashboard hien data cu.
- Pipeline co the success hoac fail.

Triage:

1. Check mart `max(updated_at)` va `max(order_date)`.
2. Check orchestrator run cho data interval lien quan.
3. Check upstream raw freshness.
4. Check dbt model run result.
5. Check data quality gate co block publish khong.
6. Check warehouse permissions/quota/cost limits.

Mitigation:

- Neu upstream missing: mark data stale, notify business, wait/retry source.
- Neu transform fail: fix model hoac rollback last change.
- Neu publish fail: republish last known good hoac rerun publish step.

Prevention:

- Freshness check by partition.
- Publish marker table.
- Dashboard reads only certified/published marts.

### Runbook: cost spike

Symptom:

- Warehouse bill tang bat thuong.
- Query slots/bytes scanned tang dot bien.

Triage:

1. Lay top queries by cost trong 24h.
2. Identify user/service account/job label.
3. Check query co missing partition filter khong.
4. Check dashboard refresh frequency.
5. Check backfill/retry storm.
6. Check dbt full refresh accidentally run on large models.

Mitigation:

- Pause offending schedule.
- Add partition filter.
- Replace repeated heavy query with aggregate mart.
- Cap concurrency/backfill batch size.

Prevention:

- Job labels.
- Cost alerts by project/dataset/service account.
- Query review for heavy marts.
- Separate prod/dev billing budgets.

### Runbook: lag spike

Symptom:

- Kafka/CDC/streaming consumer lag tang.
- Warehouse data realtime bi tre.

Triage:

1. Lag tang tren tat ca partitions hay mot vai partitions?
2. Consumer co rebalance lien tuc khong?
3. Sink write co cham/fail khong?
4. Message size/rate co tang khong?
5. Poison pill co lam consumer crash khong?
6. Backpressure co lan nguoc ve upstream khong?

Mitigation:

- Pause bad partition/topic neu co poison pill.
- Scale consumers neu bottleneck la compute va partitions du.
- Fix sink throughput/batch size neu bottleneck la warehouse.
- Route bad records vao DLQ co metadata day du.

Prevention:

- Lag alert theo partition.
- DLQ policy.
- Consumer idempotency.
- Capacity test truoc traffic spike.

### Release calendar va maintenance window

Data changes co the gay business incident neu deploy sai luc.

Rules:

- Khong deploy breaking model change truoc board meeting/financial close.
- Large backfill can maintenance window.
- Schema migration phai co rollback/backout plan.
- Stakeholders can biet neu metric definition thay doi.

### Postmortem template

```text
Incident:
Severity:
Start time:
Detection time:
Resolution time:
Customer/business impact:
What happened:
Root cause:
Contributing factors:
What worked:
What did not work:
Immediate fix:
Preventive actions:
Owners:
Due dates:
```

Good postmortem khong do loi ca nhan. No tim system weakness: missing test, missing alert, unsafe deploy, no ownership, bad runbook.
