# repo_notes_M02

Tài liệu này tổng hợp **toàn bộ** nội dung được yêu cầu từ thư mục `02-workflow-orchestration/` trong repo `data-engineering-zoomcamp`.

---

═══════════════════════════════
1. CẤU TRÚC THƯ MỤC
═══════════════════════════════

## 1.1 Tree đầy đủ (theo phạm vi đã đọc trong module)

```text
02-workflow-orchestration/
├── docker-compose.yml
├── README.md
├── flows/
│   ├── 01_hello_world.yaml
│   ├── 02_python.yaml
│   ├── 03_getting_started_data_pipeline.yaml
│   ├── 04_postgres_taxi.yaml
│   ├── 05_postgres_taxi_scheduled.yaml
│   ├── 06_gcp_kv.yaml
│   ├── 07_gcp_setup.yaml
│   ├── 08_gcp_taxi.yaml
│   ├── 09_gcp_taxi_scheduled.yaml
│   ├── 10_chat_without_rag.yaml
│   └── 11_chat_with_rag.yaml
└── images/
    └── homework.png
```

## 1.2 Mục đích từng folder/file

- `docker-compose.yml`: Dựng local stack gồm Postgres cho taxi data, pgAdmin, Postgres cho Kestra metadata, Kestra server.
- `README.md`: Tài liệu học Module 2 (khái niệm orchestration, hướng dẫn setup Kestra, ETL/ELT pipelines local + GCP, scheduling/backfill, AI Copilot, RAG).
- `flows/01_hello_world.yaml`: Flow nhập môn Kestra concepts (input, variable, output, trigger, concurrency, pluginDefaults).
- `flows/02_python.yaml`: Chạy Python trong Kestra, gọi DockerHub API và trả output qua `Kestra.outputs()`.
- `flows/03_getting_started_data_pipeline.yaml`: Mini ETL demo: HTTP extract → Python transform → DuckDB query.
- `flows/04_postgres_taxi.yaml`: ETL taxi CSV vào Postgres local (manual run theo taxi/year/month).
- `flows/05_postgres_taxi_scheduled.yaml`: Bản scheduled/backfill của flow Postgres taxi (trigger theo cron).
- `flows/06_gcp_kv.yaml`: Set KV values cho GCP settings trong Kestra.
- `flows/07_gcp_setup.yaml`: Tạo GCS bucket + BigQuery dataset từ KV + secret.
- `flows/08_gcp_taxi.yaml`: ELT taxi lên GCP (GCS + BigQuery), merge theo unique key.
- `flows/09_gcp_taxi_scheduled.yaml`: Bản scheduled/backfill của ELT GCP flow.
- `flows/10_chat_without_rag.yaml`: Demo LLM chat không có retrieval context.
- `flows/11_chat_with_rag.yaml`: Demo RAG ingest docs + chat có context.
- `images/homework.png`: Ảnh minh họa liên quan homework module.

## 1.3 Tool/framework được dùng là gì?

- Orchestration tool chính: **Kestra**.
- Không dùng Airflow/Prefect trong code module này.
- Workflows định nghĩa bằng **YAML** với Kestra plugin types.

## 1.4 Version và stack tổng thể

- Kestra image: `kestra/kestra:v1.1`
- Postgres image: `postgres:18` (2 instance: `pgdatabase` cho taxi data, `kestra_postgres` cho metadata Kestra)
- pgAdmin image: `dpage/pgadmin4`
- Python runtime trong tasks:
  - `python:slim` (flow 02)
  - `python:3.11-alpine` (flow 03)
- Data tooling/plugin stack:
  - Kestra core/log/flow/schedule/kv/secret
  - Kestra shell + Python script tasks
  - JDBC Postgres plugin (`Queries`, `CopyIn`)
  - DuckDB JDBC query task
  - GCP plugins (GCS, BigQuery)
  - AI plugins (Gemini ChatCompletion, RAG Ingest + Chat)

---

═══════════════════════════════
2. TỔNG QUAN WORKFLOW ORCHESTRATION TOOL
═══════════════════════════════

## 2.1 Tool này là gì, cách hoạt động

**Kestra** là open-source orchestration platform theo hướng event-driven + scheduled. Flow được khai báo bằng YAML, gồm các task theo thứ tự/nhánh điều kiện; Kestra runtime thực thi từng task, quản lý execution state, logs, outputs, retries/trigger/schedule.

Cách hoạt động cơ bản trong module này:
1. Define flow YAML (`id`, `namespace`, `inputs`, `variables`, `tasks`, `triggers`, `pluginDefaults`).
2. Import flow vào Kestra.
3. Execute thủ công hoặc bằng schedule trigger.
4. Task dùng output/input/context expressions (`{{ ... }}`) để truyền dữ liệu giữa bước.
5. Kết quả lưu trong execution logs/outputs; có thể purge file làm sạch storage.

## 2.2 Các concept cốt lõi (theo README + flow thực tế)

- **flow**: container orchestration logic (vd `04_postgres_taxi`).
- **task**: đơn vị thực thi (log, shell, python, sql query, upload...).
- **trigger**: tự động chạy flow (vd cron ở `01`, `05`, `09`).
- **schedule**: trigger theo `cron`.
- **namespace**: vùng phân loại flow (`zoomcamp`).
- **input**: tham số runtime (`taxi`, `year`, `month`, `name`, `columns_to_keep`).
- **output**: output từ task dùng cho task sau (`outputs.extract...`, `outputs.generate_output...`).
- **variable**: biến nội bộ flow tái dùng expression (`file`, `table`, `gcs_file`, `data`).
- **secret**: giá trị nhạy cảm, dùng qua `{{secret('GCP_CREDS')}}`.
- **KV store**: key-value config dùng qua `{{kv('GCP_PROJECT_ID')}}`, `{{ kv('GEMINI_API_KEY') }}`.

## 2.3 Khác gì với Airflow / Prefect

Trong phạm vi repo này:
- Kestra dùng YAML declarative, nhẹ phần bootstrapping (đặc biệt cho người mới), task plugin phong phú + expression templating mạnh.
- Airflow thường thiên Python DAG code, scheduler/webserver/worker topology riêng, nhiều setup/ops hơn với người mới.
- Prefect thiên Python-native flow/task definitions, linh hoạt code-first; Kestra ở đây thể hiện flow-as-config mạnh (IaC cho orchestration).
- Kestra trong repo demo rõ cả scheduled và event-like patterns với ít code Python hơn (trừ task script).

## 2.4 docker-compose.yml: services, ports, volumes, env vars — copy nguyên văn

```yaml
volumes:
  ny_taxi_postgres_data:
    driver: local
  kestra_postgres_data:
    driver: local
  kestra_data:
    driver: local
  kestra_tmp:
    driver: local

services:
  pgdatabase:
    image: postgres:18
    environment:
      POSTGRES_USER: root
      POSTGRES_PASSWORD: root
      POSTGRES_DB: ny_taxi
    ports:
      - "5432:5432"
    volumes:
      - ny_taxi_postgres_data:/var/lib/postgresql
    depends_on:
      kestra:
        condition: service_started

  pgadmin:
    image: dpage/pgadmin4
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - "8085:80"
    depends_on:
      pgdatabase:
        condition: service_started

  kestra_postgres:
    image: postgres:18
    volumes:
      - kestra_postgres_data:/var/lib/postgresql
    environment:
      POSTGRES_DB: kestra
      POSTGRES_USER: kestra
      POSTGRES_PASSWORD: k3str4
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
      interval: 30s
      timeout: 10s
      retries: 10

  kestra:
    image: kestra/kestra:v1.1
    pull_policy: always
    # Note that this setup with a root user is intended for development purpose.
    # Our base image runs without root, but the Docker Compose implementation needs root to access the Docker socket
    # To run Kestra in a rootless mode in production, see: https://kestra.io/docs/installation/podman-compose
    user: "root"
    command: server standalone
    volumes:
      - kestra_data:/app/storage
      - /var/run/docker.sock:/var/run/docker.sock
      - kestra_tmp:/tmp/kestra-wd
    environment:
      KESTRA_CONFIGURATION: |
        datasources:
          postgres:
            url: jdbc:postgresql://kestra_postgres:5432/kestra
            driverClassName: org.postgresql.Driver
            username: kestra
            password: k3str4
        kestra:
          server:
            basicAuth:
              username: "admin@kestra.io" # it must be a valid email address
              password: Admin1234!
          repository:
            type: postgres
          storage:
            type: local
            local:
              basePath: "/app/storage"
          queue:
            type: postgres
          tasks:
            tmpDir:
              path: /tmp/kestra-wd/tmp
          url: http://localhost:8080/
    ports:
      - "8080:8080"
      - "8081:8081"
    depends_on:
      kestra_postgres:
        condition: service_started
```

---

═══════════════════════════════
3. PHÂN TÍCH TỪNG FLOW FILE
═══════════════════════════════

## 3.1 `flows/01_hello_world.yaml`

- Mục đích: Flow demo đầy đủ concept Kestra cơ bản.
- Namespace / ID: `zoomcamp` / `01_hello_world`
- Inputs:
  - `name` (STRING, default `Will`)
- Tasks theo thứ tự:
  1. `hello_message` (Log) — log welcome message từ variable.
  2. `generate_output` (Return) — tạo output value.
  3. `sleep` (Sleep) — chờ 15s.
  4. `log_output` (Log) — log output từ task return.
  5. `goodbye_message` (Log) — log goodbye.
- Triggers / Schedule:
  - `schedule` cron `0 10 * * *`, input `name: Sarah`, đang `disabled: true`.
- Variables / Secrets / KV:
  - Variable `welcome_message`; không dùng secret/KV.
- Dependencies giữa tasks:
  - Linear: `hello_message → generate_output → sleep → log_output → goodbye_message`.
- Điểm đáng chú ý:
  - Có `concurrency` limit=2 + behavior FAIL.
  - `pluginDefaults` set level ERROR cho log tasks.

### Copy nguyên văn toàn bộ file

```yaml
id: 01_hello_world
namespace: zoomcamp

inputs:
  - id: name
    type: STRING
    defaults: Will

concurrency:
  behavior: FAIL
  limit: 2

variables:
  welcome_message: "Hello, {{ inputs.name }}!"
  
tasks:
  - id: hello_message
    type: io.kestra.plugin.core.log.Log
    message: "{{ render(vars.welcome_message) }}"
  
  - id: generate_output
    type: io.kestra.plugin.core.debug.Return
    format: I was generated during this workflow.

  - id: sleep
    type: io.kestra.plugin.core.flow.Sleep
    duration: PT15S

  - id: log_output
    type: io.kestra.plugin.core.log.Log
    message: "This is an output: {{ outputs.generate_output.value }}"

  - id: goodbye_message
    type: io.kestra.plugin.core.log.Log
    message: "Goodbye, {{ inputs.name }}!"

pluginDefaults:
  - type: io.kestra.plugin.core.log.Log
    values:
      level: ERROR

triggers:
  - id: schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 10 * * *"
    inputs:
      name: Sarah
    disabled: true
```

