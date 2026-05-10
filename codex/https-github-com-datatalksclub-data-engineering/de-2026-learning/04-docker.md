# Docker va Local Data Platform

## Vai tro cua Docker trong Data Engineering 2026

Docker giup Data Engineer tao moi truong chay lap lai duoc. Mot pipeline khong nen chi "chay tren may toi". No phai chay duoc tren may dong nghiep, CI, dev server va orchestrator voi cung dependency.

Trong data engineering, Docker thuong dung de:

- Chay PostgreSQL local.
- Chay Airflow/Kestra local.
- Chay Kafka local.
- Chay Spark/MinIO local cho lab.
- Dong goi Python ingestion job.
- Tao reproducible environment cho dbt/test.
- Mo phong local data platform truoc khi dua len cloud.

Docker khong giai quyet tat ca van de production, nhung no ep ban ro rang ve dependency, config, port, network, volume va runtime.

## Muc tieu can dat

Sau module nay, ban nen lam duoc:

- Giai thich image, container, volume, network.
- Viet Dockerfile cho Python pipeline.
- Viet Docker Compose cho local data platform.
- Chay PostgreSQL co persistent volume.
- Ket noi app container voi database container qua service name.
- Truyen environment variables an toan.
- Debug container crash bang logs/exec/inspect.
- Hieu common mistakes: localhost, volume permission, port conflict, stale image.
- Biet Docker phu hop va khong phu hop o dau trong production.

## Khai niem can nam

- Image.
- Container.
- Dockerfile.
- Layer.
- Build context.
- Tag.
- Registry.
- Port mapping.
- Volume.
- Bind mount.
- Network.
- Environment variables.
- Docker Compose.
- Healthcheck.
- Entrypoint vs command.
- Logs.
- Exit code.
- Container user.

## Learning roadmap

### Giai doan 1: Beginner

Muc tieu: chay service co san.

Can lam:

- `docker run hello-world`.
- Chay PostgreSQL container.
- Xem logs.
- Stop/start container.
- Hieu port mapping.

### Giai doan 2: Implement

Muc tieu: dong goi Python pipeline.

Can lam:

- Viet Dockerfile.
- Build image.
- Chay container voi env vars.
- Mount data folder.
- Connect Postgres tu container khac.

### Giai doan 3: Productionize

Muc tieu: Docker Compose cho local data platform.

Can lam:

- Compose multi-service.
- Volume persistent.
- Network service names.
- Healthcheck.
- `.env` file.
- Restart policy concept.

### Giai doan 4: Debug

Muc tieu: debug container fail.

Can lam:

- `docker logs`.
- `docker exec`.
- `docker inspect`.
- Check env.
- Check DNS/network.
- Check permission.
- Check exit code.

### Giai doan 5: Optimize

Muc tieu: image nho, build nhanh, runtime on dinh.

Can lam:

- `.dockerignore`.
- Layer caching.
- Non-root user concept.
- Multi-stage concept.
- Pin dependency versions.

### Giai doan 6: Interview

Muc tieu: giai thich duoc Docker trong data workflow.

Can tra loi:

- Image khac container nhu the nao?
- Volume dung de lam gi?
- Vi sao container khong connect duoc localhost?
- Debug container crash ra sao?
- Docker Compose khac Kubernetes/Airflow nhu the nao?

## Image vs container

Image la template bat bien gom OS layer, dependency, code va command mac dinh. Container la mot process dang chay tu image.

Tu duy:

- Image: "ban build".
- Container: "ban run".
- Image co the tao nhieu container.
- Xoa container khong xoa image.
- Xoa container database khong nen lam mat data neu data nam trong volume.

Command:

```bash
docker images
docker ps
docker ps -a
docker stop <container>
docker rm <container>
```

## Dockerfile cho Python pipeline

Vi du:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

ENV PYTHONPATH=/app

