# repo_notes_M03

═══════════════════════════════
1. CẤU TRÚC THƯ MỤC
═══════════════════════════════

```text
03-data-warehouse/
├── README.md
├── big_query.sql
├── big_query_hw.sql
├── big_query_ml.sql
├── extract_model.md
└── extras/
    ├── .env-example
    ├── .gitignore
    ├── README.md
    ├── pyproject.toml
    ├── web_to_gcs.py
    └── web_to_gcs_with_progress_bar.py
```

## Mục đích từng folder/file

- `03-data-warehouse/`: module về Data Warehouse và BigQuery trong zoomcamp.
- `03-data-warehouse/README.md`: entrypoint tài liệu module, link video/slides/sql/homework/community notes.
- `03-data-warehouse/big_query.sql`: demo core BigQuery flow (external table, non-partitioned table, partition+cluster table, query comparison).
- `03-data-warehouse/big_query_hw.sql`: script bài tập/homework về external table, partitioning, clustering và kiểm tra partition metadata.
- `03-data-warehouse/big_query_ml.sql`: demo BigQuery ML end-to-end (prepare feature table, train/evaluate/predict/explain/hyperparameter tuning).
- `03-data-warehouse/extract_model.md`: hướng dẫn extract model từ BigQuery và serve local qua TensorFlow Serving + Docker.
- `03-data-warehouse/extras/`: helper scripts + cấu hình môi trường để tải dữ liệu web -> convert parquet -> upload GCS.
- `03-data-warehouse/extras/README.md`: hướng dẫn chạy nhanh scripts trong `extras`.
- `03-data-warehouse/extras/web_to_gcs.py`: script batch tải CSV.GZ từ GitHub release, convert parquet, upload GCS.
- `03-data-warehouse/extras/web_to_gcs_with_progress_bar.py`: phiên bản nâng cấp với progress bar + skip logic nếu file đã tồn tại local/GCS.
- `03-data-warehouse/extras/pyproject.toml`: dependency/runtime config cho scripts extras.
- `03-data-warehouse/extras/.env-example`: template env vars cho bucket và credentials.
- `03-data-warehouse/extras/.gitignore`: ngăn commit env/data artifact.

═══════════════════════════════
2. NỘI DUNG CÁC FILE .MD
═══════════════════════════════

[03-data-warehouse/README.md]
- Dạy về: Data Warehouse + BigQuery fundamentals, partitioning/clustering, BigQuery ML, model deployment, homework.
- Concepts chính:
  - Data Warehouse trong bối cảnh analytics
  - BigQuery SQL cơ bản
  - Partitioning vs Clustering
  - BigQuery best practices & internals (qua video links)
  - BigQuery ML và deploy model
- Commands được dùng:
  - Không có command shell trực tiếp trong file này (chủ yếu là links/video/sql references).
- Lưu ý đặc biệt:
  - Link trực tiếp tới `big_query.sql`, `big_query_ml.sql`, `extract_model.md`.
  - Có homework link cohort 2026 và danh sách community notes rất dài.

[03-data-warehouse/extract_model.md]
- Dạy về: xuất (extract/export) model từ BigQuery ML và serving local.
- Concepts chính:
  - BigQuery ML model export
  - Copy artifact từ GCS
  - TensorFlow Serving bằng Docker
  - Inference qua HTTP endpoint
- Commands được dùng:
  - `gcloud auth login`
  - `bq --project_id taxi-rides-ny extract -m nytaxi.tip_model gs://taxi_ml_model/tip_model`
  - `mkdir /tmp/model`
  - `gsutil cp -r gs://taxi_ml_model/tip_model /tmp/model`
  - `mkdir -p serving_dir/tip_model/1`
  - `cp -r /tmp/model/tip_model/* serving_dir/tip_model/1`
  - `docker pull tensorflow/serving`
  - `docker run -p 8501:8501 --mount type=bind,source=`pwd`/serving_dir/tip_model,target=/models/tip_model -e MODEL_NAME=tip_model -t tensorflow/serving &`
  - `curl -d '{"instances": [{"passenger_count":1, "trip_distance":12.2, "PULocationID":"193", "DOLocationID":"264", "payment_type":"2","fare_amount":20.4,"tolls_amount":0.0}]}' -X POST http://localhost:8501/v1/models/tip_model:predict`
- Lưu ý đặc biệt:
  - Hướng dẫn là “quick steps”, chưa cover production deployment hardening (auth, autoscaling, rollout, observability).

[03-data-warehouse/extras/README.md]
- Dạy về: cách dùng nhanh scripts để tải data lên GCS.
- Concepts chính:
  - `uv sync` để cài dependencies
  - chạy script Python để tải + upload data
- Commands được dùng:
  - `uv sync`
  - `uv run python web_to_gcs_with_progress_bar.py`
  - `uv run python web_to_gcs.py`
