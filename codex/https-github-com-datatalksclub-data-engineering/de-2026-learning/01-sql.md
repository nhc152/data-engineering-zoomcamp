# SQL nang cao cho Data Engineer

## Vai tro cua SQL trong Data Engineering 2026

SQL la ky nang cot loi cua Data Engineer. Python, Docker, Airflow, dbt, Spark, Kafka la cac cong cu quan trong, nhung phan lon logic du lieu van quay ve SQL:

- Clean du lieu.
- Join nhieu source.
- Deduplicate record.
- Build fact/dimension.
- Tinh KPI.
- Validate data quality.
- Debug pipeline.
- Toi uu chi phi warehouse.

Voi background ODI/Talend, ban da co loi the vi da quen voi mapping source-target, ETL flow va migration. Viec can lam la nang cap tu "keo tha mapping" sang "viet SQL co cau truc, de bao tri, co test, co performance mindset".

## Muc tieu sau khi hoc file nay

Sau phan SQL, ban nen lam duoc:

- Viet query co nhieu CTE nhung van doc duoc.
- Hieu grain cua bang truoc khi join.
- Dung window functions de deduplicate, xep hang, tinh running metrics.
- Thiet ke bang fact/dimension co ban.
- Viet SQL cho incremental load.
- Viet SQL quality checks.
- Debug row count, duplicate, missing data.
- Hieu performance o muc Data Engineer: index, partition, clustering, scan cost.
- Giai thich SQL logic trong phong van.

## SQL stack nen dung de thuc hanh

Nen hoc bang 2 moi truong:

1. PostgreSQL
   - Tot de hoc SQL chuan, index, constraint, query plan.
   - Chay local bang Docker rat de.

2. BigQuery hoac Snowflake
   - Tot de hoc warehouse, partition, clustering, columnar storage, cost.
   - Neu theo DataTalksClub Zoomcamp thi dung BigQuery.

Neu moi bat dau, dung PostgreSQL truoc. Sau do port query sang BigQuery de thay khac biet.

## Lo trinh hoc SQL trong 4 tuan

### Tuan 1: SQL foundation nhung theo huong DE

Muc tieu:

- Viet query sach.
- Thanh thao join, aggregation, CTE.
- Hieu NULL va data type.

Can lam:

- SELECT, WHERE, GROUP BY, HAVING.
- JOIN cac loai.
- CASE WHEN.
- COALESCE.
- CAST.
- CTE.
- Subquery.
- UNION vs UNION ALL.

Dau ra:

- 20 query clean/aggregate tren dataset ecommerce hoac taxi.
- 1 file `staging.sql`.

### Tuan 2: Window functions va deduplication

Muc tieu:

- Xu ly duplicate va history.
- Tim record moi nhat.
- Tinh metric theo thoi gian.

Can lam:

- `row_number()`
- `rank()`
- `dense_rank()`
- `lag()`
- `lead()`
- `sum() over`
- `count() over`
- `first_value()`, `last_value()`

Dau ra:

- Query deduplicate bang raw events.
- Query daily revenue + running revenue.
- Query compare ngay hien tai voi ngay truoc.

### Tuan 3: Data modeling va incremental SQL

Muc tieu:

- Thiet ke fact/dimension.
- Hieu grain.
- Viet incremental load logic.

Can lam:

- Fact table.
- Dimension table.
- Star schema.
- SCD type 1/type 2 concept.
- Full refresh.
- Append.
- Merge/upsert.
- Watermark.
- Late arriving data.

Dau ra:

- `dim_customers.sql`
- `dim_products.sql`
- `fct_orders.sql`
- `incremental_orders.sql`

### Tuan 4: Performance va data quality

Muc tieu:

- Debug query cham.
- Giam duplicate/missing data.
- Viet quality checks.

Can lam:

- Index trong PostgreSQL.
- Partition/clustering trong BigQuery.
- Query plan.
- Row count reconciliation.
- Uniqueness check.
- Not null check.
- Referential integrity check.
- Freshness check.

