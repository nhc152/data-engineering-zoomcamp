# PROMPT_Review_Module_07.md
# Review toàn diện file Module07_Streaming.html

> Dùng cho: Antigravity review code sau khi Claude build xong 5 prompts.
> Mục tiêu: phát hiện lỗi kỹ thuật, nội dung sai, UX hỏng, thiếu sót so với spec.
> Cách chạy: paste toàn bộ prompt này vào Antigravity sau khi đã có `Module07_Streaming.html`.

---

## BƯỚC 0 - ĐỌC FILE TRƯỚC KHI LÀM BẤT CỨ ĐIỀU GÌ

Đọc TOÀN BỘ các file sau theo thứ tự:

1. `Module07_Streaming.html` - file cần review.
2. `module_template.html` - chuẩn gốc về CSS/component.
3. `master_de_roadmap.html` - spec Module 07 và DoD nếu có.
4. `repo_notes_M07.md` - nguồn tổng hợp bắt buộc.
5. `data-engineering-zoomcamp/07-streaming/workshop/docker-compose.yml`
6. `data-engineering-zoomcamp/07-streaming/workshop/src/models.py`
7. `data-engineering-zoomcamp/07-streaming/workshop/src/producers/producer.py`
8. `data-engineering-zoomcamp/07-streaming/workshop/src/producers/producer_realtime.py`
9. `data-engineering-zoomcamp/07-streaming/workshop/src/consumers/consumer.py`
10. `data-engineering-zoomcamp/07-streaming/workshop/src/consumers/consumer_postgres.py`
11. `data-engineering-zoomcamp/07-streaming/workshop/src/job/pass_through_job.py`
12. `data-engineering-zoomcamp/07-streaming/workshop/src/job/aggregation_job.py`
13. `data-engineering-zoomcamp/07-streaming/extras/python/avro_example/producer.py`
14. `data-engineering-zoomcamp/07-streaming/theory/java/kafka_examples/src/main/java/org/example/JsonKStream.java`
15. `data-engineering-zoomcamp/07-streaming/theory/java/kafka_examples/src/main/java/org/example/JsonKStreamJoins.java`
16. `data-engineering-zoomcamp/07-streaming/theory/java/kafka_examples/src/test/java/org/example/JsonKStreamTest.java`

KHÔNG bắt đầu review cho đến khi đã đọc xong tất cả file trên.
Mục đích: review phải đối chiếu HTML với source code thực tế, không review bằng trí nhớ.

---

## BƯỚC 1 - KIỂM TRA KỸ THUẬT HTML/CSS/JS

Kiểm tra toàn bộ phần kỹ thuật của file. Với mỗi mục, ghi rõ `PASS / FAIL / WARNING` + mô tả cụ thể nếu không pass.

### 1.1 HTML Structure

- [ ] File có đúng `<!DOCTYPE html>` không?
- [ ] `<head>` có đủ charset UTF-8, viewport, title, Google Fonts?
- [ ] Title đúng: `Module 07 - Streaming với Kafka, Redpanda & Flink` hoặc biến thể rất gần, không sai module number.
- [ ] Tất cả 9 section div tồn tại: `id="s0"` đến `id="s8"`.
- [ ] Không còn placeholder `Đang xây dựng...`.
- [ ] Không có broken tag: thẻ mở không đóng, nested table/card sai.
- [ ] Code blocks dùng `<pre><code>` hoặc component tương đương và đóng tag đúng.

### 1.2 CSS Variables & Components

So sánh với `module_template.html`:

- [ ] CSS variables gốc tồn tại: color, surface, border, font, radius, shadow.
- [ ] Component classes có đủ:
  `.hero-banner`, `.sidebar`, `.nav-item`, `.section-content`, `.info-box`, `.quiz-block`, `.practice-task`, `.data-table`, `.code-block`, `.tab-container`, `.checklist-item`, `.badge`, `.progress-bar`.
- [ ] Không override CSS gây lỗi layout.
- [ ] Tables không tràn container.
- [ ] Sidebar và main content không overlap.
- [ ] Mobile/responsive không vỡ nghiêm trọng.

### 1.3 JavaScript Functions

Kiểm tra function tồn tại và hoạt động:

- [ ] `showModule(index)` - click S0-S8 hiển thị đúng section, nav active đúng.
- [ ] `toggleSection(id)` - dùng cho S7 interview collapsibles.
- [ ] `answerQuiz(questionId, answer, correct)` - click đáp án hiển thị đúng/sai + explanation.
- [ ] `toggleSolution(taskId)` - show/hide solution trong S3.
- [ ] `switchTab(group, name)` - tab S2 chuyển đúng, không leak content.
- [ ] `toggleCheck(itemId)` - checklist tick/untick.
- [ ] `updateProgress()` - progress bar S8 cập nhật sau mỗi tick.
- [ ] Không có console error khi mở file.