- Lưu ý đặc biệt:
  - Mô tả script là “quick hack”, không phải production ingestion framework.

═══════════════════════════════
3. PHÂN TÍCH CODE FILES
═══════════════════════════════

[big_query.sql]
- Từng query làm gì (mục đích, bảng input → output):
  1. `CREATE OR REPLACE EXTERNAL TABLE taxi-rides-ny.nytaxi.fhv_tripdata`: tạo external table đọc CSV trực tiếp từ `gs://nyc-tl-data/trip data/fhv_tripdata_2019-*.csv`.
  2. `SELECT count(*)` trên external table: đếm tổng record external source.
  3. `SELECT COUNT(DISTINCT(dispatching_base_num))`: đếm số dispatching base distinct trong external data.
  4. `CREATE OR REPLACE TABLE ... fhv_nonpartitioned_tripdata AS SELECT *`: materialize external data thành native table không partition.
  5. `CREATE OR REPLACE TABLE ... fhv_partitioned_tripdata PARTITION BY DATE(dropoff_datetime) CLUSTER BY dispatching_base_num AS SELECT *`: tạo native table có partition+cluster.
  6. Query filter date range + dispatching base trên non-partitioned table: baseline scan behavior.
  7. Query filter tương tự trên partitioned table: so sánh hiệu quả scan.
- Concepts BigQuery được demo:
  - External table
  - Native table materialization
  - Partitioning theo `DATE(dropoff_datetime)`
  - Clustering theo `dispatching_base_num`
  - Filter predicate theo date + dimension key để tận dụng partition/cluster pruning
- Copy nguyên văn toàn bộ file:

```sql
CREATE OR REPLACE EXTERNAL TABLE `taxi-rides-ny.nytaxi.fhv_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://nyc-tl-data/trip data/fhv_tripdata_2019-*.csv']
);


SELECT count(*) FROM `taxi-rides-ny.nytaxi.fhv_tripdata`;


SELECT COUNT(DISTINCT(dispatching_base_num)) FROM `taxi-rides-ny.nytaxi.fhv_tripdata`;


CREATE OR REPLACE TABLE `taxi-rides-ny.nytaxi.fhv_nonpartitioned_tripdata`
AS SELECT * FROM `taxi-rides-ny.nytaxi.fhv_tripdata`;

CREATE OR REPLACE TABLE `taxi-rides-ny.nytaxi.fhv_partitioned_tripdata`
PARTITION BY DATE(dropoff_datetime)
CLUSTER BY dispatching_base_num AS (
  SELECT * FROM `taxi-rides-ny.nytaxi.fhv_tripdata`
);

SELECT count(*) FROM  `taxi-rides-ny.nytaxi.fhv_nonpartitioned_tripdata`
WHERE DATE(dropoff_datetime) BETWEEN '2019-01-01' AND '2019-03-31'
  AND dispatching_base_num IN ('B00987', 'B02279', 'B02060');


SELECT count(*) FROM `taxi-rides-ny.nytaxi.fhv_partitioned_tripdata`
WHERE DATE(dropoff_datetime) BETWEEN '2019-01-01' AND '2019-03-31'
  AND dispatching_base_num IN ('B00987', 'B02279', 'B02060');
```

[big_query_hw.sql]
- Từng query làm gì:
  1. Query public table `bigquery-public-data.new_york_citibike.citibike_stations` để làm quen dataset public BigQuery.
  2. Tạo external table `external_yellow_tripdata` từ GCS wildcard của 2019/2020.
  3. Preview 10 rows từ external table.
  4. Tạo table `yellow_tripdata_non_partitioned` từ external.
  5. Tạo table `yellow_tripdata_partitioned` partition theo `DATE(tpep_pickup_datetime)`.
  6. Query distinct `VendorID` trên non-partitioned table (comment: scan 1.6GB).
  7. Query tương tự trên partitioned table (comment: scan ~106MB) để minh họa lợi ích partition pruning.
  8. Query `INFORMATION_SCHEMA.PARTITIONS` để inspect partition metadata.
  9. Tạo table `yellow_tripdata_partitioned_clustered` (partition + cluster by `VendorID`).
  10. Query count trips trên partitioned table (comment: scan 1.1GB).
  11. Query tương tự trên partitioned+clustered table (comment: scan 864.5MB) để minh họa clustering benefit.
- Đây là homework hay demo?
  - Đây là file theo phong cách homework/lab thực hành (tên file `big_query_hw.sql`, cấu trúc gồm câu truy vấn kiểm chứng scan amount và metadata inspection).
- Copy nguyên văn toàn bộ file:

```sql
-- Query public available table
SELECT
    station_id,
    name
FROM bigquery-public-data.new_york_citibike.citibike_stations
LIMIT 100;