Dau ra:

- `quality_checks.sql`
- `performance_notes.md`
- README giai thich grain va checks.

## Dataset goi y de hoc

Nen chon 1 dataset va dung xuyen suot:

- Ecommerce: customers, orders, order_items, products, payments.
- Taxi: trips, zones, vendors, payments.
- Retail: stores, products, sales, inventory.

Ecommerce la de nhat de hoc modeling va interview.

Schema mau:

```sql
customers(customer_id, customer_name, email, created_at, updated_at)
products(product_id, product_name, category, price, updated_at)
orders(order_id, customer_id, order_status, order_timestamp, updated_at)
order_items(order_item_id, order_id, product_id, quantity, unit_price)
payments(payment_id, order_id, payment_method, amount, payment_timestamp)
```

## Nen tang bat buoc

### SELECT va filter

Can viet ro cot can lay. Trong data warehouse, tranh `select *` voi bang lon.

```sql
select
    order_id,
    customer_id,
    order_status,
    order_timestamp
from raw_orders
where order_timestamp >= date '2026-01-01';
```

Kinh nghiem:

- Lay dung cot can dung.
- Filter som neu co the.
- Chuan hoa ten cot ngay tu staging layer.

### GROUP BY va HAVING

`where` loc truoc aggregation. `having` loc sau aggregation.

```sql
select
    customer_id,
    count(*) as total_orders,
    sum(order_amount) as total_revenue
from fct_orders
group by customer_id
having count(*) >= 2;
```

Loi hay gap:

- Dung `where count(*) > 1`, sai vi aggregation chua xay ra.
- Group theo qua nhieu cot lam metric bi vo nho.

### CASE WHEN

Dung de mapping status, tao flag, tao bucket.

```sql
select
    order_id,
    case
        when order_status in ('paid', 'shipped', 'completed') then 'valid'
        when order_status in ('cancelled', 'refunded') then 'invalid'
        else 'unknown'
    end as order_status_group
from raw_orders;
```

Kinh nghiem:

- Luon co `else` de tranh NULL bat ngo.
- Neu mapping lon, nen tao dimension/mapping table thay vi CASE qua dai.

### NULL handling

NULL khong bang 0, khong bang chuoi rong. NULL la unknown/missing.

```sql
select
    customer_id,
    coalesce(phone_number, 'unknown') as phone_number,
    coalesce(total_amount, 0) as total_amount
from customers;
```

Can nho:

- `where column = null` la sai. Dung `is null`.
- `count(*)` dem tat ca rows.
- `count(column)` khong dem NULL.
- `sum(NULL)` co the tra NULL neu tat ca gia tri la NULL.

### UNION vs UNION ALL

`UNION` remove duplicate, ton chi phi hon. `UNION ALL` giu tat ca rows.

Trong pipeline data, thuong dung `UNION ALL`, sau do deduplicate ro rang neu can.

```sql
select order_id, order_timestamp from orders_2025
union all
select order_id, order_timestamp from orders_2026;
```

## Query co cau truc bang CTE

CTE giup query dai de doc hon. Pattern nen dung:

```sql
with source as (
    select * from raw_orders
),

cleaned as (
    select
        cast(order_id as varchar) as order_id,
        cast(customer_id as varchar) as customer_id,
        lower(trim(order_status)) as order_status,
        cast(order_timestamp as timestamp) as order_timestamp,
        cast(updated_at as timestamp) as updated_at
    from source
),

deduped as (
    select *
    from cleaned
    qualify row_number() over (
        partition by order_id
        order by updated_at desc
    ) = 1
),

final as (
    select
        order_id,
        customer_id,
        order_status,
        order_timestamp,
        updated_at
    from deduped
)

select * from final;
```

Luu y:

- BigQuery/Snowflake ho tro `qualify`.
- PostgreSQL khong ho tro `qualify`, can boc them CTE:

