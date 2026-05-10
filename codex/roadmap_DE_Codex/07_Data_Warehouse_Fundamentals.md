# 07_Data_Warehouse_Fundamentals.md

## 1. Introduction

Data warehouse là nơi dữ liệu được tổ chức để phân tích, báo cáo và ra quyết định. Junior thường chỉ biết viết query trên warehouse. Mid hiểu fact/dimension, partition, materialized view. Senior phải hiểu kiến trúc storage/compute, columnar format, MPP, optimizer, cost, workload management và cách thiết kế để dữ liệu vừa đúng vừa chạy nhanh.

```mermaid
flowchart LR
    A["OLTP systems"] --> B["Ingestion"]
    B --> C["Raw data"]
    C --> D["Warehouse storage"]
    D --> E["Compute/query engine"]
    E --> F["Semantic marts"]
    F --> G["BI/Analytics/ML"]
    E --> H["Monitoring and cost control"]
```

## 2. Theory

### OLTP vs OLAP

OLTP tối ưu cho giao dịch nhỏ, nhiều write, latency thấp: tạo đơn hàng, cập nhật thanh toán. OLAP tối ưu cho scan lớn, aggregation, join nhiều bảng: doanh thu theo tháng, cohort retention, funnel.

Warehouse không nên là bản copy thô của production DB. Nó cần mô hình phân tích, lịch sử, quality checks, security và workload isolation.

### Columnar storage

Warehouse hiện đại thường lưu theo cột. Khi query chỉ cần `order_date`, `amount`, `status`, engine đọc các cột đó thay vì toàn bộ row. Lợi ích:

- Ít I/O hơn.
- Compression tốt hơn vì dữ liệu cùng kiểu nằm cạnh nhau.
- Predicate pushdown hiệu quả.
- Vectorized execution.

### Partitioning và clustering

Partition chia dữ liệu thành phần vật lý/logical, thường theo ngày. Partition pruning giúp engine bỏ qua partition không liên quan. Clustering/sort key sắp xếp dữ liệu trong partition để filter/join nhanh hơn.

Sai lầm phổ biến: partition quá nhỏ tạo nhiều metadata, hoặc partition theo cột ít dùng filter.

### MPP architecture

MPP là Massively Parallel Processing: query được chia cho nhiều node xử lý song song. Senior cần hiểu data distribution:

- Broadcast join: bảng nhỏ được gửi đến các node.
- Shuffle join: dữ liệu hai bảng được repartition theo join key.
- Colocated join: dữ liệu đã phân phối cùng key nên join rẻ hơn.

```mermaid
flowchart TD
    Q["SQL query"] --> P["Query planner"]
    P --> N1["Worker 1 scans partitions"]
    P --> N2["Worker 2 scans partitions"]
    P --> N3["Worker 3 scans partitions"]
    N1 --> S["Shuffle/Aggregate"]
    N2 --> S
    N3 --> S
    S --> R["Final result"]
```

## 3. Real-world example

Một dashboard doanh thu đọc bảng `fact_orders` 5 tỷ dòng. Ban đầu query scan toàn bộ bảng mỗi lần lọc theo tháng, chi phí cao và chạy 8 phút. Sau khi partition theo `order_date`, clustering theo `customer_id`, tạo aggregate mart theo ngày, query dashboard giảm còn 5 giây.

Incident thực tế: BI dashboard timeout vào sáng thứ Hai. Nguyên nhân không phải warehouse yếu, mà do 200 dashboard refresh cùng lúc, query scan bảng raw thay vì mart, và không có workload management. Fix gồm semantic mart, schedule refresh lệch giờ, resource group riêng cho BI, và alert query cost.

## 4. SQL example

### PostgreSQL: partition và materialized view

```sql
CREATE TABLE fact_orders (
    order_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    order_date date NOT NULL,
    amount numeric(18, 2) NOT NULL,
    status text NOT NULL
) PARTITION BY RANGE (order_date);

CREATE TABLE fact_orders_2026_05
PARTITION OF fact_orders
FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');

CREATE INDEX idx_fact_orders_2026_05_customer
ON fact_orders_2026_05 (customer_id, order_date);

CREATE MATERIALIZED VIEW mart_daily_revenue AS
SELECT order_date, status, SUM(amount) AS revenue, COUNT(*) AS orders
FROM fact_orders
GROUP BY order_date, status;
```

### Oracle: partitioned table và bitmap index

```sql
CREATE TABLE fact_orders (
    order_id NUMBER NOT NULL,
    customer_id NUMBER NOT NULL,
    order_date DATE NOT NULL,
    amount NUMBER(18, 2) NOT NULL,
    status VARCHAR2(30) NOT NULL
)
PARTITION BY RANGE (order_date) (
    PARTITION p202605 VALUES LESS THAN (DATE '2026-06-01'),
    PARTITION p202606 VALUES LESS THAN (DATE '2026-07-01')
);

CREATE BITMAP INDEX bix_fact_orders_status
ON fact_orders(status)
LOCAL;

CREATE MATERIALIZED VIEW mart_daily_revenue
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT TRUNC(order_date) AS order_date, status, SUM(amount) AS revenue, COUNT(*) AS orders
FROM fact_orders
GROUP BY TRUNC(order_date), status;
```

