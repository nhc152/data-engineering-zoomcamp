# dbt va Analytics Engineering

## Vai tro

dbt la cong cu quan ly transformation bang SQL trong warehouse. No giup bien SQL roi rac thanh mot project co dependency, tests, documentation, lineage va workflow gan voi Git.

dbt khong thay the Airflow/Kestra. Orchestrator tra loi "chay khi nao va theo thu tu nao". dbt tra loi "model nao phu thuoc model nao, transform ra sao, test gi, docs gi".

Architecture thuong gap:

```text
raw warehouse tables
    -> dbt sources
    -> staging models
    -> intermediate models
    -> marts
    -> tests/docs/lineage
```

Voi background ODI/Talend, co the xem dbt nhu phan transform/mapping duoc viet bang SQL co version control, tests va lineage ro hon.

## Muc tieu can dat

Sau module nay, ban nen lam duoc:

- Tao dbt project co cau truc production.
- Dinh nghia sources va source freshness.
- Dung `ref()` va `source()` dung cach.
- Chia model thanh staging/intermediate/marts.
- Viet tests cho primary key, not null, relationship, accepted values.
- Viet custom tests khi business rule phuc tap.
- Tao docs va doc columns.
- Doc va debug lineage.
- Dung snapshots cho SCD/history.
- Dung incremental models voi unique key va watermark/lookback.
- Viet macro don gian de giam duplication co y nghia.
- Tich hop dbt vao CI/CD.
- Nhan dien anti-patterns va production failures.

## Khai niem can nam

- dbt project.
- Profile/target.
- Adapter.
- Model.
- Source.
- `ref()`.
- `source()`.
- Materialization: view, table, incremental, ephemeral.
- Staging/intermediate/marts.
- Generic tests.
- Singular tests.
- Custom tests.
- Source freshness.
- Documentation.
- Lineage graph.
- Exposures.
- Seeds.
- Snapshots.
- Macros.
- Variables.
- Tags.
- Selectors.
- State/defer.
- Slim CI.
- Data contracts.

## dbt architecture

### Control flow

dbt compile SQL templates thanh SQL that, sau do execute tren warehouse. Compute khong nam trong dbt, ma nam trong BigQuery/Snowflake/Postgres/Databricks.

Y nghia:

- Performance phu thuoc warehouse va SQL.
- dbt giup organization/test/docs, khong tu dong lam query nhanh.
- SQL modeling kem van kem khi dua vao dbt.

### Project layers

Pattern production:

```text
models/
  staging/
    source_name/
      stg_source__orders.sql
      stg_source__customers.sql
      _source_name__sources.yml
      _source_name__models.yml
  intermediate/
    int_orders__items_aggregated.sql
    int_payments__aggregated_to_order.sql
  marts/
    core/
      dim_customers.sql
      dim_products.sql
      fct_orders.sql
    finance/
      mart_daily_revenue.sql
```

Naming convention:

- `stg_<source>__<entity>`
- `int_<domain>__<purpose>`
- `dim_<entity>`
- `fct_<event/entity>`
- `mart_<business_area>_<metric>`

## Architecture mindset

### dbt la transformation layer

Dung dbt de:

- Clean/cast/rename source tables.
- Build fact/dimension.
- Build marts.
- Add tests/docs.
- Manage lineage.

Khong dung dbt de:

- Call API.
- Move files giua storage.
- Orchestrate multi-system workflow phuc tap.
- Loop qua tung row bang Python logic.
- Store secrets trong model SQL.

### `source()` va `ref()`

`source()` dung cho raw/source tables:

```sql
select *
from {{ source('shopify', 'orders') }}
```

`ref()` dung cho dbt models:

```sql
select *
from {{ ref('stg_shopify__orders') }}
```

Y nghia:

- dbt build dependency graph.
- dbt biet order chay.
- dbt docs hien lineage.
- Refactor table/schema de hon.

Anti-pattern:

```sql
select * from raw.orders
```

Hard-code table name lam hong lineage va kho deploy multi-env.

### Layering

Staging:

- Mot source object -> mot staging model.
- Rename, cast, clean, normalize.
- Dedup source neu can.
- Khong aggregate business lon.

Intermediate:

- Logic trung gian phuc tap.
- Aggregate order items ve order grain.
- Combine payment events.
- Tao reusable building blocks.

Marts:

- Business-facing.
- Fact/dimension.
- Dashboard/semantic layer ready.
- Tests va docs day du hon.

## Production mindset

### dbt build workflow

Lenh hay dung:

```bash
dbt debug
dbt parse
dbt compile
dbt run
dbt test
dbt build
dbt docs generate
dbt docs serve
```

Production thich `dbt build` vi no run model, tests, seeds, snapshots theo dependency.

### Environment

Can tach:

- dev: developer schema rieng.
- CI: temporary schema.
- prod: production schema.

Nguyen tac:

- Developer khong overwrite prod.
- CI build subset bi anh huong.
- Prod run bang service account.

### Materialization

View:

- Recompute khi query.
- Tot cho staging nho.
- Co the cham neu nested view day.

Table:

- Materialized ket qua.
- Tot cho marts/dashboard.
- Can refresh.

Incremental:

- Xu ly data moi/thay doi.
- Tot cho fact lon.
- Phuc tap: unique key, watermark, late data.

Ephemeral:

- Inline vao downstream SQL.
- Tot cho logic nho.
- Co the lam compiled SQL qua dai neu lam dung sai.

### Tests la production guardrail

Test nen gan voi risk:

- Primary key uniqueness cho dim/fact.
- Not null cho key/date/amount.
- Relationships cho foreign keys.
- Accepted values cho status.
- Freshness cho sources.
- Reconciliation cho metric quan trong.

Test khong nen chi de trang tri. Moi test fail phai co action ro.

## Data contracts

Data contract la thoa thuan ve schema va y nghia du lieu giua producer va consumer.

Trong dbt, contract co the the hien qua:

- Column names/types.
- Not null/unique tests.
- Accepted values.
- Source freshness.
- Model docs.
- Ownership metadata.

Production mindset:

- Mart quan trong nen co contract.
- Breaking change phai qua review.
- Source schema drift phai alert.

## Snapshots

Snapshots giup track history cua dimension/source thay doi theo thoi gian.

Dung khi:

- Source chi cung cap current state.
- Can xem history thay doi customer tier, product price, account status.

SCD2 output thuong co:

- `dbt_valid_from`
- `dbt_valid_to`

Trade-off:

- Snapshots tao them storage.
- Can unique key tot.
- Can biet cot nao de detect change.
- Khong nen snapshot moi thu.

## Incremental models

### Khi nao dung

Dung incremental khi:

- Table lon.
- Full refresh qua cham/dat.
- Data co cot `updated_at` hoac partition date.
- Co unique key/on conflict strategy.

Khong dung incremental khi:

- Data nho.
- Logic thuong xuyen thay doi.
- Source khong co key/watermark dang tin.
- Ban chua hieu late-arriving data.

### Pattern co ban

Concept:

```sql
select *
from {{ ref('stg_orders') }}

{% if is_incremental() %}
where updated_at >= (
    select max(updated_at) - interval '2 days'
    from {{ this }}
)
{% endif %}
```

Lookback window giup bat late updates.

### Failure modes

- Unique key sai -> duplicate.
- Watermark theo `created_at` -> miss updates.
- Khong lookback -> miss late arriving data.
- Full refresh bi disable trong khi logic can rebuild history.
- Schema change lam incremental fail.
- Delete/cancel event khong duoc propagate.

Debug incremental:

1. So sanh source rows trong lookback.
2. Check duplicate unique key.
3. Check max updated_at target.
4. Check late records co updated_at moi nhung event_date cu.
5. Chay full refresh tren sample/dev de compare.

## Macros

Macros giup reuse SQL/Jinja.

Dung cho:

- Standard status mapping.
- Reusable date spine.
- Reusable test logic.
- Generate repetitive SQL co pattern ro.

Khong nen:

- An business logic phuc tap kho doc.
- Tao abstraction som.
- Viet macro lam compiled SQL kho debug.

Production rule:

- Macro phai co docs/example.
- Macro phai lam SQL ro hon, khong phai "thong minh" hon.

## Documentation va lineage

Docs nen tra loi:

- Bang nay grain la gi?
- Cot nay nghia la gi?
- Metric tinh the nao?
- Source tu dau?
- Ai owner?
- Refresh cadence?

Lineage giup:

- Biet downstream impact khi thay doi model.
- Debug metric sai.
- Chon subset de run/test.
- Review PR an toan hon.

Broken lineage thuong do:

- Hard-code table names thay vi `ref()`.
- Model ngoai dbt ghi vao schema dbt.
- BI query truc tiep staging/raw khong qua marts.

Fix:

- Dung `ref()`/`source()`.
- Dinh nghia exposures cho dashboard quan trong.
- Document external dependencies.

## CI/CD with dbt

### PR workflow