```sql
with ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by updated_at desc
        ) as rn
    from cleaned_orders
)

select *
from ranked
where rn = 1;
```

Nguyen tac CTE:

- `source`: lay raw data.
- `cleaned`: cast/rename/basic clean.
- `deduped`: xu ly duplicate.
- `enriched`: join bo sung thong tin.
- `aggregated`: aggregate.
- `final`: select cot output cuoi.

## Join va grain

### Grain la gi?

Grain la dinh nghia moi dong trong bang dai dien cho cai gi.

Vi du:

- `orders`: moi dong la mot order.
- `order_items`: moi dong la mot item trong mot order.
- `payments`: moi dong la mot payment transaction.
- `customers`: moi dong la mot customer.

Truoc khi join, luon hoi:

- Bang trai grain la gi?
- Bang phai grain la gi?
- Join key co unique o bang phai khong?
- Join co lam nhan dong khong?

### Vi du join bi nhan dong

Neu `orders` co 1 dong/order, `order_items` co nhieu dong/order:

```sql
select
    o.order_id,
    o.customer_id,
    o.order_amount,
    oi.product_id
from orders o
left join order_items oi
    on o.order_id = oi.order_id;
```

Sau join, grain khong con la order nua. No thanh order-item. Neu tinh `sum(o.order_amount)` sau join se bi double count.

Dung cach an toan:

```sql
with order_item_agg as (
    select
        order_id,
        count(*) as item_count,
        sum(quantity * unit_price) as item_revenue
    from order_items
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_amount,
    oi.item_count,
    oi.item_revenue
from orders o
left join order_item_agg oi
    on o.order_id = oi.order_id;
```

### Checklist truoc/sau join

Truoc join:

```sql
select count(*) as rows, count(distinct order_id) as distinct_orders
from orders;
```

Kiem tra bang phai co unique key khong:

```sql
select
    customer_id,
    count(*) as row_count
from customers
group by customer_id
having count(*) > 1;
```

Sau join:

```sql
select
    count(*) as rows_after_join,
    count(distinct order_id) as distinct_orders_after_join
from joined_orders;
```

Kinh nghiem:

- Dung `distinct` de sua duplicate thuong la dau hieu chua hieu root cause.
- Neu join voi dimension, key ben dimension nen unique.
- Neu join 1-n, phai chap nhan doi grain hoac aggregate truoc.

## Window functions

Window function tinh toan tren mot "cua so" rows ma khong lam gop rows nhu GROUP BY.

### GROUP BY vs Window function

GROUP BY:

```sql
select
    customer_id,
    count(*) as total_orders
from orders
group by customer_id;
```

Ket qua: moi customer 1 dong.

Window:

```sql
select
    order_id,
    customer_id,
    count(*) over (partition by customer_id) as total_orders_of_customer
from orders;
```

Ket qua: van giu moi order 1 dong, them metric cua customer.

### Deduplicate bang row_number

```sql
with ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by updated_at desc
        ) as rn
    from raw_orders
)

select *
from ranked
where rn = 1;
```

Neu co tie-breaker:

```sql
row_number() over (
    partition by order_id
    order by updated_at desc, ingestion_timestamp desc
) as rn
```

Kinh nghiem:

- Dedup logic phai co rule ro: giu record moi nhat, record co version cao nhat, hay record ingestion moi nhat.
- Neu order by khong deterministic, ket qua co the thay doi giua cac lan chay.

### Rank va dense_rank

```sql
select
    customer_id,
    order_id,
    order_amount,
    rank() over (
        partition by customer_id
        order by order_amount desc
    ) as order_rank
from orders;
```

Khac biet:

- `rank`: co the nhay so khi tie.
- `dense_rank`: khong nhay so.
- `row_number`: luon unique, khong quan tam tie.

### Lag/lead

Dung de so sanh row hien tai voi row truoc/sau.

