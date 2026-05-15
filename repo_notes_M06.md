# repo_notes_M06

Ghi chú đọc toàn bộ các file được yêu cầu trong `06-batch`. Hai file trong danh sách yêu cầu không tồn tại ở checkout hiện tại: `setup/README.md` và `setup/.gitignore`; phần tương ứng được đánh dấu missing thay vì tự tạo nội dung giả.

## 1. CẤU TRÚC THƯ MỤC

```text
06-batch/
├── code - Notebook/script thực hành Spark: download raw data, Parquet, SQL, groupBy/join, RDD, GCS/BigQuery, homework.
│   ├── 03_test.ipynb - Notebook phụ ngoài danh sách yêu cầu; test Spark cơ bản.
│   ├── 04_pyspark.ipynb - First look PySpark: SparkSession, CSV, schema, repartition, Parquet, DataFrame ops, UDF.
│   ├── 05_taxi_schema.ipynb - Define taxi schemas và convert CSV raw sang Parquet.
│   ├── 06_spark_sql.ipynb - Spark SQL/DataFrame union green/yellow taxi và revenue aggregation.
│   ├── 06_spark_sql.py - Script hóa Spark SQL để chạy bằng python/spark-submit/Dataproc, output Parquet.
│   ├── 06_spark_sql_big_query.py - Biến thể script ghi kết quả aggregation vào BigQuery.
│   ├── 07_groupby_join.ipynb - GroupBy revenue, join green/yellow, join zone lookup.
│   ├── 08_rdds.ipynb - RDD API, reduceByKey, mapPartitions và DataFrame conversion.
│   ├── 09_spark_gcs.ipynb - Cấu hình SparkContext để đọc Parquet từ Google Cloud Storage.
│   ├── cloud.md - Hướng dẫn GCS connector, local cluster, spark-submit, Dataproc, BigQuery connector.
│   ├── download_data.sh - Download 12 tháng NYC TLC CSV gzip theo taxi type/year.
│   └── homework.ipynb - Notebook homework PySpark trên FHVHV Feb 2021.
├── setup - Tài liệu cài đặt Spark/PySpark và Hadoop/YARN.
│   ├── config - Config mẫu cho Spark/YARN/GCS connector.
│   │   ├── core-site.xml - Hadoop core-site cấu hình GCS filesystem và service account.
│   │   ├── spark-defaults.conf - Spark defaults cho YARN và GCS auth.
│   │   └── spark.dockerfile - Dockerfile tối thiểu dùng OpenJDK 11.
│   ├── hadoop-yarn.md - Cài Hadoop/YARN pseudo-distributed và chạy Spark on YARN/Docker/GCS.
│   ├── linux.md - Cài Spark 4.x/PySpark trên Linux/Ubuntu/WSL.
│   ├── macos.md - Cài Spark 4.x/PySpark trên macOS.
│   └── windows.md - Cài Spark 4.x/PySpark trên Windows Git Bash.
├── .gitignore - File ignore rỗng ở root module; không có rule nào.
└── README.md - Mục lục Module 6 Batch Processing: videos, setup, Spark SQL/DataFrames, internals, RDD, cloud, homework.
! missing requested: setup/README.md - File được yêu cầu nhưng không tồn tại.
! missing requested: setup/.gitignore - File được yêu cầu nhưng không tồn tại.
```


## 2. NỘI DUNG CÁC FILE .MD

### [README.md]
- Dạy về: Module 6 Batch Processing: lộ trình học Spark batch từ intro, install, DataFrame/SQL, internals, RDD đến cloud.
- Concepts chính: Batch processing, Spark/PySpark, Spark SQL/DataFrames, Spark cluster anatomy, groupBy/join internals, RDD, GCS, Dataproc, BigQuery connector
- Commands được dùng:
  - `Không có command chạy trực tiếp; chỉ có link tới setup và script download_data.sh.`
- Lưu ý đặc biệt: Homework link trỏ tới cohorts/2026/06-batch/homework.md; README là syllabus/run index.

### [code/cloud.md]
- Dạy về: Chạy Spark trong cloud: GCS, local standalone cluster, spark-submit, Dataproc, BigQuery.
- Concepts chính: GCS connector, Spark standalone master/worker, nbconvert, spark-submit, Dataproc jobs, BigQuery connector jar
- Commands được dùng:
  - `gsutil -m cp -r pq/ gs://dtc_data_lake_de-zoomcamp-nytaxi/pq`
  - `gsutil cp gs://hadoop-lib/gcs/gcs-connector-hadoop3-2.2.5.jar ./lib/`
  - `./sbin/start-master.sh`
  - `./sbin/start-slave.sh ${URL}`
  - `./sbin/start-worker.sh ${URL}`
  - `jupyter nbconvert --to=script 06_spark_sql.ipynb`
  - `python 06_spark_sql.py --input_green=... --input_yellow=... --output=...`
  - `spark-submit --master="${URL}" 06_spark_sql.py ...`
  - `gcloud dataproc jobs submit pyspark --cluster=... --region=... gs://.../06_spark_sql.py -- ...`
  - `gcloud dataproc jobs submit pyspark --jars=gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar gs://.../06_spark_sql_big_query.py -- ...`
- Lưu ý đặc biệt: Bucket/project/region hardcoded theo bài giảng; cần đổi khi chạy thật.

### [setup/hadoop-yarn.md]
- Dạy về: Cài Hadoop 3.2.3/YARN single node, chạy Spark trên YARN, cấu hình GCS và Docker runtime.
- Concepts chính: SSH localhost passwordless, Hadoop binaries, YARN pseudo-distributed, HADOOP_HOME, YARN_CONF_DIR, GCS connector, YARN Docker containers
- Commands được dùng:
  - `ssh localhost`
  - `cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys`
  - `chmod 0600 ~/.ssh/authorized_keys`
  - `sudo service ssh start`
  - `wget https://dlcdn.apache.org/hadoop/common/hadoop-3.2.3/hadoop-3.2.3.tar.gz`
  - `tar xzfv hadoop-3.2.3.tar.gz`
  - `cd hadoop-3.2.3/`
  - `echo "export JAVA_HOME=${JAVA_HOME}" >> etc/hadoop/hadoop-env.sh`
  - `./sbin/start-yarn.sh`
  - `export HADOOP_HOME="${HOME}/spark/hadoop-3.2.3"`
  - `export YARN_CONF_DIR="${HADOOP_HOME}/etc/hadoop"`
  - `gsutil cp gs://hadoop-lib/gcs/gcs-connector-hadoop3-2.2.5.jar .`
  - `spark-submit --master yarn --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_TYPE=docker ...`
- Lưu ý đặc biệt: Có placeholder link rỗng cho spark-defaults; Docker YARN config chưa đủ trong repo.

### [setup/linux.md]
- Dạy về: Cài PySpark/Spark 4.x trên Linux/Ubuntu/WSL.
- Concepts chính: Java 17/21, JAVA_HOME, uv, pip fallback, PySpark bundled Spark, SparkSession local[*] smoke test
- Commands được dùng:
  - `sudo apt update`
  - `sudo apt install default-jdk`
  - `java --version`
  - `export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))`
  - `export PATH="${JAVA_HOME}/bin:${PATH}"`
  - `uv init`
  - `uv add pyspark`
  - `uv run python your_script.py`
  - `pip install pyspark`
  - `uv run python test_spark.py`
- Lưu ý đặc biệt: Không cần tải Spark riêng vì PySpark 4.x bundle Spark.

### [setup/macos.md]
- Dạy về: Cài PySpark/Spark 4.x trên macOS.
- Concepts chính: Homebrew OpenJDK 17, JAVA_HOME, uv/pip, PySpark bundled Spark, old SPARK_HOME conflict
- Commands được dùng:
  - `brew install openjdk@17`
  - `export JAVA_HOME=$(brew --prefix openjdk@17)`
  - `export PATH="$JAVA_HOME/bin:$PATH"`
  - `java --version`
  - `uv init`
  - `uv add pyspark`
  - `uv run python your_script.py`
  - `pip install pyspark`
  - `uv run python test_spark.py`
- Lưu ý đặc biệt: Cảnh báo xóa SPARK_HOME cũ nếu từng cài Spark 3.x.

### [setup/windows.md]
- Dạy về: Cài PySpark/Spark 4.x trên Windows bằng MINGW/Git Bash.
- Concepts chính: Git Bash, Adoptium JDK 17, JAVA_HOME, uv/pip, Windows Firewall warning, old SPARK_HOME conflict
- Commands được dùng:
  - `wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.18%2B8/OpenJDK17U-jdk_x64_windows_hotspot_17.0.18_8.zip`
  - `unzip OpenJDK17U-jdk_x64_windows_hotspot_17.0.18_8.zip -d /c/tools/`
  - `export JAVA_HOME="/c/tools/jdk-17.0.18+8"`
  - `export PATH="${JAVA_HOME}/bin:${PATH}"`
  - `java --version`
  - `uv init`
  - `uv add pyspark`
  - `uv run python your_script.py`
  - `pip install pyspark`
  - `uv run python test_spark.py`