-- Create an external table referencing files in GCS
CREATE OR REPLACE EXTERNAL TABLE `taxi-rides-ny.nytaxi.external_yellow_tripdata`
OPTIONS (
    format = 'CSV',
    uris = [
        'gs://nyc-tl-data/trip data/yellow_tripdata_2019-*.csv',
        'gs://nyc-tl-data/trip data/yellow_tripdata_2020-*.csv'
    ]
);

-- Preview yellow trip data from the external table
SELECT *
FROM taxi-rides-ny.nytaxi.external_yellow_tripdata
LIMIT 10;

-- Create a non-partitioned table from the external table
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_non_partitioned AS
SELECT *
FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;

-- Create a partitioned table from the external table
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
PARTITION BY DATE(tpep_pickup_datetime) AS
SELECT *
FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;

-- Impact of partition
-- Scanning 1.6GB of data
SELECT DISTINCT(VendorID)
FROM taxi-rides-ny.nytaxi.yellow_tripdata_non_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Scanning ~106 MB of DATA
SELECT DISTINCT(VendorID)
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Inspect table partitions
SELECT
    table_name,
    partition_id,
    total_rows
FROM `nytaxi.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitioned'
ORDER BY total_rows DESC;

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_partitioned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * 
FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;

-- Query scans 1.1 GB
SELECT count(*) as trips
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;

-- Query scans 864.5 MB
SELECT count(*) as trips
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned_clustered
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;

```

[big_query_ml.sql]
- ML model được tạo: 
  - `tip_model`: `model_type='linear_reg'` (linear regression), label `tip_amount`.
  - `tip_hyperparam_model`: linear regression có hyperparameter tuning (`l1_reg`, `l2_reg`, `num_trials`, `max_parallel_trials`).
- Features và target:
  - Target: `tip_amount`
  - Features: `passenger_count`, `trip_distance`, `PULocationID`, `DOLocationID`, `payment_type`, `fare_amount`, `tolls_amount`.
- Các bước:
  1. `SELECT` cột quan tâm từ `yellow_tripdata_partitioned` (`fare_amount != 0`).
  2. `CREATE OR REPLACE TABLE yellow_tripdata_ml` với schema explicit (cast một số cột về STRING).
  3. `CREATE OR REPLACE MODEL ... tip_model`.
  4. `ML.FEATURE_INFO` kiểm tra feature metadata.
  5. `ML.EVALUATE`.
  6. `ML.PREDICT`.
  7. `ML.EXPLAIN_PREDICT` (top 3 features).
  8. `CREATE OR REPLACE MODEL ... tip_hyperparam_model` để tuning.
- Copy nguyên văn toàn bộ file:

```sql
-- SELECT THE COLUMNS INTERESTED FOR YOU
SELECT passenger_count, trip_distance, PULocationID, DOLocationID, payment_type, fare_amount, tolls_amount, tip_amount
FROM `taxi-rides-ny.nytaxi.yellow_tripdata_partitioned` WHERE fare_amount != 0;

-- CREATE A ML TABLE WITH APPROPRIATE TYPE
CREATE OR REPLACE TABLE `taxi-rides-ny.nytaxi.yellow_tripdata_ml` (
`passenger_count` INTEGER,
`trip_distance` FLOAT64,
`PULocationID` STRING,
`DOLocationID` STRING,
`payment_type` STRING,
`fare_amount` FLOAT64,
`tolls_amount` FLOAT64,
`tip_amount` FLOAT64
) AS (
SELECT passenger_count, trip_distance, cast(PULocationID AS STRING), CAST(DOLocationID AS STRING),
CAST(payment_type AS STRING), fare_amount, tolls_amount, tip_amount
FROM `taxi-rides-ny.nytaxi.yellow_tripdata_partitioned` WHERE fare_amount != 0
);

-- CREATE MODEL WITH DEFAULT SETTING
CREATE OR REPLACE MODEL `taxi-rides-ny.nytaxi.tip_model`
OPTIONS
(model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT') AS
SELECT
*
FROM
`taxi-rides-ny.nytaxi.yellow_tripdata_ml`
WHERE
tip_amount IS NOT NULL;

-- CHECK FEATURES
SELECT * FROM ML.FEATURE_INFO(MODEL `taxi-rides-ny.nytaxi.tip_model`);

-- EVALUATE THE MODEL
SELECT
*
FROM
ML.EVALUATE(MODEL `taxi-rides-ny.nytaxi.tip_model`,
(
SELECT
*
FROM
`taxi-rides-ny.nytaxi.yellow_tripdata_ml`
WHERE
tip_amount IS NOT NULL
));

-- PREDICT THE MODEL
SELECT
*
FROM
ML.PREDICT(MODEL `taxi-rides-ny.nytaxi.tip_model`,
(
SELECT
*
FROM
`taxi-rides-ny.nytaxi.yellow_tripdata_ml`
WHERE
tip_amount IS NOT NULL
));

-- PREDICT AND EXPLAIN
SELECT
*
FROM
ML.EXPLAIN_PREDICT(MODEL `taxi-rides-ny.nytaxi.tip_model`,
(
SELECT
*
FROM
`taxi-rides-ny.nytaxi.yellow_tripdata_ml`
WHERE
tip_amount IS NOT NULL
), STRUCT(3 as top_k_features));

-- HYPER PARAM TUNNING
CREATE OR REPLACE MODEL `taxi-rides-ny.nytaxi.tip_hyperparam_model`
OPTIONS
(model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT',
num_trials=5,
max_parallel_trials=2,
l1_reg=hparam_range(0, 20),
l2_reg=hparam_candidates([0, 0.1, 1, 10])) AS
SELECT
*
FROM
`taxi-rides-ny.nytaxi.yellow_tripdata_ml`
WHERE
tip_amount IS NOT NULL;

```

