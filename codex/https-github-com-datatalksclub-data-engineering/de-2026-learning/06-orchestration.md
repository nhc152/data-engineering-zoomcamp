# Orchestration: Airflow, Kestra va DAG Thinking

## Vai tro

Orchestration la lop dieu phoi pipeline: chay khi nao, chay theo thu tu nao, task nao phu thuoc task nao, fail thi retry hay dung, backfill the nao, ai nhan alert, va lam sao biet data da san sang.

Voi background ODI/Talend, ban co the da quen scheduler va job dependency. Trong modern data stack, orchestration thuong duoc mo ta bang code/YAML, luu trong Git, review qua pull request, va quan sat bang UI/logs.

Orchestrator khong phai data processing engine. Airflow/Kestra khong nen la noi chua business SQL dai hoac transform phuc tap. No nen goi cac cong cu dung viec:

```text
extract task
    -> load raw task
    -> data quality raw task
    -> dbt build task
    -> data quality marts task
    -> publish/notify task
```

## Muc tieu can dat

Sau module nay, ban nen lam duoc:

- Thiet ke DAG co task boundary ro.
- Phan biet schedule time, logical date, data interval.
- Truyen parameter ngay chay vao pipeline.
- Thiet ke retry an toan.
- Backfill nhieu ngay ma khong tao duplicate.
- Debug DAG fail bang logs, task state, dependency, input/output.
- Hieu SLA, freshness va alert.
- Giai thich idempotency.
- Biet khi nao dung Airflow, Kestra, cron, event-driven trigger.
- Nhan dien retry storm, backfill disaster, dependency failure.

## Khai niem can nam

- DAG.
- Task.
- Dependency.
- Operator/plugin.
- Flow.
- Schedule.
- Logical date/execution date.
- Data interval.
- Catchup.
- Backfill.
- Retry.
- Retry delay.
- Timeout.
- SLA.
- Sensor.
- Trigger.
- Idempotency.
- Parameterization.
- Dynamic DAG/pipeline.
- Task state.
- Queue/worker.
- Concurrency.
- Pool.
- XCom/output passing.
- Alerting.
- Runbook.

## Airflow va Kestra

### Airflow

Airflow pho bien trong enterprise va tuyen dung.

Dac diem:

- DAG viet bang Python.
- Ecosystem operator lon.
- Scheduler, webserver, workers.
- Manh cho batch workflows.
- Can van hanh can than neu self-host.

Phu hop khi:

- Team quen Python.
- Can custom logic.
- Co nhieu integration.
- Can pattern mature trong cong ty lon.

Rui ro:

- DAG Python de bi viet thanh application phuc tap.
- Scheduler/metadata DB/worker can monitoring.
- Dynamic DAG sai cach co the lam scheduler cham.

### Kestra

Kestra dung YAML declarative flows, kha de hoc voi Zoomcamp.

Dac diem:

- Workflow khai bao bang YAML.
- UI truc quan.
- Tot cho hoc orchestration va production-style flows.
- Co plugins cho nhieu task.

Phu hop khi:

- Muon flow de doc.
- Muon it Python boilerplate.
- Muon hoc DAG/dependency/retry nhanh.

Rui ro:

- Thi truong viec lam co the yeu cau Airflow nhieu hon.
- Custom logic phuc tap co the can task/script rieng.

## Architecture mindset

### Orchestrator la control plane

Orchestrator nen dieu phoi, khong nen xu ly du lieu lon trong memory cua no.

Dung orchestrator de:

- Goi Python ingestion.
- Chay SQL/dbt.
- Trigger Spark job.
- Kiem tra quality.
- Quan ly dependency.
- Alert.

Khong nen:

- Loop qua hang trieu rows trong DAG code.
- Chua business transform SQL dai trong task definition.
- Dung XCom/output de truyen dataset lon.

### Task boundary

Task tot co:

- Input ro.
- Output ro.
- Log ro.
- Retry an toan.
- Thoi gian chay hop ly.
- Ten task noi len muc dich.

Bad task:

```text
do_everything
```

Good tasks:

```text
extract_orders_api
load_orders_raw
validate_orders_raw
run_dbt_orders_models
validate_orders_marts
publish_orders_ready
```

### Data interval thinking

Pipeline daily khong nen dung `current_date` tuy tien. Nen dung logical date/data interval do orchestrator truyen vao.

Vi du:

