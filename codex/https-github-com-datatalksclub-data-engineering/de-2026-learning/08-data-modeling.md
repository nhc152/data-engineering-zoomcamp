# Data Modeling va Warehouse Design

## Vai tro

Data modeling la ky nang bien du lieu raw thanh data product dang tin. Neu pipeline chi move data nhanh nhung model sai grain, sai metric, duplicate revenue, join explosion, thi platform van khong dung duoc.

Senior Data Engineer khong chi hoi "load data thanh cong chua", ma hoi:

- Moi bang co grain gi?
- Metric duoc tinh o dau?
- Ai la owner cua definition?
- Join co lam nhan dong khong?
- Lich su thay doi entity co can giu khong?
- Dashboard co dang query mot mart on dinh khong?
- Neu business thay doi definition thi impact o dau?

Data modeling tot giup:

- Dashboard nhat quan.
- Query nhanh hon.
- Cost thap hon.
- Debug de hon.
- Team tin du lieu hon.

## Muc tieu can dat

Sau module nay, ban nen lam duoc:

- Xac dinh grain cua moi table.
- Thiet ke fact va dimension cho ecommerce/finance/event data.
- Giai thich star schema va snowflake schema.
- Chon SCD type 1 hay type 2.
- Model event data thanh facts/marts.
- Thiet ke incremental model khong duplicate.
- Tao data marts phuc vu business.
- Debug metric inconsistency.
- Debug join explosion va duplicate metrics.
- Dinh nghia metric o mot noi chuan.
- Giai thich Kimball mindset o muc practical.

## Khai niem can nam

- Entity.
- Grain.
- Business key.
- Surrogate key.
- Primary key.
- Foreign key.
- Fact table.
- Dimension table.
- Measure.
- Attribute.
- Additive/semi-additive/non-additive metric.
- Star schema.
- Snowflake schema.
- SCD type 1.
- SCD type 2.
- Snapshot fact.
- Accumulating snapshot.
- Transaction fact.
- Event fact.
- Data mart.
- Semantic layer.
- Metric definition.
- Data contract.

## Architecture mindset

### Model theo layer

Pattern:

```text
raw
    -> staging
    -> intermediate
    -> marts
    -> semantic/dashboard
```

Raw:

- Giu gan source.
- It business logic.
- Co the co duplicate/schema drift.

Staging:

- Clean/cast/rename.
- Dedup source co rule.
- Mot source -> mot staging model.

Intermediate:

- Resolve grain.
- Aggregate child tables.
- Business joins trung gian.

Marts:

- Fact/dimension.
- KPI tables.
- Dashboard-ready.
- Co owner, docs, tests.

### Grain first

Truoc khi viet SQL, viet cau:

```text
Moi dong trong bang nay dai dien cho ...
```

Vi du:

- `fct_orders`: moi dong la mot order.
- `fct_order_items`: moi dong la mot line item trong order.
- `fct_payments`: moi dong la mot payment transaction.
- `dim_customers`: moi dong la mot customer hien tai.
- `mart_daily_revenue`: moi dong la mot ngay.

Neu khong noi duoc grain, chua nen viet join.

## Kimball mindset

Kimball dimensional modeling tap trung vao facts va dimensions de phuc vu analytics.

Tu duy chinh:

- Business process -> fact table.
- Descriptive context -> dimension table.
- Conformed dimensions giup metric nhat quan giua marts.
- Star schema giup BI query de va nhanh.

Vi du ecommerce:

Business processes:

- Orders.
- Payments.
- Shipments.
- Refunds.
- Web events.

Dimensions:

- Customers.
- Products.
- Date.
- Geography.
- Marketing campaign.

## Fact tables

### Transaction fact

Moi dong la mot transaction/event.

Vi du:

- `fct_orders`: one row per order.
- `fct_order_items`: one row per order item.
- `fct_payments`: one row per payment.

Chua:

- Foreign keys.
- Timestamps/dates.
- Measures.
- Degenerate dimensions nhu order_number neu can.

### Periodic snapshot fact

Moi dong la trang thai tai mot thoi diem/dinh ky.

Vi du:

- Daily inventory balance.
- Account balance by day.
- Daily subscription status.

Can can than voi metric semi-additive:

- Inventory count cong theo product duoc.
- Khong nen cong inventory count qua nhieu ngay de ra "total inventory".

### Accumulating snapshot fact

Moi dong theo doi lifecycle co nhieu milestone.

Vi du order fulfillment:

- order_created_at
- paid_at
- shipped_at
- delivered_at
- cancelled_at

Phu hop khi quy trinh co start/end ro.

### Event fact

Moi dong la mot event.

Vi du:

- page_view
- add_to_cart
- checkout
- payment_failed

Event facts can:

- event_id.
- user/customer_id.
- session_id.
- event_timestamp.
- event_name.
- properties.

Can deduplicate event_id va xu ly out-of-order events.

## Dimension tables

Dimension chua attributes mo ta entity:

- Customer name, tier, country.
- Product name, category, brand.
- Store region.
- Campaign channel.

Dimension nen co:

- Stable key.
- Attributes ro nghia.
- Current flag neu co history.
- Validity dates neu SCD2.

### Business key vs surrogate key

Business key:

- Key den tu source: `customer_id`, `product_id`.
- Co y nghia business.
- Co the thay doi/duplicate/khong global unique.

Surrogate key:

- Key do warehouse tao.
- On dinh trong warehouse.
- Tot khi integrate nhieu source hoac SCD2.

Trong portfolio nho, business key co the du. Trong production lon, surrogate key thuong can.

## Star schema va snowflake schema

### Star schema

Fact o giua, dimensions xung quanh.

```text
dim_customers
      |
dim_products -- fct_orders -- dim_date
      |
dim_channels
```

Uu diem:

- De query.
- Tot cho BI.
- It join depth.
- De giai thich.

Nhuoc diem:

- Dimension co the denormalized.
- Mot so attribute lap lai.

### Snowflake schema

Dimension duoc normalized tiep.

Vi du:

```text
fct_orders -> dim_products -> dim_categories
```

Uu diem:

- Giam duplication.
- Model normalized hon.

Nhuoc diem:

- Nhieu joins hon.
- BI user kho hon.
- Co the cham hon.

Rule:

- Analytics marts nen uu tien star schema.
- Snowflake khi dimension qua lon/phuc tap hoac governance yeu cau.

## Slowly Changing Dimensions

### SCD Type 1

Ghi de gia tri cu.

Phu hop:

- Sua typo.
- Email/phone current state.
- Attribute khong can history.

Trade-off:

- Don gian.
- Khong report duoc historical state.

### SCD Type 2

Giu history bang valid time.

Cot thuong co:

- surrogate_key.
- business_key.
- valid_from.
- valid_to.
- is_current.

Vi du:

```text
customer_sk | customer_id | tier   | valid_from | valid_to   | is_current
101         | C001        | silver | 2026-01-01 | 2026-03-15 | false
205         | C001        | gold   | 2026-03-15 | null       | true
```

Phu hop:

- Customer tier history.
- Product price/category history.
- Account status.
- Sales territory assignment.

Trade-off:

- Query phuc tap hon.
- Storage tang.
- Can join theo effective date.

### SCD2 join pattern

Order join customer dimension theo ngay order:

```sql
select
    orders.order_id,
    customers.customer_sk,
    customers.customer_tier
from fct_orders as orders
left join dim_customers_scd2 as customers
    on orders.customer_id = customers.customer_id
   and orders.order_timestamp >= customers.valid_from
   and orders.order_timestamp < coalesce(customers.valid_to, timestamp '9999-12-31');
```

Neu join chi theo customer_id, ban co the join vao nhieu version va gay duplicate.

## Event modeling

Event data thuong co volume lon va schema linh hoat.