---

## 3.2 `flows/02_python.yaml`

- Mục đích: Chạy Python trong container, gọi DockerHub API, trả output về Kestra.
- Namespace / ID: `zoomcamp` / `02_python`
- Inputs: không có.
- Tasks theo thứ tự:
  1. `collect_stats` (Python Script) — gọi `https://hub.docker.com/v2/repositories/kestra/kestra/`, lấy `pull_count`, xuất output `downloads`.
- Triggers / Schedule: không có.
- Variables / Secrets / KV: không dùng.
- Dependencies giữa tasks: 1 task độc lập.
- Điểm đáng chú ý:
  - Dùng `taskRunner` Docker.
  - Cài dependencies runtime: `requests`, `kestra`.
  - Dùng `Kestra.outputs(outputs)` để publish output.

### Copy nguyên văn toàn bộ file

```yaml
id: 02_python
namespace: zoomcamp

description: This flow will install the pip package in a Docker container, and use kestra's Python library to generate outputs (number of downloads of the Kestra Docker image) and metrics (duration of the script).

tasks:
  - id: collect_stats
    type: io.kestra.plugin.scripts.python.Script
    taskRunner:
      type: io.kestra.plugin.scripts.runner.docker.Docker
    containerImage: python:slim
    dependencies:
      - requests
      - kestra
    script: |
      from kestra import Kestra
      import requests
      def get_docker_image_downloads(image_name: str = "kestra/kestra"):
          """Queries the Docker Hub API to get the number of downloads for a specific Docker image."""
          url = f"https://hub.docker.com/v2/repositories/{image_name}/"
          response = requests.get(url)
          data = response.json()
          downloads = data.get('pull_count', 'Not available')
          return downloads
      downloads = get_docker_image_downloads()
      outputs = {
          'downloads': downloads
      }
      Kestra.outputs(outputs)
```

---

## 3.3 `flows/03_getting_started_data_pipeline.yaml`

- Mục đích: Demo pipeline Extract (HTTP) → Transform (Python) → Query (DuckDB).
- Namespace / ID: `zoomcamp` / `03_getting_started_data_pipeline`
- Inputs:
  - `columns_to_keep` (ARRAY<STRING>, default `brand`, `price`)
- Tasks theo thứ tự:
  1. `extract` (HTTP Download) — tải JSON từ `https://dummyjson.com/products`.
  2. `transform` (Python Script) — filter fields theo env `COLUMNS_TO_KEEP`, xuất `products.json`.
  3. `query` (DuckDB Queries) — đọc JSON, tính avg price theo brand.
- Triggers / Schedule: không có.
- Variables / Secrets / KV: không dùng vars/secret/KV.
- Dependencies giữa tasks:
  - `extract → transform → query`.
- Điểm đáng chú ý:
  - Input parameterization rõ ràng, transform dynamic theo list column.
  - Dùng `fetchType: STORE` cho SQL result.

### Copy nguyên văn toàn bộ file

```yaml
id: 03_getting_started_data_pipeline
namespace: zoomcamp

inputs:
  - id: columns_to_keep
    type: ARRAY
    itemType: STRING
    defaults:
      - brand
      - price

tasks:
  - id: extract
    type: io.kestra.plugin.core.http.Download
    uri: https://dummyjson.com/products

  - id: transform
    type: io.kestra.plugin.scripts.python.Script
    containerImage: python:3.11-alpine
    inputFiles:
      data.json: "{{outputs.extract.uri}}"
    outputFiles:
      - "*.json"
    env:
      COLUMNS_TO_KEEP: "{{inputs.columns_to_keep}}"
    script: |
      import json
      import os

      columns_to_keep_str = os.getenv("COLUMNS_TO_KEEP")
      columns_to_keep = json.loads(columns_to_keep_str)

      with open("data.json", "r") as file:
          data = json.load(file)

      filtered_data = [
          {column: product.get(column, "N/A") for column in columns_to_keep}
          for product in data["products"]
      ]

      with open("products.json", "w") as file:
          json.dump(filtered_data, file, indent=4)

  - id: query
    type: io.kestra.plugin.jdbc.duckdb.Queries
    inputFiles:
      products.json: "{{outputs.transform.outputFiles['products.json']}}"
    sql: |
      INSTALL json;
      LOAD json;
      SELECT brand, round(avg(price), 2) as avg_price
      FROM read_json_auto('{{workingDir}}/products.json')
      GROUP BY brand
      ORDER BY avg_price DESC;
    fetchType: STORE
```

---

## 3.4 `flows/04_postgres_taxi.yaml`

- Mục đích: ETL taxi CSV vào Postgres local theo taxi/year/month.
- Namespace / ID: `zoomcamp` / `04_postgres_taxi`
- Inputs:
  - `taxi` (SELECT, values: yellow/green, default yellow)
  - `year` (SELECT, values: 2019/2020, default 2019)
  - `month` (SELECT, values: 01..12, default 01)
- Tasks theo thứ tự:
  1. `set_label`
  2. `extract` (wget + gunzip)
  3. `if_yellow_taxi` nhánh yellow:
     - create final table
     - create staging table
     - truncate staging
     - copy CSV vào staging
     - update unique_row_id + filename
     - merge vào final
  4. `if_green_taxi` nhánh green: logic tương tự với schema green.
  5. `purge_files`
- Triggers / Schedule: không có (manual flow).
- Variables / Secrets / KV:
  - variables `file`, `staging_table`, `table`, `data`.
  - không dùng secret/KV.
- Dependencies giữa tasks:
  - `set_label → extract → (if_yellow_taxi OR if_green_taxi) → purge_files`.
  - Trong mỗi nhánh: create → create_staging → truncate → copyin → update_id → merge.
- Điểm đáng chú ý:
  - Merge theo `unique_row_id` giúp giảm duplicate khi rerun.
  - Plugin defaults chứa DB creds hardcoded (`root/root`).

### Copy nguyên văn toàn bộ file

```yaml
id: 04_postgres_taxi
namespace: zoomcamp
description: |
  The CSV Data used in the course: https://github.com/DataTalksClub/nyc-tlc-data/releases

inputs:
  - id: taxi
    type: SELECT
    displayName: Select taxi type
    values: [yellow, green]
    defaults: yellow

  - id: year
    type: SELECT
    displayName: Select year
    values: ["2019", "2020"]
    defaults: "2019"

  - id: month
    type: SELECT
    displayName: Select month
    values: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    defaults: "01"

variables:
  file: "{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv"
  staging_table: "public.{{inputs.taxi}}_tripdata_staging"
  table: "public.{{inputs.taxi}}_tripdata"
  data: "{{outputs.extract.outputFiles[inputs.taxi ~ '_' ~ 'tripdata_' ~ inputs.year ~ '-' ~ inputs.month ~ '.csv']}}"

tasks:
  - id: set_label
    type: io.kestra.plugin.core.execution.Labels
    labels:
      file: "{{render(vars.file)}}"
      taxi: "{{inputs.taxi}}"

  - id: extract
    type: io.kestra.plugin.scripts.shell.Commands
    outputFiles:
      - "*.csv"
    taskRunner:
      type: io.kestra.plugin.core.runner.Process
    commands:
      - wget -qO- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{{inputs.taxi}}/{{render(vars.file)}}.gz | gunzip > {{render(vars.file)}}

  - id: if_yellow_taxi
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.taxi == 'yellow'}}"
    then:
      - id: yellow_create_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          CREATE TABLE IF NOT EXISTS {{render(vars.table)}} (
              unique_row_id          text,
              filename               text,
              VendorID               text,
              tpep_pickup_datetime   timestamp,
              tpep_dropoff_datetime  timestamp,
              passenger_count        integer,
              trip_distance          double precision,
              RatecodeID             text,
              store_and_fwd_flag     text,
              PULocationID           text,
              DOLocationID           text,
              payment_type           integer,
              fare_amount            double precision,
              extra                  double precision,
              mta_tax                double precision,
              tip_amount             double precision,
              tolls_amount           double precision,
              improvement_surcharge  double precision,
              total_amount           double precision,
              congestion_surcharge   double precision
          );

      - id: yellow_create_staging_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          CREATE TABLE IF NOT EXISTS {{render(vars.staging_table)}} (
              unique_row_id          text,
              filename               text,
              VendorID               text,
              tpep_pickup_datetime   timestamp,
              tpep_dropoff_datetime  timestamp,
              passenger_count        integer,
              trip_distance          double precision,
              RatecodeID             text,
              store_and_fwd_flag     text,
              PULocationID           text,
              DOLocationID           text,
              payment_type           integer,
              fare_amount            double precision,
              extra                  double precision,
              mta_tax                double precision,
              tip_amount             double precision,
              tolls_amount           double precision,
              improvement_surcharge  double precision,
              total_amount           double precision,
              congestion_surcharge   double precision
          );

      - id: yellow_truncate_staging_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          TRUNCATE TABLE {{render(vars.staging_table)}};

      - id: yellow_copy_in_to_staging_table
        type: io.kestra.plugin.jdbc.postgresql.CopyIn
        format: CSV
        from: "{{render(vars.data)}}"
        table: "{{render(vars.staging_table)}}"
        header: true
        columns: [VendorID,tpep_pickup_datetime,tpep_dropoff_datetime,passenger_count,trip_distance,RatecodeID,store_and_fwd_flag,PULocationID,DOLocationID,payment_type,fare_amount,extra,mta_tax,tip_amount,tolls_amount,improvement_surcharge,total_amount,congestion_surcharge]

      - id: yellow_add_unique_id_and_filename
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          UPDATE {{render(vars.staging_table)}}
          SET 
            unique_row_id = md5(
              COALESCE(CAST(VendorID AS text), '') ||
              COALESCE(CAST(tpep_pickup_datetime AS text), '') || 
              COALESCE(CAST(tpep_dropoff_datetime AS text), '') || 
              COALESCE(PULocationID, '') || 
              COALESCE(DOLocationID, '') || 
              COALESCE(CAST(fare_amount AS text), '') || 
              COALESCE(CAST(trip_distance AS text), '')      
            ),
            filename = '{{render(vars.file)}}';

      - id: yellow_merge_data
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          MERGE INTO {{render(vars.table)}} AS T
          USING {{render(vars.staging_table)}} AS S
          ON T.unique_row_id = S.unique_row_id
          WHEN NOT MATCHED THEN
            INSERT (
              unique_row_id, filename, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
              passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID,
              DOLocationID, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount,
              improvement_surcharge, total_amount, congestion_surcharge
            )
            VALUES (
              S.unique_row_id, S.filename, S.VendorID, S.tpep_pickup_datetime, S.tpep_dropoff_datetime,
              S.passenger_count, S.trip_distance, S.RatecodeID, S.store_and_fwd_flag, S.PULocationID,
              S.DOLocationID, S.payment_type, S.fare_amount, S.extra, S.mta_tax, S.tip_amount, S.tolls_amount,
              S.improvement_surcharge, S.total_amount, S.congestion_surcharge
            );

  - id: if_green_taxi
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.taxi == 'green'}}"
    then:
      - id: green_create_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          CREATE TABLE IF NOT EXISTS {{render(vars.table)}} (
              unique_row_id          text,
              filename               text,
              VendorID               text,
              lpep_pickup_datetime   timestamp,
              lpep_dropoff_datetime  timestamp,
              store_and_fwd_flag     text,
              RatecodeID             text,
              PULocationID           text,
              DOLocationID           text,
              passenger_count        integer,
              trip_distance          double precision,
              fare_amount            double precision,
              extra                  double precision,
              mta_tax                double precision,
              tip_amount             double precision,
              tolls_amount           double precision,
              ehail_fee              double precision,
              improvement_surcharge  double precision,
              total_amount           double precision,
              payment_type           integer,
              trip_type              integer,
              congestion_surcharge   double precision
          );

      - id: green_create_staging_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          CREATE TABLE IF NOT EXISTS {{render(vars.staging_table)}} (
              unique_row_id          text,
              filename               text,
              VendorID               text,
              lpep_pickup_datetime   timestamp,
              lpep_dropoff_datetime  timestamp,
              store_and_fwd_flag     text,
              RatecodeID             text,
              PULocationID           text,
              DOLocationID           text,
              passenger_count        integer,
              trip_distance          double precision,
              fare_amount            double precision,
              extra                  double precision,
              mta_tax                double precision,
              tip_amount             double precision,
              tolls_amount           double precision,
              ehail_fee              double precision,
              improvement_surcharge  double precision,
              total_amount           double precision,
              payment_type           integer,
              trip_type              integer,
              congestion_surcharge   double precision
          );

      - id: green_truncate_staging_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          TRUNCATE TABLE {{render(vars.staging_table)}};

      - id: green_copy_in_to_staging_table
        type: io.kestra.plugin.jdbc.postgresql.CopyIn
        format: CSV
        from: "{{render(vars.data)}}"
        table: "{{render(vars.staging_table)}}"
        header: true
        columns: [VendorID,lpep_pickup_datetime,lpep_dropoff_datetime,store_and_fwd_flag,RatecodeID,PULocationID,DOLocationID,passenger_count,trip_distance,fare_amount,extra,mta_tax,tip_amount,tolls_amount,ehail_fee,improvement_surcharge,total_amount,payment_type,trip_type,congestion_surcharge]

      - id: green_add_unique_id_and_filename
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          UPDATE {{render(vars.staging_table)}}
          SET 
            unique_row_id = md5(
              COALESCE(CAST(VendorID AS text), '') ||
              COALESCE(CAST(lpep_pickup_datetime AS text), '') || 
              COALESCE(CAST(lpep_dropoff_datetime AS text), '') || 
              COALESCE(PULocationID, '') || 
              COALESCE(DOLocationID, '') || 
              COALESCE(CAST(fare_amount AS text), '') || 
              COALESCE(CAST(trip_distance AS text), '')      
            ),
            filename = '{{render(vars.file)}}';

      - id: green_merge_data
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          MERGE INTO {{render(vars.table)}} AS T
          USING {{render(vars.staging_table)}} AS S
          ON T.unique_row_id = S.unique_row_id
          WHEN NOT MATCHED THEN
            INSERT (
              unique_row_id, filename, VendorID, lpep_pickup_datetime, lpep_dropoff_datetime,
              store_and_fwd_flag, RatecodeID, PULocationID, DOLocationID, passenger_count,
              trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount, ehail_fee,
              improvement_surcharge, total_amount, payment_type, trip_type, congestion_surcharge
            )
            VALUES (
              S.unique_row_id, S.filename, S.VendorID, S.lpep_pickup_datetime, S.lpep_dropoff_datetime,
              S.store_and_fwd_flag, S.RatecodeID, S.PULocationID, S.DOLocationID, S.passenger_count,
              S.trip_distance, S.fare_amount, S.extra, S.mta_tax, S.tip_amount, S.tolls_amount, S.ehail_fee,
              S.improvement_surcharge, S.total_amount, S.payment_type, S.trip_type, S.congestion_surcharge
            );
  
  - id: purge_files
    type: io.kestra.plugin.core.storage.PurgeCurrentExecutionFiles
    description: This will remove output files. If you'd like to explore Kestra outputs, disable it.

pluginDefaults:
  - type: io.kestra.plugin.jdbc.postgresql
    values:
      url: jdbc:postgresql://pgdatabase:5432/ny_taxi
      username: root
      password: root
```

