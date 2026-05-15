# repo_notes_M08 - Module 08: Cohorts, Projects & Course Assets

Nguồn đọc: `cohorts/`, `projects/`, `images/`, và `README.md` root để xác định nơi asset được tham chiếu.

Module 08 là meta/support module. Nó không thay thế các module kỹ thuật 01-07. Mục tiêu của notes này là giải thích phần course wrapper: lịch sử cohorts, homework/workshop/project theo năm, final project rubric/datasets, và static assets.

## 1. CẤU TRÚC THƯ MỤC

```text
cohorts/
  2022/
    README.md
    project.md
    week_1_basics_n_setup/homework.md
    week_2_data_ingestion/
      README.md
      homework/homework.md
      homework/solution.py
      transfer_service/README.md
      airflow/
        .env_example
        1_setup_official.md
        2_setup_nofrills.md
        README.md
        Dockerfile
        docker-compose.yaml
        docker-compose-nofrills.yml
        docker-compose_2.3.4.yaml
        requirements.txt
        scripts/entrypoint.sh
        dags/data_ingestion_gcs_dag.py
        dags_local/data_ingestion_local.py
        dags_local/ingest_script.py
        extras/data_ingestion_gcs_dag_ex2.py
        extras/web_to_gcs.sh
        docs/1_concepts.md
        docs/arch-diag-airflow.png
        docs/gcs_ingestion_dag.png
    week_3_data_warehouse/airflow/
      .env_example
      1_setup_official.md
      2_setup_nofrills.md
      README.md
      docker-compose.yaml
      docker-compose-nofrills.yml
      scripts/entrypoint.sh
      dags/gcs_to_bq_dag.py
      docs/gcs_2_bq_dag_graph_view.png
      docs/gcs_2_bq_dag_tree_view.png
    week_5_batch_processing/homework.md
    week_6_stream_processing/homework.md
  2023/
    README.md
    project.md
    leaderboard.md
    week_1_docker_sql/homework.md
    week_1_terraform/homework.md
    week_2_workflow_orchestration/README.md
    week_2_workflow_orchestration/homework.md
    week_3_data_warehouse/homework.md
    week_4_analytics_engineering/homework.md
    week_5_batch_processing/homework.md
    week_6_stream_processing/
      homework.md
      client.properties
      settings.py
      producer_confluent.py
      streaming_confluent.py
      spark-submit.sh
    workshops/piperider.md
  2024/
    README.md
    project.md
    leaderboard.md
    01-docker-terraform/homework.md
    01-docker-terraform/solutions.md
    02-workflow-orchestration/README.md
    02-workflow-orchestration/homework.md
    03-data-warehouse/homework.md
    04-analytics-engineering/homework.md
    05-batch/homework.md
    06-streaming/homework.md
    06-streaming/docker-compose.yml
    workshops/dlt.md
    workshops/rising-wave.md
    workshops/dlt_resources/
      data_ingestion_workshop.md
      workshop.ipynb
      homework_starter.ipynb
      homework_solution.ipynb
      incremental_loading.png
  2025/
    README.md
    project.md
    01-docker-terraform/homework.md
    02-workflow-orchestration/
      README.md
      homework.md
      flows/*.yaml
      images/homework.png
    03-data-warehouse/
      homework.md
      load_yellow_taxi_data.py
      DLT_upload_to_GCP.ipynb
    04-analytics-engineering/homework.md
    04-analytics-engineering/homework_q2.png
    05-batch/homework.md
    06-streaming/homework.md
    06-streaming/homework/homework.ipynb
    workshops/
      dynamic_load_dlt.py
      dlt/README.md
      dlt/data_ingestion_workshop.md
      dlt/dlt_homework.md
      dlt/img/*.png|*.jpg
  2026/
    README.md
    project.md
    01-docker-terraform/homework.md
    02-workflow-orchestration/homework.md
    03-data-warehouse/
      homework.md
      load_yellow_taxi_data.py
      DLT_upload_to_GCP.ipynb
    04-analytics-engineering/homework.md
    05-data-platforms/homework.md
    06-batch/homework.md
    07-streaming/homework.md
    workshops/dlt.md
    workshops/dlt/
      README.md
      dlt_homework.md
      pyproject.toml
      open_library_pipeline.py
      analysis.py
      dlt_Pipeline_Overview.ipynb
      images/etl_diagram.png

projects/
  README.md
  datasets.md

images/
  bruin.svg
  dlthub.png
  kestra.svg
  mage.svg
  piperider.png
  rising-wave.png
  architecture/
    arch_v3_workshops.jpg
    arch_v4_workshops.jpg
    arch_v5_workshops.png
    photo1700757552.jpeg
  aws/
    iam.png
```

### Vai trò từng folder

| Folder | Vai trò |
|---|---|
| `cohorts/2022` | Cohort cũ theo week. Có Airflow setup/examples cho ingestion và data warehouse. |
| `cohorts/2023` | Cohort theo week. Có Prefect-era workflow docs, leaderboard/project, và streaming Confluent/Spark example. |
| `cohorts/2024` | Bắt đầu tổ chức theo module number. Có Mage docs, dlt/RisingWave workshops, leaderboard, solutions cho module 1. |
| `cohorts/2025` | Module-based. Có Kestra flow YAML rất quan trọng, DLT/GCS helper, dlt workshop, streaming notebook. |
| `cohorts/2026` | Cohort mới nhất trong repo. Có `05-data-platforms`, `07-streaming`, dlt workshop cập nhật theo hướng AI-assisted ingestion. |
| `projects/` | Final project rubric, dataset suggestions, peer review, reproducibility và portfolio guidance. |
| `images/` | Static assets dùng bởi README/cohort docs: architecture overview, logos, cloud screenshots. Không có business logic. |

### Các asset được README root tham chiếu