CMD ["python", "-m", "src.pipeline.main"]
```

Giai thich:

- Copy `requirements.txt` truoc de Docker cache dependency layer.
- Copy source sau de sua code khong can install lai dependency neu requirements khong doi.
- `CMD` la command mac dinh, co the override khi run.

`.dockerignore` nen co:

```text
.git
.venv
__pycache__
.pytest_cache
data
.env
```

Khong co `.dockerignore`, build context co the rat lon va vo tinh copy secret/data.

## Docker Compose

Compose dung de chay nhieu service local.

Vi du Postgres + Python app:

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: de_user
      POSTGRES_PASSWORD: de_password
      POSTGRES_DB: de_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U de_user -d de_db"]
      interval: 5s
      timeout: 5s
      retries: 10

  pipeline:
    build: .
    environment:
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: de_db
      DATABASE_USER: de_user
      DATABASE_PASSWORD: de_password
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  postgres_data:
```

Quan trong:

- App container connect database bang host `postgres`, khong phai `localhost`.
- `ports` expose ra host de ban connect tu may local.
- `volumes` giu data Postgres sau khi container bi xoa.
- `depends_on` voi healthcheck giup app doi database san sang.

## Postgres container

Chay nhanh:

```bash
docker run --name de-postgres \
  -e POSTGRES_USER=de_user \
  -e POSTGRES_PASSWORD=de_password \
  -e POSTGRES_DB=de_db \
  -p 5432:5432 \
  -v de_postgres_data:/var/lib/postgresql/data \
  postgres:16
```

Connect tu host:

```bash
psql -h localhost -p 5432 -U de_user -d de_db
```

Connect tu container cung Compose network:

```text
host=postgres
port=5432
```

Init scripts:

- Files trong `/docker-entrypoint-initdb.d` chi chay khi database volume moi tao.
- Neu volume da ton tai, sua init SQL khong tu dong re-run.

Day la loi rat hay gap khi hoc Docker/Postgres.

## Volumes va bind mounts

### Named volume

```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
```

Phu hop:

- Database data.
- Can persist.
- Khong can xem file truc tiep thuong xuyen.

### Bind mount

```yaml
volumes:
  - ./src:/app/src
```

Phu hop:

- Development.
- Sua code local va container thay doi theo.
- Mount init scripts/config.

Trade-off:

- Bind mount phu thuoc path local.
- Permission issue hay gap tren Linux/Windows/Mac.
- Named volume on dinh hon cho database.

## Networking

Trong Compose, moi service co DNS name bang service name.

Sai:

```text
DATABASE_HOST=localhost
```

Dung khi app la container:

```text
DATABASE_HOST=postgres
```

Vi sao:

- `localhost` ben trong container la chinh container do.
- Database nam o container khac.
- Compose network resolve `postgres` den IP cua database container.

Debug network:

```bash
docker compose ps
docker compose logs postgres
docker compose exec pipeline sh
```

Trong container:

```bash
env
python -c "import socket; print(socket.gethostbyname('postgres'))"
```

## Environment variables

Dung env vars de truyen config:

- Database host/user/password.
- API URL/token.
- Run date.
- Batch size.

Khong nen hard-code secrets trong image.

Compose co the doc `.env`, nhung `.env` khong nen commit.

Nen commit `.env.example`:

```text
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=de_db
DATABASE_USER=de_user
DATABASE_PASSWORD=change_me
```

## Local data platform examples

### Minimal DE local platform

```text
Python app -> PostgreSQL
```

Dung cho:

- Ingestion lab.
- SQL practice.
- Upsert/idempotency.

### Analytics local platform

```text
Python app -> PostgreSQL -> dbt -> marts
```

Dung cho:

- ELT practice.
- Data modeling.
- Tests.

### Streaming local platform

```text
Producer -> Kafka -> Consumer -> PostgreSQL
```

Kafka Compose co the nang, nhung nen biet concept.

Kafka service pattern:

```yaml
services:
  kafka:
    image: bitnami/kafka:latest
    ports:
      - "9092:9092"
    environment:
      KAFKA_CFG_NODE_ID: 1
      KAFKA_CFG_PROCESS_ROLES: broker,controller
      KAFKA_CFG_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
      KAFKA_CFG_LISTENERS: PLAINTEXT://:9092,CONTROLLER://:9093
      KAFKA_CFG_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_CFG_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE: "true"
```

Trong practice, chi can producer/consumer connect `kafka:9092` tu container cung network.

### Airflow local concept

Airflow can nhieu service hon:

```text
webserver + scheduler + metadata database + worker optional
```

Dung Airflow Docker Compose de hoc DAG, nhung dung no qua som co the lam ban mat thoi gian vao config. Trien khai thuc te can quan tam:

- Metadata DB.
- Scheduler health.
- Worker logs.
- DAG volume.
- Secrets.
- Connections.

## Container debugging

### Container crash ngay khi start

Command:

```bash
docker compose ps
docker compose logs pipeline
```

Check:

- Exit code.
- Stack trace.
- Missing env var.
- Wrong command.
- Dependency missing.
- File path sai.

### Container chay nhung app khong connect DB

Checklist:

1. Database container co healthy khong?
2. App dung host `postgres` hay `localhost`?
3. Port trong container co dung 5432 khong?
4. User/password/db co khop khong?
5. App start truoc khi DB ready khong?

### Init SQL khong chay

Nguyen nhan thuong gap:

- Volume Postgres da ton tai.
- File khong nam dung folder mount.
- File extension khong phai `.sql`/`.sh`.
- SQL fail nhung log bi bo qua.

Fix:

- Xem logs Postgres.
- Neu muon init lai local lab, xoa volume co chu dich.
- Trong production khong xoa volume tuy tien.

### Permission denied voi volume

Trieu chung:

- App khong ghi duoc `/data`.
- Postgres khong start do owner sai.

Debug:

```bash
docker compose exec pipeline sh
whoami
ls -lah /data
```

Fix:

- Chon user phu hop.
- Sua owner/quyen tren host.
- Dung named volume neu phu hop.

## Production mindset

Docker image production nen:

- Build reproducible.
- Pin dependency versions.
- Khong chua secret.
- Khong chua data raw lon.
- Chay command ro rang.
- Log stdout/stderr.
- Fail fast khi config sai.
- Co healthcheck neu la service.

Khong nen:

- SSH vao container de sua code tay.
- Build image tu dependency floating khong pin.
- Chay container voi root neu khong can.
- Dua `.env` vao image.
- De container silently restart vo han ma khong alert.

## Architecture mindset

Docker trong data architecture co vai tro khac nhau:

### Local development

Dung Compose de mo phong:

```text
postgres + pipeline + dbt + admin tool
```

Muc tieu: reproduce nhanh, hoc/debug local.

### CI

Dung container de chay:

- pytest.
- SQL tests.
- dbt build.
- integration tests voi Postgres service.

### Production

Docker image co the duoc chay boi:

- Kubernetes.
- ECS.
- Cloud Run.
- Airflow KubernetesPodOperator.
- Batch service.

Docker Compose khong phai production orchestrator cho he thong lon, nhung rat tot cho local lab va small internal tools.

## Real-world failure cases

### "Works on my machine"

Nguyen nhan:

- Dependency local khac.
- Python version khac.
- Env var khac.
- File path hard-code.

Docker fix:

- Pin runtime.
- Pin dependencies.
- Run command standardized.
- Env documented.

### Stale image

Trieu chung:

- Sua code nhung container van chay logic cu.

Fix:

```bash
docker compose build --no-cache pipeline
docker compose up
```

Hoac xem Dockerfile cache layer co copy source dung khong.

### Port conflict

Trieu chung:

- Bind for 0.0.0.0:5432 failed.

Nguyen nhan:

- May local da co Postgres chay.

Fix:

- Doi host port: `"5433:5432"`.
- Connect tu host qua 5433, tu container van la 5432.

### Data mat sau khi down

Nguyen nhan:

- Khong dung volume.
- Dung `down -v` lam xoa volume.

Fix:

- Dung named volume.
- Hieu ro lenh nao xoa volume.

### App start truoc DB

Nguyen nhan:

- `depends_on` khong doi database ready neu khong co healthcheck.

Fix:

- Healthcheck.
- Retry connection trong app.
- Migration/load step co retry gioi han.

## Trade-offs

- Docker Compose: nhanh cho local, de doc, nhung khong thay the production scheduler/orchestrator.
- Named volume: on dinh cho data, nhung kho inspect truc tiep hon bind mount.
- Bind mount: tot cho dev, nhung permission/path issue nhieu hon.
- Alpine image: nho, nhung co the gap loi build dependency native.
- Slim Debian image: lon hon Alpine, thuong it loi hon cho Python data libs.
- Root user: tien local, rui ro production.
- One container many processes: tien demo, kem production. Nen moi container mot vai tro ro.

## Performance considerations

- Build context nho bang `.dockerignore`.
- Copy requirements truoc source de tan dung cache.
- Pin dependency de build reproducible.
- Tranh install dependency moi lan container start; install luc build image.
- Mount data lon can hieu I/O performance theo OS.
- Log qua nhieu co the lam day disk.
- Kafka/Spark/Airflow local can RAM; khong chay tat ca neu may yeu.

## Hands-on exercises

### Level 1: Postgres container

1. Viet `docker-compose.yml` cho Postgres.
2. Expose port 5432.
3. Tao named volume.
4. Them init SQL tao table `orders`.
5. Connect bang `psql`.

### Level 2: Python pipeline container

1. Viet Dockerfile cho Python app.
2. App doc env vars database.
3. App insert 10 records vao Postgres.
4. Chay bang Compose.
5. Log loaded count.

### Level 3: Debug networking

1. Co tinh dat `DATABASE_HOST=localhost`.
2. Chay app va quan sat fail.
3. Doi thanh `postgres`.
4. Ghi lai root cause trong README.

### Level 4: Volume va init

1. Sua init SQL sau khi volume da tao.
2. Quan sat init khong chay lai.
3. Giai thich vi sao.
4. Reset local volume co chu dich.

### Level 5: Local mini platform

1. Postgres.
2. Python ingestion app.
3. dbt hoac SQL transform container.
4. Quality check command.
5. README co one-command run.

## Mini project

### De bai

Build local data platform:

```text
Python ingestion container -> PostgreSQL container -> SQL quality checks
```

### Yeu cau

- `docker-compose.yml`.
- `Dockerfile`.
- `.dockerignore`.
- `.env.example`.
- `init/00_schema.sql`.
- Python app load data idempotent.
- Healthcheck Postgres.
- README co architecture, setup, debug guide.

### Debug scenarios bat buoc

- Sai DB host.
- Sai password.
- Init script khong chay do volume cu.
- Duplicate load khi retry neu khong upsert.
- Port conflict 5432.

## Kinh nghiem thuc te

- Container log nen ra stdout/stderr de orchestrator thu thap.
- Service trong Compose connect nhau bang service name.
- Postgres init scripts chi chay khi data directory moi.
- Volume la ranh gioi giua ephemeral container va persistent state.
- Dockerfile tot giup CI va teammate reproduce nhanh.
- Docker khong thay the config management, secrets management va observability.
- Local Compose nen giong production ve contract, khong can giong 100% ve infrastructure.

## Loi thuong gap

- App container connect `localhost` thay vi service name.
- Khong dung volume cho database.
- Vo tinh xoa volume local.
- Copy `.env` hoac data lon vao image.
- Khong co `.dockerignore`.
- Build image cham vi layer order sai.
- Port host bi conflict.
- Khong pin dependency.
- Container crash nhung khong doc logs.
- `depends_on` nhung khong co healthcheck.
- Chay nhieu service nang cung luc lam may local het RAM.