1. Developer tao branch.
2. Sua models/tests/docs.
3. CI chay `dbt parse`.
4. CI chay subset modified models va downstream.
5. CI chay tests.
6. Review SQL, lineage, cost risk.
7. Merge vao main.
8. Prod job chay theo schedule/orchestrator.

### Slim CI

Slim CI chi build models bi thay doi va downstream, dua tren state artifacts.

Gia tri:

- Nhanh hon full build.
- Giam compute cost.
- Van bat duoc dependency impact.

### Deployment

Production dbt nen:

- Chay bang service account.
- Co target prod rieng.
- Luu artifacts: manifest, run_results.
- Alert khi run/test fail.
- Co runbook.

## Debugging mindset

### dbt compile fail

Nguyen nhan:

- Jinja syntax sai.
- `ref()` sai ten model.
- Macro sai.
- YAML indentation sai.

Debug:

- Chay `dbt parse`.
- Chay `dbt compile`.
- Xem compiled SQL trong `target/compiled`.

### dbt run fail

Nguyen nhan:

- SQL syntax sai theo warehouse dialect.
- Permission thieu.
- Source table missing.
- Type cast fail.
- Query cost/time-out.

Debug:

- Copy compiled SQL chay truc tiep tren warehouse.
- Check warehouse job history.
- Check source exists/permission.

### dbt test fail

Can hoi:

- Test bat dung data bug hay test sai?
- Impact downstream la gi?
- Co can quarantine data khong?
- Co can update business rule khong?

Debug:

- Query rows fail.
- Check source change.
- Check recent model change.
- Check known accepted values.

### Broken lineage

Checklist:

- Co hard-code table name khong?
- Co model ngoai dbt chen vao flow khong?
- Co source chua khai bao khong?
- Dashboard co exposure khong?

## Real-world failures

### Failure 1: Incremental model miss updates

Mo ta:

- Model filter `created_at > max(created_at)`.
- Source update order cu.
- Mart khong cap nhat status/refund.

Fix:

- Dung `updated_at` watermark.
- Merge theo unique key.
- Lookback window.
- Reconciliation refunds/cancelled.

### Failure 2: dbt tests qua it

Mo ta:

- Fact table co duplicate order_id.
- Dashboard revenue gap doi.
- Khong co unique test.

Fix:

- Add unique/not null tests.
- Add relationship tests.
- Add revenue reconciliation singular test.

### Failure 3: View nesting cham

Mo ta:

- Mart la view tren nhieu view staging/intermediate.
- Dashboard query cham va dat.

Fix:

- Materialize intermediate/marts thanh table.
- Tao aggregate mart.
- Review compiled SQL.

### Failure 4: Hard-code prod table

Mo ta:

- Dev model query truc tiep prod raw table.
- CI/prod lineage sai, permission fail.

Fix:

- Dung `source()`.
- Profiles/targets dung schema rieng.
- Code review rule cam hard-code cross-env.

## Anti-patterns

- Tat ca logic trong mot model SQL 500 dong.
- Staging model chua business aggregation lon.
- Hard-code database/schema/table thay vi `ref()`/`source()`.
- Tests chi co not null nhung khong co unique/relationship.
- Incremental model khong co unique key.
- Dung `select *` trong marts.
- Macro qua phuc tap lam SQL kho doc.
- Dashboard query truc tiep staging.
- Khong document grain.
- Full refresh prod khong co ke hoach cost.

## Trade-offs

### dbt vs stored procedures

dbt:

- Git-friendly.
- Lineage/docs/tests tot.
- SQL modular.

Stored procedures:

- Gan voi database.
- Co the phu hop transactional/internal logic.
- Kho lineage/review hon.

### View vs table

View:

- Realtime hon.
- Recompute moi lan.
- Tot cho staging nho.

Table:

- On dinh/nhanh hon.
- Ton storage.
- Can refresh.

### Generic test vs singular test

Generic:

- Reusable.
- Tot cho unique/not null/accepted values.

Singular:

- SQL custom.
- Tot cho reconciliation/business rules.

## Cost considerations

dbt co the lam warehouse cost tang neu:

- Full refresh table lon moi ngay.
- Incremental sai lam scan full source.
- View nested lam dashboard scan nhieu.
- CI build qua rong.
- Tests scan table lon khong partition filter.

Cost habits:

- Tag heavy models.
- Chay heavy models theo schedule rieng.
- Dung incremental co partition pruning.
- Dung slim CI.
- Materialize marts phu hop.
- Theo doi run duration va bytes scanned.

## Exercises

### Level 1: Project setup