Raw event:

```text
event_id, user_id, session_id, event_name, event_timestamp, payload
```

Modeling questions:

- Event_id co unique khong?
- Event den tre/out of order khong?
- Payload co schema on dinh khong?
- Event nao duoc dung cho KPI?
- Session duoc dinh nghia the nao?

Pattern:

- `stg_events`: dedup, normalize event_name, parse common fields.
- `fct_events`: one row per event.
- `fct_sessions`: one row per session.
- `mart_funnel_conversion`: one row per date/channel/funnel step.

Rui ro:

- Duplicate events lam conversion sai.
- Timezone lam daily active users sai.
- Bot/internal traffic lam metric sai.
- Event taxonomy thay doi khong document.

## Incremental modeling

Model incremental can tra loi:

- Unique key la gi?
- Watermark cot nao?
- Late arriving data xu ly sao?
- Delete/cancel/update xu ly sao?
- Can rebuild partition nao?

Patterns:

### Append-only event fact

Phu hop khi event immutable va co event_id.

Can:

- Dedup event_id.
- Lookback theo ingestion/update time.

### Merge fact

Phu hop khi order/payment co update status.

Can:

- Unique key: order_id/payment_id.
- Watermark: updated_at.
- Lookback window.

### Delete + insert partition

Phu hop khi rebuild daily partitions.

Can:

- Partition boundary dung.
- Source co du data cho ngay do.
- Transaction/publish an toan.

## Business metrics

Metric can co definition chuan.

Vi du revenue:

Questions:

- Dung gross item amount hay captured payment?
- Co tru refund khong?
- Cancelled order tinh sao?
- Tax/shipping/discount tinh sao?
- Currency conversion ngay nao?
- Timezone theo customer, store hay UTC?

Metric doc nen co:

```text
metric_name: recognized_revenue
grain: order
definition: captured payment amount for non-cancelled, non-refunded orders
timezone: UTC order_date
owner: finance analytics
source tables: fct_orders, fct_payments
known exclusions: test orders, internal users
```

Semantic consistency nghia la revenue khong duoc moi dashboard tinh mot kieu.

## Data marts

Data mart la bang/view phuc vu mot nhom use case.

Vi du:

- `mart_daily_revenue`: finance dashboard.
- `mart_customer_ltv`: marketing/customer.
- `mart_product_performance`: merchandising.
- `mart_funnel_conversion`: product analytics.

Mart tot:

- Grain ro.
- Metric ro.
- Column names business-friendly.
- Query nhanh.
- Tests day du.
- Owner ro.

## Production mindset

### Ownership

Moi mart quan trong can co:

- Owner.
- SLA.
- Data dictionary.
- Metric definitions.
- Upstream/downstream lineage.
- Incident process.

### Versioning metric

Metric thay doi la breaking change. Vi du revenue truoc day khong tru refund, bay gio tru refund.

Production options:

- Update definition va backfill, thong bao downstream.
- Tao metric moi `net_revenue` thay vi doi am tham.
- Version mart neu impact lon.

### Governance

Model phai quan tam:

- PII cot nao.
- Ai duoc xem.
- Column masking.
- Row-level security.
- Retention.

## Debugging mindset

### Metric inconsistency

Trieu chung:

- Finance revenue khac marketing revenue.
- Dashboard A khac dashboard B.

Checklist:

1. Hai dashboard dung table nao?
2. Metric definition co giong nhau khong?
3. Grain co giong nhau khong?
4. Filter status/cancel/refund co giong nhau khong?
5. Timezone/date field co giong nhau khong?
6. Join co lam duplicate khong?
7. Co late data/backfill chua cap nhat khong?

### Join explosion

Trieu chung:

- Row count tang sau join.
- Revenue/count bi nhan.

Checklist:

1. Xac dinh grain hai bang.
2. Check uniqueness cua join key ben dimension.
3. Neu join fact voi child fact, aggregate child ve dung grain truoc.
4. Neu SCD2, join them valid_from/valid_to.
5. Check row count/distinct key truoc va sau join.