---

## 3.5 `flows/05_postgres_taxi_scheduled.yaml`

- Mục đích: Scheduled/backfill version cho Postgres taxi pipeline.
- Namespace / ID: `zoomcamp` / `05_postgres_taxi_scheduled`
- Inputs:
  - `taxi` (SELECT, values yellow/green, default yellow)
- Tasks theo thứ tự:
  1. `set_label`
  2. `extract` (file theo `trigger.date`)
  3. `if_yellow_taxi` nhánh ETL yellow
  4. `if_green_taxi` nhánh ETL green
  5. `purge_files`
- Triggers / Schedule:
  - `green_schedule`: cron `0 9 1 * *`, input taxi=green
  - `yellow_schedule`: cron `0 10 1 * *`, input taxi=yellow
- Variables / Secrets / KV:
  - `file`, `staging_table`, `table`, `data` dựa trên `trigger.date`.
- Dependencies giữa tasks:
  - `set_label → extract → conditional branch → purge_files`.
- Điểm đáng chú ý:
  - `concurrency.limit = 1` (tránh chạy chồng).
  - Thiết kế hỗ trợ backfill theo lịch sử tháng thông qua trigger date.

### Copy nguyên văn toàn bộ file

```yaml
id: 05_postgres_taxi_scheduled
namespace: zoomcamp
description: |
  Best to add a label `backfill:true` from the UI to track executions created via a backfill.
  CSV data used here comes from: https://github.com/DataTalksClub/nyc-tlc-data/releases

concurrency:
  limit: 1

inputs:
  - id: taxi
    type: SELECT
    displayName: Select taxi type
    values: [yellow, green]
    defaults: yellow

variables:
  file: "{{inputs.taxi}}_tripdata_{{trigger.date | date('yyyy-MM')}}.csv"
  staging_table: "public.{{inputs.taxi}}_tripdata_staging"
  table: "public.{{inputs.taxi}}_tripdata"
  data: "{{outputs.extract.outputFiles[inputs.taxi ~ '_tripdata_' ~ (trigger.date | date('yyyy-MM')) ~ '.csv']}}"

tasks:
  - id: set_label
    type: io.kestra.plugin.core.execution.Labels
    labels:
      file: "{{render(vars.file)}}"
      taxi: "{{inputs.taxi}}"

  - id: extract
    type: io.kestra.plugin.scripts.shell.Commands
    outputFiles:
      - "*.csv"
    taskRunner:
      type: io.kestra.plugin.core.runner.Process
    commands:
      - wget -qO- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{{inputs.taxi}}/{{render(vars.file)}}.gz | gunzip > {{render(vars.file)}}

  - id: if_yellow_taxi
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.taxi == 'yellow'}}"
    then:
      - id: yellow_create_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          CREATE TABLE IF NOT EXISTS {{render(vars.table)}} (
              unique_row_id          text,
              filename               text,
              VendorID               text,
              tpep_pickup_datetime   timestamp,
              tpep_dropoff_datetime  timestamp,
              passenger_count        integer,
              trip_distance          double precision,
              RatecodeID             text,
              store_and_fwd_flag     text,
              PULocationID           text,
              DOLocationID           text,
              payment_type           integer,
              fare_amount            double precision,
              extra                  double precision,
              mta_tax                double precision,
              tip_amount             double precision,
              tolls_amount           double precision,
              improvement_surcharge  double precision,
              total_amount           double precision,
              congestion_surcharge   double precision
          );

      - id: yellow_create_staging_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          CREATE TABLE IF NOT EXISTS {{render(vars.staging_table)}} (
              unique_row_id          text,
              filename               text,
              VendorID               text,
              tpep_pickup_datetime   timestamp,
              tpep_dropoff_datetime  timestamp,
              passenger_count        integer,
              trip_distance          double precision,
              RatecodeID             text,
              store_and_fwd_flag     text,
              PULocationID           text,
              DOLocationID           text,
              payment_type           integer,
              fare_amount            double precision,
              extra                  double precision,
              mta_tax                double precision,
              tip_amount             double precision,
              tolls_amount           double precision,
              improvement_surcharge  double precision,
              total_amount           double precision,
              congestion_surcharge   double precision
          );

      - id: yellow_truncate_staging_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          TRUNCATE TABLE {{render(vars.staging_table)}};

      - id: yellow_copy_in_to_staging_table
        type: io.kestra.plugin.jdbc.postgresql.CopyIn
        format: CSV
        from: "{{render(vars.data)}}"
        table: "{{render(vars.staging_table)}}"
        header: true
        columns: [VendorID,tpep_pickup_datetime,tpep_dropoff_datetime,passenger_count,trip_distance,RatecodeID,store_and_fwd_flag,PULocationID,DOLocationID,payment_type,fare_amount,extra,mta_tax,tip_amount,tolls_amount,improvement_surcharge,total_amount,congestion_surcharge]

      - id: yellow_add_unique_id_and_filename
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          UPDATE {{render(vars.staging_table)}}
          SET 
            unique_row_id = md5(
              COALESCE(CAST(VendorID AS text), '') ||
              COALESCE(CAST(tpep_pickup_datetime AS text), '') || 
              COALESCE(CAST(tpep_dropoff_datetime AS text), '') || 
              COALESCE(PULocationID, '') || 
              COALESCE(DOLocationID, '') || 
              COALESCE(CAST(fare_amount AS text), '') || 
              COALESCE(CAST(trip_distance AS text), '')      
            ),
            filename = '{{render(vars.file)}}';

      - id: yellow_merge_data
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          MERGE INTO {{render(vars.table)}} AS T
          USING {{render(vars.staging_table)}} AS S
          ON T.unique_row_id = S.unique_row_id
          WHEN NOT MATCHED THEN
            INSERT (
              unique_row_id, filename, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
              passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID,
              DOLocationID, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount,
              improvement_surcharge, total_amount, congestion_surcharge
            )
            VALUES (
              S.unique_row_id, S.filename, S.VendorID, S.tpep_pickup_datetime, S.tpep_dropoff_datetime,
              S.passenger_count, S.trip_distance, S.RatecodeID, S.store_and_fwd_flag, S.PULocationID,
              S.DOLocationID, S.payment_type, S.fare_amount, S.extra, S.mta_tax, S.tip_amount, S.tolls_amount,
              S.improvement_surcharge, S.total_amount, S.congestion_surcharge
            );

  - id: if_green_taxi
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.taxi == 'green'}}"
    then:
      - id: green_create_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          CREATE TABLE IF NOT EXISTS {{render(vars.table)}} (
              unique_row_id          text,
              filename               text,
              VendorID               text,
              lpep_pickup_datetime   timestamp,
              lpep_dropoff_datetime  timestamp,
              store_and_fwd_flag     text,
              RatecodeID             text,
              PULocationID           text,
              DOLocationID           text,
              passenger_count        integer,
              trip_distance          double precision,
              fare_amount            double precision,
              extra                  double precision,
              mta_tax                double precision,
              tip_amount             double precision,
              tolls_amount           double precision,
              ehail_fee              double precision,
              improvement_surcharge  double precision,
              total_amount           double precision,
              payment_type           integer,
              trip_type              integer,
              congestion_surcharge   double precision
          );

      - id: green_create_staging_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          CREATE TABLE IF NOT EXISTS {{render(vars.staging_table)}} (
              unique_row_id          text,
              filename               text,
              VendorID               text,
              lpep_pickup_datetime   timestamp,
              lpep_dropoff_datetime  timestamp,
              store_and_fwd_flag     text,
              RatecodeID             text,
              PULocationID           text,
              DOLocationID           text,
              passenger_count        integer,
              trip_distance          double precision,
              fare_amount            double precision,
              extra                  double precision,
              mta_tax                double precision,
              tip_amount             double precision,
              tolls_amount           double precision,
              ehail_fee              double precision,
              improvement_surcharge  double precision,
              total_amount           double precision,
              payment_type           integer,
              trip_type              integer,
              congestion_surcharge   double precision
          );

      - id: green_truncate_staging_table
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          TRUNCATE TABLE {{render(vars.staging_table)}};

      - id: green_copy_in_to_staging_table
        type: io.kestra.plugin.jdbc.postgresql.CopyIn
        format: CSV
        from: "{{render(vars.data)}}"
        table: "{{render(vars.staging_table)}}"
        header: true
        columns: [VendorID,lpep_pickup_datetime,lpep_dropoff_datetime,store_and_fwd_flag,RatecodeID,PULocationID,DOLocationID,passenger_count,trip_distance,fare_amount,extra,mta_tax,tip_amount,tolls_amount,ehail_fee,improvement_surcharge,total_amount,payment_type,trip_type,congestion_surcharge]

      - id: green_add_unique_id_and_filename
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          UPDATE {{render(vars.staging_table)}}
          SET 
            unique_row_id = md5(
              COALESCE(CAST(VendorID AS text), '') ||
              COALESCE(CAST(lpep_pickup_datetime AS text), '') || 
              COALESCE(CAST(lpep_dropoff_datetime AS text), '') || 
              COALESCE(PULocationID, '') || 
              COALESCE(DOLocationID, '') || 
              COALESCE(CAST(fare_amount AS text), '') || 
              COALESCE(CAST(trip_distance AS text), '')      
            ),
            filename = '{{render(vars.file)}}';

      - id: green_merge_data
        type: io.kestra.plugin.jdbc.postgresql.Queries
        sql: |
          MERGE INTO {{render(vars.table)}} AS T
          USING {{render(vars.staging_table)}} AS S
          ON T.unique_row_id = S.unique_row_id
          WHEN NOT MATCHED THEN
            INSERT (
              unique_row_id, filename, VendorID, lpep_pickup_datetime, lpep_dropoff_datetime,
              store_and_fwd_flag, RatecodeID, PULocationID, DOLocationID, passenger_count,
              trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount, ehail_fee,
              improvement_surcharge, total_amount, payment_type, trip_type, congestion_surcharge
            )
            VALUES (
              S.unique_row_id, S.filename, S.VendorID, S.lpep_pickup_datetime, S.lpep_dropoff_datetime,
              S.store_and_fwd_flag, S.RatecodeID, S.PULocationID, S.DOLocationID, S.passenger_count,
              S.trip_distance, S.fare_amount, S.extra, S.mta_tax, S.tip_amount, S.tolls_amount, S.ehail_fee,
              S.improvement_surcharge, S.total_amount, S.payment_type, S.trip_type, S.congestion_surcharge
            );
  
  - id: purge_files
    type: io.kestra.plugin.core.storage.PurgeCurrentExecutionFiles
    description: To avoid cluttering your storage, we will remove the downloaded files

pluginDefaults:
  - type: io.kestra.plugin.jdbc.postgresql
    values:
      url: jdbc:postgresql://pgdatabase:5432/ny_taxi
      username: root
      password: root

triggers:
  - id: green_schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 1 * *"
    inputs:
      taxi: green

  - id: yellow_schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 10 1 * *"
    inputs:
      taxi: yellow
```

