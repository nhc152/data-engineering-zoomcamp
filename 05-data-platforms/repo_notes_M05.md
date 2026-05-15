# Phân Tích Repo: Module 05 - Data Platforms (Bruin)

═══════════════════════════════
1. CẤU TRÚC THƯ MỤC
═══════════════════════════════
```text
05-data-platforms/
├── README.md                 # Tổng quan module 5 về Data Platforms và công cụ Bruin, chứa links tới các video và hướng dẫn.
└── notes/                    # Chứa các file markdown bài học chi tiết
    ├── 01-introduction.md    # Giới thiệu về nền tảng Bruin và khái niệm Modern Data Stack.
    ├── 02-getting-started.md # Cài đặt CLI, config IDE, Bruin MCP, và các file cơ bản (project, pipeline).
    ├── 03-nyc-taxi-pipeline.md # Hướng dẫn end-to-end xây dựng pipeline xử lý dữ liệu NYC Taxi dùng DuckDB.
    ├── 04-bruin-mcp.md       # Tích hợp AI Agent (Claude, Cursor, Copilot) vào quá trình code Data Pipeline thông qua MCP.
    ├── 05-bruin-cloud.md     # Quản lý và deploy pipelines tự động thông qua Github và Bruin Cloud.
    ├── 06-core-01-projects.md # Giải thích Core Concept về Bruin Project và file `.bruin.yml` quản lý connections.
    ├── 06-core-02-pipelines.md # Giải thích Core Concept về Pipeline, cách gom nhóm Assets và config scheduling.
    ├── 06-core-03-assets.md  # Giải thích Core Concept về Assets (SQL, Python, Seed) và materialization.
    ├── 06-core-04-variables.md # Giải thích cách dùng built-in variables (start_date, end_date) và custom variables.
    └── 06-core-05-commands.md # Tổng hợp các CLI commands thường dùng để thao tác với dự án Bruin.
```

═══════════════════════════════
2. NỘI DUNG CÁC FILE .MD
═══════════════════════════════
**[README.md]**
- Dạy về: Tổng quan nội dung Module 5 sử dụng nền tảng Bruin.
- Concepts chính: Data lifecycle (Ingestion, Transformation, Orchestration, Data Quality, Metadata management).
- Commands được dùng: `bruin init zoomcamp my-taxi-pipeline`
- Lưu ý đặc biệt: Project thực hành dựa trên mẫu template có dạng TODO-based learning, yêu cầu học viên tự điền code/config.

**[01-introduction.md]**
- Dạy về: Giới thiệu Bruin data platform và Modern Data Stack.
- Concepts chính: Extract/Ingest, Transformations, Orchestrate, Data Quality. Bruin kết hợp toàn bộ công cụ thành một nền tảng duy nhất, giảm bớt nhu cầu kiến thức DevOps/Infra cho data pipelines.
- Commands được dùng: Không có
- Lưu ý đặc biệt: Mục tiêu của module là hiểu cấu trúc dự án Bruin, materialization, dependencies, lineage tự động và parameterization.

**[02-getting-started.md]**
- Dạy về: Cài đặt công cụ và cấu trúc dự án cơ bản của Bruin.
- Concepts chính: Bruin CLI, Bruin VS Code / Cursor extensions, Bruin MCP (Model Context Protocol), cấu trúc `.bruin.yml` (environments/connections), `pipeline.yml` (schedules) và cấu trúc assets.
- Commands được dùng: 
  - `curl -LsSf https://getbruin.com/install/cli | sh`
  - `bruin version`
  - `bruin init default my-first-pipeline`
  - `bruin validate <path>`
  - `bruin run <path>`
  - `bruin run --downstream`
  - `bruin run --full-refresh`
  - `bruin lineage <path>`
  - `bruin query --connection <conn> --query "..."`
- Lưu ý đặc biệt: File `.bruin.yml` tuyệt đối không được push lên version control vì chứa secrets và credentials.