[web_to_gcs.py]
- Arguments nhận vào:
  - Hàm `web_to_gcs(year, service)` nhận `year`, `service`.
  - Hàm `upload_to_gcs(bucket, object_name, local_file)` nhận tên bucket, object path, local file.
- Logic chính từng bước:
  1. Load env (`load_dotenv`), lấy bucket từ `GCP_GCS_BUCKET` hoặc default.
  2. Loop 12 tháng để tạo file name `service_tripdata_year-month.csv.gz`.
  3. Download bằng `requests.get` từ GitHub releases `init_url`.
  4. Đọc CSV.GZ bằng pandas với typed schema + parse_dates theo service.
  5. Convert sang parquet bằng `df.to_parquet(engine='pyarrow')`.
  6. Upload parquet lên GCS theo key `{service}/{file_name}`.
  7. Cuối file chạy hardcoded cho `green` 2019/2020/2021.
- Flow: source URL → download → upload GCS:
  - Source: `https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{service}/{file_name}`
  - Local: `.csv.gz` -> `.parquet`
  - Sink: `gs://{BUCKET}/{service}/{parquet_file}`
- Libraries dùng:
  - `os`, `requests`, `pandas`, `google.cloud.storage`, `dotenv.load_dotenv`
- Copy nguyên văn toàn bộ file:

```python
import os
import requests
import pandas as pd
from google.cloud import storage
from dotenv import load_dotenv


"""
Pre-reqs: 
1. run `uv sync` from this 'extra' folder (create venv and install dependencies from pyproject.toml)
2. rename .env-example to .env (not commited thanks to .gitignore)
3. in .env, 
    - set GCP_GCS_BUCKET as your bucket or change default value of BUCKET
    - Set GOOGLE_APPLICATION_CREDENTIALS to your project/service-account json key 
    (or don't set it if you use google ADC)
"""
# load env vars from .env
load_dotenv()

# services = ['fhv','green','yellow']
init_url = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/"
# if not done in .env, switch out the default bucketname
BUCKET = os.environ.get("GCP_GCS_BUCKET", "dtc-data-lake-bucketname")


def upload_to_gcs(bucket, object_name, local_file):
    """
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    """
    # # WORKAROUND to prevent timeout for files > 6 MB on 800 kbps upload speed.
    # # (Ref: https://github.com/googleapis/python-storage/issues/74)
    # storage.blob._MAX_MULTIPART_SIZE = 5 * 1024 * 1024  # 5 MB
    # storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024 * 1024  # 5 MB

    client = storage.Client()
    bucket = client.bucket(bucket)
    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)


def web_to_gcs(year, service):
    for i in range(12):
        # sets the month part of the file_name string
        month = "0" + str(i + 1)
        month = month[-2:]

        # csv file_name
        file_name = f"{service}_tripdata_{year}-{month}.csv.gz"

        # download it using requests via a pandas df
        request_url = f"{init_url}{service}/{file_name}"
        r = requests.get(request_url)
        open(file_name, "wb").write(r.content)
        print(f"Local: {file_name}")

        # read it back into a parquet file
        # enforce types so parquet columns will directly have good types
        # (as we did in module 1 in ingest.py script)
        dtypes = {
            "VendorID": "Int64",
            "RatecodeID": "Int64",
            "PULocationID": "Int64",
            "DOLocationID": "Int64",
            "passenger_count": "Int64",
            "payment_type": "Int64",
            "trip_type": "Int64",  # only in green but ignored if missing column
            "store_and_fwd_flag": "string",
            "trip_distance": "float64",
            "fare_amount": "float64",
            "extra": "float64",
            "mta_tax": "float64",
            "tip_amount": "float64",
            "tolls_amount": "float64",
            "ehailfee": "float64",  # only in green but ignored if missing column
            "improvement_surcharge": "float64",
            "total_amount": "float64",
            "congestion_surcharge": "float64",
        }

        if service == "yellow":
            parse_dates = ["tpep_pickup_datetime", "tpep_dropoff_datetime"]
        else:
            parse_dates = ["lpep_pickup_datetime", "lpep_dropoff_datetime"]

        df = pd.read_csv(
            file_name, dtype=dtypes, parse_dates=parse_dates, compression="gzip"
        )
        file_name = file_name.replace(".csv.gz", ".parquet")
        df.to_parquet(file_name, engine="pyarrow")
        print(f"Parquet: {file_name}")

        # upload it to gcs
        upload_to_gcs(BUCKET, f"{service}/{file_name}", file_name)
        print(f"GCS: {service}/{file_name}")


web_to_gcs("2019", "green")
web_to_gcs("2020", "green")
web_to_gcs("2021", "green")  # fail when reach 08 (normal, file not in github :)
# web_to_gcs("2019", "yellow")
# web_to_gcs("2020", "yellow")
# web_to_gcs("2021", "yellow") # fail when reach 08 (normal, file not in github :)
```