```sql
select
    customer_id,
    order_id,
    order_timestamp,
    lag(order_timestamp) over (
        partition by customer_id
        order by order_timestamp
    ) as previous_order_timestamp
from orders;
```

Tinh so ngay giua 2 lan mua:

```sql
select
    customer_id,
    order_id,
    order_timestamp,
    order_timestamp
        - lag(order_timestamp) over (
            partition by customer_id
            order by order_timestamp
        ) as time_since_previous_order
from orders;
```

### Running total

```sql
select
    order_date,
    daily_revenue,
    sum(daily_revenue) over (
        order by order_date
        rows between unbounded preceding and current row
    ) as running_revenue
from daily_revenue;
```

### Moving average

```sql
select
    order_date,
    daily_revenue,
    avg(daily_revenue) over (
        order by order_date
        rows between 6 preceding and current row
    ) as revenue_7_day_avg
from daily_revenue;
```

## Data modeling bang SQL

### Layering

Mot SQL project nen chia layer:

- Raw: data goc, it thay doi.
- Staging: clean, rename, cast.
- Intermediate: logic trung gian, join/aggregate phuc tap.
- Mart: fact/dimension/dashboard-ready tables.

Trong dbt, pattern nay rat tu nhien:

- `stg_orders`
- `int_order_items_aggregated`
- `dim_customers`
- `fct_orders`

### Staging model

Muc tieu staging:

- Rename cot.
- Cast type.
- Standardize status.
- Deduplicate raw neu can.
- Khong aggregate business metric lon.

Vi du:

```sql
with source as (
    select * from raw_orders
),

cleaned as (
    select
        cast(order_id as varchar) as order_id,
        cast(customer_id as varchar) as customer_id,
        lower(trim(order_status)) as order_status,
        cast(order_timestamp as timestamp) as order_timestamp,
        cast(updated_at as timestamp) as updated_at
    from source
)

select * from cleaned;
```

### Dimension table

Dimension chua attributes mo ta entity.

```sql
select
    customer_id,
    customer_name,
    email,
    created_at,
    updated_at
from stg_customers;
```

Grain: moi dong la mot customer.

### Fact table

Fact chua event/transaction va measures.

```sql
with orders as (
    select * from stg_orders
),

items as (
    select
        order_id,
        sum(quantity) as total_quantity,
        sum(quantity * unit_price) as gross_item_amount
    from stg_order_items
    group by order_id
),

payments as (
    select
        order_id,
        sum(amount) as paid_amount
    from stg_payments
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    cast(o.order_timestamp as date) as order_date,
    o.order_status,
    coalesce(i.total_quantity, 0) as total_quantity,
    coalesce(i.gross_item_amount, 0) as gross_item_amount,
    coalesce(p.paid_amount, 0) as paid_amount
from orders o
left join items i
    on o.order_id = i.order_id
left join payments p
    on o.order_id = p.order_id;
```

Grain: moi dong la mot order.

## Incremental load

### Full refresh

Xoa va build lai toan bo table.

Phu hop khi:

- Data nho.
- Logic thay doi nhieu.
- Can sua du lieu lich su.

Bat loi khi:

- Data qua lon.
- Chay lau.
- Ton chi phi.

### Append

Chi them du lieu moi.

```sql
insert into fct_orders
select *
from stg_orders
where order_date > (
    select max(order_date) from fct_orders
);
```

Rui ro:

- Late arriving data bi bo sot.
- Update record cu khong duoc cap nhat.
- Duplicate neu source gui lai record cu.

### Merge/upsert

Dung khi can insert record moi va update record cu.

BigQuery/Snowflake/Postgres deu co cach merge/upsert rieng. Vi du concept:

```sql
merge into fct_orders as target
using stg_orders as source
    on target.order_id = source.order_id
when matched then update set
    order_status = source.order_status,
    updated_at = source.updated_at
when not matched then insert (
    order_id,
    customer_id,
    order_status,
    order_timestamp,
    updated_at
) values (
    source.order_id,
    source.customer_id,
    source.order_status,
    source.order_timestamp,
    source.updated_at
);
```