---

## 3.6 `flows/06_gcp_kv.yaml`

- Mục đích: Set KV config cho GCP parameters.
- Namespace / ID: `zoomcamp` / `06_gcp_kv`
- Inputs: không có.
- Tasks theo thứ tự:
  1. `gcp_project_id` (KV Set)
  2. `gcp_location` (KV Set)
  3. `gcp_bucket_name` (KV Set)
  4. `gcp_dataset` (KV Set)
- Triggers / Schedule: không có.
- Variables / Secrets / KV:
  - Ghi vào KV: `GCP_PROJECT_ID`, `GCP_LOCATION`, `GCP_BUCKET_NAME`, `GCP_DATASET`.
- Dependencies giữa tasks:
  - Linear 4 bước set KV.
- Điểm đáng chú ý:
  - Có placeholder TODO values (`kestra-sandbox`, `your-name-kestra`).

### Copy nguyên văn toàn bộ file

```yaml
id: 06_gcp_kv
namespace: zoomcamp

tasks:
  - id: gcp_project_id
    type: io.kestra.plugin.core.kv.Set
    key: GCP_PROJECT_ID
    kvType: STRING
    value: kestra-sandbox # TODO replace with your project id

  - id: gcp_location
    type: io.kestra.plugin.core.kv.Set
    key: GCP_LOCATION
    kvType: STRING
    value: europe-west2

  - id: gcp_bucket_name
    type: io.kestra.plugin.core.kv.Set
    key: GCP_BUCKET_NAME
    kvType: STRING
    value: your-name-kestra # TODO make sure it's globally unique!

  - id: gcp_dataset
    type: io.kestra.plugin.core.kv.Set
    key: GCP_DATASET
    kvType: STRING
    value: zoomcamp
```

---

## 3.7 `flows/07_gcp_setup.yaml`

- Mục đích: Tạo GCS bucket + BigQuery dataset từ KV config.
- Namespace / ID: `zoomcamp` / `07_gcp_setup`
- Inputs: không có.
- Tasks theo thứ tự:
  1. `create_gcs_bucket` (ifExists SKIP)
  2. `create_bq_dataset` (ifExists SKIP)
- Triggers / Schedule: không có.
- Variables / Secrets / KV:
  - Dùng KV: `GCP_BUCKET_NAME`, `GCP_PROJECT_ID`, `GCP_LOCATION`, `GCP_DATASET`.
  - Dùng Secret: `GCP_CREDS`.
- Dependencies giữa tasks:
  - Linear create bucket → create dataset.
- Điểm đáng chú ý:
  - `pluginDefaults` cho toàn bộ plugin `io.kestra.plugin.gcp`.

### Copy nguyên văn toàn bộ file

```yaml
id: 07_gcp_setup
namespace: zoomcamp

tasks:
  - id: create_gcs_bucket
    type: io.kestra.plugin.gcp.gcs.CreateBucket
    ifExists: SKIP
    storageClass: REGIONAL
    name: "{{kv('GCP_BUCKET_NAME')}}" # make sure it's globally unique!

  - id: create_bq_dataset
    type: io.kestra.plugin.gcp.bigquery.CreateDataset
    name: "{{kv('GCP_DATASET')}}"
    ifExists: SKIP

pluginDefaults:
  - type: io.kestra.plugin.gcp
    values:
      serviceAccount: "{{secret('GCP_CREDS')}}"
      projectId: "{{kv('GCP_PROJECT_ID')}}"
      location: "{{kv('GCP_LOCATION')}}"
      bucket: "{{kv('GCP_BUCKET_NAME')}}"
```

---

## 3.8 `flows/08_gcp_taxi.yaml`

- Mục đích: ELT taxi data lên GCP (GCS + BigQuery).
- Namespace / ID: `zoomcamp` / `08_gcp_taxi`
- Inputs:
  - `taxi` (SELECT: yellow/green, default green)
  - `year` (SELECT + allowCustomValue true, default 2019)
  - `month` (SELECT 01..12, default 01)
- Tasks theo thứ tự:
  1. `set_label`
  2. `extract`
  3. `upload_to_gcs`
  4. `if_yellow_taxi`:
     - create main table
     - create external table
     - create monthly tmp table with `unique_row_id`
     - merge to main
  5. `if_green_taxi` tương tự cho green schema.
  6. `purge_files`
- Triggers / Schedule: không có (manual).
- Variables / Secrets / KV:
  - Variables: `file`, `gcs_file`, `table`, `data`.
  - KV: `GCP_PROJECT_ID`, `GCP_DATASET`, `GCP_BUCKET_NAME`, `GCP_LOCATION`.
  - Secret: `GCP_CREDS`.
- Dependencies giữa tasks:
  - `set_label → extract → upload_to_gcs → conditional BQ branch → purge_files`.
- Điểm đáng chú ý:
  - Pattern ELT: file lên GCS trước, rồi BQ external table + transform/merge.
  - Sử dụng `ignore_unknown_values = TRUE` để giảm lỗi schema mismatch một phần.

### Copy nguyên văn toàn bộ file