### 1.4 Navigation

- [ ] Sidebar đủ 9 nav items đúng tên:
  - S0: Tổng quan & Mục tiêu
  - S1: Lý thuyết nền
  - S2: Đọc hiểu code repo
  - S3: Thực hành từng bước
  - S4: Production Readiness
  - S5: Kiến thức nâng cao
  - S6: Lỗi thường gặp
  - S7: Interview Prep
  - S8: Checklist & Tổng kết
- [ ] S0 active mặc định.
- [ ] Không nav item nào click ra màn hình trắng.

---

## BƯỚC 2 - KIỂM TRA NỘI DUNG TỪNG SECTION

Format báo cáo: `PASS | WARNING | FAIL`.

### S0 - Tổng quan & Mục tiêu

- [ ] Có hero title đúng Module 07 Streaming.
- [ ] Có bảng 9 sections với thời gian ước tính.
- [ ] Có giải thích vấn đề streaming giải quyết: latency thấp, realtime reaction, operational cost.
- [ ] Có nói trước streaming thường dùng batch/micro-batch/polling/cron.
- [ ] Có stack module: Redpanda, Python producer/consumer, PyFlink, PostgreSQL, extras, Java theory.
- [ ] Có ít nhất 4 data flow ASCII:
  - Workshop producer -> Redpanda -> Flink -> PostgreSQL.
  - Consumer debug.
  - Extras Avro.
  - Java Kafka Streams.
- [ ] Có exit criteria cụ thể, actionable.

### S1 - Lý thuyết nền

Phần Streaming Fundamentals:
- [ ] Có Batch vs Micro-batch vs Streaming table.
- [ ] Có topic/partition/offset/consumer group.
- [ ] Có producer ack/retry/idempotence ở mức khái niệm.
- [ ] Có `earliest` vs `latest`.
- [ ] Có Redpanda vs Kafka operational differences.
- [ ] Có 6 quiz scenario-based.

Phần Flink:
- [ ] Có stateless vs stateful.
- [ ] Có event time vs processing time.
- [ ] Có watermark, late events.
- [ ] Có tumbling/sliding/session windows.
- [ ] Có checkpoint/savepoint/state backend.
- [ ] Có Flink architecture JobManager/TaskManager/task slots.
- [ ] Có 6 quiz scenario-based.

Phần Serialization/Applications:
- [ ] Có JSON vs Avro vs Protobuf.
- [ ] Có Schema Registry compatibility.
- [ ] Có Kafka Streams concepts.
- [ ] Có Spark Structured Streaming concepts.
- [ ] Có CDC/outbox/event sourcing/stream-table duality.
- [ ] Có 6 quiz scenario-based.

### S2 - Đọc hiểu code repo

- [ ] Có tree diagram `07-streaming/` đầy đủ.
- [ ] Có giải thích folder groups: `workshop`, `workshop/live`, `extras/python`, `extras/pyflink`, `extras/ksqldb`, `theory/java`.

Docker Compose:
- [ ] Có trích `workshop/docker-compose.yml` nguyên văn hoặc đầy đủ phần quan trọng.
- [ ] Redpanda image đúng: `redpandadata/redpanda:v25.3.9`.
- [ ] Redpanda ports đúng: `8082`, `9092`, `28082`, `29092`.
- [ ] Advertised listeners đúng:
  - internal `redpanda:29092`
  - external `localhost:9092`
- [ ] JobManager port `8081`.
- [ ] TaskManager `taskmanager.numberOfTaskSlots: 15`, `parallelism.default: 3`.
- [ ] PostgreSQL image `postgres:18`, credentials `postgres/postgres`.

Python model/producer/consumer:
- [ ] `Ride` fields đúng:
  - `PULocationID`
  - `DOLocationID`
  - `trip_distance`
  - `total_amount`
  - `tpep_pickup_datetime`
- [ ] Producer topic đúng: `rides`.
- [ ] Producer bootstrap đúng: `localhost:9092`.
- [ ] Consumer group đúng: `rides-console`.
- [ ] PostgreSQL consumer group đúng: `rides-to-postgres`.
- [ ] Có giải thích timestamp epoch milliseconds.