- `README.md` dùng `/images/architecture/arch_v5_workshops.png` làm overview image.
- `README.md` sponsor/supporter section dùng `images/kestra.svg`, `images/bruin.svg`, `images/dlthub.png`.
- `cohorts/2022/week_2_data_ingestion/transfer_service/README.md` tham chiếu `../../images/aws/iam.png`; relative path này đáng review vì từ vị trí file đó có thể không trỏ đúng về root `images/`.

## 2. NỘI DUNG CÁC FILE .MD

### Root/projects

#### `projects/README.md`
- Vai trò: final project requirements/rubric.
- Dạy về: capstone project end-to-end data pipeline.
- Concepts chính: problem statement, batch vs stream decision, cloud/IaC, orchestration, DWH, transformations, dashboard, reproducibility, peer review.
- Commands được dùng: docs nhắc reviewer nên chạy `docker compose up`; dbt projects cần `dbt deps` nếu dùng packages.
- Dataset/service liên quan: chọn dataset bất kỳ, nhưng không được dùng NYC taxi dataset của course.
- Câu hỏi/project chính: build dashboard tối thiểu 2 tiles từ pipeline tự chọn.
- Lưu ý đặc biệt: peer review 3 projects; plagiarism/reuse prohibited; project nên là repo riêng có README tốt.

#### `projects/datasets.md`
- Vai trò: dataset suggestions.
- Dạy về: nơi tìm dataset cho final project.
- Concepts chính: Kaggle, AWS Open Data, UK open data, GitHub Archive, BigQuery public datasets, streaming datasets, Open Food Facts, Binance public data, NOAA weather.
- Lưu ý đặc biệt: không bắt buộc dùng dataset trong list; có thể dùng dataset khác.

### Cohorts root files

#### `cohorts/2022/README.md`
- Vai trò: landing page cho 2022 cohort.
- Dạy về: course schedule/links của cohort 2022.
- Concepts chính: cohort archive, week-based course organization.

#### `cohorts/2022/project.md`
- Vai trò: 2022 project submission.
- Dạy về: submission attempts cho project cohort 2022.
- Concepts chính: project attempts, submission forms, peer review context.

#### `cohorts/2023/README.md`
- Vai trò: 2023 cohort landing.
- Dạy về: Data Engineering Zoomcamp 2023 course map.
- Concepts chính: week-based modules, project link.

#### `cohorts/2023/project.md`
- Vai trò: 2023 project submission/evaluation.
- Concepts chính: project attempts, review links, evaluation criteria, hash email helper.

#### `cohorts/2023/leaderboard.md`
- Vai trò: showcase/leaderboard of projects.
- Concepts chính: learner project gallery, GitHub/LinkedIn links, project references.

#### `cohorts/2024/README.md`
- Vai trò: 2024 cohort landing.
- Concepts chính: module-based naming, project link.

#### `cohorts/2024/project.md`
- Vai trò: 2024 project submission.
- Concepts chính: two attempts, peer review required, links to project/review forms.

#### `cohorts/2024/leaderboard.md`
- Vai trò: 2024 project leaderboard.

#### `cohorts/2025/README.md`
- Vai trò: 2025 cohort landing.
- Concepts chính: module-based current-ish path, project link.

#### `cohorts/2025/project.md`
- Vai trò: 2025 project submission.
- Concepts chính: two attempts, peer review links, link to `../../projects/README.md`.

#### `cohorts/2026/README.md`
- Vai trò: 2026 cohort landing.
- Concepts chính: latest cohort in this repo, links to module homework and project.

#### `cohorts/2026/project.md`
- Vai trò: 2026 project submission.
- Concepts chính: two attempts, peer review links, link to common `projects/README.md`.

### Homework docs by topic

| Path pattern | Vai trò | Topic |
|---|---|---|
| `cohorts/2022/week_1_basics_n_setup/homework.md` | homework | GCP SDK, Terraform, Postgres SQL with taxi data. |
| `cohorts/2022/week_2_data_ingestion/homework/homework.md` | homework | Airflow DAGs for yellow taxi, FHV, zones. |
| `cohorts/2022/week_5_batch_processing/homework.md` | homework | Spark/PySpark with HVFHW data. |
| `cohorts/2022/week_6_stream_processing/homework.md` | homework | stream processing assignment for old course. |
| `cohorts/2023/week_1_docker_sql/homework.md` | homework | Docker tags, Postgres, SQL over taxi data. |
| `cohorts/2023/week_1_terraform/homework.md` | homework | Terraform resources. |
| `cohorts/2023/week_2_workflow_orchestration/homework.md` | homework | Prefect/GCP/BigQuery/deployments/secrets. |
| `cohorts/2023/week_3_data_warehouse/homework.md` | homework | BigQuery warehouse questions. |
| `cohorts/2023/week_4_analytics_engineering/homework.md` | homework | dbt models, variables, macros, taxi analytics. |
| `cohorts/2023/week_5_batch_processing/homework.md` | homework | Spark batch processing. |
| `cohorts/2023/week_6_stream_processing/homework.md` | homework | Kafka/Spark streaming. |
| `cohorts/2024/01-docker-terraform/homework.md` | homework | Docker/SQL/Terraform module 1. |
| `cohorts/2024/01-docker-terraform/solutions.md` | solution | solutions for Docker/SQL/Terraform questions. |
| `cohorts/2024/02-workflow-orchestration/homework.md` | homework | Mage workflow orchestration. |
| `cohorts/2024/03-data-warehouse/homework.md` | homework | BigQuery homework. |
| `cohorts/2024/04-analytics-engineering/homework.md` | homework | dbt homework. |
| `cohorts/2024/05-batch/homework.md` | homework | Spark homework. |
| `cohorts/2024/06-streaming/homework.md` | homework | Redpanda/PySpark streaming homework. |
| `cohorts/2025/01-docker-terraform/homework.md` | homework | Docker networking, Postgres, Terraform. |
| `cohorts/2025/02-workflow-orchestration/homework.md` | homework | Kestra orchestration quiz/questions. |
| `cohorts/2025/03-data-warehouse/homework.md` | homework | BigQuery data warehouse. |
| `cohorts/2025/04-analytics-engineering/homework.md` | homework | dbt lineage, variables, macros, revenue SQL. |
| `cohorts/2025/05-batch/homework.md` | homework | Spark with Yellow October 2024. |
| `cohorts/2025/06-streaming/homework.md` | homework | Redpanda, Kafka producer, sessionization. |
| `cohorts/2026/01-docker-terraform/homework.md` | homework | Docker images/networking, SQL, Terraform, learning in public. |
| `cohorts/2026/02-workflow-orchestration/homework.md` | homework | orchestration homework, learning in public prompts. |
| `cohorts/2026/03-data-warehouse/homework.md` | homework | BigQuery records, storage estimation, partitioning/clustering. |
| `cohorts/2026/04-analytics-engineering/homework.md` | homework | dbt lineage/tests, revenue, FHV staging model. |
| `cohorts/2026/05-data-platforms/homework.md` | homework | Bruin pipeline structure, materialization, variables, quality, lineage. |
| `cohorts/2026/06-batch/homework.md` | homework | Spark with Yellow November 2025. |
| `cohorts/2026/07-streaming/homework.md` | homework | Redpanda + PyFlink tumbling/session windows. |