1. Tao dbt project.
2. Ket noi Postgres/BigQuery.
3. Dinh nghia source `raw.orders`.
4. Tao `stg_orders`.
5. Dung `source()` thay vi hard-code.

### Level 2: Layering

1. Tao `stg_customers`, `stg_orders`, `stg_order_items`, `stg_payments`.
2. Tao `int_order_items__aggregated_to_order`.
3. Tao `fct_orders`.
4. Tao `dim_customers`.
5. Document grain.

### Level 3: Tests

1. Unique test cho `fct_orders.order_id`.
2. Not null test cho keys.
3. Relationship test orders -> customers.
4. Accepted values cho order_status.
5. Singular reconciliation test payment vs item totals.

### Level 4: Incremental

1. Convert `fct_orders` thanh incremental.
2. Them unique key.
3. Dung `updated_at` watermark.
4. Them lookback 2 ngay.
5. Gia lap late-arriving record va test.

### Level 5: CI/docs

1. Generate dbt docs.
2. Add exposures cho dashboard revenue.
3. Setup CI chay parse/build/test subset.
4. Viet runbook khi dbt test fail.

## Mini project

### De bai

Build dbt project cho ecommerce warehouse.

Input:

- Raw customers.
- Raw products.
- Raw orders.
- Raw order_items.
- Raw payments.

Output:

- `stg_*` models.
- `int_order_items__aggregated_to_order`.
- `int_payments__aggregated_to_order`.
- `dim_customers`.
- `dim_products`.
- `fct_orders`.
- `mart_daily_revenue`.
- `mart_customer_ltv`.

### Yeu cau

- Khong hard-code raw table, dung `source()`.
- Khong hard-code dbt model, dung `ref()`.
- Moi mart co docs va grain.
- Co tests cho keys, status, relationships.
- Co at least 1 singular reconciliation test.
- Co docs generate.
- Co README giai thich production workflow.

### Dau ra

- dbt project chay duoc.
- `schema.yml` hoac chia YAML theo folder.
- Screenshot lineage/docs neu co.
- CI workflow neu co GitHub.
- Incident notes cho mot test fail.

## Interview questions

### Concept

- dbt khac Airflow nhu the nao?
- `ref()` va `source()` khac nhau nhu the nao?
- Materialization la gi?
- Staging/intermediate/marts khac nhau nhu the nao?
- dbt lineage duoc tao ra tu dau?

### Production

- Khi nao dung incremental model?
- Incremental model co the fail theo cach nao?
- Lam sao debug dbt test fail?
- Lam sao thiet ke dbt tests cho fact orders?
- Lam sao giam dbt run cost?
- Slim CI la gi?

### Modeling

- Vi sao staging khong nen aggregate business metric lon?
- Vi sao mart can document grain?
- Khi nao dung snapshot?
- Data contract trong dbt nghia la gi?

## GitHub outputs

Toi thieu:

- `dbt_project.yml`.
- `models/staging`.
- `models/intermediate`.
- `models/marts`.
- YAML docs/tests.
- README workflow.

Tot hon:

- `tests/` singular tests.
- `macros/` co macro don gian.
- `snapshots/` cho customer/product history.
- `.github/workflows/dbt-ci.yml`.
- Artifacts/docs screenshots.

## Production appendix: skeleton, selectors va artifacts

### YAML examples

```yaml
sources:
  - name: shopify
    schema: raw
    tables:
      - name: orders
        loaded_at_field: ingestion_timestamp
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}
```

```yaml
models:
  - name: fct_orders
    description: One row per order.
    columns:
      - name: order_id
        tests: [not_null, unique]
      - name: customer_id
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_id
```

### Test strategy matrix

```text
staging: not_null, accepted_values, light dedup checks
intermediate: grain checks, reconciliation by key
marts: unique PK, relationships, business metrics, freshness
finance marts: reconciliation + owner approval on definition changes
```

### Selectors va state comparison

Selectors giup run dung subset:

```bash
dbt build --select tag:finance
dbt build --select state:modified+
dbt test --select result:error+
```

State artifacts:

- `manifest.json` cho lineage/model state.
- `run_results.json` cho duration/status.
- `sources.json` cho freshness.

Production use:

- Slim CI.
- Detect changed models.
- Track slow models over time.
- Debug failing runs.

### Compiled SQL debug walkthrough

Khi model fail:

1. Run `dbt compile`.
2. Open compiled SQL in `target/compiled`.
3. Copy SQL to warehouse.
4. Add filters/sample to isolate bad CTE.
5. Check source row count and data type casts.

dbt error line often points to compiled SQL, not source model line. Senior workflow la debug compiled SQL, roi quay lai sua model.