PyFlink jobs:
- [ ] Kafka source bootstrap đúng: `redpanda:29092`.
- [ ] Topic đúng: `rides`.
- [ ] Format đúng: `json`.
- [ ] `pass_through_job.py` ghi `processed_events`.
- [ ] `aggregation_job.py` ghi `processed_events_aggregated`.
- [ ] Có computed column `event_timestamp AS TO_TIMESTAMP_LTZ(tpep_pickup_datetime, 3)`.
- [ ] Có watermark `event_timestamp - INTERVAL '5' SECOND`.
- [ ] Có `TUMBLE(... INTERVAL '1' HOUR)`.
- [ ] Có `PRIMARY KEY (window_start, PULocationID) NOT ENFORCED`.
- [ ] Có checkpointing `10 * 1000` và parallelism `3`.

Extras:
- [ ] Có JSON example.
- [ ] Có Avro example và schema key/value.
- [ ] Có Redpanda example.
- [ ] Có Faust stream/branch/window examples.
- [ ] Có PySpark/Redpanda Structured Streaming examples.

Java Kafka theory:
- [ ] Có `Topics.java`, `Secrets.java`.
- [ ] Có Producer/Consumer.
- [ ] Có `JsonKStream`, `JsonKStreamJoins`, `JsonKStreamWindow`.
- [ ] Có `AvroProducer`.
- [ ] Có `CustomSerdes`.
- [ ] Có topology tests dùng `TopologyTestDriver`.

### S3 - Thực hành từng bước

- [ ] Có setup Docker/uv/SQL client.
- [ ] Có `docker compose up redpanda -d`.
- [ ] Có verify `docker compose ps`.
- [ ] Có producer/consumer basic flow.
- [ ] Có PostgreSQL table `processed_events` và consumer_postgres flow.
- [ ] Có Flink pass-through submit command:
  `docker compose exec jobmanager ./bin/flink run -py /opt/src/job/pass_through_job.py --pyFiles /opt/src -d`
- [ ] Có aggregation submit command:
  `docker compose exec jobmanager ./bin/flink run -py /opt/src/job/aggregation_job.py --pyFiles /opt/src -d`
- [ ] Có realtime producer/late events exercise.
- [ ] Có ít nhất 5 practice tasks, có hint + solution toggle.
- [ ] Có ít nhất 7 "cố tình phá" scenarios với debug steps cụ thể.

### S4 - Production Readiness

- [ ] Có đủ 8 production questions.
- [ ] Có security hardcoded secrets/listeners.
- [ ] Có delivery semantics at-least-once/exactly-once.
- [ ] Có offset/reprocessing/savepoint strategy.
- [ ] Có schema evolution + Schema Registry.
- [ ] Có late events/watermark policy.
- [ ] Có backpressure/scaling/partition strategy.
- [ ] Có observability: Kafka lag, Flink metrics, DB sink metrics.
- [ ] Có DLQ/data quality/quarantine flow.
- [ ] Mỗi câu có code/config example hoặc pseudo-code cụ thể.

### S5 - Kiến thức nâng cao

- [ ] Có Kafka/Redpanda internals: partition, replication, ISR, retention, compaction.
- [ ] Có producer/consumer advanced configs.
- [ ] Có Flink advanced: checkpoint barrier, savepoint, state backend, restart strategy.
- [ ] Có Kafka Streams advanced: KStream/KTable, state stores, changelog, repartition topics.
- [ ] Có Spark Structured Streaming advanced.
- [ ] Có streaming architecture patterns: Lambda/Kappa, CDC, outbox, event sourcing, CQRS.
- [ ] Có trade-off matrices.
- [ ] Có senior design scenario realtime taxi revenue dashboard.

### S6 - Lỗi thường gặp

- [ ] Có ít nhất 14 lỗi.
- [ ] Mỗi lỗi có triệu chứng, nguyên nhân, debug steps, fix, phòng tránh.
- [ ] Có các lỗi quan trọng:
  - `NoBrokersAvailable`
  - wrong Docker listener `localhost:9092` vs `redpanda:29092`
  - missing PostgreSQL table
  - missing connector JAR
  - timestamp seconds vs milliseconds
  - missing primary key/upsert
  - new Flink job reprocess from beginning
  - port conflicts
- [ ] Có debugging checklist theo thứ tự ưu tiên.

### S7 - Interview Prep

- [ ] Có 15 câu hỏi.
- [ ] Chia Junior 5, Mid 5, Senior 5.
- [ ] Mỗi câu collapsible.
- [ ] Mỗi câu có answer chi tiết.
- [ ] Mỗi câu có `Red flag: đừng nói...`.
- [ ] Senior questions đủ sâu:
  - realtime dashboard design
  - Flink fail/restart no data loss/dup
  - Kafka lag increasing
  - schema breaking change incident
  - exactly-once end-to-end Kafka -> Flink -> PostgreSQL