### Workshop docs

| Path | Vai trò | Nội dung chính |
|---|---|---|
| `cohorts/2023/workshops/piperider.md` | workshop | dbt model change confidence with PipeRider, homework questions. |
| `cohorts/2024/workshops/dlt.md` | workshop | dlt data ingestion, generator exercises, merge/append homework. |
| `cohorts/2024/workshops/rising-wave.md` | workshop | RisingWave stream processing homework. |
| `cohorts/2024/workshops/dlt_resources/data_ingestion_workshop.md` | workshop material | API extraction, memory control, generators, dlt concepts. |
| `cohorts/2025/workshops/dlt/README.md` | workshop | data ingestion with dlt, navigation/resources/homework. |
| `cohorts/2025/workshops/dlt/data_ingestion_workshop.md` | workshop material | REST APIs, rate limits, pipeline concepts. |
| `cohorts/2025/workshops/dlt/dlt_homework.md` | homework | dlt version, NYC Taxi API, DuckDB exploration, trip duration. |
| `cohorts/2026/workshops/dlt.md` | workshop landing | From APIs to Warehouses: AI-Assisted Data Ingestion with dlt. |
| `cohorts/2026/workshops/dlt/README.md` | workshop | Open Library API, dlt MCP/agentic IDE, uv/Python setup. |
| `cohorts/2026/workshops/dlt/dlt_homework.md` | homework | build own dlt pipeline with API source and agent prompt. |

## 3. PHÂN TÍCH CODE FILES & CONFIGS

### Python files

#### `cohorts/2022/week_2_data_ingestion/homework/solution.py`
- Mục đích: helper/solution script cho homework week 2.
- Role: đọc trong context Airflow ingestion homework.
- Risk: không nên dùng như production code.

#### `cohorts/2022/week_2_data_ingestion/airflow/dags/data_ingestion_gcs_dag.py`
- Mục đích: Airflow DAG ingest yellow taxi CSV -> Parquet -> GCS -> BigQuery external table.
- Inputs/env vars: `GCP_PROJECT_ID`, `GCP_GCS_BUCKET`, `AIRFLOW_HOME`, `BIGQUERY_DATASET`.
- Libraries: Airflow DAG/operators, `google.cloud.storage`, `pyarrow.csv`, `pyarrow.parquet`.
- Data source: `https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv`.
- Sink: `gs://<bucket>/raw/yellow_tripdata_2021-01.parquet` and BigQuery external table.
- Logic:
  1. `BashOperator` downloads CSV with `curl`.
  2. `PythonOperator` converts CSV to Parquet.
  3. `PythonOperator` uploads Parquet to GCS.
  4. `BigQueryCreateExternalTableOperator` creates external table.
- Flow: `download_dataset_task >> format_to_parquet_task >> local_to_gcs_task >> bigquery_external_table_task`.
- Raw excerpt:

```python
PROJECT_ID = os.environ.get("GCP_PROJECT_ID")
BUCKET = os.environ.get("GCP_GCS_BUCKET")

dataset_file = "yellow_tripdata_2021-01.csv"
dataset_url = f"https://s3.amazonaws.com/nyc-tlc/trip+data/{dataset_file}"
path_to_local_home = os.environ.get("AIRFLOW_HOME", "/opt/airflow/")
parquet_file = dataset_file.replace('.csv', '.parquet')
BIGQUERY_DATASET = os.environ.get("BIGQUERY_DATASET", 'trips_data_all')
```

```python
download_dataset_task >> format_to_parquet_task >> local_to_gcs_task >> bigquery_external_table_task
```

#### `cohorts/2022/week_3_data_warehouse/airflow/dags/gcs_to_bq_dag.py`
- Mục đích: Airflow DAG move files in GCS and create BigQuery external/native partitioned tables.
- Inputs/env vars: `GCP_PROJECT_ID`, `GCP_GCS_BUCKET`, `BIGQUERY_DATASET`.
- Libraries/operators: `BigQueryCreateExternalTableOperator`, `BigQueryInsertJobOperator`, `GCSToGCSOperator`.
- Data source: GCS raw parquet files under `raw/{colour}_tripdata*.parquet`.
- Sink: moved objects under `yellow/` or `green/`; BigQuery external table and partitioned native table.
- Logic:
  1. Loop over `COLOUR_RANGE = {'yellow': 'tpep_pickup_datetime', 'green': 'lpep_pickup_datetime'}`.
  2. Move raw files to color-specific GCS prefix.
  3. Create external table.
  4. Create partitioned BigQuery table with `PARTITION BY DATE(...)`.