**[03-nyc-taxi-pipeline.md]**
- Dạy về: Xây dựng hoàn chỉnh một kiến trúc pipeline 3 lớp cho dữ liệu taxi với DuckDB.
- Concepts chính: Kiến trúc Ingestion -> Staging -> Reports. Cấu hình Python assets, Seed files, SQL assets. Sử dụng các materialization strategies (append, time_interval) và Incremental key deduplication.
- Commands được dùng: 
  - `bruin init zoomcamp my-taxi-pipeline`
  - `bruin validate ./pipeline/pipeline.yml`
  - `bruin run ./pipeline/pipeline.yml --start-date 2022-01-01 --end-date 2022-02-01`
  - `bruin run ./pipeline/pipeline.yml --full-refresh`
  - `bruin query --connection duckdb-default --query "SELECT COUNT(*) FROM ingestion.trips"`
- Lưu ý đặc biệt: Asset staging SQL sử dụng strategy `time_interval` và deduplicate dữ liệu trùng bằng mệnh đề `QUALIFY ROW_NUMBER() OVER (...) = 1`.

**[04-bruin-mcp.md]**
- Dạy về: Sử dụng Bruin MCP để tích hợp AI Agent vào IDE.
- Concepts chính: Model Context Protocol. AI Agents có thể tự động viết code pipeline, config metadata, đọc cấu trúc pipeline, và thực hiện truy vấn natural language đến dữ liệu thực.
- Commands được dùng: 
  - `bruin init zoomcamp my-taxi-pipeline`
  - `claude mcp add bruin -- bruin mcp`
- Lưu ý đặc biệt: Có thể dùng prompt có sẵn trong README của template để AI Agent scaffold toàn bộ pipeline và chạy thử.

**[05-bruin-cloud.md]**
- Dạy về: Đưa pipeline từ môi trường local lên production thông qua Bruin Cloud.
- Concepts chính: Managed Infrastructure, GitHub repo integration, Connection Management trên Cloud, Monitoring/Observability (Asset status, lineage, data quality checks).
- Commands được dùng: Không có.
- Lưu ý đặc biệt: Khi enable pipeline có schedule trên Bruin Cloud, nó sẽ tự động chạy run cho khoảng thời gian (interval) gần nhất.

**[06-core-01-projects.md]**
- Dạy về: Concept về Bruin Project.
- Concepts chính: File cấu hình `.bruin.yml`, Project Root, quản lý nhiều môi trường (default, production, staging) và bảo mật Connection types.
- Commands được dùng: `bruin init zoomcamp my-pipeline`, `cd my-pipeline`, `bruin validate .`
- Lưu ý đặc biệt: Việc set up các môi trường khác nhau giúp chạy pipeline an toàn khi phát triển mà không đụng vào dữ liệu production.

**[06-core-02-pipelines.md]**
- Dạy về: Concept về Bruin Pipeline.
- Concepts chính: Grouping assets theo schedule (monthly, daily), Single Schedule per pipeline, Connection Scoping (giới hạn pipeline chỉ truy cập được những DB connections nhất định).
- Commands được dùng: 
  - `bruin validate ./pipelines/nyc-taxi/pipeline.yml`
  - `bruin lineage ./pipelines/nyc-taxi/pipeline.yml`
  - `bruin run ./pipelines/nyc-taxi/pipeline.yml`
- Lưu ý đặc biệt: Connection scoping giúp cách ly quyền truy cập và bảo mật tốt hơn giữa các phòng ban trong công ty.

**[06-core-03-assets.md]**
- Dạy về: Concept về Data Assets.
- Concepts chính: Asset Definition (Metadata) & Code, Asset Types (SQL, Python, YAML, R), Asset naming convention (phản ánh schema), Materialization strategies (table, view, insert, incremental), Tự động nội suy dependencies (Lineage).
- Commands được dùng:
  - `bruin run ./pipeline.yml --asset raw.trips_raw`
  - `bruin run ./pipeline.yml --asset raw.trips_raw --downstream`
  - `bruin run ./pipeline.yml --asset staging.trips_summary --upstream`
  - `bruin lineage ./pipeline.yml --asset raw.trips_raw`