### S8 - Checklist & Tổng kết

- [ ] Có progress bar với `checklist-progress-fill` và `checklist-progress-text`.
- [ ] Có 24 checklist items chia 4 nhóm 6/6/6/6.
- [ ] Items actionable/verifiable, không chung chung.
- [ ] Có summary grid 6 điểm chốt.
- [ ] Có file mapping từ repo files -> concept học được.
- [ ] Có Definition of Done.
- [ ] Preview module tiếp theo không dùng link hỏng.

---

## BƯỚC 3 - FACT-CHECK KỸ THUẬT

Đây là phần quan trọng nhất. Đối chiếu từng claim kỹ thuật trong HTML với source repo.

### 3.1 Docker/Networking Accuracy

- [ ] Redpanda image đúng: `redpandadata/redpanda:v25.3.9`.
- [ ] External Kafka address đúng: `localhost:9092`.
- [ ] Internal Kafka address đúng: `redpanda:29092`.
- [ ] `--kafka-addr` có cả `PLAINTEXT://0.0.0.0:29092` và `OUTSIDE://0.0.0.0:9092`.
- [ ] `--advertise-kafka-addr` có `PLAINTEXT://redpanda:29092` và `OUTSIDE://localhost:9092`.
- [ ] JobManager UI port đúng: `8081`.
- [ ] PostgreSQL port đúng: `5432`.
- [ ] Không được nói Flink trong container dùng `localhost:9092`.

### 3.2 Python Accuracy

- [ ] `Ride` dataclass fields đúng tên/case.
- [ ] `tpep_pickup_datetime` là epoch milliseconds.
- [ ] Topic name đúng: `rides`.
- [ ] Producer dùng `KafkaProducer` từ `kafka`.
- [ ] Serializer JSON encode UTF-8.
- [ ] Consumer `auto_offset_reset='earliest'`.
- [ ] Console consumer group: `rides-console`.
- [ ] PostgreSQL consumer group: `rides-to-postgres`.
- [ ] DB credentials hardcoded đúng theo repo: host `localhost`, port `5432`, user/password `postgres`.
- [ ] Không bịa message key nếu repo producer không dùng key.

### 3.3 PyFlink Accuracy

- [ ] Kafka source table name và topic không bị đổi sai.
- [ ] Bootstrap server trong Flink DDL là `redpanda:29092`.
- [ ] Startup mode nếu HTML nêu phải khớp source file.
- [ ] Sink table `processed_events` / `processed_events_aggregated` đúng.
- [ ] Watermark đúng `INTERVAL '5' SECOND`.
- [ ] Tumbling window đúng `INTERVAL '1' HOUR`.
- [ ] Aggregation group by đúng `window_start, PULocationID`.
- [ ] Columns output đúng: `window_start`, `PULocationID`, `num_trips`, `total_revenue`.
- [ ] JDBC URL đúng: `jdbc:postgresql://postgres:5432/postgres`.
- [ ] Checkpoint interval đúng nếu nêu: `10 * 1000`.
- [ ] Parallelism đúng nếu nêu: `3`.

### 3.4 Java Kafka/Kafka Streams Accuracy

- [ ] Topic constants trong HTML khớp `Topics.java`.
- [ ] Secrets/config claims khớp `Secrets.java`.
- [ ] Producer/consumer properties không bị bịa.
- [ ] `CustomSerdes.java` được mô tả đúng vai trò.
- [ ] `JsonKStream.java` topology mô tả đúng source/transform/sink.
- [ ] `JsonKStreamJoins.java` join mô tả đúng.
- [ ] `JsonKStreamWindow.java` window mô tả đúng.
- [ ] Tests dùng `TopologyTestDriver`, không cần Kafka broker thật.
- [ ] Avro compatibility claims khớp schema files `rides.avsc`, `rides_compatible.avsc`, `rides_non_compatible.avsc`.

### 3.5 Concept Accuracy

- [ ] Offset thuộc consumer group, không thuộc topic chung.
- [ ] `earliest` chỉ áp dụng khi consumer group chưa có committed offset.
- [ ] Watermark không phải "drop mọi event trễ hơn 5 giây" một cách tuyệt đối; phải giải thích theo event time/window.
- [ ] Exactly-once end-to-end với PostgreSQL phải được trình bày có điều kiện, không hứa tuyệt đối.
- [ ] Redpanda compatible Kafka nghĩa là Kafka protocol compatible, không phải cùng codebase Java Kafka.
- [ ] Spark Structured Streaming là micro-batch by default, Flink là continuous/event-at-a-time style.
- [ ] `PRIMARY KEY NOT ENFORCED` trong Flink JDBC là metadata/upsert contract, PostgreSQL vẫn cần table key phù hợp nếu muốn enforce.