[web_to_gcs_with_progress_bar.py]
- Khác gì so với `web_to_gcs.py`:
  - Có progress bar cho download, convert parquet theo chunk, upload.
  - Có skip idempotency theo existence check (GCS object tồn tại -> skip; local CSV/parquet tồn tại -> skip bước tương ứng).
  - Convert parquet theo stream/chunks (`ParquetWriter`) thay vì load toàn bộ DataFrame rồi write một lần.
  - Có `r.raise_for_status()` nên fail nhanh nếu HTTP lỗi.
- Progress bar implementation:
  - Download: `tqdm` + `requests.get(..., stream=True)` + `iter_content`.
  - CSV->Parquet: đếm trước số rows rồi `pd.read_csv(..., chunksize=...)` + cập nhật bar mỗi chunk.
  - Upload: `tqdm.wrapattr(f, "read", total=file_size, ...)` bọc file reader khi upload.
  - Loop month: `for i in tqdm(range(12), desc=f"{service} {year}", unit="month")`.
- Copy nguyên văn toàn bộ file:

```python
import os
import requests
import pandas as pd
from google.cloud import storage
from dotenv import load_dotenv
from tqdm import tqdm
import gzip
import pyarrow as pa
import pyarrow.parquet as pq


"""
Pre-reqs: 
1. run `uv sync` from this 'extra' folder (create venv and install dependencies from pyproject.toml)
2. rename .env-example to .env (not commited thanks to .gitignore)
3. in .env, 
    - set GCP_GCS_BUCKET as your bucket or change default value of BUCKET
    - Set GOOGLE_APPLICATION_CREDENTIALS to your project/service-account json key 
    (or don't set it if you use google ADC)
"""
# load env vars from .env
load_dotenv()

# services = ['fhv','green','yellow']
init_url = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/"
# if not done in .env, switch out the default bucketname
BUCKET = os.environ.get("GCP_GCS_BUCKET", "dtc-data-lake-bucketname")


def download_with_progress(url: str, local_path: str, desc: str = "Downloading"):
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        total = int(r.headers.get("content-length", 0))
        # Configure tqdm for bytes
        with (
            open(local_path, "wb") as f,
            tqdm(
                total=total,
                unit="B",
                unit_scale=True,
                unit_divisor=1024,
                desc=desc,
            ) as bar,
        ):
            for chunk in r.iter_content(chunk_size=1024 * 1024):  # 1 MB
                if not chunk:
                    continue
                size = f.write(chunk)
                bar.update(size)


def csv_to_parquet_with_progress(
    csv_path: str, parquet_path: str, service_color: str, chunksize: int = 100_000
):
    # 1) Count rows (gzip-aware)
    with gzip.open(csv_path, mode="rt") as f:
        total_rows = sum(1 for _ in f) - 1  # minus header
    if total_rows <= 0:
        raise ValueError("CSV appears to be empty")

    # 2) Read in chunks with fixed dtypes so parquet columns will directly have good types
    # (as we did in module 1 in ingest.py script)
    dtypes = {
        "VendorID": "Int64",
        "RatecodeID": "Int64",
        "PULocationID": "Int64",
        "DOLocationID": "Int64",
        "passenger_count": "Int64",
        "payment_type": "Int64",
        "trip_type": "Int64",  # only in green but ignored if missing column
        "store_and_fwd_flag": "string",
        "trip_distance": "float64",
        "fare_amount": "float64",
        "extra": "float64",
        "mta_tax": "float64",
        "tip_amount": "float64",
        "tolls_amount": "float64",
        "ehailfee": "float64",  # only in green but ignored if missing column
        "improvement_surcharge": "float64",
        "total_amount": "float64",
        "congestion_surcharge": "float64",
    }

    if service_color == "yellow":
        parse_dates = ["tpep_pickup_datetime", "tpep_dropoff_datetime"]
    else:
        parse_dates = ["lpep_pickup_datetime", "lpep_dropoff_datetime"]

    reader = pd.read_csv(
        csv_path,
        dtype=dtypes,
        parse_dates=parse_dates,
        compression="gzip",
        chunksize=chunksize,
        low_memory=False,
    )

    writer = None

    with tqdm(total=total_rows, unit="rows", desc=f"Parquet {csv_path}") as bar:
        for chunk in reader:
            table = pa.Table.from_pandas(chunk)
            if writer is None:
                writer = pq.ParquetWriter(parquet_path, table.schema)
            else:
                # Optional safety: align to first schema
                table = table.cast(writer.schema)
            writer.write_table(table)
            bar.update(len(chunk))

    if writer is not None:
        writer.close()


def upload_to_gcs_with_progress(bucket: str, object_name: str, local_file: str):
    # # WORKAROUND to prevent timeout for files > 6 MB on 800 kbps upload speed.
    # # (Ref: https://github.com/googleapis/python-storage/issues/74)
    # Optional: tune chunk size (must be multiple of 256 KiB)
    storage.blob._MAX_MULTIPART_SIZE = 5 * 1024 * 1024  # 5 MB
    storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024 * 1024  # 5 MB

    client = storage.Client()
    bucket_obj = client.bucket(bucket)
    blob = bucket_obj.blob(object_name)

    if blob.exists(client):
        print(f"Skipping upload, already in GCS: gs://{bucket}/{object_name}")
        return

    file_size = os.path.getsize(local_file)

    with open(local_file, "rb") as f:
        with tqdm.wrapattr(
            f,
            "read",
            total=file_size,
            miniters=1,
            unit="B",
            unit_scale=True,
            unit_divisor=1024,
            desc=f"Uploading {os.path.basename(local_file)}",
        ) as wrapped_file:
            blob.upload_from_file(
                wrapped_file,
                size=file_size,  # important so the library knows total bytes
            )

    print(f"Uploaded to GCS: gs://{bucket}/{object_name}")


def web_to_gcs(year, service):
    client = storage.Client()
    bucket_obj = client.bucket(BUCKET)

    for i in tqdm(range(12), desc=f"{service} {year}", unit="month"):
        month = f"{i + 1:02d}"

        csv_file_name = f"{service}_tripdata_{year}-{month}.csv.gz"
        parquet_file_name = csv_file_name.replace(".csv.gz", ".parquet")
        object_name = f"{service}/{parquet_file_name}"

        # 1) Check if parquet already in GCS
        blob = bucket_obj.blob(object_name)
        if blob.exists(client):
            print(f"Already in GCS, skipping: gs://{BUCKET}/{object_name}")
            continue

        # 2) Check if CSV already downloaded locally
        if os.path.exists(csv_file_name):
            print(f"CSV already exists locally, skipping download: {csv_file_name}")
        else:
            request_url = f"{init_url}{service}/{csv_file_name}"
            download_with_progress(
                request_url, csv_file_name, desc=f"Downloading {csv_file_name}"
            )

        # 3) Check if Parquet already exists locally
        if os.path.exists(parquet_file_name):
            print(
                f"Parquet already exists locally, skipping conversion: {parquet_file_name}"
            )
        else:
            csv_to_parquet_with_progress(csv_file_name, parquet_file_name, service)
            print(f"Parquet: {parquet_file_name}")

        # 4) Upload with per-byte progress bar
        upload_to_gcs_with_progress(BUCKET, object_name, parquet_file_name)


web_to_gcs("2019", "green")
web_to_gcs("2020", "green")
web_to_gcs(
    "2021", "green"
)  # will fail when reaching 08 (normal, file does not exists in github :)
# web_to_gcs("2019", "yellow")
# web_to_gcs("2020", "yellow")
# web_to_gcs("2021", "yellow") # will fail when reaching 08 (normal, file does not exists in github :)
```