- Lưu ý đặc biệt: Không cần declare cứng dependency cho SQL; Bruin tự động phân tích câu lệnh `SELECT FROM` để xây dựng dependency graph.

**[06-core-04-variables.md]**
- Dạy về: Quản lý biến số (Variables) để parameterize pipelines.
- Concepts chính: Built-in variables (`start_date`, `end_date`), Jinja templating cho SQL (`{{ start_date }}`), Environment variables cho Python (`BRUIN_VAR_START_DATE`), Custom variables.
- Commands được dùng:
  - `bruin run ./pipeline.yml --start-date 2020-01-01 --end-date 2020-01-31`
  - `bruin run ./pipeline.yml --var taxi_types=["green","fhv"]`
  - `bruin run ./pipeline.yml --var customer_id=12345`
  - `bruin run ./pipeline.yml --full-refresh`
  - `bruin run ./pipeline.yml --exclusive-end-date`
- Lưu ý đặc biệt: Trong Python, các custom variable arrays hoặc objects được truyền dưới dạng JSON string qua OS environment, cần dùng `json.loads` để parse.

**[06-core-05-commands.md]**
- Dạy về: Bruin CLI Workflow.
- Concepts chính: Thực thi pipeline (`bruin run`), Kiểm tra tính hợp lệ (`bruin validate`), Trực quan hoá DAG (`bruin lineage`), Truy vấn dữ liệu (`bruin query`). Khái niệm "Run" lifecycle.
- Commands được dùng: (Tương tự các file trên, có tổng hợp các flags như `--asset`, `--upstream`, `--downstream`, `--start-date`, `--environment`).
- Lưu ý đặc biệt: Luôn phải chạy `bruin validate` trước khi run để phòng ngừa circular dependencies.

═══════════════════════════════
3. PHÂN TÍCH CODE FILES & CONFIGS
═══════════════════════════════

**[bruin CLI config - `.bruin.yml` và `mcp.json`]**
- Environments được định nghĩa: `default`, `production`
- Connection types và fields: `duckdb` (path), `motherduck` (token), `bigquery` (project, dataset)
- Copy nguyên văn (`.bruin.yml`):
```yaml
default_environment: default

environments:
  default:
    connections:
      duckdb:
        - name: duckdb-default
          path: duckdb.db
      motherduck:
        - name: motherduck
          token: <your-token>

  production:
    connections:
      bigquery:
        - name: bq-prod
          project: my-project
          dataset: production
```
- Copy nguyên văn (`mcp.json`):
```json
{
  "servers": {
    "bruin": {
      "type": "stdio",
      "command": "bruin",
      "args": [
        "mcp"
      ]
    }
  },
  "inputs": []
}
```

**[pipeline config files - `pipeline.yml`]**
- Assets được định nghĩa: (Không định nghĩa asset ở mức config này, các asset nằm ở các file con)
- Connections: duckdb-default
- Schedule / trigger settings: schedule `daily`, start_date `2022-01-01`, pipeline default_connections. Có parameter custom variable `taxi_types` dưới dạng array.
- Copy nguyên văn:
```yaml
name: nyc_taxi
schedule: daily
start_date: "2022-01-01"
default_connections:
  duckdb: duckdb-default
variables:
  taxi_types:
    type: array
    items:
      type: string
    default: ["yellow"]
```

**[pyproject.toml / requirements.txt]**
- Dependencies list: `pandas`, `requests`, `pyarrow`, `python-dateutil`
- Copy nguyên văn (`requirements.txt`):
```text
pandas
requests
pyarrow
python-dateutil
```

