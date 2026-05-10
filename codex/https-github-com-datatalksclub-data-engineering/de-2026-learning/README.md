# Data Engineer 2026 Learning Pack

Bo tai lieu nay duoc viet cho nguoi da biet ETL, SQL, ODI/Talend va muon chuyen sang Data Engineer hien dai trong nam 2026.

Muc tieu cua bo tai lieu:

- Hoc theo huong thuc hanh truoc, ly thuyet dung luc sau.
- Biet co ban toan bo modern data engineering stack trong 3 thang.
- Tao duoc 1-2 project end-to-end co the dua vao portfolio.
- Biet cach giai thich pipeline, trade-off, failure, data quality khi phong van.

## Thu tu hoc khuyen nghi

1. [Tong quan lo trinh 3 thang](./00-roadmap-3-months.md)
2. [SQL nang cao cho Data Engineer](./01-sql.md)
3. [Python cho data pipeline](./02-python.md)
4. [Git, Linux va engineering workflow](./03-git-linux-workflow.md)
5. [Docker va local data platform](./04-docker.md)
6. [Cloud, data lake va data warehouse](./05-cloud-warehouse-lake.md)
7. [Orchestration: Airflow, Kestra va DAG thinking](./06-orchestration.md)
8. [dbt va analytics engineering](./07-dbt.md)
9. [Data modeling va warehouse design](./08-data-modeling.md)
10. [Spark va batch processing](./09-spark.md)
11. [Kafka va streaming co ban](./10-kafka-streaming.md)
12. [Data quality, observability va reliability](./11-data-quality-observability.md)
13. [CI/CD, testing va production habits](./12-cicd-testing-production.md)
14. [Portfolio project va interview 2026](./13-portfolio-interview.md)

## Cach dung bo tai lieu

Moi file co cung mot format:

- Muc tieu can dat.
- Khai niem can nam.
- Bai hoc theo thu tu.
- Bai tap thuc hanh.
- Kinh nghiem thuc te.
- Loi thuong gap.
- Cau hoi phong van.
- Dau ra can co tren GitHub.

Khong can doc het truoc. Moi tuan chi mo file lien quan den module dang hoc, lam bai tap, sau do viet note ngan.

## Nguyen tac hoc

- 70% thuc hanh, 20% doc/ly thuyet, 10% viet lai va lam portfolio.
- Moi cong nghe phai gan voi mot pipeline that.
- Khong hoc nhieu tool cung chuc nang cung luc.
- Chon mot stack chinh: Python, SQL, Docker, GCP/BigQuery, dbt, Airflow/Kestra, Spark basic, Kafka basic.
- Sau moi module, phai tra loi duoc: tool nay giai quyet van de gi, input/output la gi, fail thi sao, scale thi nghen o dau.

## Stack chinh nen theo

Neu hoc song song DataTalksClub Zoomcamp va Data Engineer Handbook, stack chinh nen la:

- Language: Python + SQL
- Local dev: Git + Docker + Docker Compose
- Database: PostgreSQL
- Cloud: GCP
- Storage: Google Cloud Storage
- Warehouse: BigQuery
- Transformation: dbt
- Orchestration: Kestra theo Zoomcamp, hoc them Airflow de phong van
- Batch big data: Spark
- Streaming: Kafka
- Quality: dbt tests, Great Expectations/Soda concept
- CI/CD: GitHub Actions basic

## Ket qua mong muon sau 3 thang

Sau 3 thang, ban nen co:

- 1 repo pipeline nho: API/CSV -> Postgres -> SQL transform -> output.
- 1 repo portfolio lon: data source -> cloud storage -> BigQuery -> dbt -> orchestration -> quality checks -> dashboard/table analytics.
- README co architecture, setup, run command, data model, failure handling.
- Kha nang giai thich ETL vs ELT, batch vs streaming, warehouse vs lake, dbt vs Airflow, Spark vs SQL engine.