### Duplicate metrics

Nguyen nhan:

- Duplicate raw source.
- Incremental append chay lai.
- SCD2 join sai.
- One-to-many join khong aggregate.
- Union all duplicate partitions.

Fix:

- Dedup staging.
- Unique tests.
- Merge/upsert.
- Reconciliation.
- Document grain.

## Real-world failures

### Failure 1: Revenue gap doi sau khi them product category

Nguyen nhan:

- `fct_orders` join truc tiep `order_items`.
- Order-level payment repeated per item.

Fix:

- Tao `fct_order_items` rieng.
- Aggregate item metrics ve order grain truoc khi join `fct_orders`.
- Hoac tinh product revenue tu item-level fact, khong tu order-level payment.

### Failure 2: SCD2 join tao duplicate

Nguyen nhan:

- `fct_orders` join `dim_customers_scd2` chi bang `customer_id`.
- Moi customer co nhieu version.

Fix:

- Join theo business key + effective date.
- Test fact row count truoc/sau join.

### Failure 3: Dashboard DAU sai do timezone

Nguyen nhan:

- Event timestamp UTC nhung business report theo Asia/Saigon.
- Date cast sai.

Fix:

- Dinh nghia reporting timezone.
- Tao `event_date_local`.
- Document metric.

### Failure 4: LTV sai do refund

Nguyen nhan:

- LTV tinh gross order amount, khong tru refunded/cancelled orders.

Fix:

- Define recognized/net revenue.
- Add refund fact.
- Rebuild customer LTV mart.

## Trade-offs

### One wide table vs dimensional model

Wide table:

- De dung cho BI nhanh.
- It join.
- Co the duplicate attributes/metrics.
- Kho maintain khi logic phuc tap.

Dimensional:

- Grain ro.
- Reuse dimensions.
- Metric consistency tot hon.
- Can BI/user hieu joins hoac semantic layer.

Rule:

- Portfolio/project nho co the co mart wide cho dashboard.
- Production nen co facts/dims lam core, marts wide phuc vu use case.

### Fact order vs fact order item

`fct_orders`:

- One row per order.
- Tot cho revenue/order/customer.
- Khong tot cho product-level analysis neu order co nhieu products.

`fct_order_items`:

- One row per order item.
- Tot cho product/category revenue.
- Can can than khi join payment/order-level metrics.

### SCD1 vs SCD2

SCD1:

- Don gian.
- Khong history.

SCD2:

- Giu history.
- Query/debug phuc tap.

Rule:

- Attribute anh huong historical reporting -> SCD2.
- Attribute chi can current state -> SCD1.

## Cost considerations

Modeling anh huong cost:

- Query raw events moi dashboard rat dat.
- Star schema/marts giam scan.
- Aggregate marts giam compute lap lai.
- Partition facts theo date giam scan.
- Wide tables co the scan nhieu cot neu BI dung `select *`.
- SCD2 dimensions lon join sai co the rat dat.

Cost habits:

- Build marts cho queries lap lai.
- Partition facts lon.
- Cluster theo keys/filter hay dung.
- Avoid nested views qua sau.
- Materialize heavy intermediate.
- Document query pattern chinh.

## Exercises

### Level 1: Grain

1. Viet grain cho `orders`, `order_items`, `payments`, `customers`.
2. Tim query nao doi grain sau join.
3. Check row count/distinct key truoc/sau join.

### Level 2: Star schema

1. Thiet ke `dim_customers`.
2. Thiet ke `dim_products`.
3. Thiet ke `fct_orders`.
4. Thiet ke `fct_order_items`.
5. Ve star schema.

### Level 3: Metrics

1. Define gross revenue.
2. Define recognized revenue.
3. Define net revenue.
4. Viet SQL cho tung metric.
5. Giai thich cancel/refund/tax/shipping.