- Lưu ý đặc biệt: Nếu dùng WSL thì theo linux.md; không cần tải Spark/Hadoop riêng cho PySpark 4.x.

### [setup/README.md]
- Dạy về: MISSING
- Concepts chính: File không tồn tại trong checkout hiện tại.
- Commands được dùng:
  - Không có / file missing.
- Lưu ý đặc biệt: Đường dẫn user yêu cầu không có trên filesystem.

## 3. PHÂN TÍCH CODE FILES

### [download_data.sh]
- Làm gì: download 12 file CSV gzip từ DataTalksClub/nyc-tlc-data GitHub releases cho `TAXI_TYPE` và `YEAR`, lưu vào `data/raw/{taxi_type}/{year}/{month}/`.
- Arguments: `$1` là `TAXI_TYPE`; `$2` là `YEAR`.
- Cách chạy: `bash download_data.sh yellow 2020` hoặc `./download_data.sh green 2021`.
- Logic: `set -e`, loop tháng 1..12, format `%02d`, build URL, `mkdir -p`, `wget -O`.
- Idempotency: chạy lại overwrite file; không checksum, retry/backoff, skip existing.

Copy nguyên văn toàn bộ file:
```bash

set -e

TAXI_TYPE=$1 # "yellow"
YEAR=$2 # 2020

URL_PREFIX="https://github.com/DataTalksClub/nyc-tlc-data/releases/download"

for MONTH in {1..12}; do
  FMONTH=`printf "%02d" ${MONTH}`

  URL="${URL_PREFIX}/${TAXI_TYPE}/${TAXI_TYPE}_tripdata_${YEAR}-${FMONTH}.csv.gz"

  LOCAL_PREFIX="data/raw/${TAXI_TYPE}/${YEAR}/${FMONTH}"
  LOCAL_FILE="${TAXI_TYPE}_tripdata_${YEAR}_${FMONTH}.csv.gz"
  LOCAL_PATH="${LOCAL_PREFIX}/${LOCAL_FILE}"

  echo "downloading ${URL} to ${LOCAL_PATH}"
  mkdir -p ${LOCAL_PREFIX}
  wget ${URL} -O ${LOCAL_PATH}

done
```


### [spark.dockerfile]
- Base image: `library/openjdk:11`.
- Layers theo thứ tự: chỉ có một layer `FROM`; không install Python/Spark/dependencies.
- Entry point: không khai báo `ENTRYPOINT`.
- CMD: không khai báo `CMD`.
- Ý nghĩa: Dockerfile tối thiểu làm Java base, chưa đủ để tự chạy PySpark job nếu container cần Python/package runtime.

Copy nguyên văn toàn bộ file:
```dockerfile
FROM library/openjdk:11
```


### [core-site.xml]
- Cấu hình: Hadoop filesystem integration cho Google Cloud Storage.
- Key properties:
  - `fs.AbstractFileSystem.gs.impl`: AbstractFileSystem implementation cho `gs://`.
  - `fs.gs.impl`: FileSystem implementation cho GCS.
  - `fs.gs.auth.service.account.json.keyfile`: đường dẫn local tới service account JSON key.
  - `fs.gs.auth.service.account.enable`: bật service account auth.
- Mục đích: cho Hadoop/Spark đọc ghi `gs://...` qua GCS connector.

Copy nguyên văn toàn bộ file:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
  <property>
    <name>fs.AbstractFileSystem.gs.impl</name>
    <value>com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS</value>
  </property>
  <property>
    <name>fs.gs.impl</name>
    <value>com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem</value>
  </property>
  <property>
    <name>fs.gs.auth.service.account.json.keyfile</name>
    <value>/home/alexey/.google/credentials/google_credentials.json</value>
  </property>
  <property>
    <name>fs.gs.auth.service.account.enable</name>
    <value>true</value>
  </property>
</configuration>
```


### [spark-defaults.conf]
- Cấu hình: default Spark properties cho YARN và GCS auth.
- Key properties:
  - `spark-master yarn`: intended là master YARN, nhưng key chuẩn Spark thường là `spark.master`.
  - `spark.hadoop.google.cloud.auth.service.account.enable true`: bật service account auth.
  - `spark.hadoop.google.cloud.auth.service.account.json.keyfile /home/alexey`: path keyfile có vẻ thiếu tên file JSON.
- Mục đích: đưa GCS auth vào Spark job mặc định.

Copy nguyên văn toàn bộ file:
```properties
spark-master    yarn
spark.hadoop.google.cloud.auth.service.account.enable        true
spark.hadoop.google.cloud.auth.service.account.json.keyfile  /home/alexey
```


### [04_pyspark.ipynb]
- Mục tiêu notebook: Làm quen PySpark: tạo SparkSession local, download FHVHV CSV, đọc CSV, infer/define schema, repartition, ghi/đọc Parquet, DataFrame select/filter, UDF.
- SparkContext/SparkSession/DataFrame ops được dùng: SparkSession local[*], spark.read.csv, pandas sample schema inference, StructType schema, repartition(24), write/read Parquet, printSchema, show, select, filter, withColumn, F.udf
- Ghi chú phân tích: SparkContext được tạo ngầm qua SparkSession; notebook dùng shell magic wget/gzip/wc/head để chuẩn bị local CSV.

Copy toàn bộ code/markdown cells theo thứ tự notebook:
#### Cell 1 - code

- Output trong notebook: không có output lưu trong notebook

```python
import pyspark
from pyspark.sql import SparkSession
```

#### Cell 2 - code

- Output trong notebook: stream: WARNING: An illegal reflective access operation has occurred

```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```

#### Cell 3 - code

- Output trong notebook: stream: --2022-02-16 21:13:50--  https://nyc-tlc.s3.amazonaws.com/trip+data/fhvhv_tripdata_2021-01.csv

```python
!wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhvhv/fhvhv_tripdata_2021-01.csv.gz
```

#### Cell 4 - code

- Output trong notebook: không có output lưu trong notebook

```python
!gzip -dc fhvhv_tripdata_2021-01.csv.gz
```

#### Cell 5 - code

- Output trong notebook: stream: 11908469 fhvhv_tripdata_2021-01.csv

```python
!wc -l fhvhv_tripdata_2021-01.csv
```

#### Cell 6 - code

- Output trong notebook: không có output lưu trong notebook

```python
df = spark.read \
    .option("header", "true") \
    .csv('fhvhv_tripdata_2021-01.csv')
```

#### Cell 7 - code

- Output trong notebook: execute_result: StructType(List(StructField(hvfhs_license_num,StringType,true),StructField(dispatching_base_num,StringType,true),StructField(pickup_datetime,StringType,true),St

```python
df.schema
```

#### Cell 8 - code

- Output trong notebook: không có output lưu trong notebook

```python
!head -n 1001 fhvhv_tripdata_2021-01.csv > head.csv
```

#### Cell 9 - code

- Output trong notebook: không có output lưu trong notebook

```python
import pandas as pd
```

#### Cell 10 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_pandas = pd.read_csv('head.csv')
```

#### Cell 11 - code

- Output trong notebook: execute_result: hvfhs_license_num        object

```python
df_pandas.dtypes
```

#### Cell 12 - code