**[asset files - Ingestion - `ingestion/trips.py`]**
- Asset type: python
- Parameters / variables nhận vào: `BRUIN_START_DATE`, `BRUIN_END_DATE`, biến môi trường `BRUIN_VARS` chứa JSON var `taxi_types`
- Logic chính từng bước: Lấy biến OS, parse json -> Sinh list các tháng -> Fetch Parquet files từ Cloudfront của NYC Taxi -> Trả về kết quả là Pandas DataFrame. Bruin lấy DF để tự động ingest với strategy `append`.
- Upstream dependencies: Không có.
- Copy nguyên văn:
```python
"""@bruin
name: ingestion.trips
type: python
image: python:3.11

materialization:
  type: table
  strategy: append

columns:
  - name: pickup_datetime
    type: timestamp
    description: "When the meter was engaged"
  - name: dropoff_datetime
    type: timestamp
    description: "When the meter was disengaged"
@bruin"""

import os
import json
import pandas as pd

def materialize():
    start_date = os.environ["BRUIN_START_DATE"]
    end_date = os.environ["BRUIN_END_DATE"]
    taxi_types = json.loads(os.environ["BRUIN_VARS"]).get("taxi_types", ["yellow"])

    # Generate list of months between start and end dates
    # Fetch parquet files from:
    # https://d37ci6vzurychx.cloudfront.net/trip-data/{taxi_type}_tripdata_{year}-{month}.parquet

    return final_dataframe
```

**[asset files - Ingestion Seed YAML - `payment_lookup.asset.yml`]**
- Asset type: duckdb.seed
- Parameters / variables nhận vào: `path`
- Logic chính từng bước: Trỏ tới file `payment_lookup.csv` và tạo Data Quality checks (`not_null`, `unique`) cho primary key và các fields khác.
- Upstream dependencies: Không có.
- Copy nguyên văn:
```yaml
name: ingestion.payment_lookup
type: duckdb.seed
parameters:
  path: payment_lookup.csv
columns:
  - name: payment_type_id
    type: integer
    description: "Numeric code for payment type"
    primary_key: true
    checks:
      - name: not_null
      - name: unique
  - name: payment_type_name
    type: string
    description: "Human-readable payment type"
    checks:
      - name: not_null
```

**[asset files - Ingestion CSV - `payment_lookup.csv`]**
- Copy nguyên văn:
```csv
payment_type_id,payment_type_name
0,flex_fare
1,credit_card
2,cash
3,no_charge
4,dispute
5,unknown
6,voided_trip
```

**[asset files - Staging SQL - `staging/trips.sql`]**
- Asset type: duckdb.sql
- Parameters / variables nhận vào: `{{ start_datetime }}`, `{{ end_datetime }}`
- Logic chính từng bước: Join `ingestion.trips` với lookup bảng payment. Giới hạn bản ghi theo khung start-end time (`time_interval` incremental strategy). Sử dụng window function `QUALIFY ROW_NUMBER() = 1` để thực hiện data deduplication. Kèm theo custom check validation logic để đảm bảo row_count > 0.
- Upstream dependencies: `ingestion.trips`, `ingestion.payment_lookup`
- Copy nguyên văn:
```sql
/* @bruin
name: staging.trips
type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table
  strategy: time_interval
  incremental_key: pickup_datetime
  time_granularity: timestamp

columns:
  - name: pickup_datetime
    type: timestamp
    primary_key: true
    checks:
      - name: not_null

custom_checks:
  - name: row_count_greater_than_zero
    query: |
      SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
      FROM staging.trips
    value: 1
@bruin */

SELECT
    t.pickup_datetime,
    t.dropoff_datetime,
    t.pickup_location_id,
    t.dropoff_location_id,
    t.fare_amount,
    t.taxi_type,
    p.payment_type_name
FROM ingestion.trips t
LEFT JOIN ingestion.payment_lookup p
    ON t.payment_type = p.payment_type_id
WHERE t.pickup_datetime >= '{{ start_datetime }}'
  AND t.pickup_datetime < '{{ end_datetime }}'
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY t.pickup_datetime, t.dropoff_datetime,
                 t.pickup_location_id, t.dropoff_location_id, t.fare_amount
    ORDER BY t.pickup_datetime
) = 1
```