### Level 4: SCD

1. Tao customer tier history.
2. Build SCD2 dimension.
3. Join orders theo order_timestamp.
4. Chung minh join sai gay duplicate.

### Level 5: Event modeling

1. Tao `fct_events`.
2. Dedup event_id.
3. Tao `fct_sessions`.
4. Tao funnel mart.
5. Xu ly duplicate/out-of-order event.

### Level 6: Debugging

1. Tao query revenue sai do join explosion.
2. Viet diagnostic queries.
3. Fix bang aggregate grain.
4. Add quality checks.

## Mini project

### De bai

Design warehouse model cho ecommerce analytics.

Input:

- customers.
- products.
- orders.
- order_items.
- payments.
- refunds.
- web_events.

Core models:

- `dim_customers_current`.
- `dim_customers_scd2`.
- `dim_products`.
- `fct_orders`.
- `fct_order_items`.
- `fct_payments`.
- `fct_events`.

Marts:

- `mart_daily_revenue`.
- `mart_customer_ltv`.
- `mart_product_performance`.
- `mart_funnel_conversion`.

### Yeu cau

- Moi table co grain.
- Moi fact co primary/business key.
- Moi metric co definition.
- Co SCD2 cho customer tier.
- Co event dedup.
- Co reconciliation payment vs order/item.
- Co debugging note cho join explosion.

### Dau ra

- ERD hoac markdown diagram.
- SQL/dbt models.
- Data dictionary.
- Metric dictionary.
- README architecture va assumptions.

## Interview questions

### Concept

- Grain la gi?
- Fact va dimension khac nhau nhu the nao?
- Star schema va snowflake schema khac nhau ra sao?
- Kimball modeling la gi o muc practical?
- SCD type 1 va type 2 khac nhau the nao?

### Production

- Vi sao dashboard revenue cua hai team khac nhau?
- Lam sao debug join explosion?
- Khi nao can `fct_order_items` rieng thay vi chi `fct_orders`?
- Lam sao join SCD2 dimension dung?
- Metric definition nen dat o dau?
- Semantic consistency nghia la gi?

### Event modeling

- Event fact khac transaction fact the nao?
- Lam sao xu ly duplicate events?
- Sessionization can nhung gi?
- Timezone anh huong DAU/WAU ra sao?

## GitHub outputs

Toi thieu:

- `docs/data_model.md`.
- `docs/metric_definitions.md`.
- SQL/dbt models cho facts/dims.
- README co grain cua tung table.

Tot hon:

- ERD/mermaid diagram.
- Data dictionary.
- SCD2 example.
- Join explosion incident note.
- Metric reconciliation checks.
- BI-facing mart examples.

## Production appendix: metric governance workflow

### Metric change workflow

Khi doi definition cua revenue/LTV/active user:

1. Write proposed definition.
2. Identify affected marts/dashboards.
3. Compare old vs new metric on historical window.
4. Review with business owner.
5. Decide backfill or versioned metric.
6. Communicate release date.
7. Add tests/reconciliation.

### Bridge tables va many-to-many

Many-to-many example:

- Customer co nhieu segments.
- Campaign gan nhieu products.
- Account co nhieu users.

Bridge table:

```text
bridge_customer_segments
  customer_id
  segment_id
  valid_from
  valid_to
  allocation_weight
```

Risk:

- Join bridge without allocation can duplicate metrics.

Fix:

- Use allocation weights.
- Aggregate at correct grain.
- Document metric semantics.

### Concrete metric mismatch investigation

Symptom:

- Finance revenue = 100M, Growth dashboard = 112M.

Investigation:

1. Compare source tables used.
2. Compare date field/timezone.
3. Compare status filters.
4. Check refunds/cancellations.
5. Check join grain.
6. Compare daily deltas to find first divergence.

Prevention:

- Certified revenue mart.
- Metric owner.
- Dashboard uses semantic layer/certified mart only.