- Raw excerpt:

```python
CREATE_BQ_TBL_QUERY = (
    f"CREATE OR REPLACE TABLE {BIGQUERY_DATASET}.{colour}_{DATASET} \
    PARTITION BY DATE({ds_col}) \
    AS \
    SELECT * FROM {BIGQUERY_DATASET}.{colour}_{DATASET}_external_table;"
)
```

#### `cohorts/2023/week_6_stream_processing/producer_confluent.py`
- Mục đích: Confluent Kafka producer for green/FHV taxi CSV rows.
- Inputs: CLI arg `--type` (`green` default, `fhv` optional).
- Libraries: `confluent_kafka.Producer`, `argparse`, `csv`.
- Source: `GREEN_TRIP_DATA_PATH` or `FHV_TRIP_DATA_PATH`.
- Sink: `GREEN_TAXI_TOPIC` or `FHV_TAXI_TOPIC`.
- Logic: parse row -> key/value -> `producer.produce(topic=..., key=..., value=...)` -> flush.
- Raw excerpt:

```python
if self.ride_type == 'green':
    record = f'{row[5]}, {row[6]}'  # PULocationID, DOLocationID
    key = str(row[0])  # vendor_id
elif self.ride_type == 'fhv':
    record = f'{row[3]}, {row[4]}'  # PULocationID, DOLocationID,
    key = str(row[0])  # dispatching_base_num
```

#### `cohorts/2023/week_6_stream_processing/streaming_confluent.py`
- Mục đích: Spark Structured Streaming job reading green/FHV topics, writing to `all_rides`, then reading and aggregating by pickup location.
- Libraries: `pyspark.sql.SparkSession`, `pyspark.sql.functions`.
- Source topics: `GREEN_TAXI_TOPIC`, `FHV_TAXI_TOPIC`, then `RIDES_TOPIC`.
- Sink: Kafka topic `RIDES_TOPIC` and console.
- Security: uses `SASL_SSL` and JAAS config with values from `CONFLUENT_CLOUD_CONFIG`.
- Raw excerpt:

```python
df_stream = spark \
    .readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", CONFLUENT_CLOUD_CONFIG['bootstrap.servers']) \
    .option("subscribe", consume_topic) \
    .option("startingOffsets", "earliest") \
    .option("checkpointLocation", "checkpoint") \
    .option("kafka.security.protocol", "SASL_SSL") \
    .option("kafka.sasl.mechanism", "PLAIN") \
    .option("failOnDataLoss", False) \
    .load()
```

#### `cohorts/2023/week_6_stream_processing/settings.py`
- Mục đích: constants and Confluent config reader.
- Important constants: `RIDES_TOPIC = 'all_rides'`, `FHV_TAXI_TOPIC = 'fhv_taxi_rides'`, `GREEN_TAXI_TOPIC = 'green_taxi_rides'`.
- Risk: references `client_original.properties`; listed file is `client.properties`, so review actual local config names before running.

#### `cohorts/2025/03-data-warehouse/load_yellow_taxi_data.py` and `cohorts/2026/03-data-warehouse/load_yellow_taxi_data.py`
- Mục đích: download yellow taxi parquet files and upload to GCS.
- Source: `https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-`.
- Months: `01` to `06`.
- Sink: GCS bucket `dezoomcamp_hw3_2025`.
- Libraries: `urllib.request`, `ThreadPoolExecutor`, `google.cloud.storage`.
- Security gap: hardcoded `BUCKET_NAME = "dezoomcamp_hw3_2025"` and `CREDENTIALS_FILE = "gcs.json"`.
- Reliability: retries upload up to 3 times and verifies blob exists.

#### `cohorts/2025/workshops/dynamic_load_dlt.py`
- Mục đích: dynamic dlt load helper for workshop.
- Risk: environment/config handling should be reviewed before production; comments include `project_id = "your project id"`.

#### `cohorts/2026/workshops/dlt/open_library_pipeline.py`
- Mục đích: dlt pipeline for Open Library Search API.
- Source: `https://openlibrary.org/search.json`.
- Resource: `books`, `data_selector = "docs"`, offset paginator.
- Destination: DuckDB, dataset `open_library_data`.
- Raw excerpt:

```python
pipeline = dlt.pipeline(
    pipeline_name="open_library_pipeline",
    destination="duckdb",
    dataset_name="open_library_data",
    progress="log",
)
load_info = pipeline.run(open_library_source(query="harry potter"))
```

#### `cohorts/2026/workshops/dlt/analysis.py`
- Mục đích: marimo app analyzing Open Library Harry Potter books with dlt dataset interface, ibis, altair.
- Inputs: attaches to `open_library_pipeline`.
- Outputs: charts for top authors, books by publication year, languages, summary stats.
- Raw excerpt:

```python
pipeline = dlt.attach("open_library_pipeline")
dataset = pipeline.dataset()
ibis_con = dataset.ibis()
```

### YAML/YML files

#### `cohorts/2025/02-workflow-orchestration/flows/01_getting_started_data_pipeline.yaml`
- Type: Kestra flow.
- id/namespace: `01_getting_started_data_pipeline`, `zoomcamp`.
- Inputs: `columns_to_keep`.
- Tasks: `extract` HTTP download, `transform` Python script, `query` DuckDB query.
- Purpose: first local pipeline showing extract/transform/query.

