# PROMPT_Review_Module_06.md
# Review toàn diện file Module06_Batch_Spark.html

> Dùng cho: Antigravity review code sau khi Claude build xong 5 prompts
> Mục tiêu: Phát hiện lỗi kỹ thuật, nội dung sai, UX hỏng, thiếu sót so với spec
> Cách chạy: Paste toàn bộ prompt này vào Antigravity sau khi có file .html

---

## BƯỚC 0 — ĐỌC FILE TRƯỚC KHI LÀM BẤT CỨ ĐIỀU GÌ

```
Đọc TOÀN BỘ các file sau theo thứ tự:

1. Module06_Batch_Spark.html                       ← file cần review
2. module_template.html                            ← chuẩn gốc về CSS/component
3. master_de_roadmap.html                          ← spec Module 06 và DoD
4. data-engineering-zoomcamp/06-batch/code/download_data.sh
5. data-engineering-zoomcamp/06-batch/code/06_spark_sql.py
6. data-engineering-zoomcamp/06-batch/code/06_spark_sql_big_query.py
7. data-engineering-zoomcamp/06-batch/code/cloud.md
8. data-engineering-zoomcamp/06-batch/setup/config/core-site.xml
9. data-engineering-zoomcamp/06-batch/setup/config/spark-defaults.conf
10. data-engineering-zoomcamp/06-batch/setup/config/spark.dockerfile

KHÔNG bắt đầu review cho đến khi đã đọc xong tất cả 10 file.
Mục đích: review phải đối chiếu HTML với source code thực tế,
không thể review đúng nếu chỉ đọc HTML một mình.
```

---

## BƯỚC 1 — KIỂM TRA KỸ THUẬT HTML/CSS/JS

```
Kiểm tra toàn bộ phần kỹ thuật của file. Với mỗi mục, ghi rõ:
PASS / FAIL / WARNING + mô tả cụ thể nếu không pass.

═══════════════════════════════
1.1 HTML STRUCTURE
═══════════════════════════════

□ File có đúng DOCTYPE html không?
□ <head> có đủ: charset UTF-8, viewport meta, title, Google Fonts link?
□ Title tag đúng: "Module 06 — Batch Processing với Apache Spark"?
□ Không có broken tag nào (thẻ mở không có thẻ đóng)?
□ Tất cả 9 section div tồn tại: id="s0" đến id="s8"?
□ Không còn placeholder nào dạng <p>Đang xây dựng...</p> trong bất kỳ section nào?

═══════════════════════════════
1.2 CSS VARIABLES
═══════════════════════════════

So sánh với module_template.html — kiểm tra từng biến:
□ --color-primary tồn tại và đúng giá trị?
□ --color-secondary tồn tại và đúng giá trị?
□ --color-accent tồn tại và đúng giá trị?
□ --color-bg, --color-surface, --color-border tồn tại?
□ --font-main, --font-mono tồn tại?
□ --radius, --shadow tồn tại?
□ Tất cả component classes từ template có trong file:
  .hero-banner, .sidebar, .nav-item, .section-content,
  .info-box (tip/warn/note/danger), .quiz-block, .practice-task,
  .data-table, .code-block, .tab-container, .checklist-item,
  .badge, .progress-bar?
□ Không có CSS custom nào override template theo cách gây visual bug?

═══════════════════════════════
1.3 JAVASCRIPT FUNCTIONS
═══════════════════════════════

□ showModule(index) tồn tại và hoạt động đúng không?
  → Test: click S1 → S1 hiện, S0 ẩn, nav item S1 active
□ toggleSection(id) tồn tại?
  → Dùng cho collapsible answers trong S7 interview
□ answerQuiz(questionId, answer, correct) tồn tại?
  → Click đáp án đúng → hiển thị "Đúng!" + explanation
  → Click đáp án sai → hiển thị "Sai" + explanation
□ toggleSolution(taskId) tồn tại?
  → Dùng trong S3 practice tasks — show/hide solution
□ switchTab(tabGroup, tabName) tồn tại?
  → Dùng trong S2 cho tab groups (download_data | config | notebooks...)
□ toggleCheck(itemId) tồn tại?
  → Dùng cho checklist S8 — tick/untick item
□ updateProgress() tồn tại và được gọi sau mỗi toggleCheck?
  → Progress bar S8 tự cập nhật số item hoàn thành / tổng
□ Không có lỗi JavaScript nào (undefined function, syntax error)?
□ Không có lỗi console khi mở file trên browser?

═══════════════════════════════
1.4 NAVIGATION & SIDEBAR
═══════════════════════════════

□ Sidebar có đủ 9 nav items: S0 đến S8?
□ Tên từng nav item đúng:
  S0: Tổng quan & Mục tiêu
  S1: Lý thuyết nền
  S2: Đọc hiểu code repo
  S3: Thực hành từng bước
  S4: Production Readiness
  S5: Kiến thức nâng cao
  S6: Lỗi thường gặp
  S7: Interview Prep
  S8: Checklist & Tổng kết
□ S0 active mặc định khi mở file?
□ Click từng nav item → đúng section hiện lên?
□ Không có nav item nào click → màn hình trắng hoặc lỗi?

═══════════════════════════════
1.5 RESPONSIVE & VISUAL
═══════════════════════════════

□ File mở được trên Chrome/Firefox không lỗi layout?
□ Sidebar và main content không overlap nhau?
□ Code blocks có monospace font (JetBrains Mono)?
□ Tables không tràn ra ngoài container?
□ Info boxes (tip/warn/note/danger) hiển thị đúng màu?
□ Badge colors đúng: Junior=xanh lam, Mid=vàng, Senior=đỏ?
□ Progress bar S8 render đúng — không bị cứng đờ ở 0%?
□ Tab switcher trong S2 hoạt động — click tab → content đổi?

Báo cáo tất cả FAIL và WARNING với dòng code cụ thể (line number).
```