[pyproject.toml]
- Dependencies list:
  - `google-cloud-storage>=3.8.0`
  - `pandas>=3.0.0`
  - `pyarrow>=23.0.0`
  - `python-dotenv>=1.2.1`
  - `requests>=2.32.5`
  - `tqdm>=4.67.1`
- Copy nguyên văn toàn bộ file:

```toml
[project]
name = "extras"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.14"
dependencies = [
    "google-cloud-storage>=3.8.0",
    "pandas>=3.0.0",
    "pyarrow>=23.0.0",
    "python-dotenv>=1.2.1",
    "requests>=2.32.5",
    "tqdm>=4.67.1",
]
```

[.env-example]
- Các env vars cần thiết:
  - `GCP_GCS_BUCKET`: tên GCS bucket mục tiêu.
  - `GOOGLE_APPLICATION_CREDENTIALS`: path tới service account key JSON.
- Copy nguyên văn toàn bộ file:

```dotenv
GCP_GCS_BUCKET="your_bucket_name"
GOOGLE_APPLICATION_CREDENTIALS=Path/to/key/GCP_service_account_key.json
```

[Bổ sung: .gitignore]
- Mục đích:
  - Tránh commit secrets/data artifacts.
- Nội dung:

```gitignore
*.env
*.parquet
*.csv*
```