## 5. Python example

```python
import logging
import pandas as pd
from sqlalchemy import create_engine

logging.basicConfig(level=logging.INFO)

engine = create_engine("postgresql+psycopg2://etl:secret@localhost:5432/warehouse")

def profile_table(table_name: str) -> pd.DataFrame:
    query = f"""
        SELECT
            COUNT(*) AS row_count,
            COUNT(DISTINCT order_date) AS active_days,
            MIN(order_date) AS min_date,
            MAX(order_date) AS max_date,
            SUM(amount) AS total_amount
        FROM {table_name}
    """
    return pd.read_sql(query, engine)

def detect_partition_gap():
    df = pd.read_sql("""
        SELECT order_date::date AS d, COUNT(*) AS rows
        FROM fact_orders
        WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY order_date::date
        ORDER BY d
    """, engine)
    missing = df[df["rows"] == 0]
    if not missing.empty:
        logging.warning("Possible missing partitions: %s", missing["d"].tolist())

if __name__ == "__main__":
    print(profile_table("fact_orders"))
    detect_partition_gap()
```

## 6. Optimization

Performance:

- Chọn partition key theo filter phổ biến, thường là event date.
- Tránh query trực tiếp raw table cho BI; tạo mart hoặc aggregate table.
- Dùng `EXPLAIN` để xác nhận partition pruning.
- Giảm shuffle bằng distribution key phù hợp trong MPP warehouse.
- Chỉ select cột cần thiết để tận dụng columnar storage.

Cost:

- Tách workload ad hoc, BI, batch transform.
- Materialize metric đắt tiền thay vì tính lại mỗi dashboard.
- Dọn table/intermediate không còn dùng.
- Theo dõi query scan bytes, CPU time, warehouse credits.

Monitoring:

- Query runtime p50/p95/p99.
- Scan bytes per query.
- Queue time.
- Failed query rate.
- Freshness của mart.
- Table size growth.
- Partition count và skew.

## 7. Common mistakes

Best practices:

- Dùng star schema cho analytics phổ biến.
- Định nghĩa grain rõ cho fact table.
- Có semantic layer hoặc mart cho KPI chính.
- Tài liệu hóa owner, SLA, lineage.

Anti-patterns:

- Một bảng wide chứa mọi thứ và không rõ grain.
- Partition theo `created_at` trong khi mọi query lọc `event_date`.
- Tạo quá nhiều materialized view không ai quản lý refresh.
- Cho dashboard production đọc staging/raw.
- Dùng index kiểu OLTP để giải quyết vấn đề OLAP.

Debugging scenario:

- Query chậm đột ngột: kiểm tra plan, partition pruning, stats, data skew, concurrent workload, spill to disk, missing refresh.
- Cost tăng: tìm top queries theo scan bytes, dashboard loop, full refresh không cần thiết, bảng duplicate.

## 8. Interview questions

Junior:

- Data warehouse khác database transaction như thế nào?
- Columnar storage giúp gì cho analytics?
- Partitioning là gì?

Mid:

- Khi nào dùng materialized view?
- Giải thích broadcast join và shuffle join.
- Thiết kế warehouse mart cho doanh thu ecommerce.

Senior:

- Warehouse 10 TB tăng lên 500 TB, bạn thiết kế partition, clustering, workload và cost control thế nào?
- Dashboard C-level phải chạy dưới 3 giây nhưng dữ liệu 5 tỷ dòng, bạn xử lý ra sao?
- Làm sao phát hiện KPI sai do thay đổi grain?

## 9. Exercises

1. Thiết kế `fact_orders` và `dim_customer` cho ecommerce.
2. Viết query PostgreSQL kiểm tra partition pruning bằng `EXPLAIN`.
3. Viết Oracle materialized view cho revenue daily.
4. Tạo bảng aggregate theo ngày và so sánh runtime với query raw.
5. Mini project: xây warehouse mart cho order, payment, refund, shipment và dashboard KPI.

## 10. Checklist

- [ ] Fact table có grain rõ ràng.
- [ ] Dimension có key, history strategy và owner.
- [ ] Partition key khớp query pattern.
- [ ] Query BI đọc mart/aggregate thay vì raw.
- [ ] Có monitoring runtime, scan bytes, freshness, failures.
- [ ] Có cost dashboard theo team/workload.
- [ ] Có access control cho PII.
- [ ] Có runbook khi dashboard timeout hoặc KPI sai.
- [ ] Có strategy refresh materialized view.
- [ ] Có data contract giữa warehouse và downstream.