---

## BƯỚC 2 — KIỂM TRA NỘI DUNG TỪNG SECTION

```
Đọc từng section, đối chiếu với spec build prompt và source code thực tế.
Format báo cáo: ✅ PASS | ⚠️ WARNING | ❌ FAIL

═══════════════════════════════
S0 — TỔNG QUAN & MỤC TIÊU
═══════════════════════════════

□ Có Hero Banner với title đúng "Module 06 — Batch Processing với Apache Spark"?
□ Có bảng 9 sections với tên và thời gian ước tính?
□ Có giải thích "tại sao Spark, không phải pandas" — nêu single-machine limit?
□ Có đề cập Hadoop MapReduce là predecessor không?
□ Có 2 data flow diagram ASCII:
  Flow A (Local): download_data.sh → CSV.gz → 05_taxi_schema → Parquet → 06_spark_sql → report Parquet
  Flow B (Cloud): Parquet → GCS → Dataproc → BigQuery
□ Có Exit Criteria "Bạn đã nắm module này khi..." với ít nhất 5 điểm cụ thể?

═══════════════════════════════
S1 — LÝ THUYẾT NỀN
═══════════════════════════════

Phần Batch vs Spark Overview:
□ Có bảng Batch vs Stream Processing tối thiểu 5 chiều so sánh?
□ Có giải thích Spark architecture: Driver → SparkContext → Executors?
□ Có phân biệt rõ Local mode vs Standalone vs YARN?
□ Có giải thích Lazy Evaluation với ví dụ transformation vs action?
□ Có mental model 1 câu về Spark?
□ Có 6 câu quiz với 4 đáp án và explanation?

Phần RDD, DataFrame, Dataset:
□ Có bảng so sánh RDD vs DataFrame vs Dataset?
□ Có giải thích Narrow vs Wide Dependencies với ASCII diagram?
□ Có giải thích repartition vs coalesce với trade-offs cụ thể?
□ Có Senior box về Catalyst 4 phases (Analysis → Logical Opt → Physical Planning → Codegen)?
□ Có giải thích cách đọc df.explain(True)?
□ Có 6 câu quiz với 4 đáp án và explanation?

Phần File Formats:
□ Có bảng so sánh CSV vs Parquet (ít nhất) với: encoding, schema, splittable, compression?
□ Có giải thích tại sao Parquet phù hợp với Spark?
□ Có đề cập schema inference vấn đề production vs define StructType?
□ Có 6 câu quiz với 4 đáp án và explanation?

═══════════════════════════════
S2 — ĐỌC HIỂU CODE REPO
═══════════════════════════════

□ Có tree diagram thư mục 06-batch/ đầy đủ?
  Kiểm tra có đủ: code/, setup/, config/, README.md, cloud.md, download_data.sh,
  04_pyspark.ipynb → 09_spark_gcs.ipynb, homework.ipynb

Phần download_data.sh:
□ Có trích code nguyên văn (set -e, loop {1..12}, printf "%02d", wget)?
□ Đúng URL_PREFIX: https://github.com/DataTalksClub/nyc-tlc-data/releases/download?
□ Đúng local path pattern: data/raw/{TAXI_TYPE}/{YEAR}/{FMONTH}/?
□ Có giải thích các arguments: $1=TAXI_TYPE, $2=YEAR?
□ Có warn box về các điểm yếu (không checksum, không skip-if-exists)?

Phần Config files:
□ Có core-site.xml nguyên văn (4 properties: AbstractFileSystem, gs.impl, keyfile, enable)?
□ Có spark-defaults.conf nguyên văn (3 dòng)?
□ Có cảnh báo về "spark-master" key SAI (phải là "spark.master")?
□ Có cảnh báo về path keyfile thiếu tên file JSON?
□ Có spark.dockerfile nguyên văn (chỉ 1 dòng FROM library/openjdk:11)?

Phần Schema Notebooks (04, 05):
□ Có Schema FHVHV đầy đủ 7 fields với đúng types:
  hvfhs_license_num: StringType
  dispatching_base_num: StringType
  pickup_datetime: TimestampType
  dropoff_datetime: TimestampType
  PULocationID: IntegerType
  DOLocationID: IntegerType
  SR_Flag: StringType
□ Có Schema Green đầy đủ 20 fields? (lpep_pickup/dropoff, VendorID, RatecodeID, PULocationID, DOLocationID, ...)
□ Có Schema Yellow đầy đủ 18 fields? (tpep_pickup/dropoff, VendorID, ...)
□ Có UDF crazy_stuff() code nguyên văn?

Phần SQL Scripts (06):
□ Có 06_spark_sql.py toàn bộ file (argparse, SparkSession, rename, common_columns, union, SQL, write)?
□ Có 06_spark_sql_big_query.py toàn bộ file (BigQuery connector config, temporaryGcsBucket, write format bigquery)?
□ Có tab cloud.md với đủ 4 tabs: Local Cluster, spark-submit, Dataproc, BigQuery?

Phần Homework:
□ Có 6 câu hỏi homework với đề bài (Q1-Q6)?
□ Answer Q3 = 367170 (trips on Feb 15)?

═══════════════════════════════
S3 — THỰC HÀNH TỪNG BƯỚC
═══════════════════════════════

□ Có ít nhất 5 tasks với độ khó tăng dần: Junior → Mid → Senior?
□ Task 1 (Hello PySpark): SparkSession, download, read CSV, printSchema?
□ Task 2 (Parquet Pipeline): repartition, write, read back, coalesce(1) so sánh?
□ Task 3 (Transformations): select, filter, withColumn, UDF?
□ Task 4 (Spark SQL + Union): rename, common_columns, unionAll, registerTempTable, revenue SQL?
□ Task 5 (GroupBy, Join, RDD): broadcast join, RDD reduceByKey?
□ Task 6 ("Cố tình phá"): ít nhất 4 kịch bản lỗi với debug steps cụ thể?
□ Mỗi task có toggleSolution để show/hide solution?
□ Expected output box hiện sau mỗi task?
□ warn box về UDF performance có trong Task 3?

═══════════════════════════════
S4 — PRODUCTION READINESS
═══════════════════════════════

□ Có bảng Security Issues với ít nhất 4 files từ repo: core-site.xml, spark-defaults.conf, 06_spark_sql_big_query.py, 09_spark_gcs.ipynb?
□ Có code pattern an toàn hơn: os.environ.get() thay hardcode?
□ Có cải thiện download_data.sh: skip-if-exists, retry logic?
□ Có giải thích idempotent Spark writes: mode("overwrite").partitionBy()?
□ Có công thức chọn số partitions: target 100-200MB, tính từ data size?
□ Có AQE config: spark.sql.adaptive.enabled=true?
□ Có Spark UI guide: Jobs/Stages/Storage/SQL tab, tìm gì ở đâu?
□ Có structured logging pattern với logger và timing?
□ Có bảng Dataproc cluster types: Standard vs Single-node vs Serverless?

═══════════════════════════════
S5 — KIẾN THỨC NÂNG CAO
═══════════════════════════════

□ Có Catalyst 4 phases với giải thích từng phase?
□ Có Executor Memory Model: execution / storage / user / overhead với % chia?
□ Có bảng Join Strategies: Broadcast Hash / Sort-Merge / Shuffle Hash / BNLJ — khi nào trigger?
□ Có giải thích và code demo Skew Join Handling (salting)?
□ Có so sánh Full load vs Incremental batch với code pattern partition-based?
□ Có giải thích BigQuery direct vs indirect write?
□ Có Structured Streaming introduction: readStream, writeStream, trigger, watermark?

═══════════════════════════════
S6 — LỖI THƯỜNG GẶP
═══════════════════════════════

□ Có ít nhất 7 lỗi?
□ Mỗi lỗi có: error message thực tế, nguyên nhân, debug steps, fix?
□ Lỗi 1: JAVA_HOME not set — có trong không?
□ Lỗi 2: AnalysisException Column not found?
□ Lỗi 3: Path does not exist local?
□ Lỗi 4: GCS 403 Forbidden?
□ Lỗi 5: OOM — có đề cập collect() và shuffle spill?
□ Lỗi 6: BigQuery connector version mismatch?
□ Lỗi 7: spark-defaults.conf key sai (spark-master vs spark.master)?
□ Debug steps theo thứ tự cụ thể (không chỉ "kiểm tra lại")?

═══════════════════════════════
S7 — INTERVIEW PREP
═══════════════════════════════

□ Có phân chia rõ: Junior / Mid / Senior badge?
□ Có ít nhất 3 câu Junior, 3 câu Mid, 3 câu Senior?
□ Câu Senior có thực sự phức tạp không (UDF performance, skew, production design)?
□ Mỗi câu có toggleSection để expand answer?
□ Answer không chỉ là định nghĩa — có trade-offs và ví dụ cụ thể?
□ Q6 (data flow): trả lời đúng pipeline từ download_data.sh → BigQuery?
□ Q7: registerTempTable deprecated → createOrReplaceTempView?
□ Q10 (Senior production design): có ít nhất 8 thứ cần thêm ngoài repo?

═══════════════════════════════
S8 — CHECKLIST & TỔNG KẾT
═══════════════════════════════

□ Có progress bar hiển thị X / N items?
□ Có đủ 20 checklist items (hoặc ít nhất 16)?
□ 4 nhóm: Setup, Parquet Pipeline, Spark SQL, Cloud, Production Mindset?
□ Items có actionable và verifiable — không phải "hiểu Spark"
  (ví dụ: "ls data/pq/fhvhv/2021/01/ cho thấy 24 file part-*.parquet")?
□ updateProgress() chạy đúng khi tick?
□ Có bảng tóm tắt "File nào → Học được gì" với 10 files từ repo?
□ Có bảng "Concept đã học vs Production gap"?
□ Có link Preview module tiếp theo: href="Module07_Streaming.html"?
  Text: "Module tiếp theo: Streaming với Kafka và Spark Structured Streaming"?
```