#### `02_postgres_taxi.yaml`
- Type: Kestra flow to ingest taxi data into Postgres.
- Inputs: `taxi`, `year`, `month`.
- Tasks include: `set_label`, `extract`, conditional branches for yellow/green taxi, create table, create staging table, truncate staging, `CopyIn`, add unique id/filename, merge data, purge files.
- Plugin namespace: `io.kestra.plugin.jdbc.postgresql`.
- Important: uses merge/upsert-style pattern instead of blind append.

#### `02_postgres_taxi_scheduled.yaml`
- Same Postgres taxi ingestion pattern plus schedule triggers for green/yellow.
- Triggers: `green_schedule`, `yellow_schedule`.

#### `03_postgres_dbt.yaml`
- Type: Kestra + dbt CLI flow.
- Tasks: `sync` namespace files from Git, `dbt-build` using `io.kestra.plugin.dbt.cli.DbtCLI`.
- Profile target: Postgres.

#### `04_gcp_kv.yaml`
- Type: Kestra KV setup.
- Tasks set `GCP_PROJECT_ID`, `GCP_LOCATION`, `GCP_BUCKET_NAME`, `GCP_DATASET`.
- Risk: sample values must be replaced; `gcp_project_id` default is placeholder-like `kestra-sandbox`.

#### `05_gcp_setup.yaml`
- Type: GCP infra setup via Kestra plugins.
- Tasks: `create_gcs_bucket`, `create_bq_dataset`.
- Uses `{{kv('GCP_PROJECT_ID')}}`.

#### `06_gcp_taxi.yaml`
- Type: GCS/BigQuery taxi ingestion flow.
- Inputs: `taxi`, `year`, `month`.
- Tasks: extract source file, upload to GCS, create BigQuery tables/external tables/tmp tables, merge yellow/green data.
- External dependencies: GCS, BigQuery, KV values from `04_gcp_kv.yaml`.

#### `06_gcp_taxi_scheduled.yaml`
- Same BigQuery/GCS ingestion plus scheduled triggers.

#### `07_gcp_dbt.yaml`
- Type: dbt CLI on BigQuery.
- Tasks: `sync`, `dbt-build`.
- Profile target: BigQuery using `{{kv('GCP_PROJECT_ID')}}`.

#### `cohorts/2024/06-streaming/docker-compose.yml`
- Type: local streaming support compose.
- Purpose: Redpanda/Kafka-like local service for 2024 streaming homework.

### Shell files

#### `cohorts/2022/week_2_data_ingestion/airflow/scripts/entrypoint.sh`
#### `cohorts/2022/week_3_data_warehouse/airflow/scripts/entrypoint.sh`
- Purpose: Airflow container entrypoint/setup.
- Review for env dependency before running; works as local course setup, not production hardening.

#### `cohorts/2022/week_2_data_ingestion/airflow/extras/web_to_gcs.sh`
- Purpose: shell helper to move web data to GCS.

#### `cohorts/2023/week_6_stream_processing/spark-submit.sh`
- Purpose: submit Spark streaming job with Kafka integration.

### Docker/config/dependency files

#### Airflow 2022 docker-compose files
- `cohorts/2022/week_2_data_ingestion/airflow/docker-compose.yaml`
- `cohorts/2022/week_2_data_ingestion/airflow/docker-compose-nofrills.yml`
- `cohorts/2022/week_2_data_ingestion/airflow/docker-compose_2.3.4.yaml`
- `cohorts/2022/week_3_data_warehouse/airflow/docker-compose.yaml`
- `cohorts/2022/week_3_data_warehouse/airflow/docker-compose-nofrills.yml`
- Purpose: local Airflow stack for old cohort. Includes official and no-frills variants.
- Production gaps: local-only credentials/config, no secret manager, no full observability, fragile volume/path setup on Windows/WSL.

#### `.env_example` files
- `cohorts/2022/week_2_data_ingestion/airflow/.env_example`
- `cohorts/2022/week_3_data_warehouse/airflow/.env_example`
- Purpose: expected env vars for Airflow/GCP.
- Security note: example env files are useful for local setup; real values must not be committed.

#### `cohorts/2023/week_6_stream_processing/client.properties`
- Purpose: Confluent Cloud Kafka client config.
- Security note: do not commit real credentials. The Python settings reader expects Confluent properties.

#### `cohorts/2026/workshops/dlt/pyproject.toml`
- Purpose: Python project metadata/dependencies for 2026 dlt workshop.
- Used by uv/pip workflow in dlt README.

### Notebook files

| Path | Role | Notes |
|---|---|---|
| `cohorts/2024/workshops/dlt_resources/workshop.ipynb` | dlt workshop notebook | Read cells for API/generator/dlt flow; JSON notebook not copied fully. |
| `cohorts/2024/workshops/dlt_resources/homework_starter.ipynb` | starter notebook | Used for dlt homework practice. |
| `cohorts/2024/workshops/dlt_resources/homework_solution.ipynb` | solution notebook | Contains worked dlt homework solution. |
| `cohorts/2025/03-data-warehouse/DLT_upload_to_GCP.ipynb` | DLT/GCP notebook | Demonstrates loading/uploading data for warehouse homework. |
| `cohorts/2025/06-streaming/homework/homework.ipynb` | streaming homework notebook | Supports 2025 streaming homework. |
| `cohorts/2026/03-data-warehouse/DLT_upload_to_GCP.ipynb` | DLT/GCP notebook | Similar role to 2025 version. |
| `cohorts/2026/workshops/dlt/dlt_Pipeline_Overview.ipynb` | dlt workshop overview | References `./images/etl_diagram.png`; includes Open Library API and dlt pipeline exploration. |

Notebook policy for build: do not paste full JSON; summarize markdown/code cells and quote key code cells only.

### Image/binary files