### Watermark

Watermark la moc thoi gian/key de biet lan sau lay tiep tu dau.

Vi du:

```sql
select *
from raw_orders
where updated_at >= (
    select max(updated_at) - interval '2 days'
    from fct_orders
);
```

Dung lookback 2 ngay de bat late updates.

Kinh nghiem:

- Watermark theo `updated_at` tot hon `created_at` neu source co update.
- Can lookback window neu co late arriving data.
- Merge/upsert an toan hon append cho data co update.

## Slowly Changing Dimension

### SCD Type 1

Ghi de gia tri cu. Khong giu history.

Phu hop:

- Sua typo.
- Thuoc tinh khong can lich su.

Vi du: customer email moi ghi de email cu.

### SCD Type 2

Giu history bang effective date.

Cot thuong co:

- `valid_from`
- `valid_to`
- `is_current`

Vi du output:

```text
customer_id | tier   | valid_from | valid_to   | is_current
1           | silver | 2026-01-01 | 2026-03-15 | false
1           | gold   | 2026-03-15 | null       | true
```

Khi nao can SCD2:

- Can report theo state tai thoi diem xay ra transaction.
- Customer tier, product category, sales region thay doi theo thoi gian.

## Data quality checks bang SQL

### Row count check

```sql
select
    count(*) as row_count
from fct_orders
where order_date = current_date - interval '1 day';
```

### Duplicate key check

```sql
select
    order_id,
    count(*) as row_count
from fct_orders
group by order_id
having count(*) > 1;
```

Expected: 0 rows.

### Not null check

```sql
select *
from fct_orders
where order_id is null
   or customer_id is null
   or order_date is null;
```

Expected: 0 rows.

### Accepted values check

```sql
select distinct order_status
from fct_orders
where order_status not in ('pending', 'paid', 'shipped', 'completed', 'cancelled', 'refunded');
```

Expected: 0 rows.

### Referential integrity check

```sql
select
    f.order_id,
    f.customer_id
from fct_orders f
left join dim_customers c
    on f.customer_id = c.customer_id
where c.customer_id is null;
```

Expected: 0 rows, tru khi business cho phep guest order.

### Freshness check

```sql
select
    max(order_timestamp) as latest_order_timestamp
from fct_orders;
```

Can so sanh voi SLA. Vi du: data phai moi hon 24 gio.

### Reconciliation check

So sanh source va target:

```sql
select
    'source' as layer,
    count(*) as row_count,
    sum(amount) as total_amount
from raw_payments
where cast(payment_timestamp as date) = date '2026-05-01'

union all

select
    'target' as layer,
    count(*) as row_count,
    sum(paid_amount) as total_amount
from fct_orders
where order_date = date '2026-05-01';
```

Kinh nghiem:

- Check count thoi chua du. Can check sum amount, min/max date, distinct key.
- Data quality query nen duoc luu trong repo, khong chi chay tam tren UI.

## Performance mindset

### OLTP vs OLAP

OLTP:

- PostgreSQL/MySQL app database.
- Nhieu transaction nho.
- Index quan trong.
- Row-based storage.

OLAP:

- BigQuery/Snowflake/Redshift/Databricks.
- Query analytics tren data lon.
- Columnar storage.
- Partition/clustering quan trong.

### Index trong PostgreSQL

Index giup filter/join nhanh hon nhung lam write cham hon va ton storage.

Vi du:

```sql
create index idx_orders_customer_id
on orders(customer_id);
```

Index hay dung:

- Join key.
- Filter key.
- Sort key neu query thuong order.

Can tranh:

- Tao index tren moi cot.
- Tao index nhung query khong dung duoc vi function/cast sai cach.

### Partition trong warehouse

Partition chia table theo cot, thuong la date.

Phu hop:

- Bang lon.
- Query thuong filter theo date.

Query tot:

```sql
select
    order_date,
    sum(paid_amount) as revenue
from fct_orders
where order_date between date '2026-05-01' and date '2026-05-07'
group by order_date;
```

Query kem:

```sql
select *
from fct_orders;
```

### Clustering

Clustering sap xep data theo cot thuong filter/join, vi du:

- `customer_id`
- `product_id`
- `region`
- `order_status`

Partition va clustering khac nhau:

- Partition cat table thanh phan lon theo date/range.
- Clustering sap xep/nhom data ben trong partition.

### Query plan

Trong PostgreSQL:

```sql
explain analyze
select *
from orders
where customer_id = 'C001';
```

Can nhin:

- Sequential scan hay index scan.
- Rows estimate vs actual rows.
- Join type.
- Execution time.

Trong BigQuery:

- Xem bytes processed.
- Xem stage co shuffle lon khong.
- Xem partition filter co apply khong.

## Debug SQL pipeline

### Khi row count tang bat thuong

Checklist:

1. Kiem tra source row count.
2. Kiem tra duplicate key trong source.
3. Kiem tra join key ben dimension co unique khong.
4. Kiem tra join 1-n co lam doi grain khong.
5. Kiem tra `union all` co append duplicate khong.

Query mau:

```sql
select
    customer_id,
    count(*) as row_count
from dim_customers
group by customer_id
having count(*) > 1;
```

### Khi row count giam bat thuong

Checklist:

1. Co dung INNER JOIN lam mat records khong?
2. Filter WHERE co qua chat khong?
3. Date/timezone co sai khong?
4. Incremental watermark co bo sot data khong?
5. Source data hom nay co thieu khong?

Query mau:

```sql
select
    count(*) as source_rows
from raw_orders
where cast(order_timestamp as date) = date '2026-05-01';
```

### Khi metric sai

Checklist:

1. Grain cua bang metric la gi?
2. Co double count sau join khong?
3. Refund/cancelled order co duoc xu ly khong?
4. Currency/tax/discount co tinh dung khong?
5. Timezone cua ngay bao cao la gi?

### Khi duplicate xuat hien

Checklist:

1. Source co duplicate khong?
2. Key dung de dedup co du khong?
3. Chay lai job co append lan 2 khong?
4. Merge key co dung khong?
5. Tie-breaker trong row_number co deterministic khong?

## SQL style guide

Nen theo style on dinh:

- Keyword viet thuong hoac hoa deu duoc, nhung nhat quan.
- Moi cot tren mot dong khi query dai.
- Alias ro nghia.
- CTE ten theo muc dich.
- Khong dat alias mot chu cai neu query phuc tap, tru truong hop join don gian.
- Khong de logic quan trong trong comment.

Vi du nen:

```sql
select
    orders.order_id,
    orders.customer_id,
    customers.customer_name,
    orders.order_date,
    orders.paid_amount
from fct_orders as orders
left join dim_customers as customers
    on orders.customer_id = customers.customer_id;
```

Vi du can tranh:

```sql
select *
from a
join b on a.id = b.id;
```

## Biet khac biet giua cac SQL dialect

Can nhan dien khac biet giua PostgreSQL, BigQuery, Snowflake, Spark SQL:

- Date functions khac nhau.
- `qualify` co/khong.
- `merge` syntax khac nhau.
- Cast syntax co the khac.
- JSON functions khac nhau.
- Array/struct support khac nhau.

Nguyen tac:

- Hoc SQL concept truoc.
- Khi dung engine nao thi doc syntax engine do.
- Trong README nen noi ro query viet cho engine nao.

## Bai tap thuc hanh chi tiet

### Level 1: Foundation

1. Tao bang `customers`, `orders`, `order_items`, `payments`.
2. Dem so order theo ngay.
3. Tinh revenue theo ngay.
4. Tim top 10 customers theo revenue.
5. Liet ke order co payment amount khac item amount.