---

## BƯỚC 3 — FACT-CHECK KỸ THUẬT

```
Đây là phần quan trọng nhất. Đối chiếu từng claim kỹ thuật trong HTML
với source code thực tế trong repo. Ghi rõ từng sai lệch.

═══════════════════════════════
3.1 BASH SCRIPT ACCURACY — đối chiếu với download_data.sh
═══════════════════════════════

□ URL_PREFIX đúng: https://github.com/DataTalksClub/nyc-tlc-data/releases/download
□ URL pattern đúng: ${URL_PREFIX}/${TAXI_TYPE}/${TAXI_TYPE}_tripdata_${YEAR}-${FMONTH}.csv.gz
□ Local path đúng: data/raw/${TAXI_TYPE}/${YEAR}/${FMONTH}/
□ Local filename đúng: ${TAXI_TYPE}_tripdata_${YEAR}_${FMONTH}.csv.gz
  (chú ý: dấu _ thay vì - trong tên file local)
□ Loop đúng: for MONTH in {1..12} — không phải range(1, 13)
□ set -e ở dòng đầu tiên không phải cuối
□ Dùng wget, không phải curl

═══════════════════════════════
3.2 CONFIG FILES ACCURACY
═══════════════════════════════

□ core-site.xml: fs.AbstractFileSystem.gs.impl = com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS
□ core-site.xml: fs.gs.impl = com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem
□ core-site.xml: keyfile path = /home/alexey/.google/credentials/google_credentials.json
  (path cụ thể này, không phải path khác)
□ spark-defaults.conf: key đầu tiên là "spark-master" (KHÔNG phải "spark.master")
  → Đây là lỗi trong repo, HTML phải ghi nhận đây là lỗi, không phải đúng
□ spark-defaults.conf: keyfile path = /home/alexey (THIẾU tên file JSON)
  → Đây là lỗi trong repo, HTML phải ghi nhận
□ spark.dockerfile: chỉ có 1 dòng duy nhất: FROM library/openjdk:11

═══════════════════════════════
3.3 SCHEMA ACCURACY — đối chiếu với 04_pyspark.ipynb và 05_taxi_schema.ipynb
═══════════════════════════════

Verify schema FHVHV (7 fields) — thứ tự phải đúng:
□ hvfhs_license_num: StringType
□ dispatching_base_num: StringType
□ pickup_datetime: TimestampType (không phải StringType)
□ dropoff_datetime: TimestampType (không phải StringType)
□ PULocationID: IntegerType (không phải LongType)
□ DOLocationID: IntegerType (không phải LongType)
□ SR_Flag: StringType

Verify schema Green (20 fields) — check types không sai:
□ VendorID: IntegerType (không phải LongType hay StringType)
□ lpep_pickup_datetime: TimestampType
□ lpep_dropoff_datetime: TimestampType
□ trip_distance: DoubleType (không phải FloatType)
□ ehail_fee: DoubleType — field này CHỈ có trong Green, không có Yellow

Verify schema Yellow (18 fields) — kiểm tra:
□ tpep_pickup_datetime: TimestampType (không phải lpep)
□ tpep_dropoff_datetime: TimestampType (không phải lpep)
□ Không có ehail_fee trong Yellow

═══════════════════════════════
3.4 PYTHON SCRIPT ACCURACY — đối chiếu với 06_spark_sql.py và 06_spark_sql_big_query.py
═══════════════════════════════

06_spark_sql.py:
□ argparse arguments đúng: --input_green, --input_yellow, --output
□ SparkSession appName đúng: 'test' (theo repo)
□ Rename columns đúng:
  lpep_pickup_datetime → pickup_datetime (GREEN)
  lpep_dropoff_datetime → dropoff_datetime (GREEN)
  tpep_pickup_datetime → pickup_datetime (YELLOW)
  tpep_dropoff_datetime → dropoff_datetime (YELLOW)
□ Revenue SQL đầy đủ: SUM fare/extra/mta_tax/tip/tolls/improvement/total, AVG passenger/distance
□ Output dùng: df_result.coalesce(1).write.parquet(output, mode='overwrite')

06_spark_sql_big_query.py:
□ BigQuery connector config: .config("temporaryGcsBucket", ...)
□ Output format: df_result.write.format('bigquery').save(output)
□ Hardcode temporaryGcsBucket — HTML phải flag đây là security issue

═══════════════════════════════
3.5 CLOUD COMMANDS ACCURACY — đối chiếu với cloud.md
═══════════════════════════════

□ GCS connector đúng: gsutil cp gs://hadoop-lib/gcs/gcs-connector-hadoop3-2.2.5.jar ./lib/
□ Start master: ./sbin/start-master.sh
□ Start worker: ./sbin/start-worker.sh ${URL} (Spark 4.x dùng start-worker, không phải start-slave)
□ Dataproc submit đúng region: europe-west6 (trong cloud.md)
□ BigQuery jar đúng: gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar
□ Dataproc 2.1+: không cần --jars cho BigQuery connector

═══════════════════════════════
3.6 CONCEPT ACCURACY
═══════════════════════════════

□ coalesce(1) tạo ĐÚNG 1 file Parquet output — không phải "nhiều hơn 1"
□ repartition(4) tạo ĐÚNG 4 file — không phải số khác
□ registerTempTable bị deprecated từ Spark 2.0 → createOrReplaceTempView
□ Homework Q3: trips on Feb 15, 2021 = 367170 (từ notebook output)
□ UDF Python phải serialize JVM → Python via Py4J — không phải socket hay shared memory
□ AQE: spark.sql.adaptive.enabled=true (không phải spark.adaptive.enabled)
□ Broadcast threshold default: spark.sql.autoBroadcastJoinThreshold = 10MB (10485760 bytes)

Liệt kê mọi claim kỹ thuật SAI trong HTML, kèm:
- Câu/đoạn sai trong HTML (line number nếu có)
- Giá trị đúng từ source code/repo
- Cách fix
```