| Path | Role |
|---|---|
| `images/architecture/arch_v5_workshops.png` | Main course overview image in root `README.md`. |
| `images/architecture/arch_v4_workshops.jpg` | Older course architecture/workshop image. |
| `images/architecture/arch_v3_workshops.jpg` | Older course architecture/workshop image. |
| `images/architecture/photo1700757552.jpeg` | Architecture/photo asset. |
| `images/kestra.svg` | Sponsor/tool logo used in root README. |
| `images/bruin.svg` | Sponsor/tool logo used in root README and Data Platforms context. |
| `images/dlthub.png` | Sponsor/tool logo used in root README and dlt workshops. |
| `images/mage.svg` | Mage logo asset for 2024 workflow orchestration context. |
| `images/piperider.png` | Piperider workshop asset. |
| `images/rising-wave.png` | RisingWave workshop asset. |
| `images/aws/iam.png` | AWS IAM screenshot referenced by 2022 transfer service docs. |
| `cohorts/2022/.../docs/*.png` | Airflow DAG/architecture screenshots. |
| `cohorts/2025/02-workflow-orchestration/images/homework.png` | Homework dataset image referenced by 2025/2026 orchestration homework. |
| `cohorts/2026/workshops/dlt/images/etl_diagram.png` | ETL diagram referenced by 2026 dlt notebook. |

## 4. SO SÁNH COHORTS THEO NĂM

| Year | Structure | Stack/tool emphasis | Homework/workshop changes | Read when |
|---|---|---|---|---|
| 2022 | Week-based | Docker, Terraform, Airflow, GCS, BigQuery, Spark, streaming basics | Has old Airflow DAG examples and GCS -> BQ warehouse DAG. | Need Airflow historical material or old homework. |
| 2023 | Week-based | Docker, Terraform, Prefect, BigQuery, dbt, Spark, Confluent/Spark streaming | Adds leaderboard, project showcase, Confluent/Spark streaming files. | Need project examples or Confluent streaming practice. |
| 2024 | Module-based | Docker/Terraform, Mage, BigQuery, dbt, Spark, Redpanda/PySpark, dlt, RisingWave | Module naming introduced; has `solutions.md` for M1; dlt/RisingWave workshops. | Need Mage-era orchestration or 2024 workshop context. |
| 2025 | Module-based | Kestra, BigQuery, dbt, Spark, Redpanda, dlt | Kestra YAML flows are major addition; updated dlt workshop and notebooks. | Need Kestra flow examples and current-ish homework. |
| 2026 | Module-based latest | Kestra/current modules, BigQuery, dbt, Data Platforms/Bruin, Spark, PyFlink/Redpanda, AI-assisted dlt | Adds `05-data-platforms`, updated dlt workshop with Open Library and agentic workflow. | Default choice for latest homework and current path. |

### Course evolution

- Naming evolved from `week_X_*` to `0X-*` module folders.
- Orchestration material evolved across old Airflow, Prefect, Mage, and Kestra eras.
- Workshops evolved from Piperider to dlt/RisingWave to AI-assisted dlt.
- Streaming homework evolved from older stream-processing assignments to Redpanda/PySpark and then PyFlink-style tasks in 2026.
- Final project docs converged around common `projects/README.md`, while each cohort has a `project.md` for submission timing/links.

## 5. FINAL PROJECT & DATASETS

### Project objective

`projects/README.md` says the project goal is to apply course learning to build an end-to-end data pipeline. The problem statement asks for a dashboard with two tiles by selecting a dataset, creating a processing pipeline into a data lake, moving data from lake to warehouse, transforming it, and building a dashboard.

### Dataset rule

The NYC taxi dataset is used throughout modules/homework and cannot be used for final project. Pick another dataset.

### Batch vs stream decision

The project can be stream or batch:
- Stream: consume data in real time and put it to a data lake.
- Batch: run periodically, for example hourly/daily.

### Technologies

The docs allow alternatives:
- Cloud: AWS, GCP, Azure.
- IaC: Terraform, Pulumi, CloudFormation.
- Orchestration: Airflow, Prefect, Luigi.
- DWH: BigQuery, Snowflake, Redshift.
- Batch: Spark, Flink, AWS Batch.
- Stream: Kafka, Pulsar, Kinesis.

If using a tool not covered in course, explain what it does.

### Dashboard requirement

Dashboard should have at least two tiles. Suggested:
- one graph showing distribution of categorical data.
- one graph showing distribution across a temporal line.

### Peer review

To get points, evaluate 3 peer projects. Each evaluation gives 3 extra points.

### Evaluation criteria

| Area | 0 points | 2 points | 4 points |
|---|---|---|---|
| Problem description | Not described | Short/not clear | Clear problem and purpose |
| Cloud | No cloud | Project in cloud | Cloud + IaC |
| Data ingestion batch | No orchestration | Partial orchestration | End-to-end DAG to data lake |
| Data ingestion stream | No streaming | Simple producer/consumer | Streaming tech like Kafka/Spark/Flink |
| Data warehouse | No DWH | Tables created but not optimized | Partitioned/clustered with explanation |
| Transformations | No transformations | Simple SQL | dbt/Spark/similar |
| Dashboard | No dashboard | 1 tile | 2 tiles |
| Reproducibility | No instructions | Incomplete instructions | Clear, easy to run, code works |

### Project quality tips from docs

- Create a new repo with meaningful title.
- Keep README detailed; empty/minimal README may lose points.
- Test from a clean clone.
- Do not hardcode local paths or personal cloud project IDs.
- Handle external API failures.
- Run `docker compose up` at least once before submitting.
- Keep README consistent with code.
- Run `dbt deps` if dbt packages are used.

### Plagiarism/reuse policy

Not allowed:
- taking someone else's notebooks/projects in full or partly.
- reusing own projects from other courses/bootcamps.
- reusing ML Zoomcamp midterm/capstone from previous iterations.