### Level 2: Join va grain

1. Join orders voi customers.
2. Join orders voi order_items va giai thich grain thay doi.
3. Aggregate order_items truoc khi join lai orders.
4. Check duplicate customer_id trong dim_customers.
5. Tao query reconciliation source vs target.

### Level 3: Window functions

1. Deduplicate orders theo `order_id`, giu `updated_at` moi nhat.
2. Tinh order thu may cua moi customer.
3. Tinh ngay giua 2 lan mua.
4. Tinh running revenue theo ngay.
5. Tinh moving average 7 ngay.

### Level 4: Modeling

1. Tao `stg_orders`.
2. Tao `stg_order_items`.
3. Tao `dim_customers`.
4. Tao `dim_products`.
5. Tao `fct_orders`.
6. Viet data dictionary cho tung bang.

### Level 5: Incremental va quality

1. Viet append incremental theo order_date.
2. Viet merge/upsert theo order_id.
3. Them lookback window 2 ngay.
4. Viet duplicate check.
5. Viet freshness check.
6. Viet referential integrity check.

## Mini project SQL

### De bai

Build SQL layer cho ecommerce analytics.

Input:

- Raw customers.
- Raw products.
- Raw orders.
- Raw order_items.
- Raw payments.

Output:

- `dim_customers`
- `dim_products`
- `fct_orders`
- `mart_daily_revenue`
- `mart_customer_lifetime_value`

### Yeu cau

- Moi output table phai co grain ro rang.
- Co query deduplicate raw orders.
- Co query check duplicate primary key.
- Co query check not null.
- Co query check payment/order mismatch.
- Co README giai thich business rules.

### Cau truc folder

```text
sql/
  00_schema.sql
  01_seed_data.sql
  staging/
    stg_customers.sql
    stg_products.sql
    stg_orders.sql
    stg_order_items.sql
    stg_payments.sql
  marts/
    dim_customers.sql
    dim_products.sql
    fct_orders.sql
    mart_daily_revenue.sql
    mart_customer_lifetime_value.sql
  quality/
    duplicate_checks.sql
    not_null_checks.sql
    reconciliation_checks.sql
README.md
```

## Cau hoi phong van SQL

### Co ban nhung hay bi hoi

- INNER JOIN va LEFT JOIN khac nhau nhu the nao?
- WHERE va HAVING khac nhau nhu the nao?
- UNION va UNION ALL khac nhau nhu the nao?
- NULL trong SQL hoat dong ra sao?
- CTE khac subquery nhu the nao?

### Data Engineer practical

- Lam sao deduplicate data?
- Lam sao tranh duplicate khi pipeline chay lai?
- Lam sao debug row count tang sau join?
- Lam sao debug metric revenue bi sai?
- Khi nao dung full refresh, khi nao dung incremental?
- Late arriving data la gi va xu ly sao?
- Watermark la gi?

### Modeling

- Grain la gi?
- Fact va dimension khac nhau nhu the nao?
- Star schema la gi?
- SCD type 1 va type 2 khac nhau nhu the nao?
- Vi sao khong nen tinh metric quan trong o nhieu noi?

### Performance

- Index giup gi?
- Partition va clustering khac nhau nhu the nao?
- BigQuery tinh cost dua tren gi?
- Query plan dung de lam gi?
- Vi sao `select *` tren warehouse lon la thoi quen xau?

## Dap an ngan nen tap noi

### Window function khac GROUP BY nhu the nao?

GROUP BY gom nhieu rows thanh mot row moi group. Window function tinh metric tren mot tap rows nhung van giu chi tiet tung row. Vi du, GROUP BY customer tra 1 dong/customer, con window co the giu 1 dong/order va them total_orders cua customer.

### Lam sao deduplicate records?

Xac dinh business key va rule giu record. Thuong dung `row_number() over (partition by key order by updated_at desc, ingestion_time desc)` roi giu `rn = 1`. Rule order by phai deterministic de chay lai cho cung ket qua.