═══════════════════════════════
4. BIGQUERY CONCEPTS DEEP DIVE
═══════════════════════════════

## EXTERNAL TABLES

- Cú pháp tạo trong repo:
  - `CREATE OR REPLACE EXTERNAL TABLE ... OPTIONS(format='CSV', uris=[...])`
- Ví dụ thực tế:
  - `fhv_tripdata` trong `big_query.sql`
  - `external_yellow_tripdata` trong `big_query_hw.sql`
- Khi nào dùng vs native table:
  - External table: đọc trực tiếp file ở GCS, nhanh để bắt đầu, không cần nạp ngay vào BigQuery storage.
  - Native table: cần cho hiệu năng ổn định, tận dụng partitioning/clustering/materialization, ML/truy vấn lặp nhiều.
- Trong repo flow chuẩn là: external table -> create native table để tối ưu scan.

## PARTITIONING

- Partition by gì trong repo:
  - `PARTITION BY DATE(dropoff_datetime)` (FHV)
  - `PARTITION BY DATE(tpep_pickup_datetime)` (Yellow taxi)
- Câu lệnh thực tế trong repo:
  - `CREATE OR REPLACE TABLE ... PARTITION BY DATE(...) AS SELECT ...`
- Performance impact được demo:
  - `big_query_hw.sql` có comment so sánh scan:
    - non-partitioned query: `1.6GB`
    - partitioned query: `~106MB`
  - Ý nghĩa: predicate theo date giúp partition pruning, giảm bytes scanned.

## CLUSTERING

- Cluster by gì:
  - `CLUSTER BY dispatching_base_num` (FHV)
  - `CLUSTER BY VendorID` (Yellow taxi)
- Kết hợp với partition thế nào:
  - Dùng đồng thời `PARTITION BY DATE(...)` + `CLUSTER BY key dimension`.
  - Partition cắt theo thời gian, cluster tối ưu sắp xếp trong partition cho điều kiện filter theo key.
- Query cost comparison trong repo:
  - `big_query_hw.sql` comment:
    - partitioned only query: `1.1 GB`
    - partitioned + clustered query: `864.5 MB`

## BIGQUERY ML

- Model type được dùng:
  - `linear_reg` (regression dự đoán `tip_amount`).
- Feature engineering steps:
  1. Chọn subset cột feature + label.
  2. Loại bỏ hàng `fare_amount = 0`.
  3. Cast location/payment IDs sang `STRING` trong bảng `yellow_tripdata_ml`.
  4. Train model bằng `CREATE MODEL`.
- Evaluation metrics:
  - Script dùng `ML.EVALUATE` (không ghi cứng metric name trong file; BigQuery sẽ trả tập metric phù hợp regression như RMSE/MAE/R2).
- Additional ML operations:
  - `ML.FEATURE_INFO`
  - `ML.PREDICT`
  - `ML.EXPLAIN_PREDICT`
  - Hyperparameter tuning với `num_trials`, `max_parallel_trials`, `l1_reg`, `l2_reg`.

═══════════════════════════════
5. DATA FLOW THỰC TẾ
═══════════════════════════════

## Flow đầy đủ

### Flow A (SQL-centric trong repo core)
1. Source data nằm ở GCS public: `gs://nyc-tl-data/trip data/...`.
2. Tạo BigQuery External Table (`CREATE EXTERNAL TABLE`).
3. Materialize thành Native Table (`CREATE TABLE AS SELECT`).
4. Tạo biến thể optimized table: partitioned / partitioned+clustered.
5. Query analytics hoặc dùng làm input cho ML.

### Flow B (extras Python ingestion)
1. Source URL: GitHub release `DataTalksClub/nyc-tlc-data` (csv.gz).
2. Download về local.
3. Convert local csv.gz -> parquet.
4. Upload parquet lên bucket của user (`GCP_GCS_BUCKET`).
5. (Bước SQL tiếp theo không viết trực tiếp trong extras): dùng các pattern ở `big_query.sql`/`big_query_hw.sql` để tạo external/native table từ dữ liệu trên GCS.

## File nào trigger file nào

- `extras/web_to_gcs.py` và `extras/web_to_gcs_with_progress_bar.py` tự chạy trực tiếp ở cuối file (`web_to_gcs(...)`), không cần module khác trigger.
- `README.md` trỏ người học sang các SQL scripts và `extract_model.md`.
- `extract_model.md` giả định đã có model `nytaxi.tip_model` được train từ `big_query_ml.sql`.

## Thứ tự chạy đúng (khuyến nghị)

