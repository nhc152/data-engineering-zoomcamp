# Data Quality, Observability va Reliability

## Vai tro

Pipeline chay thanh cong khong co nghia data dung. Trong production, data co the sai theo nhieu cach im lang:

- Job success nhung input thieu 40%.
- Schema them cot moi lam transform drop du lieu.
- Join duplicate lam revenue tang.
- Late-arriving data khong vao incremental model.
- Dashboard dung bang stale nhung khong ai biet.
- Metric dinh nghia khac nhau giua finance va product.

Data quality va observability la he thong giup phat hien, khoanh vung, giai thich va ngan chan cac loi nay.

## Muc tieu can dat

Sau module nay, ban nen:

- Thiet ke data checks cho pipeline quan trong.
- Hieu freshness, completeness, volume, validity, uniqueness, referential integrity.
- Phan biet pipeline monitoring va data observability.
- Dinh nghia SLA/SLO cho data product.
- Hieu data contract va schema drift.
- Debug dashboard sai bang evidence, khong doan.
- Viet incident report co impact, root cause, fix, prevention.
- Biet cach alert ma khong tao noise.

## Khai niem can nam

- Freshness: data moi den muc nao.
- Completeness: data co du khong.
- Volume: row count/bytes/event count co bat thuong khong.
- Validity: gia tri co nam trong rule hop le khong.
- Uniqueness: key co duplicate khong.
- Referential integrity: foreign key co match dimension/source khong.
- Consistency: metric co khop giua layers/systems khong.
- Accuracy: data co dung voi thuc te/business khong.
- Schema drift: schema thay doi ngoai du kien.
- Data contract: thoa thuan giua producer va consumer ve schema, semantics, SLA.
- SLA: cam ket dich vu, vi du data san sang truoc 8h.
- SLO: muc tieu do luong, vi du 99% daily loads thanh cong truoc 8h.
- SLI: chi so do, vi du freshness age, row count variance.

## Architecture mindset

Data reliability khong phai mot tool. No la cac control points trong architecture:

```text
source
  |  schema/freshness checks
  v
raw layer
  |  completeness/volume checks
  v
staging layer
  |  type/null/accepted values checks
  v
fact/dim layer
  |  uniqueness/referential checks
  v
mart layer
  |  metric reconciliation/business rule checks
  v
dashboard / ML / downstream consumers
```

Nguyen tac:

- Check cang gan source cang bat loi som.
- Check o mart phai gan voi business impact.
- Khong chi check job status.
- Moi bang quan trong can owner, SLA, quality contract.

## Dimensions of data quality

### Freshness

Cau hoi:

- Data moi nhat la luc nao?
- Co tre hon SLA khong?

SQL:

```sql
select
    max(ingestion_timestamp) as latest_ingestion_timestamp,
    now() - max(ingestion_timestamp) as data_age
from raw.orders;
```

Failure:

- Pipeline success nhung source khong gui file moi.
- Dashboard hien data hom qua ma khong co warning.

### Completeness va volume

Cau hoi:

- Hom nay co du rows khong?
- Volume co lech qua nhieu so voi baseline khong?

SQL:

```sql
select
    order_date,
    count(*) as order_count
from fct_orders
group by order_date
order by order_date desc;
```

Production check nen so sanh voi:

- 7-day average.
- Same day last week.
- Expected file count.
- Source control totals.

### Uniqueness

```sql
select
    order_id,
    count(*) as row_count
from fct_orders
group by order_id
having count(*) > 1;
```

Duplicate key la tin hieu:

- Incremental append bi chay lai.
- Dedup rule sai.
- Source gui duplicate.
- Join lam doi grain.

### Referential integrity

```sql
select
    orders.order_id,
    orders.customer_id
from fct_orders orders
left join dim_customers customers
    on orders.customer_id = customers.customer_id
where customers.customer_id is null;
```

Khong phai luc nao missing FK cung la bug. Co business cho guest checkout, delayed dimension, hoac source chua sync. Quan trong la phai co policy.

### Validity

```sql
select distinct order_status
from fct_orders
where order_status not in ('paid', 'completed', 'cancelled', 'refunded');
```

Accepted values check giup bat:

- Source them status moi.
- Casing thay doi.
- Mapping logic bi loi.

### Consistency va reconciliation

So sanh source-target:

```sql
select
    'raw' as layer,
    count(*) as row_count,
    sum(amount) as total_amount
from raw_payments
where payment_date = date '2026-05-01'

union all

select
    'mart' as layer,
    count(*) as row_count,
    sum(net_payment_amount) as total_amount
from fct_orders
where order_date = date '2026-05-01';
```