### Lam sao debug join lam tang row count?

Kiem tra grain hai bang, dem distinct key truoc join, tim duplicate key o bang phai, so sanh row count truoc/sau join. Neu join 1-n, can aggregate bang n ve cung grain truoc khi join hoac chap nhan output grain thay doi.

### Incremental load khac full refresh nhu the nao?

Full refresh build lai toan bo data, don gian nhung ton chi phi voi data lon. Incremental chi xu ly data moi/thay doi, nhanh hon nhung can watermark, merge key va xu ly late arriving data.

### Partitioning giup gi?

Partition giup engine chi scan phan data can thiet, thuong theo ngay. No giam thoi gian va chi phi query neu query co filter tren cot partition.

## Checklist thanh thao SQL cho DE

- [ ] Viet query CTE doc duoc.
- [ ] Giai thich duoc grain cua moi bang.
- [ ] Biet check duplicate key.
- [ ] Biet deduplicate bang window function.
- [ ] Biet viet fact/dimension co ban.
- [ ] Biet viet incremental merge/upsert concept.
- [ ] Biet viet data quality checks.
- [ ] Biet debug join lam nhan dong.
- [ ] Biet debug metric sai.
- [ ] Biet khac biet index vs partition/clustering.
- [ ] Biet doc query plan o muc co ban.

## Dau ra can co tren GitHub

Toi thieu:

- Folder `sql/`.
- `schema.sql`.
- `staging.sql`.
- `marts.sql`.
- `quality_checks.sql`.
- README giai thich grain cua tung bang.

Tot hon:

- Chia folder staging/marts/quality.
- Co seed data nho de nguoi khac chay.
- Co screenshots/query output.
- Co data dictionary.
- Co section "known issues and assumptions".

## Cach hoc tiep voi dbt

Sau khi lam SQL project thu cong, chuyen sang dbt:

- `staging.sql` -> `models/staging/stg_*.sql`
- `marts.sql` -> `models/marts/dim_*.sql`, `fct_*.sql`
- `quality_checks.sql` -> dbt tests trong `schema.yml`
- CTE dependency -> `ref()`
- README data dictionary -> dbt docs

SQL tot se lam dbt tot. dbt khong sua duoc SQL modeling kem.

## Production appendix: incident-style SQL walkthroughs

### Incident 1: revenue duplicated after join

Symptom:

- Daily revenue tang 18% sau khi them product category vao dashboard.

Diagnostics:

```sql
select count(*) as rows, count(distinct order_id) as orders
from fct_orders;

select count(*) as rows, count(distinct order_id) as orders
from fct_orders
join fct_order_items using (order_id);
```

Interpretation:

- Neu rows tang nhung distinct orders khong tang, grain da doi tu order sang order-item.
- Order-level revenue khong duoc sum sau khi join item-level table.

Fix:

- Tinh product revenue tu `fct_order_items`.
- Hoac aggregate item ve order grain truoc khi join.

Prevention:

- Add row-count/grain check in PR.
- Document grain in mart.
- Add reconciliation between order revenue and finance source.

### Incident 2: late-arriving update missed

Symptom:

- Order ngay cu bi refund nhung mart van tinh revenue.

Root cause:

- Incremental filter dung `created_at > max(created_at)` nen miss updates to old orders.

Fix:

- Dung `updated_at` watermark.
- Add lookback window.
- Merge/upsert by order_id.

Prevention:

- Test cancelled/refunded updates.
- Audit max updated_at by partition.

### Incident 3: query cost spike

Symptom:

- BigQuery bill tang sau khi dashboard moi deploy.

Diagnostics:

- Check bytes scanned.
- Check partition filter.
- Check `select *`.
- Check view nesting.

Fix:

- Add required partition filter.
- Select only needed columns.
- Build aggregate mart.
- Consider materialized view/table for repeated dashboard query.