- Output trong notebook: execute_result: StructType(List(StructField(hvfhs_license_num,StringType,true),StructField(dispatching_base_num,StringType,true),StructField(pickup_datetime,StringType,true),St

```python
spark.createDataFrame(df_pandas).schema
```

#### Cell 13 - markdown

Integer - 4 bytes
Long - 8 bytes

#### Cell 14 - code

- Output trong notebook: không có output lưu trong notebook

```python
from pyspark.sql import types
```

#### Cell 15 - code

- Output trong notebook: không có output lưu trong notebook

```python
schema = types.StructType([
    types.StructField('hvfhs_license_num', types.StringType(), True),
    types.StructField('dispatching_base_num', types.StringType(), True),
    types.StructField('pickup_datetime', types.TimestampType(), True),
    types.StructField('dropoff_datetime', types.TimestampType(), True),
    types.StructField('PULocationID', types.IntegerType(), True),
    types.StructField('DOLocationID', types.IntegerType(), True),
    types.StructField('SR_Flag', types.StringType(), True)
])
```

#### Cell 16 - code

- Output trong notebook: không có output lưu trong notebook

```python
df = spark.read \
    .option("header", "true") \
    .schema(schema) \
    .csv('fhvhv_tripdata_2021-01.csv')
```

#### Cell 17 - code

- Output trong notebook: không có output lưu trong notebook

```python
df = df.repartition(24)
```

#### Cell 18 - code

- Output trong notebook: không có output lưu trong notebook

```python
df.write.parquet('fhvhv/2021/01/')
```

#### Cell 19 - code

- Output trong notebook: không có output lưu trong notebook

```python
df = spark.read.parquet('fhvhv/2021/01/')
```

#### Cell 20 - code

- Output trong notebook: stream: root

```python
df.printSchema()
```

#### Cell 21 - markdown

SELECT * FROM df WHERE hvfhs_license_num =  HV0003

#### Cell 22 - code

- Output trong notebook: không có output lưu trong notebook

```python
from pyspark.sql import functions as F
```

#### Cell 23 - code

- Output trong notebook: stream: +-----------------+--------------------+-------------------+-------------------+------------+------------+-------+

```python
df.show()
```

#### Cell 24 - code

- Output trong notebook: không có output lưu trong notebook

```python
def crazy_stuff(base_num):
    num = int(base_num[1:])
    if num % 7 == 0:
        return f's/{num:03x}'
    elif num % 3 == 0:
        return f'a/{num:03x}'
    else:
        return f'e/{num:03x}'
```

#### Cell 25 - code

- Output trong notebook: execute_result: 's/b44'

```python
crazy_stuff('B02884')
```

#### Cell 26 - code

- Output trong notebook: không có output lưu trong notebook

```python
crazy_stuff_udf = F.udf(crazy_stuff, returnType=types.StringType())
```

#### Cell 27 - code

- Output trong notebook: stream: +-------+-----------+------------+------------+------------+

```python
df \
    .withColumn('pickup_date', F.to_date(df.pickup_datetime)) \
    .withColumn('dropoff_date', F.to_date(df.dropoff_datetime)) \
    .withColumn('base_id', crazy_stuff_udf(df.dispatching_base_num)) \
    .select('base_id', 'pickup_date', 'dropoff_date', 'PULocationID', 'DOLocationID') \
    .show()
```

#### Cell 28 - code

- Output trong notebook: execute_result: [Row(pickup_datetime=datetime.datetime(2021, 1, 1, 0, 23, 13), dropoff_datetime=datetime.datetime(2021, 1, 1, 0, 30, 35), PULocationID=147, DOLocationID=159),

```python
df.select('pickup_datetime', 'dropoff_datetime', 'PULocationID', 'DOLocationID') \
  .filter(df.hvfhs_license_num == 'HV0003')
```

#### Cell 29 - code

- Output trong notebook: stream: hvfhs_license_num,dispatching_base_num,pickup_datetime,dropoff_datetime,PULocationID,DOLocationID,SR_Flag

```python
!head -n 10 head.csv
```

#### Cell 30 - code

- Output trong notebook: không có output lưu trong notebook

```python

```


### [05_taxi_schema.ipynb]
- Mục tiêu notebook: Define schema Green Taxi và Yellow Taxi, đọc raw CSV gzip theo month, repartition, ghi Parquet theo data/pq/{type}/{year}/{month}.
- SparkContext/SparkSession/DataFrame ops được dùng: StructType/StructField, spark.read.schema(...).csv, repartition(4), write.parquet overwrite
- Ghi chú phân tích: Một vài cell trống; các loop 2021 có output error lưu trong notebook.
- Schema được define:
- Transformations thực hiện: đọc CSV raw với schema, repartition(4), write Parquet overwrite theo taxi type/year/month.

Copy toàn bộ code/markdown cells theo thứ tự notebook:
#### Cell 1 - code

- Output trong notebook: không có output lưu trong notebook

```python
import pyspark
from pyspark.sql import SparkSession
```

#### Cell 2 - code

- Output trong notebook: stream: WARNING: An illegal reflective access operation has occurred

```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```

#### Cell 3 - code

- Output trong notebook: không có output lưu trong notebook

```python
import pandas as pd
```

#### Cell 4 - code

- Output trong notebook: không có output lưu trong notebook

```python
from pyspark.sql import types
```

#### Cell 5 - code

- Output trong notebook: không có output lưu trong notebook

```python
green_schema = types.StructType([
    types.StructField("VendorID", types.IntegerType(), True),
    types.StructField("lpep_pickup_datetime", types.TimestampType(), True),
    types.StructField("lpep_dropoff_datetime", types.TimestampType(), True),
    types.StructField("store_and_fwd_flag", types.StringType(), True),
    types.StructField("RatecodeID", types.IntegerType(), True),
    types.StructField("PULocationID", types.IntegerType(), True),
    types.StructField("DOLocationID", types.IntegerType(), True),
    types.StructField("passenger_count", types.IntegerType(), True),
    types.StructField("trip_distance", types.DoubleType(), True),
    types.StructField("fare_amount", types.DoubleType(), True),
    types.StructField("extra", types.DoubleType(), True),
    types.StructField("mta_tax", types.DoubleType(), True),
    types.StructField("tip_amount", types.DoubleType(), True),
    types.StructField("tolls_amount", types.DoubleType(), True),
    types.StructField("ehail_fee", types.DoubleType(), True),
    types.StructField("improvement_surcharge", types.DoubleType(), True),
    types.StructField("total_amount", types.DoubleType(), True),
    types.StructField("payment_type", types.IntegerType(), True),
    types.StructField("trip_type", types.IntegerType(), True),
    types.StructField("congestion_surcharge", types.DoubleType(), True)
])

yellow_schema = types.StructType([
    types.StructField("VendorID", types.IntegerType(), True),
    types.StructField("tpep_pickup_datetime", types.TimestampType(), True),
    types.StructField("tpep_dropoff_datetime", types.TimestampType(), True),
    types.StructField("passenger_count", types.IntegerType(), True),
    types.StructField("trip_distance", types.DoubleType(), True),
    types.StructField("RatecodeID", types.IntegerType(), True),
    types.StructField("store_and_fwd_flag", types.StringType(), True),
    types.StructField("PULocationID", types.IntegerType(), True),
    types.StructField("DOLocationID", types.IntegerType(), True),
    types.StructField("payment_type", types.IntegerType(), True),
    types.StructField("fare_amount", types.DoubleType(), True),
    types.StructField("extra", types.DoubleType(), True),
    types.StructField("mta_tax", types.DoubleType(), True),
    types.StructField("tip_amount", types.DoubleType(), True),
    types.StructField("tolls_amount", types.DoubleType(), True),
    types.StructField("improvement_surcharge", types.DoubleType(), True),
    types.StructField("total_amount", types.DoubleType(), True),
    types.StructField("congestion_surcharge", types.DoubleType(), True)
])
```

#### Cell 6 - code

- Output trong notebook: stream: processing data for 2020/1; stream: ; stream: processing data for 2020/2; stream: ; stream: processing data for 2020/3; stream: ; stream: processing data for 2020/4; stream: ; stream: processing data for 2020/5; stream: ; stream: processing data for 2020/6; stream: ; stream: processing data for 2020/7; stream: ; stream: processing data for 2020/8; stream: ; stream: processing data for 2020/9; stream: ; stream: processing data for 2020/10; stream: ; stream: processing data for 2020/11; stream: ; stream: processing data for 2020/12; stream: 

```python
year = 2020

for month in range(1, 13):
    print(f'processing data for {year}/{month}')

    input_path = f'data/raw/green/{year}/{month:02d}/'
    output_path = f'data/pq/green/{year}/{month:02d}/'

    df_green = spark.read \
        .option("header", "true") \
        .schema(green_schema) \
        .csv(input_path)

    df_green \
        .repartition(4) \
        .write.parquet(output_path)
```

#### Cell 7 - code

- Output trong notebook: stream: processing data for 2021/1; stream: ; stream: processing data for 2021/2; stream: ; stream: processing data for 2021/3; stream: ; stream: processing data for 2021/4; stream: ; stream: processing data for 2021/5; stream: ; stream: processing data for 2021/6; stream: ; stream: processing data for 2021/7; stream: [Stage 15:>                                                         (0 + 1) / 1]; stream: processing data for 2021/8; stream: ; error: AnalysisException Path does not exist: file:/home/alexey/data-engineering-zoomcamp/week_5_batch_processing/code/data/raw/green/2021/08;

```python
year = 2021 

for month in range(1, 13):
    print(f'processing data for {year}/{month}')

    input_path = f'data/raw/green/{year}/{month:02d}/'
    output_path = f'data/pq/green/{year}/{month:02d}/'

    df_green = spark.read \
        .option("header", "true") \
        .schema(green_schema) \
        .csv(input_path)

    df_green \
        .repartition(4) \
        .write.parquet(output_path)
```

#### Cell 8 - code

- Output trong notebook: không có output lưu trong notebook

```python

```

#### Cell 9 - code

- Output trong notebook: không có output lưu trong notebook

```python

```

#### Cell 10 - code

- Output trong notebook: không có output lưu trong notebook

```python

```

#### Cell 11 - code

- Output trong notebook: stream: processing data for 2020/1; stream: ; stream: processing data for 2020/2; stream: ; stream: processing data for 2020/3; stream: ; stream: processing data for 2020/4; stream: ; stream: processing data for 2020/5; stream: ; stream: processing data for 2020/6; stream: ; stream: processing data for 2020/7; stream: ; stream: processing data for 2020/8; stream: ; stream: processing data for 2020/9; stream: ; stream: processing data for 2020/10; stream: ; stream: processing data for 2020/11; stream: ; stream: processing data for 2020/12; stream: 

```python
year = 2020

for month in range(1, 13):
    print(f'processing data for {year}/{month}')

    input_path = f'data/raw/yellow/{year}/{month:02d}/'
    output_path = f'data/pq/yellow/{year}/{month:02d}/'

    df_yellow = spark.read \
        .option("header", "true") \
        .schema(yellow_schema) \
        .csv(input_path)

    df_yellow \
        .repartition(4) \
        .write.parquet(output_path)
```

#### Cell 12 - code

- Output trong notebook: stream: processing data for 2021/1; stream: ; stream: processing data for 2021/2; stream: ; stream: processing data for 2021/3; stream: ; stream: processing data for 2021/4; stream: ; stream: processing data for 2021/5; stream: ; stream: processing data for 2021/6; stream: ; stream: processing data for 2021/7; stream: [Stage 78:===========================================>              (3 + 1) / 4]; stream: processing data for 2021/8; stream: ; error: AnalysisException Path does not exist: file:/home/alexey/data-engineering-zoomcamp/week_5_batch_processing/code/data/raw/yellow/2021/08;

```python
year = 2021

for month in range(1, 13):
    print(f'processing data for {year}/{month}')

    input_path = f'data/raw/yellow/{year}/{month:02d}/'
    output_path = f'data/pq/yellow/{year}/{month:02d}/'

    df_yellow = spark.read \
        .option("header", "true") \
        .schema(yellow_schema) \
        .csv(input_path)

    df_yellow \
        .repartition(4) \
        .write.parquet(output_path)
```

#### Cell 13 - code

- Output trong notebook: không có output lưu trong notebook

```python

```


### [06_spark_sql.ipynb]
- Mục tiêu notebook: Đọc Parquet green/yellow, chuẩn hóa datetime columns, union dữ liệu, temp table và aggregate revenue theo zone/month/service_type.
- SparkContext/SparkSession/DataFrame ops được dùng: spark.read.parquet, withColumnRenamed, select, withColumn(F.lit), unionAll, groupBy.count, registerTempTable, spark.sql, coalesce(1).write.parquet
- Ghi chú phân tích: DataFrame API xử lý rename/select/union; Spark SQL xử lý aggregation bằng SELECT/GROUP BY/date_trunc/SUM/AVG.
- SQL queries được dùng: count/groupBy service_type; aggregate revenue theo `PULocationID`, `date_trunc('month', pickup_datetime)`, `service_type` với SUM/AVG.
- Spark SQL vs DataFrame API: DataFrame API xử lý rename/select/union; Spark SQL xử lý aggregation rõ hơn bằng truy vấn SQL trên temp table.

Copy toàn bộ code/markdown cells theo thứ tự notebook:
#### Cell 1 - code

- Output trong notebook: stream: WARNING: An illegal reflective access operation has occurred

```python
import pyspark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```

#### Cell 2 - code

- Output trong notebook: stream: 

```python
df_green = spark.read.parquet('data/pq/green/*/*')
```

#### Cell 3 - code

- Output trong notebook: không có output lưu trong notebook

```python

```

#### Cell 4 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_green = df_green \
    .withColumnRenamed('lpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('lpep_dropoff_datetime', 'dropoff_datetime')
```

#### Cell 5 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_yellow = spark.read.parquet('data/pq/yellow/*/*')
```

#### Cell 6 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_yellow = df_yellow \
    .withColumnRenamed('tpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('tpep_dropoff_datetime', 'dropoff_datetime')
```

#### Cell 7 - code

- Output trong notebook: không có output lưu trong notebook

```python
common_colums = []

yellow_columns = set(df_yellow.columns)

for col in df_green.columns:
    if col in yellow_columns:
        common_colums.append(col)
```

#### Cell 8 - code

- Output trong notebook: không có output lưu trong notebook

```python
from pyspark.sql import functions as F
```

#### Cell 9 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_green_sel = df_green \
    .select(common_colums) \
    .withColumn('service_type', F.lit('green'))
```

#### Cell 10 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_yellow_sel = df_yellow \
    .select(common_colums) \
    .withColumn('service_type', F.lit('yellow'))
```

#### Cell 11 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_trips_data = df_green_sel.unionAll(df_yellow_sel)
```

#### Cell 12 - code

- Output trong notebook: stream: ; stream: +------------+--------+

```python
df_trips_data.groupBy('service_type').count().show()
```

#### Cell 13 - code

- Output trong notebook: execute_result: ['VendorID',

```python
df_trips_data.columns
```

#### Cell 14 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_trips_data.registerTempTable('trips_data')
```

#### Cell 15 - code

- Output trong notebook: stream: ; stream: +------------+--------+

```python
spark.sql("""
SELECT
    service_type,
    count(1)
FROM
    trips_data
GROUP BY 
    service_type
""").show()
```

#### Cell 16 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_result = spark.sql("""
SELECT 
    -- Revenue grouping 
    PULocationID AS revenue_zone,
    date_trunc('month', pickup_datetime) AS revenue_month, 
    service_type, 

    -- Revenue calculation 
    SUM(fare_amount) AS revenue_monthly_fare,
    SUM(extra) AS revenue_monthly_extra,
    SUM(mta_tax) AS revenue_monthly_mta_tax,
    SUM(tip_amount) AS revenue_monthly_tip_amount,
    SUM(tolls_amount) AS revenue_monthly_tolls_amount,
    SUM(improvement_surcharge) AS revenue_monthly_improvement_surcharge,
    SUM(total_amount) AS revenue_monthly_total_amount,
    SUM(congestion_surcharge) AS revenue_monthly_congestion_surcharge,

    -- Additional calculations
    AVG(passenger_count) AS avg_monthly_passenger_count,
    AVG(trip_distance) AS avg_monthly_trip_distance
FROM
    trips_data
GROUP BY
    1, 2, 3
""")
```

#### Cell 17 - code

- Output trong notebook: stream: 

```python
df_result.coalesce(1).write.parquet('data/report/revenue/', mode='overwrite')
```

#### Cell 18 - code

- Output trong notebook: không có output lưu trong notebook

```python

```


### [06_spark_sql.py]
- Arguments nhận vào: `--input_green`, `--input_yellow`, `--output` required.
- Logic chính từng bước: parse args, tạo SparkSession appName `test`, đọc Parquet green/yellow, rename datetime columns, select common columns, thêm `service_type`, unionAll, register temp table `trips_data`, Spark SQL aggregate revenue, coalesce(1), ghi Parquet overwrite.
- SparkSession config: `SparkSession.builder.appName('test').getOrCreate()`; không set explicit master.

Copy nguyên văn toàn bộ file:
```python
#!/usr/bin/env python
# coding: utf-8

import argparse

import pyspark
from pyspark.sql import SparkSession
from pyspark.sql import functions as F


parser = argparse.ArgumentParser()

parser.add_argument('--input_green', required=True)
parser.add_argument('--input_yellow', required=True)
parser.add_argument('--output', required=True)

args = parser.parse_args()

input_green = args.input_green
input_yellow = args.input_yellow
output = args.output


spark = SparkSession.builder \
    .appName('test') \
    .getOrCreate()

df_green = spark.read.parquet(input_green)

df_green = df_green \
    .withColumnRenamed('lpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('lpep_dropoff_datetime', 'dropoff_datetime')

df_yellow = spark.read.parquet(input_yellow)


df_yellow = df_yellow \
    .withColumnRenamed('tpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('tpep_dropoff_datetime', 'dropoff_datetime')


common_colums = [
    'VendorID',
    'pickup_datetime',
    'dropoff_datetime',
    'store_and_fwd_flag',
    'RatecodeID',
    'PULocationID',
    'DOLocationID',
    'passenger_count',
    'trip_distance',
    'fare_amount',
    'extra',
    'mta_tax',
    'tip_amount',
    'tolls_amount',
    'improvement_surcharge',
    'total_amount',
    'payment_type',
    'congestion_surcharge'
]



df_green_sel = df_green \
    .select(common_colums) \
    .withColumn('service_type', F.lit('green'))

df_yellow_sel = df_yellow \
    .select(common_colums) \
    .withColumn('service_type', F.lit('yellow'))


df_trips_data = df_green_sel.unionAll(df_yellow_sel)

df_trips_data.registerTempTable('trips_data')


df_result = spark.sql("""
SELECT 
    -- Reveneue grouping 
    PULocationID AS revenue_zone,
    date_trunc('month', pickup_datetime) AS revenue_month, 
    service_type, 

    -- Revenue calculation 
    SUM(fare_amount) AS revenue_monthly_fare,
    SUM(extra) AS revenue_monthly_extra,
    SUM(mta_tax) AS revenue_monthly_mta_tax,
    SUM(tip_amount) AS revenue_monthly_tip_amount,
    SUM(tolls_amount) AS revenue_monthly_tolls_amount,
    SUM(improvement_surcharge) AS revenue_monthly_improvement_surcharge,
    SUM(total_amount) AS revenue_monthly_total_amount,
    SUM(congestion_surcharge) AS revenue_monthly_congestion_surcharge,

    -- Additional calculations
    AVG(passenger_count) AS avg_montly_passenger_count,
    AVG(trip_distance) AS avg_montly_trip_distance
FROM
    trips_data
GROUP BY
    1, 2, 3
""")


df_result.coalesce(1) \
    .write.parquet(output, mode='overwrite')
```


### [06_spark_sql_big_query.py]
- Arguments nhận vào: `--input_green`, `--input_yellow`, `--output` required; `--output` là BigQuery table name.
- Cách connect BigQuery từ Spark: cần BigQuery connector jar; code set `temporaryGcsBucket`, rồi `df_result.write.format('bigquery').option('table', output).save()`.
- Logic chính từng bước: giống script Parquet, nhưng output ghi vào BigQuery.
- SparkSession config: `SparkSession.builder.appName('test').getOrCreate()`; temporary GCS bucket hardcoded.

Copy nguyên văn toàn bộ file:
```python
#!/usr/bin/env python
# coding: utf-8

import argparse

import pyspark
from pyspark.sql import SparkSession
from pyspark.sql import functions as F


parser = argparse.ArgumentParser()

parser.add_argument('--input_green', required=True)
parser.add_argument('--input_yellow', required=True)
parser.add_argument('--output', required=True)

args = parser.parse_args()

input_green = args.input_green
input_yellow = args.input_yellow
output = args.output


spark = SparkSession.builder \
    .appName('test') \
    .getOrCreate()

spark.conf.set('temporaryGcsBucket', 'dataproc-temp-europe-west6-828225226997-fckhkym8')

df_green = spark.read.parquet(input_green)

df_green = df_green \
    .withColumnRenamed('lpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('lpep_dropoff_datetime', 'dropoff_datetime')

df_yellow = spark.read.parquet(input_yellow)


df_yellow = df_yellow \
    .withColumnRenamed('tpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('tpep_dropoff_datetime', 'dropoff_datetime')


common_columns = [
    'VendorID',
    'pickup_datetime',
    'dropoff_datetime',
    'store_and_fwd_flag',
    'RatecodeID',
    'PULocationID',
    'DOLocationID',
    'passenger_count',
    'trip_distance',
    'fare_amount',
    'extra',
    'mta_tax',
    'tip_amount',
    'tolls_amount',
    'improvement_surcharge',
    'total_amount',
    'payment_type',
    'congestion_surcharge'
]



df_green_sel = df_green \
    .select(common_columns) \
    .withColumn('service_type', F.lit('green'))

df_yellow_sel = df_yellow \
    .select(common_columns) \
    .withColumn('service_type', F.lit('yellow'))


df_trips_data = df_green_sel.unionAll(df_yellow_sel)

df_trips_data.registerTempTable('trips_data')


df_result = spark.sql("""
SELECT 
    -- Revenue grouping 
    PULocationID AS revenue_zone,
    date_trunc('month', pickup_datetime) AS revenue_month, 
    service_type, 

    -- Revenue calculation 
    SUM(fare_amount) AS revenue_monthly_fare,
    SUM(extra) AS revenue_monthly_extra,
    SUM(mta_tax) AS revenue_monthly_mta_tax,
    SUM(tip_amount) AS revenue_monthly_tip_amount,
    SUM(tolls_amount) AS revenue_monthly_tolls_amount,
    SUM(improvement_surcharge) AS revenue_monthly_improvement_surcharge,
    SUM(total_amount) AS revenue_monthly_total_amount,
    SUM(congestion_surcharge) AS revenue_monthly_congestion_surcharge,

    -- Additional calculations
    AVG(passenger_count) AS avg_monthly_passenger_count,
    AVG(trip_distance) AS avg_monthly_trip_distance
FROM
    trips_data
GROUP BY
    1, 2, 3
""")


df_result.write.format('bigquery') \
    .option('table', output) \
    .save()
```


### [07_groupby_join.ipynb]
- Mục tiêu notebook: Tách revenue green/yellow theo hour-zone, ghi từng output, rename metrics rồi outer join, sau đó join lookup zones.
- Operations chính: registerTempTable, spark.sql GROUP BY, repartition(20), write.parquet overwrite, withColumnRenamed, join outer, join zones, drop
- Ghi chú phân tích: GroupBy keys là hour/zone; join thực tế gồm outer và inner/default, không có left/right.
- GroupBy operations: keys `hour`, `zone`; aggregations `sum(total_amount)` as amount, `count(1)` as number_records.
- Join types được dùng: `outer` giữa green/yellow revenue; join zones dùng default inner. Không có left/right join trong code.
- Shuffle behavior và partition strategy: groupBy gây shuffle theo keys; join gây shuffle nếu dữ liệu không cùng partitioning; notebook dùng `repartition(20)` trước write revenue green/yellow.

Copy toàn bộ code/markdown cells theo thứ tự notebook:
#### Cell 1 - code

- Output trong notebook: stream: WARNING: An illegal reflective access operation has occurred

```python
import pyspark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```

#### Cell 2 - code

- Output trong notebook: stream: 

```python
df_green = spark.read.parquet('data/pq/green/*/*')
```

#### Cell 3 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_green.registerTempTable('green')
```

#### Cell 4 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_green_revenue = spark.sql("""
SELECT 
    date_trunc('hour', lpep_pickup_datetime) AS hour, 
    PULocationID AS zone,

    SUM(total_amount) AS amount,
    COUNT(1) AS number_records
FROM
    green
WHERE
    lpep_pickup_datetime >= '2020-01-01 00:00:00'
GROUP BY
    1, 2
""")
```

#### Cell 5 - code

- Output trong notebook: stream: 

```python
df_green_revenue \
    .repartition(20) \
    .write.parquet('data/report/revenue/green', mode='overwrite')
```

#### Cell 6 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_yellow = spark.read.parquet('data/pq/yellow/*/*')
df_yellow.registerTempTable('yellow')
```

#### Cell 7 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_yellow_revenue = spark.sql("""
SELECT 
    date_trunc('hour', tpep_pickup_datetime) AS hour, 
    PULocationID AS zone,

    SUM(total_amount) AS amount,
    COUNT(1) AS number_records
FROM
    yellow
WHERE
    tpep_pickup_datetime >= '2020-01-01 00:00:00'
GROUP BY
    1, 2
""")
```

#### Cell 8 - code

- Output trong notebook: stream: 

```python
df_yellow_revenue \
    .repartition(20) \
    .write.parquet('data/report/revenue/yellow', mode='overwrite')
```

#### Cell 9 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_green_revenue = spark.read.parquet('data/report/revenue/green')
df_yellow_revenue = spark.read.parquet('data/report/revenue/yellow')
```

#### Cell 10 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_green_revenue_tmp = df_green_revenue \
    .withColumnRenamed('amount', 'green_amount') \
    .withColumnRenamed('number_records', 'green_number_records')

df_yellow_revenue_tmp = df_yellow_revenue \
    .withColumnRenamed('amount', 'yellow_amount') \
    .withColumnRenamed('number_records', 'yellow_number_records')
```

#### Cell 11 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_join = df_green_revenue_tmp.join(df_yellow_revenue_tmp, on=['hour', 'zone'], how='outer')
```

#### Cell 12 - code

- Output trong notebook: stream: 

```python
df_join.write.parquet('data/report/revenue/total', mode='overwrite')
```

#### Cell 13 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_join = spark.read.parquet('data/report/revenue/total')
```

#### Cell 14 - code

- Output trong notebook: execute_result: DataFrame[hour: timestamp, zone: int, green_amount: double, green_number_records: bigint, yellow_amount: double, yellow_number_records: bigint]

```python
df_join
```

#### Cell 15 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_zones = spark.read.parquet('zones/')
```

#### Cell 16 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_result = df_join.join(df_zones, df_join.zone == df_zones.LocationID)
```

#### Cell 17 - code

- Output trong notebook: stream: 

```python
df_result.drop('LocationID', 'zone').write.parquet('tmp/revenue-zones')
```

#### Cell 18 - code

- Output trong notebook: không có output lưu trong notebook

```python

```


### [08_rdds.ipynb]
- Mục tiêu notebook: Minh họa RDD low-level transformations/actions và mapPartitions cho batch model inference giả lập.
- Operations chính: df.rdd, filter, map, take, reduceByKey, spark.createDataFrame, mapPartitions
- Ghi chú phân tích: RDD linh hoạt Python object/key-value nhưng ít Catalyst optimization; DataFrame có schema và SQL optimizer.
- RDD operations: map/filter/take/reduceByKey/mapPartitions; tạo key-value `(hour, zone)` rồi reduce doanh thu/count.
- So sánh RDD vs DataFrame: RDD cho custom Python logic; DataFrame nên ưu tiên cho schema, Catalyst optimizer, SQL functions, IO format integration.

Copy toàn bộ code/markdown cells theo thứ tự notebook:
#### Cell 1 - code

- Output trong notebook: stream: WARNING: An illegal reflective access operation has occurred

```python
import pyspark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```

#### Cell 2 - code

- Output trong notebook: stream: [Stage 0:>                                                          (0 + 1) / 1]

```python
df_green = spark.read.parquet('data/pq/green/*/*')
```

#### Cell 3 - markdown

```
SELECT 
    date_trunc('hour', lpep_pickup_datetime) AS hour, 
    PULocationID AS zone,

    SUM(total_amount) AS amount,
    COUNT(1) AS number_records
FROM
    green
WHERE
    lpep_pickup_datetime >= '2020-01-01 00:00:00'
GROUP BY
    1, 2
```

#### Cell 4 - code

- Output trong notebook: không có output lưu trong notebook

```python
rdd = df_green \
    .select('lpep_pickup_datetime', 'PULocationID', 'total_amount') \
    .rdd
```

#### Cell 5 - code

- Output trong notebook: không có output lưu trong notebook

```python
from datetime import datetime
```

#### Cell 6 - code

- Output trong notebook: không có output lưu trong notebook

```python
start = datetime(year=2020, month=1, day=1)

def filter_outliers(row):
    return row.lpep_pickup_datetime >= start
```

#### Cell 7 - code

- Output trong notebook: không có output lưu trong notebook

```python
rows = rdd.take(10)
row = rows[0]
```

#### Cell 8 - code

- Output trong notebook: execute_result: Row(lpep_pickup_datetime=datetime.datetime(2020, 1, 16, 19, 49, 27), PULocationID=260, total_amount=14.3)

```python
row
```

#### Cell 9 - code

- Output trong notebook: không có output lưu trong notebook

```python
def prepare_for_grouping(row): 
    hour = row.lpep_pickup_datetime.replace(minute=0, second=0, microsecond=0)
    zone = row.PULocationID
    key = (hour, zone)
    
    amount = row.total_amount
    count = 1
    value = (amount, count)

    return (key, value)
```

#### Cell 10 - code

- Output trong notebook: không có output lưu trong notebook

```python
def calculate_revenue(left_value, right_value):
    left_amount, left_count = left_value
    right_amount, right_count = right_value
    
    output_amount = left_amount + right_amount
    output_count = left_count + right_count
    
    return (output_amount, output_count)
```

#### Cell 11 - code

- Output trong notebook: không có output lưu trong notebook

```python
from collections import namedtuple
```

#### Cell 12 - code

- Output trong notebook: không có output lưu trong notebook

```python
RevenueRow = namedtuple('RevenueRow', ['hour', 'zone', 'revenue', 'count'])
```

#### Cell 13 - code

- Output trong notebook: không có output lưu trong notebook

```python
def unwrap(row):
    return RevenueRow(
        hour=row[0][0], 
        zone=row[0][1],
        revenue=row[1][0],
        count=row[1][1]
    )
```

#### Cell 14 - code

- Output trong notebook: không có output lưu trong notebook

```python
from pyspark.sql import types
```

#### Cell 15 - code

- Output trong notebook: không có output lưu trong notebook

```python
result_schema = types.StructType([
    types.StructField('hour', types.TimestampType(), True),
    types.StructField('zone', types.IntegerType(), True),
    types.StructField('revenue', types.DoubleType(), True),
    types.StructField('count', types.IntegerType(), True)
])
```

#### Cell 16 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_result = rdd \
    .filter(filter_outliers) \
    .map(prepare_for_grouping) \
    .reduceByKey(calculate_revenue) \
    .map(unwrap) \
    .toDF(result_schema)
```

#### Cell 17 - code

- Output trong notebook: stream: 

```python
df_result.write.parquet('tmp/green-revenue')
```

#### Cell 18 - code

- Output trong notebook: không có output lưu trong notebook

```python
columns = ['VendorID', 'lpep_pickup_datetime', 'PULocationID', 'DOLocationID', 'trip_distance']

duration_rdd = df_green \
    .select(columns) \
    .rdd
```

#### Cell 19 - code

- Output trong notebook: không có output lưu trong notebook

```python
import pandas as pd
```

#### Cell 20 - code

- Output trong notebook: không có output lưu trong notebook

```python
rows = duration_rdd.take(10)
```

#### Cell 21 - code

- Output trong notebook: không có output lưu trong notebook

```python
df = pd.DataFrame(rows, columns=columns)
```

#### Cell 22 - code

- Output trong notebook: execute_result: ['VendorID',

```python
columns
```

#### Cell 23 - code

- Output trong notebook: không có output lưu trong notebook

```python
#model = ...

def model_predict(df):
#     y_pred = model.predict(df)
    y_pred = df.trip_distance * 5
    return y_pred
```

#### Cell 24 - code

- Output trong notebook: không có output lưu trong notebook

```python
def apply_model_in_batch(rows):
    df = pd.DataFrame(rows, columns=columns)
    predictions = model_predict(df)
    df['predicted_duration'] = predictions

    for row in df.itertuples():
        yield row
```

#### Cell 25 - code

- Output trong notebook: stream: 

```python
df_predicts = duration_rdd \
    .mapPartitions(apply_model_in_batch)\
    .toDF() \
    .drop('Index')
```

#### Cell 26 - code

- Output trong notebook: stream: [Stage 48:>                                                         (0 + 1) / 1]; stream: +------------------+; stream: 

```python
df_predicts.select('predicted_duration').show()
```

#### Cell 27 - code

- Output trong notebook: không có output lưu trong notebook

```python

```


### [09_spark_gcs.ipynb]
- Mục tiêu notebook: Cấu hình Spark/Hadoop GCS connector bằng service account keyfile rồi đọc Parquet từ gs:// bucket.
- Operations chính: SparkConf, spark.jars, GCS Hadoop FS config, SparkContext(conf), SparkSession.builder.config, spark.read.parquet gs://, count
- Ghi chú phân tích: Auth method là service account JSON keyfile hardcoded local path.
- Cách connect GCS từ Spark: thêm GCS connector jar vào `spark.jars`, set Hadoop FS implementation/auth keys trên SparkConf, tạo SparkContext/SparkSession.
- Auth method được dùng: service account JSON keyfile local `/home/alexey/.google/credentials/google_credentials.json`.

Copy toàn bộ code/markdown cells theo thứ tự notebook:
#### Cell 1 - code

- Output trong notebook: không có output lưu trong notebook

```python
import pyspark
from pyspark.sql import SparkSession
from pyspark.conf import SparkConf
from pyspark.context import SparkContext
```

#### Cell 2 - code

- Output trong notebook: không có output lưu trong notebook

```python
credentials_location = '/home/alexey/.google/credentials/google_credentials.json'

conf = SparkConf() \
    .setMaster('local[*]') \
    .setAppName('test') \
    .set("spark.jars", "./lib/gcs-connector-hadoop3-2.2.5.jar") \
    .set("spark.hadoop.google.cloud.auth.service.account.enable", "true") \
    .set("spark.hadoop.google.cloud.auth.service.account.json.keyfile", credentials_location)
```

#### Cell 3 - code

- Output trong notebook: stream: WARNING: An illegal reflective access operation has occurred

```python
sc = SparkContext(conf=conf)

hadoop_conf = sc._jsc.hadoopConfiguration()

hadoop_conf.set("fs.AbstractFileSystem.gs.impl",  "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS")
hadoop_conf.set("fs.gs.impl", "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem")
hadoop_conf.set("fs.gs.auth.service.account.json.keyfile", credentials_location)
hadoop_conf.set("fs.gs.auth.service.account.enable", "true")
```

#### Cell 4 - code

- Output trong notebook: không có output lưu trong notebook

```python
spark = SparkSession.builder \
    .config(conf=sc.getConf()) \
    .getOrCreate()
```

#### Cell 5 - code

- Output trong notebook: stream: 

```python
df_green = spark.read.parquet('gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/*/*')
```

#### Cell 6 - code

- Output trong notebook: stream: ; execute_result: 2304517

```python
df_green.count()
```

#### Cell 7 - code

- Output trong notebook: không có output lưu trong notebook

```python

```


### [cloud.md]
- Copy nguyên văn toàn bộ file:
````markdown
## Running Spark in the Cloud

### Connecting to Google Cloud Storage 

Uploading data to GCS:

```bash
gsutil -m cp -r pq/ gs://dtc_data_lake_de-zoomcamp-nytaxi/pq
```

Download the jar for connecting to GCS to any location (e.g. the `lib` folder):

**Note**: For other versions of GCS connector for Hadoop see [Cloud Storage connector ](https://cloud.google.com/dataproc/docs/concepts/connectors/cloud-storage#connector-setup-on-non-dataproc-clusters).

```bash
gsutil cp gs://hadoop-lib/gcs/gcs-connector-hadoop3-2.2.5.jar ./lib/
```

See the notebook with configuration in [09_spark_gcs.ipynb](09_spark_gcs.ipynb)

(Thanks Alvin Do for the instructions!)


### Local Cluster and Spark-Submit

Creating a stand-alone cluster ([docs](https://spark.apache.org/docs/latest/spark-standalone.html)):

```bash
./sbin/start-master.sh
```

Creating a worker:

```bash
URL="spark://de-zoomcamp.europe-west1-b.c.de-zoomcamp-nytaxi.internal:7077"
./sbin/start-slave.sh ${URL}

# for newer versions of spark use that:
#./sbin/start-worker.sh ${URL}
```

Turn the notebook into a script:

```bash
jupyter nbconvert --to=script 06_spark_sql.ipynb
```

Edit the script and then run it:

```bash 
python 06_spark_sql.py \
    --input_green=data/pq/green/2020/*/ \
    --input_yellow=data/pq/yellow/2020/*/ \
    --output=data/report-2020
```

Use `spark-submit` for running the script on the cluster

```bash
URL="spark://de-zoomcamp.europe-west1-b.c.de-zoomcamp-nytaxi.internal:7077"

spark-submit \
    --master="${URL}" \
    06_spark_sql.py \
        --input_green=data/pq/green/2021/*/ \
        --input_yellow=data/pq/yellow/2021/*/ \
        --output=data/report-2021
```

### Data Proc

Upload the script to GCS:

```bash
gsutil -m cp -r 06_spark_sql.py gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql.py
```

Params for the job:

* `--input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2021/*/`
* `--input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2021/*/`
* `--output=gs://dtc_data_lake_de-zoomcamp-nytaxi/report-2021`


Using Google Cloud SDK for submitting to dataproc
([link](https://cloud.google.com/dataproc/docs/guides/submit-job#dataproc-submit-job-gcloud))

```bash
gcloud dataproc jobs submit pyspark \
    --cluster=de-zoomcamp-cluster \
    --region=europe-west6 \
    gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql.py \
    -- \
        --input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2020/*/ \
        --input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2020/*/ \
        --output=gs://dtc_data_lake_de-zoomcamp-nytaxi/report-2020
```

### Big Query

Upload the script to GCS:

```bash
gsutil -m cp -r 06_spark_sql_big_query.py gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql_big_query.py
```

Write results to big query ([docs](https://cloud.google.com/dataproc/docs/tutorials/bigquery-connector-spark-example#pyspark)):

```bash
gcloud dataproc jobs submit pyspark \
    --cluster=de-zoomcamp-cluster \
    --region=europe-west6 \
    --jars=gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar \
    gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql_big_query.py \
    -- \
        --input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2020/*/ \
        --input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2020/*/ \
        --output=trips_data_all.reports-2020
```

There can be issue with latest Spark version and the Big query connector. Download links to the jar file for respective Spark versions can be found at:
[Spark and Big query connector](https://github.com/GoogleCloudDataproc/spark-bigquery-connector)

**Note**: Dataproc on GCE 2.1+ images pre-install Spark BigQquery connector: [DataProc Release 2.2](https://cloud.google.com/dataproc/docs/concepts/versioning/dataproc-release-2.2). Therefore, no need to include the jar file in the job submission.
````


### [homework.ipynb]
- Mục tiêu notebook: Homework Spark: version, repartition FHVHV Feb 2021, count Feb 15 trips, longest trip, frequent dispatching_base_num, common zone pair.
- Đề bài từng câu hỏi:
  - Cell 8: **Q3**: How many taxi trips were there on February 15?
  - Cell 13: **Q4**: Longest trip for each day
  - Cell 17: **Q5**: Most frequent `dispatching_base_num`

How many stages this spark job has?
  - Cell 20: **Q6**: Most common locations pair
- Q1/Q2 được thể hiện qua code: kiểm tra `spark.version`, đọc CSV FHVHV Feb 2021 với schema, repartition 24 và ghi Parquet.

Copy toàn bộ code/markdown cells theo thứ tự notebook:
#### Cell 1 - code

- Output trong notebook: không có output lưu trong notebook

```python
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql import types
```

#### Cell 2 - code

- Output trong notebook: stream: WARNING: An illegal reflective access operation has occurred

```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```

#### Cell 3 - code

- Output trong notebook: execute_result: '3.0.3'

```python
spark.version
```

#### Cell 4 - code

- Output trong notebook: stream: -rw-rw-r-- 1 alexey alexey 700M Oct 29 18:53 fhvhv_tripdata_2021-02.csv

```python
!ls -lh fhvhv_tripdata_2021-02.csv
```

#### Cell 5 - code

- Output trong notebook: không có output lưu trong notebook

```python
schema = types.StructType([
    types.StructField('hvfhs_license_num', types.StringType(), True),
    types.StructField('dispatching_base_num', types.StringType(), True),
    types.StructField('pickup_datetime', types.TimestampType(), True),
    types.StructField('dropoff_datetime', types.TimestampType(), True),
    types.StructField('PULocationID', types.IntegerType(), True),
    types.StructField('DOLocationID', types.IntegerType(), True),
    types.StructField('SR_Flag', types.StringType(), True)
])
```

#### Cell 6 - code

- Output trong notebook: không có output lưu trong notebook

```python
df = spark.read \
    .option("header", "true") \
    .schema(schema) \
    .csv('fhvhv_tripdata_2021-02.csv')

df = df.repartition(24)

df.write.parquet('data/pq/fhvhv/2021/02/', compression=)
```

#### Cell 7 - code

- Output trong notebook: stream: [Stage 0:>                                                          (0 + 1) / 1]

```python
df = spark.read.parquet('data/pq/fhvhv/2021/02/')
```

#### Cell 8 - markdown

**Q3**: How many taxi trips were there on February 15?

#### Cell 9 - code

- Output trong notebook: không có output lưu trong notebook

```python
from pyspark.sql import functions as F
```

#### Cell 10 - code

- Output trong notebook: stream: ; execute_result: 367170

```python
df \
    .withColumn('pickup_date', F.to_date(df.pickup_datetime)) \
    .filter("pickup_date = '2021-02-15'") \
    .count()
```

#### Cell 11 - code

- Output trong notebook: không có output lưu trong notebook

```python
df.registerTempTable('fhvhv_2021_02')
```

#### Cell 12 - code

- Output trong notebook: stream: [Stage 20:>                                                         (0 + 4) / 4]; stream: +--------+; stream: [Stage 20:==============>                                           (1 + 3) / 4]

```python
spark.sql("""
SELECT
    COUNT(1)
FROM 
    fhvhv_2021_02
WHERE
    to_date(pickup_datetime) = '2021-02-15';
""").show()
```

#### Cell 13 - markdown

**Q4**: Longest trip for each day

#### Cell 14 - code

- Output trong notebook: execute_result: ['hvfhs_license_num',

```python
df.columns
```

#### Cell 15 - code

- Output trong notebook: stream: [Stage 37:==============>                                           (1 + 3) / 4]; stream: +-----------+-------------+; stream: [Stage 38:==================================================>   (187 + 4) / 200]

```python
df \
    .withColumn('duration', df.dropoff_datetime.cast('long') - df.pickup_datetime.cast('long')) \
    .withColumn('pickup_date', F.to_date(df.pickup_datetime)) \
    .groupBy('pickup_date') \
        .max('duration') \
    .orderBy('max(duration)', ascending=False) \
    .limit(5) \
    .show()
```

#### Cell 16 - code

- Output trong notebook: stream: [Stage 43:>                                                         (0 + 4) / 4]; stream: +-----------+-----------------+; stream: [Stage 44:================================================>     (180 + 4) / 200]

```python
spark.sql("""
SELECT
    to_date(pickup_datetime) AS pickup_date,
    MAX((CAST(dropoff_datetime AS LONG) - CAST(pickup_datetime AS LONG)) / 60) AS duration
FROM 
    fhvhv_2021_02
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 10;
""").show()
```

#### Cell 17 - markdown

**Q5**: Most frequent `dispatching_base_num`

How many stages this spark job has?

#### Cell 18 - code

- Output trong notebook: stream: [Stage 73:>                                                         (0 + 4) / 4]; stream: +--------------------+--------+; stream: [Stage 74:===================================================>  (189 + 5) / 200]

```python
spark.sql("""
SELECT
    dispatching_base_num,
    COUNT(1)
FROM 
    fhvhv_2021_02
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 5;
""").show()
```

#### Cell 19 - code

- Output trong notebook: stream: [Stage 86:>                                                         (0 + 4) / 4]; stream: +--------------------+-------+; stream: [Stage 87:===========================================>          (161 + 5) / 200]

```python
df \
    .groupBy('dispatching_base_num') \
        .count() \
    .orderBy('count', ascending=False) \
    .limit(5) \
    .show()
```

#### Cell 20 - markdown

**Q6**: Most common locations pair

#### Cell 21 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_zones = spark.read.parquet('zones')
```

#### Cell 22 - code

- Output trong notebook: execute_result: ['LocationID', 'Borough', 'Zone', 'service_zone']

```python
df_zones.columns
```

#### Cell 23 - code

- Output trong notebook: execute_result: ['hvfhs_license_num',

```python
df.columns
```

#### Cell 24 - code

- Output trong notebook: không có output lưu trong notebook

```python
df_zones.registerTempTable('zones')
```

#### Cell 25 - code

- Output trong notebook: stream: [Stage 103:==============================================>      (176 + 4) / 200]; stream: +--------------------+--------+; stream: 

```python
spark.sql("""
SELECT
    CONCAT(pul.Zone, ' / ', dol.Zone) AS pu_do_pair,
    COUNT(1)
FROM 
    fhvhv_2021_02 fhv LEFT JOIN zones pul ON fhv.PULocationID = pul.LocationID
                      LEFT JOIN zones dol ON fhv.DOLocationID = dol.LocationID
GROUP BY 
    1
ORDER BY
    2 DESC
LIMIT 5;
""").show()
```

#### Cell 26 - code

- Output trong notebook: không có output lưu trong notebook

```python

```


## 4. DATA FLOW THỰC TẾ

- Flow: `download_data.sh` tải raw CSV gzip từ GitHub releases -> `data/raw/{type}/{year}/{month}`; `05_taxi_schema.ipynb` đọc raw, áp schema, repartition, ghi Parquet `data/pq/{type}/{year}/{month}`; `06_spark_sql.ipynb`/`.py` đọc Parquet green/yellow, chuẩn hóa cột, union, aggregate revenue, ghi report Parquet; `06_spark_sql_big_query.py` ghi BigQuery; `09_spark_gcs.ipynb` đọc Parquet từ GCS khi bucket đã có dữ liệu.
- File trigger file nào: không có orchestrator; chạy thủ công. `cloud.md` hướng dẫn `jupyter nbconvert` tạo script từ notebook và submit bằng `spark-submit`/`gcloud dataproc jobs submit`.
- Thứ tự chạy đúng: setup Java/PySpark -> download raw -> chạy `05_taxi_schema.ipynb` ingest Parquet -> chạy `06_spark_sql.ipynb` local hoặc `06_spark_sql.py` bằng python/spark-submit -> optional `07_groupby_join.ipynb`/`08_rdds.ipynb` -> optional upload GCS/submit Dataproc -> optional write BigQuery.
- Dependencies: `04_pyspark.ipynb` tự download FHVHV sample; `05_taxi_schema.ipynb` phụ thuộc raw data; `06_*`, `07_*`, `08_*` phụ thuộc `data/pq`; `07_*` thêm `zones/`; `09_*` phụ thuộc GCS connector jar, service account key và bucket; BigQuery script phụ thuộc connector, temporary bucket, IAM.
- Local Spark vs GCP: local dùng filesystem path và local/standalone master; GCP dùng `gs://`, Dataproc, service account/IAM, BigQuery connector và temporary GCS bucket.

## 5. ĐIỂM YẾU & THIẾU SÓT

### Security issues
- Hardcode service account key path trong `core-site.xml`, `spark-defaults.conf`, `09_spark_gcs.ipynb`.
- `06_spark_sql_big_query.py` hardcode `temporaryGcsBucket` theo project cá nhân.
- Bucket/project/table names hardcoded; thiếu secret management, IAM least privilege, workload identity guidance.

### Performance issues
- `coalesce(1)` tạo single output file nhưng bottleneck và phá parallelism.
- `repartition(4)`/`repartition(20)` hardcoded không dựa trên data size/cluster cores.
- Wildcard đọc rộng, thiếu partition pruning rõ ràng theo year/month.
- Join không broadcast dimension nhỏ `zones`; không phân tích skew, shuffle size, AQE.
- Không tune executor memory/cores, shuffle partitions, cache/persist, target file size.

### Idempotency issues
- `download_data.sh` overwrite file, không checksum, retry/backoff, partial-download cleanup.
- Notebook dùng overwrite có thể xóa output tốt nếu path/input nhầm.
- Không có manifest/run marker để biết partition nào ingest thành công.

### Production readiness gaps
- Không có orchestration DAG, config/env separation, structured logging, retry policy.
- Không có schema evolution, bad-record quarantine, data quality gates.
- Không package job thành artifact; không CI/CD, tests, lineage/catalog, cost controls.

### Monitoring & observability gaps
- Không emit metrics record counts/input bytes/output bytes/null rates/shuffle spill/duration.
- Không alert thiếu partition, row count bất thường, job fail, BigQuery partial write.
- Không ghi run_id, source version, schema version, git sha.

### Những gì repo dạy nhưng không đủ cho Senior DE
- Repo dạy thao tác Spark căn bản nhưng chưa sâu Catalyst/physical plan, memory model, shuffle internals, skew mitigation.
- Chưa dạy batch production: SLA, backfill, incremental loads, idempotency, data contracts.
- Chưa dạy vận hành cloud production: IAM, Dataproc autoscaling, cost/performance tuning, observability.

## 6. KIẾN THỨC NGOÀI REPO

### Spark Core & Internals
- DAG scheduler vs task scheduler
- jobs/stages/tasks
- narrow vs wide dependencies
- Catalyst logical/optimized/physical plans
- Tungsten execution
- whole-stage codegen
- executor JVM memory model
- serialization
- spill to disk
- lineage and fault tolerance
- checkpointing
- speculative execution

### Spark Optimization & Tuning
- partition sizing and file sizing
- spark.sql.shuffle.partitions
- AQE
- broadcast/hash/sort-merge joins
- skew join handling and salting
- predicate/projection pushdown
- Parquet statistics
- bucketing and partitioning tradeoffs
- cache/persist strategy
- executor cores/memory overhead
- dynamic allocation
- small files compaction
- explain plans and Spark UI debugging

### Spark Streaming
- Structured Streaming
- micro-batch vs continuous
- watermarking
- stateful aggregations
- checkpoint location
- output modes
- Kafka source/sink semantics
- late data
- exactly-once boundaries
- streaming joins
- backpressure

### GCP Dataproc
- cluster vs serverless batches
- initialization actions
- custom images
- autoscaling policies
- preemptible/spot workers
- service accounts/IAM scopes
- network/subnet/private Google access
- component gateway/Spark History Server
- workflow templates
- Dataproc Metastore
- job labels and cost attribution

### BigQuery + Spark integration
- direct vs indirect write methods
- temporary bucket lifecycle
- BigQuery Storage API reads
- write dispositions
- table partitioning/clustering
- schema mapping
- materialization dataset for views
- connector compatibility
- parallelism controls
- MERGE/upsert patterns

### Pipeline/Batch Engineering
- incremental ingestion
- backfill/reprocessing design
- idempotent writes
- atomic publish patterns
- bronze/silver/gold layers
- data contracts
- schema registry/evolution
- orchestration
- SLA/SLO
- run metadata and lineage
- environment config
- artifact packaging

### Testing & Data Quality
- unit tests for transformations
- Spark local integration tests
- golden datasets
- property-based tests
- Great Expectations/Deequ/Soda
- row-count/freshness checks
- schema validation
- null/range/uniqueness constraints
- source reconciliation
- data diffing
- CI for notebooks/scripts