Reconciliation la check rat manh cho finance/revenue pipeline.

## Observability mindset

Monitoring tra loi: job co chay khong.

Observability tra loi:

- Data co dung khong?
- Sai tu dau?
- Anh huong bang/dashboard nao?
- Loi bat dau tu luc nao?
- Owner la ai?
- Co the rollback/reprocess khong?

Signals can co:

- Pipeline status.
- Runtime.
- Row count.
- Bytes processed.
- Freshness.
- Schema changes.
- Duplicate count.
- Null rate.
- Distribution drift.
- Metric anomaly.
- Downstream lineage impact.

## Data contracts

Data contract la thoa thuan giua producer va consumer:

- Schema: cot, type, nullable.
- Semantics: `order_status = completed` nghia la gi.
- Freshness/SLA.
- Backward compatibility.
- Owner/contact.
- Change process.

Khong co contract, producer co the doi enum, rename field, thay timezone, va consumer chi phat hien khi dashboard sai.

Contract khong can tool phuc tap luc dau. Co the bat dau bang:

- `schema.yml` trong dbt.
- README source contract.
- CI check schema.
- Alert khi schema drift.

## Alerting

Alert tot:

- Gan voi user impact.
- Co owner.
- Co runbook.
- Co severity.
- Co threshold hop ly.
- It false positives.

Alert xau:

- Moi warning deu page.
- Khong noi bang nao loi.
- Khong co cach fix.
- Alert theo job fail nhung khong alert stale data.

Severity example:

- P0: revenue dashboard sai cho executive/finance.
- P1: critical mart stale qua SLA.
- P2: non-critical dimension co null increase.
- P3: warning ve schema optional field.

## Incident management

Incident note nen co:

- Summary.
- Impact.
- Detection time.
- Start time.
- End time.
- Affected tables/dashboards.
- Root cause.
- Fix.
- Backfill/reprocess.
- Prevention.

Template:

```text
Issue: mart_daily_revenue overstated by 18% on 2026-05-04.
Impact: Finance dashboard displayed incorrect revenue for 3 hours.
Root cause: order-level payment amount was summed after joining order_items, causing join explosion.
Fix: aggregate item table before join and compute revenue from fct_orders.
Prevention: added uniqueness check on fct_orders.order_id and reconciliation check against payments.
```

## Real incidents

### Incident 1: Broken dashboard after successful pipeline

Symptoms:

- Airflow DAG green.
- Dashboard revenue drops to zero.

Likely causes:

- Source sent empty file.
- Filter date wrong.
- Payment status enum changed.
- Join to dimension became inner join.

Debug:

1. Check freshness.
2. Check row count by layer.
3. Check distinct status values.
4. Check source file count.
5. Check recent deploys/schema changes.

### Incident 2: Silent data corruption

Symptoms:

- No job failed.
- Metric slowly drifts.

Likely causes:

- Duplicate append every rerun.
- Incremental watermark misses updates.
- Upstream changed meaning of status.
- Timezone conversion changed.

Debug:

- Reconcile raw vs mart over time.
- Check duplicate key trend.
- Compare full-refresh sample vs incremental output.
- Audit deploy history.

### Incident 3: Schema drift

Symptoms:

- New column appears.
- Existing field type changes from integer to string.
- Nested JSON field changes structure.

Impact:

- Transform fails.
- Or worse, transform casts to null silently.

Prevention:

- Schema contract.
- CI schema check.
- Quarantine invalid records.
- Alert owner.

## Debugging wrong metrics

Workflow:

1. Define expected metric exactly.
2. Identify source of truth.
3. Check grain of each table.
4. Trace metric from raw -> staging -> fact -> mart.
5. Compare row count and sum at each layer.
6. Check business filters: cancelled/refunded/test orders.
7. Check duplicate keys.
8. Check timezone/date logic.
9. Check recent code/source/schema changes.

Question to ask:

- "Revenue" means gross item total, captured payment, net payment, or recognized revenue?

Many metric incidents are not SQL bugs. They are definition bugs.

## Trade-offs

- More checks vs pipeline speed: critical tables need stronger checks; low-value tables need lightweight checks.
- Hard fail vs warn: fail early for primary key duplicates, warn for small volume variance.
- Static threshold vs anomaly detection: static simpler, anomaly better for seasonal data.
- Central observability tool vs SQL/dbt tests: start simple, add platform when scale requires.
- Strict contracts vs producer agility: critical fields need strictness, optional fields can evolve.

## Cost considerations

Data quality costs:

- Extra queries.
- Extra storage for audit tables.
- Observability tools.
- Engineering time.

But missing quality costs more:

- Wrong business decisions.
- Manual debugging.
- Reprocessing.
- Lost trust.

Cost optimization:

- Run heavy checks on critical partitions only.
- Use sampling for low-risk checks.
- Store daily quality metrics instead of rescanning full history.
- Partition audit tables.
- Avoid `select *` checks on huge tables.

## Exercises

1. Add freshness check for raw orders.
2. Add duplicate check for fact orders.
3. Add referential integrity check orders -> customers.
4. Add accepted values check for order_status.
5. Add daily row count anomaly check.
6. Create a reconciliation query raw payments vs fact orders.
7. Simulate schema drift by adding status value `chargeback`.
8. Write incident report for join explosion.
9. Create alert severity matrix for 5 tables.

## Mini project

Build a data reliability layer for ecommerce marts:

```text
raw orders/payments
        |
        v
staging checks
        |
        v
fact checks
        |
        v
mart reconciliation
        |
        v
quality dashboard + incident runbook
```

Yeu cau:

- Quality SQL folder.
- dbt tests hoac plain SQL checks.
- Audit table luu check_name, status, observed_value, threshold, run_at.
- README giai thich SLA/SLO.
- 3 incident examples va cach debug.

## Interview questions

- Pipeline green nhung dashboard sai, ban debug sao?
- Freshness va completeness khac nhau nhu the nao?
- Data contract la gi?
- Schema drift xu ly the nao?
- Khi nao fail pipeline, khi nao chi warning?
- Reconciliation check la gi?
- Lam sao detect duplicate append?
- SLA/SLO cho data product nen dinh nghia ra sao?
- Alert noise la gi va giam nhu the nao?
- Silent data corruption nguy hiem o dau?

## GitHub outputs

Repo nen co:

- `quality/` chua SQL checks.
- `dbt/models/schema.yml` neu dung dbt.
- `observability/quality_metrics.sql`.
- `RUNBOOK.md`.
- `INCIDENT_EXAMPLES.md`.
- README co SLA/SLO va owner.
- Dashboard screenshot hoac query output minh hoa checks.

## Production upgrade: quality design matrix

### Check design matrix

| Check type | Layer | Frequency | Cost risk | Owner | Example |
| --- | --- | --- | --- | --- | --- |
| Schema | raw/staging | every run | low | platform/source owner | required column missing |
| Freshness | raw/mart | every run/hourly | low | data owner | latest partition < SLA |
| Volume | raw/staging | every run | medium | pipeline owner | row count drops 80% |
| Uniqueness | staging/mart | every run | medium/high | model owner | duplicate order_id |
| Referential integrity | mart | every run | medium | domain owner | order customer missing |
| Reconciliation | mart/finance | daily close | high | finance data owner | payment vs order total |
| Distribution anomaly | mart | daily/hourly | medium/high | analytics owner | revenue z-score spike |

Lesson:

- Khong phai check nao cung chay full table moi run.
- Partition-aware checks giam cost.
- Owner phai ro, neu khong alert se bi ignore.

### Freshness by partition

Bad freshness:

```sql
select max(updated_at) from huge_fact;
```

Better:

```sql
select
    partition_date,
    max(updated_at) as latest_update,
    count(*) as row_count
from fact_orders
where partition_date >= current_date - interval '7 days'
group by partition_date;
```

Production reason:

- Freshness toan table co the che mat partition bi thieu.
- Check recent partitions re hon full scan.

### Anomaly thresholds

Static threshold:

- Don gian.
- De fail sai khi seasonality.

Dynamic threshold:

- Dung rolling average/stddev.
- Tot hon cho volume/revenue.
- Can baseline va exception handling.

Rule:

- Critical finance metric: conservative threshold + human review.
- Noisy event stream: dynamic threshold + burn-in period.

### Lineage-based impact analysis

Khi test fail, can biet downstream nao bi anh huong:

- Dashboard nao doc table nay?
- ML feature nao dung cot nay?
- Reverse ETL sync nao se push sai data?

Operational pattern:

- Test fail tren staging co the block marts.
- Test fail tren non-critical mart co the warn only.
- Test fail tren certified finance mart should block publish.

### Cost-aware quality

Quality checks cung co chi phi.

Anti-pattern:

- Moi 15 phut scan full fact 5 TB de check duplicate.

Better:

- Check only new partition.
- Maintain audit aggregate table.
- Run heavy reconciliation daily.
- Sample low-risk raw data.
- Full historical check only after backfill/schema change.