Liệt kê mọi claim sai với:
- Line number nếu có.
- Claim sai trong HTML.
- Giá trị đúng từ repo/source.
- Cách fix.

---

## BƯỚC 4 - UX & COMPLETENESS

### 4.1 Completeness

- [ ] File có ít nhất 1800 dòng hoặc đủ sâu tương đương.
- [ ] Không section nào quá mỏng dưới 60 dòng HTML.
- [ ] Không đoạn nào bị cắt giữa chừng.
- [ ] Tất cả tab groups có content cho từng tab.
- [ ] Tất cả quiz có explanation.
- [ ] Tất cả practice tasks có solution.
- [ ] Tất cả interview answers có red flag.
- [ ] Checklist progress hoạt động.

### 4.2 Consistency

- [ ] Dùng nhất quán `Redpanda`, không lúc `red panda`.
- [ ] Dùng nhất quán `Kafka`, `PyFlink`, `Flink`, `PostgreSQL`.
- [ ] Topic name `rides` không bị đổi thành `ride`, `taxi_rides` khi nói workshop chính.
- [ ] Column name case đúng: `PULocationID`, `DOLocationID`, `tpep_pickup_datetime`.
- [ ] File names đúng: `pass_through_job.py`, `aggregation_job.py`, `producer_realtime.py`.
- [ ] Module number luôn là 07, không copy sót Module 06/04.

### 4.3 UX

- [ ] Quiz không bị lặp câu quá nhiều giữa sections.
- [ ] Practice tasks tăng độ khó thật sự.
- [ ] "Cố tình phá" có debug steps cụ thể, không chỉ liệt kê lỗi.
- [ ] Tables đủ ngắn để đọc được.
- [ ] Code blocks không quá dài làm hỏng layout; nếu dài, có scroll.
- [ ] Warning boxes dùng đúng chỗ cho production gaps.
- [ ] Link preview module tiếp theo không hỏng.

---

## BƯỚC 5 - BÁO CÁO & FIX

Sau khi hoàn thành Bước 1-4, tạo báo cáo theo format:

```text
REVIEW REPORT - Module07_Streaming.html

TỔNG QUAN:
- Tổng số dòng file: ___
- Tổng số lỗi FAIL: ___
- Tổng số WARNING: ___
- Đánh giá tổng thể: [ ] Đạt - dùng được | [ ] Cần fix trước khi dùng

NHÓM 1: LỖI KỸ THUẬT (phải fix ngay)
[F01] [Line] [Mô tả] [Cách fix]

NHÓM 2: NỘI DUNG SAI/THIẾU (phải fix trước khi dùng)
[C01] [Section] [Claim sai/thiếu] [Giá trị đúng từ repo] [Cách fix]

NHÓM 3: WARNING (nên fix)
[W01] [Section] [Vấn đề] [Đề xuất]

NHÓM 4: PASSES TỐT
- Những phần đúng spec, đáng giữ lại.
```

SAU KHI BÁO CÁO: thực hiện fix tất cả lỗi nhóm 1 và nhóm 2 ngay.

Nguyên tắc fix:
- Chỉ sửa đúng chỗ lỗi, không rewrite toàn bộ section nếu không cần.
- Với fact-check sai, lấy giá trị chính xác từ source repo hoặc `repo_notes_M07.md`.
- Với JS lỗi, test lại bằng trace manual từng function.
- Sau mỗi fix, ghi `[FIXED Fxx]` hoặc `[FIXED Cxx]` vào báo cáo.

Sau khi fix xong:
- Báo cáo số dòng trước/sau.
- Liệt kê file/line đã sửa.
- Xác nhận không còn placeholder.
- Xác nhận browser không có console error.

---

Lưu ý cho Antigravity:
- Bước 3 là quan trọng nhất. Claude dễ bịa chi tiết Kafka/Flink nghe có vẻ đúng.
- Đặc biệt kiểm tra kỹ:
  - `localhost:9092` vs `redpanda:29092`
  - topic `rides`
  - watermark 5 seconds
  - tumbling window 1 hour
  - PostgreSQL credentials hardcoded
  - `PRIMARY KEY NOT ENFORCED`
  - consumer group offset behavior
  - exactly-once claims