---

## BƯỚC 4 — KIỂM TRA UX & COMPLETENESS

```
═══════════════════════════════
4.1 COMPLETENESS CHECK
═══════════════════════════════

□ File có đủ 9 sections có nội dung thực (không còn placeholder trống)?
□ Tổng số dòng hợp lý cho module đầy đủ (ít nhất 1800 dòng)?
□ Không có section nào "quá mỏng" — ít hơn 60 dòng HTML?
□ Không có đoạn nào bị cắt giữa chừng (truncated mid-sentence)?
□ Tất cả code blocks đóng tag đúng (</code>, </pre>)?
□ Tất cả tables đóng tag đúng (</tr>, </td>, </table>)?
□ Tab containers đóng tag đúng, không có tab content bị leak ra ngoài?

═══════════════════════════════
4.2 CONSISTENCY CHECK
═══════════════════════════════

□ Thuật ngữ nhất quán xuyên suốt:
  "Parquet" không phải "parquet" hay "PARQUET" — nhất quán
  "DataFrame" không phải "dataframe" hay "data frame"
  "PySpark" không phải "pyspark" hay "py-spark"
  "Dataproc" không phải "DataProc" hay "data proc"
  "BigQuery" không phải "Big Query" hay "bigquery"
□ Tên file nhất quán: download_data.sh, 06_spark_sql.py, 06_spark_sql_big_query.py
□ Column names nhất quán case-sensitive: PULocationID (không phải puLocationID hay PULOCATIONID)
□ Bucket name trong ví dụ nhất quán: dtc_data_lake_de-zoomcamp-nytaxi

═══════════════════════════════
4.3 UX CHECK
═══════════════════════════════

□ Quiz questions không bị lặp nhau giữa S1 phần A/B/C?
□ Practice tasks trong S3 có độ khó tăng dần thực sự?
  (Task 1 Hello Spark < Task 2 Parquet < Task 3 Transform < Task 4 SQL < Task 5 Advanced)
□ Kịch bản "Cố tình phá" có debug steps theo thứ tự cụ thể?
  (không chỉ liệt kê lỗi — phải có "kiểm tra gì trước, xem log ở đâu")
□ Interview S7: câu Senior thực sự senior?
  (Q8 UDF: phải đề cập Py4J, serialization; Q9 Skew: phải có salting; Q10: phải có ≥8 items)
□ Checklist S8 items verifiable bằng hành động cụ thể?
  ("ls data/pq/.../01/ → thấy 24 file" tốt hơn "hiểu repartition")
□ Links nội bộ hoạt động đúng (href="#s3", v.v.)?
□ Link Preview Module 07: href="Module07_Streaming.html"?
□ Tab switcher trong S2 có ít nhất 4 tabs hoạt động cho mỗi tab group?
```