**[asset files - Reports SQL - `reports/trips_report.sql`]**
- Asset type: duckdb.sql
- Parameters / variables nhận vào: `{{ start_datetime }}`, `{{ end_datetime }}`
- Logic chính từng bước: Lấy dữ liệu staging đã được clean/dedup. Cast `pickup_datetime` sang DATE (`trip_date`). Cắt khoảng thời gian incremental, sau đó GROUP BY thực hiện các lệnh COUNT, SUM, AVG cho các metrics.
- Upstream dependencies: `staging.trips`
- Copy nguyên văn:
```sql
/* @bruin
name: reports.trips_report
type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: table
  strategy: time_interval
  incremental_key: trip_date
  time_granularity: date

columns:
  - name: trip_date
    type: date
    primary_key: true
  - name: taxi_type
    type: string
    primary_key: true
  - name: payment_type
    type: string
    primary_key: true
  - name: trip_count
    type: bigint
    checks:
      - name: non_negative
@bruin */

SELECT
    CAST(pickup_datetime AS DATE) AS trip_date,
    taxi_type,
    payment_type_name AS payment_type,
    COUNT(*) AS trip_count,
    SUM(fare_amount) AS total_fare,
    AVG(fare_amount) AS avg_fare
FROM staging.trips
WHERE pickup_datetime >= '{{ start_datetime }}'
  AND pickup_datetime < '{{ end_datetime }}'
GROUP BY 1, 2, 3
```

**[Các đoạn Code Example Phụ từ Core Concepts]**
*Python Fetch API Ingest*:
```python
@bruin.asset(
    name="raw.trips_raw",
    type="python",
    connection="duckdb-default"
)
def ingest_trips():
    import requests
    import pandas as pd

    # Connect to API, fetch data
    response = requests.get("https://api.example.com/trips")
    data = response.json()

    # Return pandas DataFrame
    # Bruin handles materialization to database
    return pd.DataFrame(data)
```

*Python Date Parsing*:
```python
import os
from datetime import datetime

@bruin.asset(name="raw.monthly_data", type="python")
def ingest_monthly_data():
    start_date = os.environ['BRUIN_VAR_START_DATE']
    end_date = os.environ['BRUIN_VAR_END_DATE']

    # Parse and use dates to fetch data for specific period
    start = datetime.fromisoformat(start_date)
    end = datetime.fromisoformat(end_date)

    # Loop through months in range
    # ...
```

*Python JSON Arrays Parsing*:
```python
import os
import json

@bruin.asset(name="example.asset", type="python")
def example_asset():
    # Custom variables are prefixed with BRUIN_VAR_
    taxi_types_json = os.environ['BRUIN_VAR_TAXI_TYPES']
    taxi_types = json.loads(taxi_types_json)

    # Use the variable in your code
    for taxi_type in taxi_types:
        # Process each taxi type
        pass
```

*SQL Concept Pattern*:
```sql
@bruin.asset(
    name="staging.trips_summary",
    type="sql",
    connection="duckdb-default",
    materialization="table"
)

SELECT
    pickup_date,
    COUNT(*) as trip_count,
    SUM(fare_amount) as total_fare
FROM raw.trips_raw
WHERE pickup_date >= '{{ start_date }}'
  AND pickup_date < '{{ end_date }}'
GROUP BY pickup_date
```

═══════════════════════════════
4. DATA FLOW THỰC TẾ
═══════════════════════════════
- **Bước 1 (Layer Ingestion)**: 
  - File `ingestion/trips.py` trigger thông qua Bruin Runtime, lấy biến thời gian và query Parquet từ NYC Taxi API. Dữ liệu được Bruin tự động append vào bảng raw `ingestion.trips`.
  - File `ingestion/payment_lookup.asset.yml` trigger việc copy nội dung file tĩnh từ `payment_lookup.csv` đổ vào database. Cả 2 quy trình này có thể thực hiện song song do không phụ thuộc nhau.
- **Bước 2 (Layer Staging)**: 
  - `staging/trips.sql` phụ thuộc (`depends:`) vào `ingestion.trips` và `ingestion.payment_lookup`. Nó đợi đến khi 2 tiến trình Ingest hoàn tất.
  - Sử dụng strategy `time_interval`, script xoá dữ liệu trong timeframe, sau đó đọc và JOIN 2 bảng Ingest, lọc trong một khoảng partition thời gian. Thực thi deduplication loại bỏ row rác bằng mệnh đề `QUALIFY ROW_NUMBER() = 1` để đảm bảo idempotent process.