Violation results in 0 points.

### Dataset suggestions

`projects/datasets.md` includes: Kaggle, AWS datasets, UK government open data, GitHub Archive, Awesome Public Datasets, Million Song Dataset, COVID datasets, Azure public datasets, BigQuery public datasets, Google Dataset Search, GCP public datasets, Eurostat, streaming datasets, Santander bicycle rentals, Common Crawl, NASA EarthData, Meta Data for Good, Open Food Facts, Binance Public Data, NOAA weather.

## 6. COURSE ASSETS & IMAGE USAGE

| Asset | Type | Role | Referenced by |
|---|---|---|---|
| `images/architecture/arch_v5_workshops.png` | PNG | Main course overview architecture | root `README.md` first image |
| `images/architecture/arch_v4_workshops.jpg` | JPG | older course/workshop architecture | asset inventory; likely older README/docs |
| `images/architecture/arch_v3_workshops.jpg` | JPG | older course/workshop architecture | asset inventory; likely older README/docs |
| `images/architecture/photo1700757552.jpeg` | JPEG | photo/architecture asset | asset inventory |
| `images/kestra.svg` | SVG | Kestra sponsor/tool logo | root `README.md` |
| `images/bruin.svg` | SVG | Bruin sponsor/tool logo | root `README.md`, Module 05 context |
| `images/dlthub.png` | PNG | dltHub logo | root `README.md`, dlt workshop context |
| `images/mage.svg` | SVG | Mage logo | 2024 workflow/Mage context |
| `images/piperider.png` | PNG | PipeRider logo | 2023 Piperider workshop context |
| `images/rising-wave.png` | PNG | RisingWave logo | 2024 RisingWave workshop context |
| `images/aws/iam.png` | PNG | AWS IAM screenshot | 2022 transfer service README references AWS IAM image |
| `cohorts/2025/02-workflow-orchestration/images/homework.png` | PNG | orchestration homework dataset image | 2025/2026 orchestration homework links |
| `cohorts/2026/workshops/dlt/images/etl_diagram.png` | PNG | ETL diagram | 2026 dlt notebook markdown |

Asset notes:
- Images are static content. Do not treat them as executable or source logic.
- HTML build can show thumbnails with relative paths from repo root if target file sits at repo root.
- If path is suspicious or old docs use relative path crossing, note it instead of silently assuming.

## 7. DATA FLOW THỰC TẾ

### 2022 Airflow ingestion

```text
NYC TLC CSV on S3
  -> BashOperator curl download
  -> pyarrow CSV to Parquet
  -> google-cloud-storage upload to GCS raw/
  -> BigQuery external table
```

Files:
- `cohorts/2022/week_2_data_ingestion/airflow/dags/data_ingestion_gcs_dag.py`
- `cohorts/2022/week_2_data_ingestion/airflow/docker-compose*.yml`
- `.env_example` for env setup

Dependencies:
- Airflow scheduler/webserver/worker stack.
- GCP credentials and bucket.
- BigQuery dataset.

### 2022 Airflow warehouse

```text
GCS raw parquet files
  -> GCSToGCSOperator move to color prefix
  -> BigQuery external table per color
  -> BigQuery native partitioned table
```

Files:
- `cohorts/2022/week_3_data_warehouse/airflow/dags/gcs_to_bq_dag.py`
- `cohorts/2022/week_3_data_warehouse/airflow/docker-compose*.yml`

### 2023 streaming

```text
green/fhv CSV
  -> producer_confluent.py
  -> Confluent Kafka topics green_taxi_rides / fhv_taxi_rides
  -> streaming_confluent.py reads both streams
  -> Kafka topic all_rides
  -> parse all_rides
  -> group by PULocationID
  -> console output
```

Key files:
- `settings.py`: topic constants, schema, Confluent config reader.
- `client.properties`: Confluent Cloud config file.
- `producer_confluent.py`: producer.
- `streaming_confluent.py`: Spark Structured Streaming job.
- `spark-submit.sh`: submission helper.

### 2025 Kestra workflow orchestration

```text
01_getting_started_data_pipeline
  -> HTTP download
  -> Python transform
  -> DuckDB query

02_postgres_taxi / scheduled
  -> download taxi parquet/csv
  -> staging table
  -> CopyIn
  -> merge into final Postgres table

04_gcp_kv
  -> set GCP project/location/bucket/dataset KV
  -> 05_gcp_setup creates GCS bucket + BQ dataset
  -> 06_gcp_taxi uploads taxi data to GCS + BigQuery external/tmp/final tables
  -> 07_gcp_dbt runs dbt on BigQuery
```

### 2025/2026 DLT

```text
API/public source
  -> dlt source/resource
  -> dlt pipeline
  -> DuckDB or GCP destination
  -> notebook/analysis layer
```

2026 concrete example:

```text
Open Library Search API
  -> rest_api_source(resource books)
  -> open_library_pipeline
  -> DuckDB dataset open_library_data
  -> analysis.py with dlt + ibis + altair
```

### Homework/project flow

```text
module root content 01-07
  -> cohort homework for practice
  -> cohort project.md for current-year submission logistics
  -> projects/README.md for general rubric
  -> projects/datasets.md for dataset ideas
  -> portfolio repo outside course repo
```

## 8. ĐIỂM YẾU & THIẾU SÓT

### Security issues

- `cohorts/2025/03-data-warehouse/load_yellow_taxi_data.py` hardcodes `BUCKET_NAME` and `CREDENTIALS_FILE = "gcs.json"`.
- 2023 streaming uses Confluent Cloud credentials via properties file; real credentials must never be committed.
- Airflow 2022 relies on local env files and mounted credentials.
- Kestra `04_gcp_kv.yaml` includes placeholder project/bucket/dataset values; users must replace them.

### Idempotency issues