1. Cấu hình env theo `.env-example`.
2. `uv sync` trong `extras`.
3. Chạy một script ingest (`web_to_gcs_with_progress_bar.py` ưu tiên).
4. Trong BigQuery chạy external table + native table scripts (`big_query.sql` / `big_query_hw.sql`).
5. Chạy `big_query_ml.sql` để tạo và đánh giá model.
6. Nếu cần serving local, làm theo `extract_model.md`.

## Dependency giữa các bước

- `big_query_ml.sql` phụ thuộc bảng `yellow_tripdata_partitioned` đã tồn tại.
- `extract_model.md` phụ thuộc model `nytaxi.tip_model` đã được train.
- Scripts extras phụ thuộc credentials hợp lệ + bucket tồn tại.

═══════════════════════════════
6. ĐIỂM YẾU & THIẾU SÓT
═══════════════════════════════

## Security issues

- Dùng key-file qua `GOOGLE_APPLICATION_CREDENTIALS` (service account JSON) nhưng không có hướng dẫn rotation/least-privilege/secret manager.
- Script chưa có kiểm tra explicit scope/quyền bucket trước khi upload.
- Có comment hướng dẫn `.env`, nhưng chưa có cơ chế audit secret leakage ngoài `.gitignore`.

## Idempotency issues trong SQL scripts

- SQL dùng `CREATE OR REPLACE` giúp idempotent ở mức object replacement.
- Nhưng không có cơ chế incremental load (append theo partition mới) hay watermark logic.
- Re-run sẽ replace toàn bảng, không phù hợp pipeline production lớn.

## Production readiness gaps

- Python scripts là batch script đơn lẻ, không có orchestration, retry policy có chủ đích, alerting.
- `web_to_gcs.py` không `raise_for_status()` nên có thể ghi file lỗi HTTP thành “dữ liệu”.
- Không có checksum/data quality assertions sau download/convert/upload.
- Không có structured logging hoặc metrics.

## Cost optimization gaps

- Có demo partition/cluster, nhưng chưa dạy quota guardrails, bytes-billed caps, reservation/slot strategy.
- Không có hướng dẫn lifecycle/storage class cho GCS parquet.
- Chưa có thực hành query plan inspection (`EXPLAIN`) và table/partition expiration policy.

## Monitoring/logging gaps

- Không có log schema chuẩn (job_id, dataset, partition, bytes, duration, error_code).
- Không tích hợp Cloud Logging/Monitoring, không có SLO/SLA checks.
- Không có lineage/metadata tracking (ví dụ Data Catalog/OpenLineage).

## Những gì repo dạy nhưng không đủ cho Senior DE

- Dạy tốt concept nền tảng BigQuery nhưng thiếu operating model production (governance, FinOps, reliability engineering).
- BigQuery ML demo ở mức notebook-like SQL, chưa cover MLOps lifecycle (registry, CI/CD model, drift monitoring, rollback).

═══════════════════════════════
7. KIẾN THỨC NGOÀI REPO
═══════════════════════════════

Dựa trên phạm vi repo hiện tại, các phần Senior DE nên biết thêm:

## BigQuery internals (repo chưa cover sâu)

- Storage architecture (Capacitor), execution tree/stages/shuffle internals.
- Slot management: on-demand vs reservations, autoscaling reservations.
- Join strategy internals (broadcast vs shuffle), skew handling.
- Metadata indexing, statistics, optimizer behavior.
- Workload isolation multi-tenant và concurrency control.

## BigQuery ML production

- Train/serve split, reproducibility và model versioning.
- Feature store patterns, training-serving skew controls.
- Scheduled retraining, drift detection, champion/challenger.
- CI/CD cho SQL ML pipelines, testing cho feature logic.
- Online serving kiến trúc (Vertex AI endpoint/TF Serving managed) + auth + autoscaling.

## GCS best practices

- IAM least privilege theo bucket/prefix/service-account.
- Uniform bucket-level access, CMEK, retention policies.
- Object lifecycle policies (transition/delete), versioning controls.
- Naming convention partition-friendly (`dt=YYYY-MM-DD/...`).
- Integrity checks (md5/crc32c), multipart tuning, retry/backoff chuẩn.

## Cost optimization

- Partition expiration, clustering key cardinality strategy.
- Materialized views/cached results và khi nào dùng.
- Dry run & bytes billed limits ở query jobs.
- Table decorators/time-travel cost awareness.
- FinOps dashboard theo team/dataset/job labels.

## Data modeling trong DW

- Star schema vs Data Vault vs wide-table tradeoffs.
- SCD Type 1/2 strategies cho dimension tables.
- Surrogate key management, conformed dimensions.
- Fact table grain governance và late-arriving facts.
- Semantic layer/metrics layer governance.

## Query optimization

- Predicate pushdown patterns và anti-pattern.
- Avoid SELECT * trong production, projection pruning.
- Pre-aggregation strategy và approximate functions (`APPROX_*`) khi phù hợp.
- UDF performance caveats, remote functions tradeoffs.
- Query plan reading + stage-level bottleneck analysis.