```yaml
id: 08_gcp_taxi
namespace: zoomcamp
description: |
  The CSV Data used in the course: https://github.com/DataTalksClub/nyc-tlc-data/releases

inputs:
  - id: taxi
    type: SELECT
    displayName: Select taxi type
    values: [yellow, green]
    defaults: green

  - id: year
    type: SELECT
    displayName: Select year
    values: ["2019", "2020"]
    defaults: "2019"
    allowCustomValue: true # allows you to type 2021 from the UI for the homework 🤗

  - id: month
    type: SELECT
    displayName: Select month
    values: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    defaults: "01"

variables:
  file: "{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv"
  gcs_file: "gs://{{kv('GCP_BUCKET_NAME')}}/{{vars.file}}"
  table: "{{kv('GCP_DATASET')}}.{{inputs.taxi}}_tripdata_{{inputs.year}}_{{inputs.month}}"
  data: "{{outputs.extract.outputFiles[inputs.taxi ~ '_tripdata_' ~ inputs.year ~ '-' ~ inputs.month ~ '.csv']}}"

tasks:
  - id: set_label
    type: io.kestra.plugin.core.execution.Labels
    labels:
      file: "{{render(vars.file)}}"
      taxi: "{{inputs.taxi}}"

  - id: extract
    type: io.kestra.plugin.scripts.shell.Commands
    outputFiles:
      - "*.csv"
    taskRunner:
      type: io.kestra.plugin.core.runner.Process
    commands:
      - wget -qO- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{{inputs.taxi}}/{{render(vars.file)}}.gz | gunzip > {{render(vars.file)}}

  - id: upload_to_gcs
    type: io.kestra.plugin.gcp.gcs.Upload
    from: "{{render(vars.data)}}"
    to: "{{render(vars.gcs_file)}}"

  - id: if_yellow_taxi
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.taxi == 'yellow'}}"
    then:
      - id: bq_yellow_tripdata
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE TABLE IF NOT EXISTS `{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.yellow_tripdata`
          (
              unique_row_id BYTES OPTIONS (description = 'A unique identifier for the trip, generated by hashing key trip attributes.'),
              filename STRING OPTIONS (description = 'The source filename from which the trip data was loaded.'),      
              VendorID STRING OPTIONS (description = 'A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc.'),
              tpep_pickup_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was engaged'),
              tpep_dropoff_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was disengaged'),
              passenger_count INTEGER OPTIONS (description = 'The number of passengers in the vehicle. This is a driver-entered value.'),
              trip_distance NUMERIC OPTIONS (description = 'The elapsed trip distance in miles reported by the taximeter.'),
              RatecodeID STRING OPTIONS (description = 'The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride'),
              store_and_fwd_flag STRING OPTIONS (description = 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka "store and forward," because the vehicle did not have a connection to the server. TRUE = store and forward trip, FALSE = not a store and forward trip'),
              PULocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was engaged'),
              DOLocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was disengaged'),
              payment_type INTEGER OPTIONS (description = 'A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip'),
              fare_amount NUMERIC OPTIONS (description = 'The time-and-distance fare calculated by the meter'),
              extra NUMERIC OPTIONS (description = 'Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges'),
              mta_tax NUMERIC OPTIONS (description = '$0.50 MTA tax that is automatically triggered based on the metered rate in use'),
              tip_amount NUMERIC OPTIONS (description = 'Tip amount. This field is automatically populated for credit card tips. Cash tips are not included.'),
              tolls_amount NUMERIC OPTIONS (description = 'Total amount of all tolls paid in trip.'),
              improvement_surcharge NUMERIC OPTIONS (description = '$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015.'),
              total_amount NUMERIC OPTIONS (description = 'The total amount charged to passengers. Does not include cash tips.'),
              congestion_surcharge NUMERIC OPTIONS (description = 'Congestion surcharge applied to trips in congested zones')
          )
          PARTITION BY DATE(tpep_pickup_datetime);

      - id: bq_yellow_table_ext
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE OR REPLACE EXTERNAL TABLE `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}_ext`
          (
              VendorID STRING OPTIONS (description = 'A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc.'),
              tpep_pickup_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was engaged'),
              tpep_dropoff_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was disengaged'),
              passenger_count INTEGER OPTIONS (description = 'The number of passengers in the vehicle. This is a driver-entered value.'),
              trip_distance NUMERIC OPTIONS (description = 'The elapsed trip distance in miles reported by the taximeter.'),
              RatecodeID STRING OPTIONS (description = 'The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride'),
              store_and_fwd_flag STRING OPTIONS (description = 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka "store and forward," because the vehicle did not have a connection to the server. TRUE = store and forward trip, FALSE = not a store and forward trip'),
              PULocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was engaged'),
              DOLocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was disengaged'),
              payment_type INTEGER OPTIONS (description = 'A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip'),
              fare_amount NUMERIC OPTIONS (description = 'The time-and-distance fare calculated by the meter'),
              extra NUMERIC OPTIONS (description = 'Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges'),
              mta_tax NUMERIC OPTIONS (description = '$0.50 MTA tax that is automatically triggered based on the metered rate in use'),
              tip_amount NUMERIC OPTIONS (description = 'Tip amount. This field is automatically populated for credit card tips. Cash tips are not included.'),
              tolls_amount NUMERIC OPTIONS (description = 'Total amount of all tolls paid in trip.'),
              improvement_surcharge NUMERIC OPTIONS (description = '$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015.'),
              total_amount NUMERIC OPTIONS (description = 'The total amount charged to passengers. Does not include cash tips.'),
              congestion_surcharge NUMERIC OPTIONS (description = 'Congestion surcharge applied to trips in congested zones')
          )
          OPTIONS (
              format = 'CSV',
              uris = ['{{render(vars.gcs_file)}}'],
              skip_leading_rows = 1,
              ignore_unknown_values = TRUE
          );

      - id: bq_yellow_table_tmp
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE OR REPLACE TABLE `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}`
          AS
          SELECT
            MD5(CONCAT(
              COALESCE(CAST(VendorID AS STRING), ""),
              COALESCE(CAST(tpep_pickup_datetime AS STRING), ""),
              COALESCE(CAST(tpep_dropoff_datetime AS STRING), ""),
              COALESCE(CAST(PULocationID AS STRING), ""),
              COALESCE(CAST(DOLocationID AS STRING), "")
            )) AS unique_row_id,
            "{{render(vars.file)}}" AS filename,
            *
          FROM `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}_ext`;

      - id: bq_yellow_merge
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          MERGE INTO `{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.yellow_tripdata` T
          USING `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}` S
          ON T.unique_row_id = S.unique_row_id
          WHEN NOT MATCHED THEN
            INSERT (unique_row_id, filename, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount, congestion_surcharge)
            VALUES (S.unique_row_id, S.filename, S.VendorID, S.tpep_pickup_datetime, S.tpep_dropoff_datetime, S.passenger_count, S.trip_distance, S.RatecodeID, S.store_and_fwd_flag, S.PULocationID, S.DOLocationID, S.payment_type, S.fare_amount, S.extra, S.mta_tax, S.tip_amount, S.tolls_amount, S.improvement_surcharge, S.total_amount, S.congestion_surcharge);

  - id: if_green_taxi
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.taxi == 'green'}}"
    then:
      - id: bq_green_tripdata
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE TABLE IF NOT EXISTS `{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.green_tripdata`
          (
              unique_row_id BYTES OPTIONS (description = 'A unique identifier for the trip, generated by hashing key trip attributes.'),
              filename STRING OPTIONS (description = 'The source filename from which the trip data was loaded.'),      
              VendorID STRING OPTIONS (description = 'A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc.'),
              lpep_pickup_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was engaged'),
              lpep_dropoff_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was disengaged'),
              store_and_fwd_flag STRING OPTIONS (description = 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka "store and forward," because the vehicle did not have a connection to the server. Y= store and forward trip N= not a store and forward trip'),
              RatecodeID STRING OPTIONS (description = 'The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride'),
              PULocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was engaged'),
              DOLocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was disengaged'),
              passenger_count INT64 OPTIONS (description = 'The number of passengers in the vehicle. This is a driver-entered value.'),
              trip_distance NUMERIC OPTIONS (description = 'The elapsed trip distance in miles reported by the taximeter.'),
              fare_amount NUMERIC OPTIONS (description = 'The time-and-distance fare calculated by the meter'),
              extra NUMERIC OPTIONS (description = 'Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges'),
              mta_tax NUMERIC OPTIONS (description = '$0.50 MTA tax that is automatically triggered based on the metered rate in use'),
              tip_amount NUMERIC OPTIONS (description = 'Tip amount. This field is automatically populated for credit card tips. Cash tips are not included.'),
              tolls_amount NUMERIC OPTIONS (description = 'Total amount of all tolls paid in trip.'),
              ehail_fee NUMERIC,
              improvement_surcharge NUMERIC OPTIONS (description = '$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015.'),
              total_amount NUMERIC OPTIONS (description = 'The total amount charged to passengers. Does not include cash tips.'),
              payment_type INTEGER OPTIONS (description = 'A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip'),
              trip_type STRING OPTIONS (description = 'A code indicating whether the trip was a street-hail or a dispatch that is automatically assigned based on the metered rate in use but can be altered by the driver. 1= Street-hail 2= Dispatch'),
              congestion_surcharge NUMERIC OPTIONS (description = 'Congestion surcharge applied to trips in congested zones')
          )
          PARTITION BY DATE(lpep_pickup_datetime);

      - id: bq_green_table_ext
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE OR REPLACE EXTERNAL TABLE `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}_ext`
          (
              VendorID STRING OPTIONS (description = 'A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc.'),
              lpep_pickup_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was engaged'),
              lpep_dropoff_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was disengaged'),
              store_and_fwd_flag STRING OPTIONS (description = 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka "store and forward," because the vehicle did not have a connection to the server. Y= store and forward trip N= not a store and forward trip'),
              RatecodeID STRING OPTIONS (description = 'The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride'),
              PULocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was engaged'),
              DOLocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was disengaged'),
              passenger_count INT64 OPTIONS (description = 'The number of passengers in the vehicle. This is a driver-entered value.'),
              trip_distance NUMERIC OPTIONS (description = 'The elapsed trip distance in miles reported by the taximeter.'),
              fare_amount NUMERIC OPTIONS (description = 'The time-and-distance fare calculated by the meter'),
              extra NUMERIC OPTIONS (description = 'Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges'),
              mta_tax NUMERIC OPTIONS (description = '$0.50 MTA tax that is automatically triggered based on the metered rate in use'),
              tip_amount NUMERIC OPTIONS (description = 'Tip amount. This field is automatically populated for credit card tips. Cash tips are not included.'),
              tolls_amount NUMERIC OPTIONS (description = 'Total amount of all tolls paid in trip.'),
              ehail_fee NUMERIC,
              improvement_surcharge NUMERIC OPTIONS (description = '$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015.'),
              total_amount NUMERIC OPTIONS (description = 'The total amount charged to passengers. Does not include cash tips.'),
              payment_type INTEGER OPTIONS (description = 'A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip'),
              trip_type STRING OPTIONS (description = 'A code indicating whether the trip was a street-hail or a dispatch that is automatically assigned based on the metered rate in use but can be altered by the driver. 1= Street-hail 2= Dispatch'),
              congestion_surcharge NUMERIC OPTIONS (description = 'Congestion surcharge applied to trips in congested zones')
          )
          OPTIONS (
              format = 'CSV',
              uris = ['{{render(vars.gcs_file)}}'],
              skip_leading_rows = 1,
              ignore_unknown_values = TRUE
          );

      - id: bq_green_table_tmp
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE OR REPLACE TABLE `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}`
          AS
          SELECT
            MD5(CONCAT(
              COALESCE(CAST(VendorID AS STRING), ""),
              COALESCE(CAST(lpep_pickup_datetime AS STRING), ""),
              COALESCE(CAST(lpep_dropoff_datetime AS STRING), ""),
              COALESCE(CAST(PULocationID AS STRING), ""),
              COALESCE(CAST(DOLocationID AS STRING), "")
            )) AS unique_row_id,
            "{{render(vars.file)}}" AS filename,
            *
          FROM `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}_ext`;

      - id: bq_green_merge
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          MERGE INTO `{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.green_tripdata` T
          USING `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}` S
          ON T.unique_row_id = S.unique_row_id
          WHEN NOT MATCHED THEN
            INSERT (unique_row_id, filename, VendorID, lpep_pickup_datetime, lpep_dropoff_datetime, store_and_fwd_flag, RatecodeID, PULocationID, DOLocationID, passenger_count, trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount, ehail_fee, improvement_surcharge, total_amount, payment_type, trip_type, congestion_surcharge)
            VALUES (S.unique_row_id, S.filename, S.VendorID, S.lpep_pickup_datetime, S.lpep_dropoff_datetime, S.store_and_fwd_flag, S.RatecodeID, S.PULocationID, S.DOLocationID, S.passenger_count, S.trip_distance, S.fare_amount, S.extra, S.mta_tax, S.tip_amount, S.tolls_amount, S.ehail_fee, S.improvement_surcharge, S.total_amount, S.payment_type, S.trip_type, S.congestion_surcharge);

  - id: purge_files
    type: io.kestra.plugin.core.storage.PurgeCurrentExecutionFiles
    description: If you'd like to explore Kestra outputs, disable it.
    disabled: false

pluginDefaults:
  - type: io.kestra.plugin.gcp
    values:
      serviceAccount: "{{secret('GCP_CREDS')}}"
      projectId: "{{kv('GCP_PROJECT_ID')}}"
      location: "{{kv('GCP_LOCATION')}}"
      bucket: "{{kv('GCP_BUCKET_NAME')}}"
```