- DAG run ngay 2026-05-10 xu ly data interval 2026-05-09.
- Backfill ngay 2026-05-01 phai xu ly dung ngay do, khong phai ngay hien tai.

Production rule:

- Moi task nen nhan `run_date`/`data_interval_start`/`data_interval_end`.
- Khong hard-code ngay.
- Khong dung current timestamp cho business date tru khi that su can.

## Production mindset

### Idempotency

Task idempotent la task chay lai nhieu lan van cho ket qua dung, khong tao duplicate/side effect sai.

Vi du:

- Load raw vao path co run_id: an toan hon overwrite tuy tien.
- Merge/upsert theo business key: an toan hon append mu.
- Delete partition roi insert lai partition do: co the an toan neu partition boundary dung.

Checklist:

- Neu task retry sau khi fail giua chung, co duplicate khong?
- Neu backfill cung ngay 2 lan, output co doi khong?
- Neu source gui duplicate, load co dedup/merge khong?

### Retry

Retry chi phu hop voi loi tam thoi:

- Network timeout.
- API 503.
- Warehouse transient error.
- Lock/contention tam thoi.

Retry khong sua:

- SQL sai.
- Schema thay doi.
- Credential thieu quyen.
- Data quality rule fail.

Production rule:

- Retry co gioi han.
- Retry delay hop ly.
- Exponential backoff neu call API.
- Task ghi data phai idempotent truoc khi retry.

### SLA va freshness

SLA khong chi la DAG success. SLA nen gan voi data san sang:

- Raw data latest timestamp.
- Mart refreshed by 8 AM.
- Row count trong range.
- Dashboard data ngay hom qua day du.

Vi du:

```text
orders_mart must be refreshed by 07:00 Asia/Saigon daily
and contain all orders up to previous business day.
```

### Alerting

Alert tot can co:

- Pipeline/task name.
- Data interval.
- Error message.
- Link logs/UI.
- Impact.
- Runbook.
- Owner.

Alert xau:

- "Task failed" khong co context.
- Alert qua nhieu, khong ai doc.
- Alert cho warning khong action duoc.

## Scheduling

### Time-based schedule

Phu hop:

- Daily/hourly batch.
- Source co SLA ro.
- Dashboard refresh theo gio.

Can can than:

- Timezone.
- DST.
- Late data.
- Source chua san sang khi pipeline chay.

### Dependency-based schedule

Pipeline B chay khi pipeline A done/data ready.

Phu hop:

- Nhieu upstream.
- Data availability khong dung gio co dinh.

Can can than:

- Sensor chay qua lau.
- Circular dependency.
- Dependency khong co timeout.

### Event-driven pipelines

Trigger khi file den, message den, event den.

Phu hop:

- Low-latency.
- File landing unpredictable.
- Micro-batch.

Trade-off:

- Debug kho hon schedule co dinh.
- Can dedup event.
- Can handle out-of-order arrival.
- Can throttle neu event burst.

## Backfill

Backfill la chay lai pipeline cho ngay/period trong qua khu.

Dung khi:

- Fix bug logic.
- Source gui late data.
- Tao table moi can history.
- Data quality incident can reprocess.

Backfill an toan can:

- Parameter date.
- Idempotent writes.
- Concurrency control.
- Cost estimate.
- Monitoring.

Backfill disaster thuong gap:

- Backfill 2 nam data lam qua tai warehouse.
- Backfill append duplicate.
- Backfill ghi de partition sai.
- Backfill trigger downstream/dashboard khi data chua xong.
- Backfill voi current_date lam tat ca ngay ra cung ket qua.

Production pattern:

- Backfill theo batch nho.
- Dry run/sample truoc.
- Disable downstream publish neu can.
- Log row count moi partition.
- Compare before/after.

## Dynamic pipelines

Dynamic DAG/flow tao task theo danh sach table/source.

Phu hop:

- 100 tables can load cung pattern.
- Multi-tenant pipelines.
- Config-driven ingestion.

Rui ro:

- Scheduler cham neu dynamic generation nang.
- Task names khong on dinh.
- Config sai tao qua nhieu task.
- Debug kho neu abstraction qua day.

Production rule:

- Config co schema validation.
- Task ID deterministic.
- Limit concurrency.
- Co owner cho moi source/table.

## Debugging mindset

### Debug failed DAG

Checklist:

1. Task nao fail dau tien?
2. Fail do dependency, code, infra, credential hay data?
3. Data interval nao fail?
4. Retry da chay may lan?
5. Log co row count/input/output khong?
6. Upstream data co san sang khong?
7. Task co side effect gi truoc khi fail?
8. Chay lai co an toan khong?

### Debug task stuck

Nguyen nhan:

- Sensor doi vo han.
- Worker het capacity.
- Pool/concurrency limit.
- External system slow.
- Deadlock/lock.

Can xem:

- Task state.
- Queue time.
- Worker logs.
- Pool slots.
- External dependency status.

### Debug data missing sau DAG success

DAG success khong dam bao data dung.

Checklist:

- Task co check row count khong?
- Source file co dung date/prefix khong?
- SQL co filter sai logical date khong?
- Downstream dbt tests co chay khong?
- Mart co freshness check khong?

## Real-world failures

### Failure 1: Retry storm

Mo ta:

- API upstream down.
- 100 tasks cung retry lien tuc.
- He thong upstream bi tang tai them.

Fix:

- Exponential backoff.
- Retry limit.
- Pool/concurrency cap.
- Circuit breaker/manual pause.
- Alert sau so lan fail hop ly.

### Failure 2: Backfill duplicate revenue

Mo ta:

- Backfill append vao fact table.
- Khong delete partition/merge key.
- Dashboard revenue gap doi.

Fix:

- Viet idempotent load.
- Dung merge/upsert hoac delete+insert partition.
- Quality check duplicate key.
- Reconciliation truoc publish.

### Failure 3: Dependency failure

Mo ta:

- Customer mart chay truoc khi orders fact xong.
- Dashboard co data nua cu nua moi.

Fix:

- Explicit dependency.
- Data readiness marker.
- Freshness check.
- Transactional publish pattern neu co.

### Failure 4: Logical date bug

Mo ta:

- DAG backfill ngay cu nhung SQL dung `current_date`.
- Moi partition co cung data ngay hien tai.

Fix:

- Bat buoc parameter data interval.
- Review SQL templates.
- Test backfill tren 1 ngay.

### Failure 5: Sensor cost/problem

Mo ta:

- Sensor polling qua nhieu, chiem worker slot.

Fix:

- Deferrable sensor/event trigger neu tool ho tro.
- Timeout.
- Poll interval hop ly.
- External readiness table.

## Trade-offs

### Airflow vs Kestra

Airflow:

- Manh, pho bien, linh hoat.
- Python-based.
- Van hanh phuc tap hon.

Kestra:

- Declarative, de hoc, UI tot.
- Flow YAML de doc.
- It pho bien hon Airflow trong mot so job market.

Rule:

- Hoc Kestra neu theo Zoomcamp.
- Hoc Airflow concept va viet duoc DAG nho de phong van.

### Cron vs orchestrator

Cron:

- Don gian.
- Tot cho job don le.
- It dependency/observability.

Orchestrator:

- Dependency, retry, UI, logs, backfill.
- Overhead cao hon.

Rule:

- Mot script nho: cron co the du.
- Data platform nhieu dependency: orchestrator.

### One big task vs many small tasks

Big task:

- It overhead.
- Kho debug.
- Retry lai toan bo.

Small tasks:

- Debug tot.
- Dependency ro.
- Qua nhieu task co overhead.

Rule:

- Tach theo boundary co y nghia: extract, load, validate, transform, publish.

## Cost considerations

Orchestration cost khong chi la tool cost. No con la compute bi trigger.

Can quan tam:

- Backfill scan bao nhieu data.
- Retry co lap lai query dat tien khong.
- Sensor co chiem worker/slot khong.
- Dynamic pipeline co tao qua nhieu jobs khong.
- Dashboard/downstream co refresh moi lan backfill khong.

Production habits:

- Estimate backfill cost.
- Cap concurrency.
- Dung pools cho external systems.
- Khong retry query dat tien neu loi logic.
- Pause downstream publish khi reprocess lon.

## Exercises

### Level 1: Simple DAG

Tao pipeline 5 task:

1. Extract orders.
2. Load raw orders.
3. Validate raw row count.
4. Run transform/dbt.
5. Validate mart row count.

Yeu cau:

- Task names ro.
- Co retry cho extract/load.
- Co no-retry cho data quality failure.
- Co parameter `run_date`.

### Level 2: Idempotency