- Airflow ingestion DAG writes fixed object/table names; rerun behavior depends on whether files/tables are overwritten safely.
- 2022 external table creation is simple course code, not a robust production backfill framework.
- Kestra 2025 improves idempotency via staging + merge patterns in Postgres/BigQuery flows.
- GCS loader verifies upload but local reruns can repeat downloads/uploads.

### Production readiness gaps

- Local docker-compose setups lack production-grade secrets, TLS, monitoring, and backup strategy.
- Notebook-based flows are not CI/CD-friendly unless converted into scripts or scheduled jobs.
- Project rubric does not provide a reference implementation/template; learners must design their own structure.
- Cohort docs may point to old tools or versions; context matters.

### Data quality gaps

- Homework prompts often ask analysis questions but do not enforce data contracts.
- Many flows do not include schema validation or null/range checks.
- dbt homework covers tests in later cohorts, but project docs only suggest tests as optional extra mile.

### Observability/testing gaps

- Airflow/Kestra examples focus on local running and teaching concepts; production alerting/log aggregation not fully covered.
- Streaming examples do not provide full lag dashboards/runbooks.
- Notebook reproducibility depends on environment, hidden state, credentials, and package versions.

### Cost/performance gaps

- BigQuery partitioning/clustering appears in homework/project rubric, but full cost governance is outside repo scope.
- Spark/Kafka/Flink tuning is largely outside cohorts materials.
- GCP bucket/BigQuery region/project choices need real cost/IAM planning.

### Documentation/asset gaps

- Same filename `homework.md` appears across years and modules; never cite without full path.
- Some relative image links in old docs may be fragile.
- Images have limited metadata/alt text in asset inventory.

## 9. KIẾN THỨC NGOÀI REPO

Senior Data Engineer should add these beyond Module 08:

- Docker/Terraform production: remote state, modules, plan/apply CI, image scanning, secrets, least privilege IAM.
- Orchestration: Airflow/Kestra internals, backfills, retries, SLA/SLO, event-driven orchestration, idempotency by partition.
- Warehouse: BigQuery internals, partition/clustering strategy, materialized views, access control, cost quotas.
- Analytics engineering: dbt contracts, exposures, semantic layer, snapshots, CI, slim CI, package governance.
- Batch: Spark shuffle, partitioning, file layout, small files, data skew, lakehouse formats.
- Streaming: Kafka internals, consumer groups, schema registry, exactly-once caveats, Flink/Spark state and checkpointing.
- Data quality: Great Expectations/Soda/dbt tests, anomaly detection, schema contracts, quarantine tables.
- Governance: IAM, PII, catalog, lineage, ownership, access review.
- Platform engineering: multi-env, IaC, deployment pipelines, observability, incident response.
- Project delivery: requirements, architecture docs, SLAs, runbooks, demo data, reproducible setup, CI, review evidence.

## Appendix A - File inventory by category

### Markdown documentation

All `.md` files under `cohorts/` were reviewed at heading level. Important heading patterns:
- 2022: `Week 1 Homework`, `Week 2: Data Ingestion`, `Airflow concepts`, `Setup (Official)`, `Setup (No-frills)`, `Week 5 Homework`, `Week 6 Homework`, `Course Project`.
- 2023: `Week 1 Homework`, `Week 2: Workflow Orchestration`, `Week 3 Homework`, `Week 4 Homework`, `Week 5 Homework`, `Week 6 Homework`, `Workshop: ... PipeRider`, `Leaderboard`, `Course Project`.
- 2024: `Module 1 Homework`, `Week 2: Workflow Orchestration`, `Module 3 Homework`, `Module 4 Homework`, `Module 5 Homework`, `Module 6 Homework`, `Data ingestion with dlt`, `Stream processing with RisingWave`.
- 2025: `Workflow Orchestration`, `Module 1-6 Homework`, `Data ingestion with dlt`, `Workshop "Data Ingestion with dlt": Homework`.
- 2026: `Module 1-7 Homework`, `Module 5 Homework: Data Platforms with Bruin`, `From APIs to Warehouses: AI-Assisted Data Ingestion with dlt`, `Build Your Own dlt Pipeline`.

### Code/config files requiring direct inspection before quoting in HTML

If the HTML needs exact code, reopen these source files or quote only from snippets above:

```text
cohorts/2022/week_2_data_ingestion/airflow/dags/data_ingestion_gcs_dag.py
cohorts/2022/week_3_data_warehouse/airflow/dags/gcs_to_bq_dag.py
cohorts/2023/week_6_stream_processing/producer_confluent.py
cohorts/2023/week_6_stream_processing/streaming_confluent.py
cohorts/2023/week_6_stream_processing/settings.py
cohorts/2025/02-workflow-orchestration/flows/*.yaml
cohorts/2025/03-data-warehouse/load_yellow_taxi_data.py
cohorts/2026/03-data-warehouse/load_yellow_taxi_data.py
cohorts/2026/workshops/dlt/open_library_pipeline.py
cohorts/2026/workshops/dlt/analysis.py
cohorts/2026/workshops/dlt/pyproject.toml
```

## Appendix B - Build guidance for Module08_Cohorts_Projects_Assets.html

- Treat Module 08 as a navigation/project-readiness module, not a new engine module.
- Default learner path: use root modules 01-07 plus `cohorts/2026` homework.
- Use old cohorts as historical/reference material:
  - 2022 Airflow.
  - 2023 Confluent/Spark streaming and project leaderboard.
  - 2024 Mage/dlt/RisingWave.
  - 2025 Kestra flows.
- Make `projects/README.md` central for S4 Final Project.
- Make `images/` an asset inventory in S5; do not over-teach images as if they are code.
- For quizzes, ask scenario-based navigation/project questions.
- For review, fact-check paths and year/tool mapping carefully.