---

## 3.9 `flows/09_gcp_taxi_scheduled.yaml`

- Mục đích: Scheduled/backfill ELT taxi trên GCP.
- Namespace / ID: `zoomcamp` / `09_gcp_taxi_scheduled`
- Inputs:
  - `taxi` (SELECT, values yellow/green, default green)
- Tasks theo thứ tự:
  1. `set_label`
  2. `extract`
  3. `upload_to_gcs`
  4. `if_yellow_taxi` branch BigQuery yellow
  5. `if_green_taxi` branch BigQuery green
  6. `purge_files`
- Triggers / Schedule:
  - `green_schedule`: cron `0 9 1 * *`, input taxi=green
  - `yellow_schedule`: cron `0 10 1 * *`, input taxi=yellow
- Variables / Secrets / KV:
  - Vars dựa trên `trigger.date`: `file`, `gcs_file`, `table`, `data`.
  - KV + secret như flow 08.
- Dependencies giữa tasks:
  - `set_label → extract → upload_to_gcs → conditional BQ branch → purge_files`.
- Điểm đáng chú ý:
  - Nhắm đến scheduled monthly processing + backfill theo execution date.

### Copy nguyên văn toàn bộ file

```yaml
id: 09_gcp_taxi_scheduled
namespace: zoomcamp
description: |
  Best to add a label `backfill:true` from the UI to track executions created via a backfill.
  CSV data used here comes from: https://github.com/DataTalksClub/nyc-tlc-data/releases

inputs:
  - id: taxi
    type: SELECT
    displayName: Select taxi type
    values: [yellow, green]
    defaults: green

variables:
  file: "{{inputs.taxi}}_tripdata_{{trigger.date | date('yyyy-MM')}}.csv"
  gcs_file: "gs://{{kv('GCP_BUCKET_NAME')}}/{{vars.file}}"
  table: "{{kv('GCP_DATASET')}}.{{inputs.taxi}}_tripdata_{{trigger.date | date('yyyy_MM')}}"
  data: "{{outputs.extract.outputFiles[inputs.taxi ~ '_tripdata_' ~ (trigger.date | date('yyyy-MM')) ~ '.csv']}}"

tasks:
  - id: set_label
    type: io.kestra.plugin.core.execution.Labels
    labels:
      file: "{{render(vars.file)}}"
      taxi: "{{inputs.taxi}}"

  - id: extract
    type: io.kestra.plugin.scripts.shell.Commands
    outputFiles:
      - "*.csv"
    taskRunner:
      type: io.kestra.plugin.core.runner.Process
    commands:
      - wget -qO- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{{inputs.taxi}}/{{render(vars.file)}}.gz | gunzip > {{render(vars.file)}}

  - id: upload_to_gcs
    type: io.kestra.plugin.gcp.gcs.Upload
    from: "{{render(vars.data)}}"
    to: "{{render(vars.gcs_file)}}"

  - id: if_yellow_taxi
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.taxi == 'yellow'}}"
    then:
      - id: bq_yellow_tripdata
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE TABLE IF NOT EXISTS `{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.yellow_tripdata`
          (
              unique_row_id BYTES OPTIONS (description = 'A unique identifier for the trip, generated by hashing key trip attributes.'),
              filename STRING OPTIONS (description = 'The source filename from which the trip data was loaded.'),      
              VendorID STRING OPTIONS (description = 'A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc.'),
              tpep_pickup_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was engaged'),
              tpep_dropoff_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was disengaged'),
              passenger_count INTEGER OPTIONS (description = 'The number of passengers in the vehicle. This is a driver-entered value.'),
              trip_distance NUMERIC OPTIONS (description = 'The elapsed trip distance in miles reported by the taximeter.'),
              RatecodeID STRING OPTIONS (description = 'The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride'),
              store_and_fwd_flag STRING OPTIONS (description = 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka "store and forward," because the vehicle did not have a connection to the server. TRUE = store and forward trip, FALSE = not a store and forward trip'),
              PULocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was engaged'),
              DOLocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was disengaged'),
              payment_type INTEGER OPTIONS (description = 'A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip'),
              fare_amount NUMERIC OPTIONS (description = 'The time-and-distance fare calculated by the meter'),
              extra NUMERIC OPTIONS (description = 'Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges'),
              mta_tax NUMERIC OPTIONS (description = '$0.50 MTA tax that is automatically triggered based on the metered rate in use'),
              tip_amount NUMERIC OPTIONS (description = 'Tip amount. This field is automatically populated for credit card tips. Cash tips are not included.'),
              tolls_amount NUMERIC OPTIONS (description = 'Total amount of all tolls paid in trip.'),
              improvement_surcharge NUMERIC OPTIONS (description = '$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015.'),
              total_amount NUMERIC OPTIONS (description = 'The total amount charged to passengers. Does not include cash tips.'),
              congestion_surcharge NUMERIC OPTIONS (description = 'Congestion surcharge applied to trips in congested zones')
          )
          PARTITION BY DATE(tpep_pickup_datetime);

      - id: bq_yellow_table_ext
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE OR REPLACE EXTERNAL TABLE `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}_ext`
          (
              VendorID STRING OPTIONS (description = 'A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc.'),
              tpep_pickup_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was engaged'),
              tpep_dropoff_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was disengaged'),
              passenger_count INTEGER OPTIONS (description = 'The number of passengers in the vehicle. This is a driver-entered value.'),
              trip_distance NUMERIC OPTIONS (description = 'The elapsed trip distance in miles reported by the taximeter.'),
              RatecodeID STRING OPTIONS (description = 'The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride'),
              store_and_fwd_flag STRING OPTIONS (description = 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka "store and forward," because the vehicle did not have a connection to the server. TRUE = store and forward trip, FALSE = not a store and forward trip'),
              PULocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was engaged'),
              DOLocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was disengaged'),
              payment_type INTEGER OPTIONS (description = 'A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip'),
              fare_amount NUMERIC OPTIONS (description = 'The time-and-distance fare calculated by the meter'),
              extra NUMERIC OPTIONS (description = 'Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges'),
              mta_tax NUMERIC OPTIONS (description = '$0.50 MTA tax that is automatically triggered based on the metered rate in use'),
              tip_amount NUMERIC OPTIONS (description = 'Tip amount. This field is automatically populated for credit card tips. Cash tips are not included.'),
              tolls_amount NUMERIC OPTIONS (description = 'Total amount of all tolls paid in trip.'),
              improvement_surcharge NUMERIC OPTIONS (description = '$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015.'),
              total_amount NUMERIC OPTIONS (description = 'The total amount charged to passengers. Does not include cash tips.'),
              congestion_surcharge NUMERIC OPTIONS (description = 'Congestion surcharge applied to trips in congested zones')
          )
          OPTIONS (
              format = 'CSV',
              uris = ['{{render(vars.gcs_file)}}'],
              skip_leading_rows = 1,
              ignore_unknown_values = TRUE
          );

      - id: bq_yellow_table_tmp
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE OR REPLACE TABLE `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}`
          AS
          SELECT
            MD5(CONCAT(
              COALESCE(CAST(VendorID AS STRING), ""),
              COALESCE(CAST(tpep_pickup_datetime AS STRING), ""),
              COALESCE(CAST(tpep_dropoff_datetime AS STRING), ""),
              COALESCE(CAST(PULocationID AS STRING), ""),
              COALESCE(CAST(DOLocationID AS STRING), "")
            )) AS unique_row_id,
            "{{render(vars.file)}}" AS filename,
            *
          FROM `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}_ext`;

      - id: bq_yellow_merge
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          MERGE INTO `{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.yellow_tripdata` T
          USING `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}` S
          ON T.unique_row_id = S.unique_row_id
          WHEN NOT MATCHED THEN
            INSERT (unique_row_id, filename, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount, congestion_surcharge)
            VALUES (S.unique_row_id, S.filename, S.VendorID, S.tpep_pickup_datetime, S.tpep_dropoff_datetime, S.passenger_count, S.trip_distance, S.RatecodeID, S.store_and_fwd_flag, S.PULocationID, S.DOLocationID, S.payment_type, S.fare_amount, S.extra, S.mta_tax, S.tip_amount, S.tolls_amount, S.improvement_surcharge, S.total_amount, S.congestion_surcharge);

  - id: if_green_taxi
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.taxi == 'green'}}"
    then:
      - id: bq_green_tripdata
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE TABLE IF NOT EXISTS `{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.green_tripdata`
          (
              unique_row_id BYTES OPTIONS (description = 'A unique identifier for the trip, generated by hashing key trip attributes.'),
              filename STRING OPTIONS (description = 'The source filename from which the trip data was loaded.'),      
              VendorID STRING OPTIONS (description = 'A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc.'),
              lpep_pickup_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was engaged'),
              lpep_dropoff_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was disengaged'),
              store_and_fwd_flag STRING OPTIONS (description = 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka "store and forward," because the vehicle did not have a connection to the server. Y= store and forward trip N= not a store and forward trip'),
              RatecodeID STRING OPTIONS (description = 'The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride'),
              PULocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was engaged'),
              DOLocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was disengaged'),
              passenger_count INT64 OPTIONS (description = 'The number of passengers in the vehicle. This is a driver-entered value.'),
              trip_distance NUMERIC OPTIONS (description = 'The elapsed trip distance in miles reported by the taximeter.'),
              fare_amount NUMERIC OPTIONS (description = 'The time-and-distance fare calculated by the meter'),
              extra NUMERIC OPTIONS (description = 'Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges'),
              mta_tax NUMERIC OPTIONS (description = '$0.50 MTA tax that is automatically triggered based on the metered rate in use'),
              tip_amount NUMERIC OPTIONS (description = 'Tip amount. This field is automatically populated for credit card tips. Cash tips are not included.'),
              tolls_amount NUMERIC OPTIONS (description = 'Total amount of all tolls paid in trip.'),
              ehail_fee NUMERIC,
              improvement_surcharge NUMERIC OPTIONS (description = '$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015.'),
              total_amount NUMERIC OPTIONS (description = 'The total amount charged to passengers. Does not include cash tips.'),
              payment_type INTEGER OPTIONS (description = 'A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip'),
              trip_type STRING OPTIONS (description = 'A code indicating whether the trip was a street-hail or a dispatch that is automatically assigned based on the metered rate in use but can be altered by the driver. 1= Street-hail 2= Dispatch'),
              congestion_surcharge NUMERIC OPTIONS (description = 'Congestion surcharge applied to trips in congested zones')
          )
          PARTITION BY DATE(lpep_pickup_datetime);

      - id: bq_green_table_ext
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE OR REPLACE EXTERNAL TABLE `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}_ext`
          (
              VendorID STRING OPTIONS (description = 'A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc.'),
              lpep_pickup_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was engaged'),
              lpep_dropoff_datetime TIMESTAMP OPTIONS (description = 'The date and time when the meter was disengaged'),
              store_and_fwd_flag STRING OPTIONS (description = 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka "store and forward," because the vehicle did not have a connection to the server. Y= store and forward trip N= not a store and forward trip'),
              RatecodeID STRING OPTIONS (description = 'The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride'),
              PULocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was engaged'),
              DOLocationID STRING OPTIONS (description = 'TLC Taxi Zone in which the taximeter was disengaged'),
              passenger_count INT64 OPTIONS (description = 'The number of passengers in the vehicle. This is a driver-entered value.'),
              trip_distance NUMERIC OPTIONS (description = 'The elapsed trip distance in miles reported by the taximeter.'),
              fare_amount NUMERIC OPTIONS (description = 'The time-and-distance fare calculated by the meter'),
              extra NUMERIC OPTIONS (description = 'Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges'),
              mta_tax NUMERIC OPTIONS (description = '$0.50 MTA tax that is automatically triggered based on the metered rate in use'),
              tip_amount NUMERIC OPTIONS (description = 'Tip amount. This field is automatically populated for credit card tips. Cash tips are not included.'),
              tolls_amount NUMERIC OPTIONS (description = 'Total amount of all tolls paid in trip.'),
              ehail_fee NUMERIC,
              improvement_surcharge NUMERIC OPTIONS (description = '$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015.'),
              total_amount NUMERIC OPTIONS (description = 'The total amount charged to passengers. Does not include cash tips.'),
              payment_type INTEGER OPTIONS (description = 'A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip'),
              trip_type STRING OPTIONS (description = 'A code indicating whether the trip was a street-hail or a dispatch that is automatically assigned based on the metered rate in use but can be altered by the driver. 1= Street-hail 2= Dispatch'),
              congestion_surcharge NUMERIC OPTIONS (description = 'Congestion surcharge applied to trips in congested zones')
          )
          OPTIONS (
              format = 'CSV',
              uris = ['{{render(vars.gcs_file)}}'],
              skip_leading_rows = 1,
              ignore_unknown_values = TRUE
          );

      - id: bq_green_table_tmp
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          CREATE OR REPLACE TABLE `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}`
          AS
          SELECT
            MD5(CONCAT(
              COALESCE(CAST(VendorID AS STRING), ""),
              COALESCE(CAST(lpep_pickup_datetime AS STRING), ""),
              COALESCE(CAST(lpep_dropoff_datetime AS STRING), ""),
              COALESCE(CAST(PULocationID AS STRING), ""),
              COALESCE(CAST(DOLocationID AS STRING), "")
            )) AS unique_row_id,
            "{{render(vars.file)}}" AS filename,
            *
          FROM `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}_ext`;

      - id: bq_green_merge
        type: io.kestra.plugin.gcp.bigquery.Query
        sql: |
          MERGE INTO `{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.green_tripdata` T
          USING `{{kv('GCP_PROJECT_ID')}}.{{render(vars.table)}}` S
          ON T.unique_row_id = S.unique_row_id
          WHEN NOT MATCHED THEN
            INSERT (unique_row_id, filename, VendorID, lpep_pickup_datetime, lpep_dropoff_datetime, store_and_fwd_flag, RatecodeID, PULocationID, DOLocationID, passenger_count, trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount, ehail_fee, improvement_surcharge, total_amount, payment_type, trip_type, congestion_surcharge)
            VALUES (S.unique_row_id, S.filename, S.VendorID, S.lpep_pickup_datetime, S.lpep_dropoff_datetime, S.store_and_fwd_flag, S.RatecodeID, S.PULocationID, S.DOLocationID, S.passenger_count, S.trip_distance, S.fare_amount, S.extra, S.mta_tax, S.tip_amount, S.tolls_amount, S.ehail_fee, S.improvement_surcharge, S.total_amount, S.payment_type, S.trip_type, S.congestion_surcharge);

  - id: purge_files
    type: io.kestra.plugin.core.storage.PurgeCurrentExecutionFiles
    description: To avoid cluttering your storage, we will remove the downloaded files

pluginDefaults:
  - type: io.kestra.plugin.gcp
    values:
      serviceAccount: "{{secret('GCP_CREDS')}}"
      projectId: "{{kv('GCP_PROJECT_ID')}}"
      location: "{{kv('GCP_LOCATION')}}"
      bucket: "{{kv('GCP_BUCKET_NAME')}}"

triggers:
  - id: green_schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 1 * *"
    inputs:
      taxi: green

  - id: yellow_schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 10 1 * *"
    inputs:
      taxi: yellow
```

---

## 3.10 `flows/10_chat_without_rag.yaml`

- Mục đích: Demo trả lời LLM không có retrieval context.
- Namespace / ID: `zoomcamp` / `10_chat_without_rag`
- Inputs: không có.
- Tasks theo thứ tự:
  1. `chat_without_rag` (AI ChatCompletion Gemini)
  2. `log_results` (log kết quả)
- Triggers / Schedule: không có.
- Variables / Secrets / KV:
  - KV: `GEMINI_API_KEY`.
- Dependencies giữa tasks:
  - `chat_without_rag → log_results`.
- Điểm đáng chú ý:
  - Prompt hỏi feature Kestra 1.1 để so sánh chất lượng với flow RAG.

### Copy nguyên văn toàn bộ file

```yaml
id: 10_chat_without_rag
namespace: zoomcamp

description: |
  This flow demonstrates what happens when you query an LLM WITHOUT RAG.
  The model can only rely on its training data, which may be outdated or incomplete.
  
  After running this, check out 11_chat_with_rag.yaml to see how RAG fixes these issues.

tasks:
  - id: chat_without_rag
    type: io.kestra.plugin.ai.completion.ChatCompletion
    description: Query about Kestra 1.1 features WITHOUT RAG
    provider:
      type: io.kestra.plugin.ai.provider.GoogleGemini
      modelName: gemini-2.5-flash
      apiKey: "{{ kv('GEMINI_API_KEY') }}"
    messages:
      - type: USER
        content: |
          Which features were released in Kestra 1.1? 
          Please list at least 5 major features with brief descriptions.

  - id: log_results
    type: io.kestra.plugin.core.log.Log
    message: |
      ❌ Response WITHOUT RAG (no retrieved context):
      {{ outputs.chat_without_rag.textOutput }}
      
      🤔 Did you notice that this response seems to be:
      - Incorrect
      - Vague/generic
      - Listing features that haven't been added in exactly this version but rather a long time ago
      
      👉 This is why context matters. Run `11_chat_with_rag.yaml` to see the accurate, context-grounded response.
```

---

## 3.11 `flows/11_chat_with_rag.yaml`

- Mục đích: Demo RAG ingest release notes + chat có grounding.
- Namespace / ID: `zoomcamp` / `11_chat_with_rag`
- Inputs: không có.
- Tasks theo thứ tự:
  1. `ingest_release_notes` (RAG IngestDocument)
  2. `chat_with_rag` (RAG ChatCompletion)
  3. `log_results`
- Triggers / Schedule: không có.
- Variables / Secrets / KV:
  - KV: `GEMINI_API_KEY`.
  - Embeddings store: `KestraKVStore`.
- Dependencies giữa tasks:
  - `ingest_release_notes → chat_with_rag → log_results`.
- Điểm đáng chú ý:
  - `drop: true` reset embeddings trước ingest.
  - Nguồn context từ URL markdown release notes Kestra 1.1.

### Copy nguyên văn toàn bộ file

```yaml
id: 11_chat_with_rag
namespace: zoomcamp

description: |
  This flow demonstrates RAG (Retrieval Augmented Generation) by ingesting Kestra release documentation and using it to answer questions accurately.
  
  Compare this with 10_chat_without_rag.yaml to see the difference RAG makes.

tasks:
  - id: ingest_release_notes
    type: io.kestra.plugin.ai.rag.IngestDocument
    description: Ingest Kestra 1.1 release notes to create embeddings
    provider:
      type: io.kestra.plugin.ai.provider.GoogleGemini
      modelName: gemini-embedding-001
      apiKey: "{{ kv('GEMINI_API_KEY') }}"
    embeddings:
      type: io.kestra.plugin.ai.embeddings.KestraKVStore
    drop: true
    fromExternalURLs:
      - https://raw.githubusercontent.com/kestra-io/docs/refs/heads/main/src/contents/blogs/release-1-1/index.md

  - id: chat_with_rag
    type: io.kestra.plugin.ai.rag.ChatCompletion
    description: Query about Kestra 1.1 features with RAG context
    chatProvider:
      type: io.kestra.plugin.ai.provider.GoogleGemini
      modelName: gemini-2.5-flash
      apiKey: "{{ kv('GEMINI_API_KEY') }}"
    embeddingProvider:
      type: io.kestra.plugin.ai.provider.GoogleGemini
      modelName: gemini-embedding-001
      apiKey: "{{ kv('GEMINI_API_KEY') }}"
    embeddings:
      type: io.kestra.plugin.ai.embeddings.KestraKVStore
    systemMessage: |
      You are a helpful assistant that answers questions about Kestra.
      Use the provided documentation to give accurate, specific answers.
      If you don't find the information in the context, say so.
    prompt: |
      Which features were released in Kestra 1.1? 
      Please list at least 5 major features with brief descriptions.

  - id: log_results
    type: io.kestra.plugin.core.log.Log
    message: |
      ✅ RAG Response (with retrieved context):
      {{ outputs.chat_with_rag.textOutput }}
      
      Note that this response is detailed, accurate, and grounded in the actual release documentation. Compare this with the output from 06_chat_without_rag.yaml.
```

---

═══════════════════════════════
4. DATA FLOW THỰC TẾ
═══════════════════════════════

## 4.1 Flow tổng: data đi từ đâu → qua đâu → đến đâu

Có 3 nhóm chính:

1. **Learning/demo flows**
   - 01: Input string → log/output.
   - 02: DockerHub API → Python → Kestra output.
   - 03: DummyJSON API → Python transform → DuckDB query.

2. **Taxi ETL local (Postgres)**
   - GitHub releases (CSV .gz) → shell wget+gunzip → staging table Postgres → add hash key → MERGE vào final table.

3. **Taxi ELT cloud (GCP)**
   - GitHub releases (CSV .gz) → local file (Kestra execution) → upload GCS → BigQuery external table → monthly transformed table (hash key) → MERGE vào partitioned final table.

4. **AI/RAG flows**
   - Không RAG: prompt trực tiếp LLM.
   - Có RAG: ingest release notes URL → embeddings KV store → retrieval+chat.

## 4.2 Flow nào gọi/kế thừa flow nào

- Không có subflow call (`Flow` task) giữa các file.
- “Kế thừa logic” theo nghĩa pattern:
  - `05` kế thừa pattern từ `04` + thêm trigger schedule.
  - `09` kế thừa pattern từ `08` + thêm trigger schedule theo `trigger.date`.

## 4.3 Thứ tự học/chạy đúng (01 → 11)

1. 01_hello_world
2. 02_python
3. 03_getting_started_data_pipeline
4. 04_postgres_taxi
5. 05_postgres_taxi_scheduled
6. 06_gcp_kv
7. 07_gcp_setup
8. 08_gcp_taxi
9. 09_gcp_taxi_scheduled
10. 10_chat_without_rag
11. 11_chat_with_rag

## 4.4 Dependency giữa các flow (flow nào cần chạy trước)

- `05` cần logic/schema của `04` (không technical hard dependency, nhưng conceptual + same DB tables).
- `07` phụ thuộc KV đã set ở `06` và secret `GCP_CREDS` có sẵn.
- `08` phụ thuộc hạ tầng GCP đã sẵn sàng (thường chạy `06` rồi `07` trước).
- `09` phụ thuộc giống `08` + flow logic GCP đã validated.
- `10`/`11` phụ thuộc `GEMINI_API_KEY` trong KV.

## 4.5 Taxi pipeline end-to-end: download → postgres → GCP

- **Postgres path (ETL)**:
  1. Download file `.csv.gz` từ release GitHub.
  2. Gunzip thành `.csv`.
  3. Create final + staging table.
  4. Truncate staging.
  5. Copy CSV vào staging.
  6. Tạo `unique_row_id` bằng hash cột business.
  7. MERGE from staging vào final.

- **GCP path (ELT)**:
  1. Download + gunzip CSV.
  2. Upload CSV lên GCS.
  3. BigQuery external table trỏ vào file GCS.
  4. Create monthly table + generate `unique_row_id`.
  5. MERGE monthly table vào main partitioned table.

## 4.6 Scheduled flows hoạt động thế nào so với manual trigger

- Manual (04/08): user chọn input `taxi/year/month` trong UI rồi execute.
- Scheduled (05/09): `cron` tự chạy theo lịch tháng, file/table derive từ `trigger.date`.
- Backfill: chạy lịch sử bằng cơ chế backfill của Kestra UI, thường gắn label để tracking.

---

═══════════════════════════════
5. PHÂN TÍCH CODE LOGIC
═══════════════════════════════

## 5.1 Pattern lặp lại giữa flows (DRY violations?)

- SQL schemas yellow/green lặp lại lớn ở 04, 05, 08, 09.
- Download command `wget ... | gunzip` lặp ở 04,05,08,09.
- Merge logic lặp theo từng taxi type.
- Có thể refactor bằng subflow/template/macros nếu muốn giảm duplication.

## 5.2 Cách handle credentials/secrets

- **Không tốt (dev/demo):**
  - `docker-compose.yml` hardcode basic auth Kestra, Postgres credentials.
  - `04/05` hardcode DB creds ở `pluginDefaults`.
- **Tốt hơn:**
  - GCP dùng `secret('GCP_CREDS')` + KV settings.
  - Gemini API key đọc từ KV (`GEMINI_API_KEY`).

## 5.3 Cách handle idempotency

- Có idempotency tương đối qua:
  - `MERGE ... WHEN NOT MATCHED` theo `unique_row_id`.
  - `TRUNCATE staging` trước load (Postgres).
  - `CREATE TABLE IF NOT EXISTS` (main tables).
- Rủi ro còn lại:
  - Nếu business key hash không đủ uniqueness thật sự có thể collision/duplicate semantics.
  - Không thấy explicit uniqueness constraint/index trên `unique_row_id`.

## 5.4 Error handling trong flows

- Hầu như không có error handling tường minh (retry policy/alert/on-failure branches).
- Phụ thuộc default failure behavior của task runner.
- Không có dead-letter, fallback, hoặc compensating actions.

## 5.5 Cách parameterize flows (inputs vs hardcode)

- Dùng inputs tốt cho taxi/year/month.
- Scheduled flows dùng `trigger.date` làm tham số thời gian.
- Nhưng nhiều giá trị vẫn hardcode:
  - URL pattern data source,
  - cron schedule,
  - nhiều schema SQL dài inline.

## 5.6 Python scripts inline vs external scripts

- Hiện tại dùng **inline script** (`02`, `03`) để dễ học và self-contained.
- Ưu: nhanh demo, nhìn toàn bộ logic trong một file YAML.
- Nhược: khó maintain/test/version khi script dài hoặc reusable.

---

═══════════════════════════════
6. ĐIỂM YẾU & THIẾU SÓT
═══════════════════════════════

## 6.1 Security issues

- Hardcode credentials trong `docker-compose.yml` và `pluginDefaults` Postgres (root/root, admin/Admin1234!).
- README có ví dụ curl chứa credentials plaintext.
- Rủi ro lộ thông tin nếu copy config lên môi trường shared.

## 6.2 Idempotency issues

- MERGE giảm duplicate nhưng phụ thuộc hash key tự xây dựng.
- Không có ràng buộc unique index/constraint để enforce tuyệt đối ở DB.
- Không có checksum/manifest để xác nhận file đầy đủ trước load.

## 6.3 Production readiness gaps

- Stack chạy single-node standalone Kestra.
- Không có cấu hình HA, worker scaling, queue tuning production.
- Không có môi trường phân tách dev/stage/prod trong flow definitions.

## 6.4 Observability / monitoring gaps

- Không có metrics pipeline-level (latency, row counts, SLA).
- Không có alerting integration (Slack/PagerDuty/email).
- Logging chủ yếu task log cơ bản.

## 6.5 Error handling gaps

- Không thấy retry/backoff per task.
- Không có branching xử lý data quality lỗi.
- Không có cleanup/rollback strategy khi lỗi giữa chừng (ngoài purge files).

## 6.6 Những gì repo dạy nhưng không đủ cho Senior DE

- Dạy tốt baseline orchestration, nhưng thiếu sâu về:
  - production operations,
  - governance,
  - testing chiến lược,
  - cost/SLA management,
  - multi-team workflow standards.

---

═══════════════════════════════
7. KIẾN THỨC NGOÀI REPO
═══════════════════════════════

Dựa trên phạm vi repo cover, các concept Senior DE cần biết thêm:

## 7.1 Workflow Orchestration nâng cao

- Dynamic task mapping/fan-out-fan-in quy mô lớn.
- Multi-tenant namespace governance + RBAC strategy.
- DAG versioning, rollout strategy, backward compatibility.
- Exactly-once/at-least-once orchestration semantics.
- Event-driven architecture với message bus (Kafka/PubSub) tích hợp orchestration.

## 7.2 Data pipeline patterns

- CDC pipelines (Debezium, log-based change capture).
- Incremental watermarking & late-arriving data handling.
- SCD Type 1/2 chuẩn hóa cho warehouse.
- Bronze/Silver/Gold lakehouse layering.
- Data contracts + schema evolution strategy.

## 7.3 Scheduling & trigger patterns

- Calendar exceptions (holiday schedules), business calendars.
- Dependency-based triggers cross-pipeline.
- Dataset availability triggers + freshness checks.
- Backfill windows với concurrency + quota guardrails.

## 7.4 GCP integration production-grade

- Workload Identity thay cho key file secrets.
- Service account least privilege IAM design.
- BigQuery cost optimization (partition, clustering, materialization).
- GCS lifecycle policy, object versioning, retention compliance.

## 7.5 Observability & alerting

- Centralized metrics (Prometheus/OpenTelemetry/Cloud Monitoring).
- Data quality checks (null rates, schema drift, distribution drift).
- SLA/SLO dashboards + incident playbooks.
- Alert routing + on-call escalation.

## 7.6 Testing flows

- Unit tests cho transformation logic.
- Integration tests với ephemeral infra.
- Contract tests giữa source–pipeline–warehouse.
- Replay tests cho backfill/idempotency.
- Canary execution trước rollout production.

---

═══════════════════════════════
8. SO SÁNH VỚI MODULE 01
═══════════════════════════════

## 8.1 Module 01 (plain Python) vs Module 02 (orchestration tool)

- **M01**: script-centric, tự quản lý execution order/logging/schedule bên ngoài script.
- **M02 (Kestra)**: flow-centric, orchestration/scheduling/traceability nằm trong platform.

Trade-offs:
- M01 đơn giản, linh hoạt code nhanh nhưng khó scale operations.
- M02 chuẩn hóa vận hành tốt hơn nhưng yêu cầu học framework + YAML/plugins.

## 8.2 Những vấn đề của M01 mà M02 giải quyết được

- Quản lý dependencies giữa step rõ ràng trong flow.
- Scheduling/backfill có sẵn qua trigger + UI.
- Execution history, logs, labels tập trung.
- Tích hợp nhiều hệ (Postgres, GCS, BigQuery, AI) theo plugin.

## 8.3 Những vấn đề M02 vẫn chưa giải quyết

- Production-grade security/secret management vẫn còn hạn chế trong sample.
- Observability và alerting nâng cao chưa được cover đầy đủ.
- Testing strategy pipeline chưa được chuẩn hóa.
- DRY và maintainability chưa tối ưu (nhiều SQL duplication).

---

## Ghi chú quan trọng về độ trung thực nội dung

- Tài liệu đã bao gồm đầy đủ nội dung nguyên văn của:
  - `docker-compose.yml`
  - toàn bộ 11 flow YAML files trong `flows/`
- `README.md` đã được đọc toàn bộ để phục vụ phân tích, nhưng không chép full vào đây nhằm giữ file notes tập trung theo đúng 8 mục yêu cầu.