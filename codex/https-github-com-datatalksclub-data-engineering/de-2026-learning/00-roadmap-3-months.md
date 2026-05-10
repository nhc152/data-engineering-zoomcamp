# Tong quan lo trinh 3 thang de tro thanh Data Engineer 2026

## Diem xuat phat cua ban

Ban da biet ETL, SQL, ODI va Talend. Day la loi the lon vi ban da quen voi:

- Source va target.
- Mapping du lieu.
- Migration.
- Transform logic.
- Batch job.
- Van de duplicate, null, data type, schedule.

Khoang trong can bu la cach lam hien dai bang code, cloud va production workflow:

- Python scripting.
- Git va code review mindset.
- Docker.
- Cloud warehouse.
- Orchestration bang DAG.
- dbt va data modeling.
- Data quality tu dong.
- Spark/Kafka o muc co ban.

## Muc tieu dung cho 3 thang

Trong 3 thang, muc tieu khong phai master tat ca. Muc tieu dung la:

- Biet vai tro cua tung cong nghe trong modern data stack.
- Tu build duoc pipeline end-to-end.
- Biet debug pipeline khi fail.
- Biet noi ve architecture va trade-off.
- Co portfolio de apply job.

## Lo trinh tong quat

### Thang 1: Nen tang code-based pipeline

Muc tieu: chuyen tu ETL tool sang pipeline viet bang code.

Can hoc:

- SQL nang cao.
- Python cho ingestion va transform nhe.
- Git/GitHub.
- Docker va Docker Compose.
- PostgreSQL.

Bai tap chinh:

- Lay data tu CSV/API.
- Load vao PostgreSQL.
- Viet SQL transform.
- Chay bang Docker Compose.
- Viet README cach reproduce.

Dau ra:

- Repo `etl-python-postgres`.
- Co script Python, SQL scripts, Docker Compose, README.

### Thang 2: Modern ELT voi cloud warehouse va dbt

Muc tieu: hieu cach team hien dai build analytics pipeline.

Can hoc:

- GCP basics.
- Google Cloud Storage.
- BigQuery.
- dbt.
- Orchestration bang Kestra hoac Airflow.

Bai tap chinh:

- Ingest raw data len cloud storage.
- Load vao BigQuery.
- Tao dbt staging, intermediate, marts.
- Them dbt tests va docs.
- Schedule pipeline bang orchestrator.

Dau ra:

- Repo `elt-bigquery-dbt-orchestration`.
- Co architecture diagram, dbt lineage, quality checks.

### Thang 3: Scale, streaming, reliability va portfolio

Muc tieu: biet cac chu de can cho interview va production.

Can hoc:

- Spark basic.
- Parquet.
- Partitioning.
- Kafka basic.
- Data quality/observability.
- CI/CD basic.
- Interview storytelling.

Bai tap chinh:

- Xu ly data bang Spark.
- Demo Kafka producer/consumer.
- Them test va GitHub Actions.
- Hoan thien final project.

Dau ra:

- 1 final project co README rat ro.
- 1 trang portfolio hoac GitHub profile duoc sap xep.

## Lich hoc hang tuan

Neu co 10-12 gio/tuan:

- 6-7 gio: lab/project.
- 2 gio: doc ly thuyet va note.
- 1 gio: SQL/Python practice.
- 1-2 gio: README, refactor, clean repo.

Neu co 20 gio/tuan:

- 12 gio: lab/project.
- 3 gio: SQL/Python.
- 3 gio: ly thuyet va docs.
- 2 gio: portfolio, interview, review.

## Cach biet minh da hieu mot cong nghe

Voi moi tool, ban phai tra loi duoc:

- No nam o dau trong pipeline?
- Input va output la gi?
- No thay the hoac bo sung tool nao?
- Khi job fail thi debug o dau?
- Retry/backfill nhu the nao?
- Chi phi va scale bi anh huong boi cai gi?
- Neu khong dung tool nay thi dung gi khac?

## Sai lam can tranh

- Hoc qua nhieu cloud cung luc.
- Doc ly thuyet qua lau nhung khong co pipeline chay duoc.
- Chi lam tutorial ma khong viet README.
- Chi hoc tool, khong hoc data modeling.
- Bo qua data quality.
- Khong hoc Git/Docker vi nghi chung la phu.

## Checklist sau 3 thang

- [ ] Viet duoc Python ingestion script.
- [ ] Viet SQL window functions, CTE, incremental logic.
- [ ] Chay duoc Postgres/Airflow/Kafka/Spark bang Docker.
- [ ] Build duoc dbt project co tests.
- [ ] Load data vao BigQuery/Snowflake.
- [ ] Giai thich duoc batch vs streaming.
- [ ] Giai thich duoc ETL vs ELT.
- [ ] Giai thich duoc warehouse vs lake/lakehouse.
- [ ] Co 2 GitHub repos sach.
- [ ] Co the ve architecture pipeline cua minh.