## Cau hoi phong van

### Docker basics

- Image khac container nhu the nao?
- Dockerfile dung de lam gi?
- Layer caching hoat dong o muc concept nhu the nao?
- CMD va ENTRYPOINT khac nhau ra sao o muc concept?

### Compose va networking

- Docker Compose dung de lam gi?
- Vi sao container khong connect database qua `localhost`?
- Port mapping `"5433:5432"` nghia la gi?
- Service name trong Compose co vai tro gi?

### Volumes va data

- Volume dung de lam gi?
- Named volume khac bind mount nhu the nao?
- Vi sao Postgres init SQL khong chay lai sau lan dau?
- Lenh nao co the lam mat data volume local?

### Debugging

- Container crash, ban debug theo thu tu nao?
- App connect DB fail, ban check gi?
- Docker build cham, ban toi uu ra sao?
- Port conflict xu ly the nao?

### Production

- Docker Compose co phai production orchestrator khong?
- Docker image production khong nen chua gi?
- Vi sao khong nen sua code tay trong container production?
- Docker lien quan gi den CI/CD data pipeline?

## Dau ra can co tren GitHub

Toi thieu:

- `Dockerfile`.
- `docker-compose.yml`.
- `.dockerignore`.
- `.env.example`.
- `init/00_schema.sql`.
- README co lenh `docker compose up`.

Tot hon:

- Healthcheck cho Postgres.
- Python app container load data.
- Quality check command.
- Debugging section trong README.
- Architecture diagram bang text.
- Scripts/Makefile cho commands thong dung.
- CI chay build image hoac integration test voi Postgres service.

## Production upgrade: secure and debuggable containers

### Multi-stage build

Multi-stage build giam image size va attack surface.

Pattern:

```dockerfile
FROM python:3.12-slim AS runtime
WORKDIR /app
COPY pyproject.toml .
RUN pip install --no-cache-dir .
COPY src/ src/
USER 10001
CMD ["python", "-m", "de_pipeline.cli"]
```

Production lessons:

- Image nho hon build/pull nhanh hon.
- It package thua hon, it CVE hon.
- Non-root user giam damage neu container bi compromise.

### `.dockerignore`

Khong co `.dockerignore` lam build context lon va co the copy secrets.

Nen exclude:

```text
.git
.env
__pycache__/
.pytest_cache/
data/
*.csv
*.parquet
```

### Healthcheck

Healthcheck nen check service san sang that, khong chi process ton tai.

Vi du Postgres:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U de_user -d de_db"]
  interval: 5s
  timeout: 5s
  retries: 10
```

### Resource limits

Local Compose co the can:

- Memory limit cho Spark/Kafka/Postgres.
- CPU limit neu may yeu.
- Disk volume cleanup policy.

Failure mode:

- Container bi OOMKilled nhung log chi hien app abruptly died.
- Kafka/Postgres day disk do volume khong cleanup.

### Debugging scenarios

#### App cannot connect DB

Checklist:

1. App va DB co cung Docker network khong?
2. App dung service name `postgres`, khong phai `localhost`.
3. DB healthcheck da ready chua?
4. Port mapping chi can cho host, container-to-container dung internal port.
5. Credential/env var co dung khong?

#### Volume permission issue

Symptom:

- Container cannot write mounted folder.

Fix:

- Check container user.
- Check host directory permission.
- Avoid running everything as root just to make it pass.
- Document Windows/macOS path caveats.

#### Port conflict

Symptom:

- `bind: address already in use`.

Fix:

- Identify existing process.
- Change host port mapping.
- Keep container port same, only host port changes.

### Secrets

Docker Compose `.env` tien loi nhung khong phai secret manager.

Production rule:

- `.env` local only.
- `.env.example` commit.
- Real secrets in CI secret store/cloud secret manager.
- Never bake secrets into image layers.