- **Bước 3 (Layer Reports)**:
  - `reports/trips_report.sql` phụ thuộc vào `staging.trips`. Đợi staging xong, truy xuất lại, CAST sang cột DATE và group metrics (Count, Sum, Avg).
- **DAG Dependency Graph**: 
  `[ingestion.trips]` & `[ingestion.payment_lookup]` ---> `[staging.trips]` ---> `[reports.trips_report]`

═══════════════════════════════
5. ĐIỂM YẾU & THIẾU SÓT
═══════════════════════════════
- **Security issues**: Thiết lập trong file `.bruin.yml` (e.g. `token: <your-token>`) có rủi ro hardcode plaintext secrets, dù file được đưa vào `.gitignore`. Senior DE phải quản lý secrets thông qua External Key Vaults hoặc Environment Secret injection.
- **Idempotency issues**: `ingestion/trips.py` sử dụng strategy `append`. Nếu pipeline chạy lại cùng một Data Interval trên lịch hẹn, hoặc re-run fail, sẽ dẫn đến trùng lặp dữ liệu trên Layer Raw (Duplicate records) vì script Python không xoá/merge đè trạng thái cũ. Mặc dù `staging` có deduplicate, nhưng storage raw bị dư thừa phi lý.
- **Production Readiness Gaps**: 
  - Xử lý lỗi (Error handling) trong Python script không có (không có try-catch blocks) để bắt Exception như request timeout, API HTTP 50x errors.
  - Không có Pin versions package ngặt nghèo trong `requirements.txt` (vd thiếu `pandas==2.1.0`), có thể gây phá vỡ code ở production.
  - Thiếu Alerting & Retry limits nếu pipeline fails.
- **Data Quality Gaps**: Custom Checks rất sơ sài (chỉ check Null, Unique, và số record > 0). Không có Data Quality Contract phức tạp như: Distribution analysis, Anomaly Detection (như lệch 50% row volume so với hôm trước), hay format schemas.
- **Observability**: Bài học có nhắc đến Bruin Cloud GUI, nhưng thiếu setup Metrics/Logs streaming export đến Datadog, Prometheus hoặc external dashboards.

═══════════════════════════════
6. KIẾN THỨC NGOÀI REPO (Dành cho Senior DE)
═══════════════════════════════
**Senior DE phải biết nhưng repo KHÔNG dạy:**
- **Bruin / Data Platform concepts**: CI/CD Workflows để deploy pipeline tự động bằng GitHub Actions (version control code assets). Setup RBAC (Role-Based Access Control) trên các data artifacts/workspaces.
- **Pipeline orchestration nâng cao**: Event-driven pipelines (Kích hoạt bằng File Drop ở S3 / Kafka stream thay vì time-based cron). Quản lý Cross-Pipeline dependencies (Pipeline B chỉ bắt đầu khi Pipeline A thành công). Pattern Scale-Out, xử lý concurrency. Resource memory limit config.
- **Data quality & testing**: Áp dụng Data Contracts (schema evolution handling). Unit testing & Mocking data cho logic pipelines bằng `pytest` trước khi chạy real execution. Thực thi Circuit Breakers (dừng pipeline toàn phần nếu Data Quality giảm xuống ngưỡng thảm họa).
- **Cloud / infrastructure**: Sử dụng Infrastructure As Code (Terraform) để provisioning resources và cloud roles tự động trước khi deploy. Phân bổ kiến trúc theo các Lakehouse open-table formats (Apache Iceberg / Delta Lake) thay vì chỉ nhúng vào local DuckDB / raw Postgres.
- **MCP & AI-assisted tooling**: Rủi ro của AI Agents, Prompt Injection, và Hallucination trên pipeline syntax. Yêu cầu Senior DE phải review/audit mã logic nghiêm ngặt đối với DAGs và materialization logic sinh ra từ AI, tránh Data loss do nhầm lẫn logic `DELETE`.