---

## BƯỚC 5 — BÁO CÁO & FIX

```
Sau khi hoàn thành Bước 1-4, tạo báo cáo theo format sau:

═══════════════════════════════════════════════════════════
REVIEW REPORT — Module06_Batch_Spark.html
═══════════════════════════════════════════════════════════

TỔNG QUAN:
- Tổng số dòng file: ___
- Tổng số lỗi FAIL: ___
- Tổng số WARNING: ___
- Đánh giá tổng thể: [ ] Đạt — deploy được | [ ] Cần fix trước khi dùng

───────────────────────────────
NHÓM 1: LỖI KỸ THUẬT (phải fix ngay)
───────────────────────────────
Liệt kê từng FAIL từ Bước 1 và Bước 3:
[F01] [Loại lỗi] [Line number nếu có] [Mô tả] [Cách fix]
[F02] ...

───────────────────────────────
NHÓM 2: NỘI DUNG SAI/THIẾU (phải fix trước khi dùng)
───────────────────────────────
Liệt kê từng FAIL từ Bước 2 và fact-check Bước 3:
[C01] [Section] [Claim sai hoặc thiếu] [Giá trị đúng từ repo] [Cách fix]
[C02] ...

───────────────────────────────
NHÓM 3: WARNING (nên fix nhưng không block)
───────────────────────────────
[W01] [Section] [Vấn đề] [Đề xuất cải thiện]
[W02] ...

───────────────────────────────
NHÓM 4: PASSES TỐT (ghi nhận để không vô tình xóa khi fix)
───────────────────────────────
- Những section/component nào làm tốt, đúng spec
- Những insight kỹ thuật nào được giải thích tốt hơn cả spec yêu cầu

═══════════════════════════════════════════════════════════
SAU KHI BÁO CÁO: THỰC HIỆN FIX
═══════════════════════════════════════════════════════════

Thực hiện fix TẤT CẢ lỗi NHÓM 1 và NHÓM 2 ngay lập tức.
NHÓM 3 (WARNING): fix nếu không tốn quá 10 dòng code, skip nếu phức tạp.

Nguyên tắc khi fix:
- Chỉ sửa đúng chỗ bị lỗi, không rewrite section nguyên vẹn
- Với fact-check sai: lấy giá trị CHÍNH XÁC từ source code repo, không đoán
- Với JS function lỗi: test lại bằng cách trace call stack thủ công
- Sau mỗi fix: ghi "[FIXED F01]" vào báo cáo

Sau khi fix xong:
- Báo cáo số dòng trước và sau khi fix
- Liệt kê line number của từng thay đổi
- Xác nhận file mở được trên browser không lỗi console
```

---

> **Lưu ý cho Antigravity:**
> Bước 3 (Fact-check) là bước quan trọng nhất và dễ bỏ sót nhất.
> Spark/PySpark có nhiều API bị deprecated và thay đổi giữa versions —
> Claude hay confuse Spark 2.x API với Spark 3.x/4.x.
> Đặc biệt chú ý:
> - registerTempTable → createOrReplaceTempView
> - start-slave.sh → start-worker.sh (Spark 4.x)
> - spark-master vs spark.master trong config
> - Schema types: Integer vs Long, Double vs Float
> Phải đối chiếu với source code repo line-by-line, không tin vào memory.