1. Viet task load append.
2. Chay lai 2 lan va quan sat duplicate.
3. Doi sang merge/upsert hoac delete+insert partition.
4. Giai thich task nao idempotent.

### Level 3: Backfill

1. Backfill 3 ngay.
2. Log row count moi ngay.
3. Gia lap fail ngay thu 2.
4. Chay lai ngay fail.
5. Kiem tra duplicate.

### Level 4: Failure handling

1. Lam extract task fail do API 503 gia lap.
2. Them retry/backoff.
3. Lam transform fail do schema change.
4. Chung minh retry khong giup schema bug.

### Level 5: Production design

1. Ve DAG cho ecommerce pipeline.
2. Dinh nghia SLA/freshness.
3. Dinh nghia alert message.
4. Viet runbook khi DAG fail.

## Mini project

### De bai

Build orchestration cho ecommerce ELT pipeline.

Architecture:

```text
schedule daily 06:00
    -> extract API/file for data interval
    -> upload raw to lake
    -> load raw warehouse tables
    -> run dbt staging/marts
    -> run data quality checks
    -> publish success marker
    -> notify
```

### Yeu cau

- Dung Kestra hoac Airflow.
- Co `run_date` parameter.
- Co retry cho transient tasks.
- Co no-retry/fail-fast cho quality checks.
- Co backfill huong dan 3 ngay.
- Co row count logs.
- Co runbook.

### Dau ra

- DAG/flow file.
- README architecture.
- Screenshot UI/log neu co.
- Failure handling notes.
- Backfill instructions.

## Interview questions

### Concept

- DAG la gi?
- Orchestrator co phai data processing engine khong?
- Logical date khac current date nhu the nao?
- Idempotency la gi?
- Backfill la gi?

### Production

- Khi nao retry task?
- Khi nao khong retry?
- Lam sao tranh duplicate khi task retry?
- Lam sao debug DAG success nhung data missing?
- Lam sao thiet ke alert co ich?
- Retry storm la gi?

### Airflow/Kestra

- Airflow va Kestra khac nhau the nao?
- Sensor dung de lam gi?
- XCom/output passing co nen truyen data lon khong?
- Dynamic DAG co rui ro gi?

## GitHub outputs

Toi thieu:

- `orchestration/flow.yml` hoac `orchestration/dag.py`.
- README co architecture va schedule.
- `RUNBOOK.md`.
- Sample logs/row count output.

Tot hon:

- Backfill instructions.
- Failure simulation.
- Alert message examples.
- Notes ve idempotency va retry policy.

## Production appendix: failed DAG triage playbook

### Airflow mini DAG shape

```python
with DAG("orders_daily", schedule="@daily", catchup=True) as dag:
    extract = BashOperator(task_id="extract_orders", bash_command="python -m app extract --date {{ ds }}")
    load = BashOperator(task_id="load_orders_raw", bash_command="python -m app load --date {{ ds }}")
    dbt = BashOperator(task_id="dbt_build", bash_command="dbt build --select tag:orders")
    quality = BashOperator(task_id="quality_checks", bash_command="python -m app quality --date {{ ds }}", retries=0)

    extract >> load >> dbt >> quality
```

### Kestra mini flow shape

```yaml
id: orders_daily
namespace: de.practice
tasks:
  - id: extract_orders
    type: io.kestra.plugin.scripts.shell.Commands
    commands:
      - python -m app extract --date "{{ trigger.date }}"
  - id: dbt_build
    type: io.kestra.plugin.scripts.shell.Commands
    commands:
      - dbt build --select tag:orders
```

### Scheduler lag/run queue saturation

Symptoms:

- DAG scheduled but not starting.
- Tasks queued long time.
- SLA missed though code is fine.

Diagnostics:

1. Scheduler heartbeat/metadata DB health.
2. Worker capacity.
3. Pools/concurrency limits.
4. Queued task count.
5. Recent dynamic DAG parsing changes.

Fix:

- Increase worker capacity only if compute is bottleneck.
- Add pools for external systems.
- Reduce dynamic DAG parse overhead.
- Separate heavy backfills from daily runs.

### Metadata DB failure

Airflow metadata DB is critical infrastructure.

Failure impact:

- Scheduler cannot persist state.
- UI stale/unavailable.
- Task state inconsistent.

Operational rule:

- Backup metadata DB.
- Monitor DB connections/locks/storage.
- Avoid huge XCom payloads.
