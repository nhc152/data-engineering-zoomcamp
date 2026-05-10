# CI/CD, Testing va Production Habits

## Vai tro

CI/CD trong data engineering khong chi la chay test cho code. No la co che de ngan pipeline loi, model dbt sai, schema thay doi, secret leak, deployment vo tinh pha production va rollback khong lam duoc.

Data pipeline production co nhieu loai failure:

- Code chay local nhung fail tren runner.
- dbt model compile duoc nhung metric sai.
- Secret bi commit len GitHub.
- Deployment overwrite bang production.
- Migration schema pha downstream.
- Rollback code nhung data da bi ghi sai.

CI/CD tot giup phat hien truoc khi merge/deploy va co du duong lui khi production fail.

## Muc tieu can dat

Sau module nay, ban nen:

- Thiet ke CI cho Python, SQL/dbt, Docker.
- Phan biet unit, integration, data, end-to-end tests.
- Tach dev/staging/prod environment.
- Quan ly secrets an toan.
- Hieu deployment strategy cho data pipelines.
- Biet rollback code va rollback/reprocess data khac nhau.
- Viet runbook production readiness.
- Debug broken deployment.

## Khai niem can nam

- CI: continuous integration, kiem tra moi change truoc khi merge.
- CD: continuous delivery/deployment, dua change ra moi truong.
- Unit test: test function nho.
- Integration test: test voi DB/API/service that hoac container.
- Data test: test properties cua data output.
- End-to-end test: chay pipeline tu input den output.
- Environment: dev, staging, prod.
- Secret: password, token, service account key.
- Migration: thay doi schema/table.
- Rollback: quay lai code/config/data state an toan.
- Blue/green/canary: chien luoc deploy giam rui ro.

## Architecture mindset

Data CI/CD nen bao ve 4 lop:

```text
code quality
  | lint, format, unit tests
  v
integration correctness
  | docker services, db tests, API mocks
  v
data correctness
  | dbt tests, SQL checks, sample reconciliation
  v
deployment safety
  | env separation, approvals, rollback, runbooks
```

Khong nen chi co "pytest pass". Data pipeline co the pass pytest nhung van sai business metric.

## Testing strategy

### Unit tests

Dung cho:

- Python transform functions.
- Date parsing.
- Config loading.
- Dedup helper.
- API pagination logic.

Example:

```python
def test_normalize_status():
    assert normalize_status(" PAID ") == "paid"
    assert normalize_status("Completed") == "completed"
```

### Integration tests

Dung cho:

- Ket noi Postgres.
- Load CSV vao table.
- Run SQL transform.
- Kafka producer/consumer local.
- Spark job voi sample data.

Integration test nen chay tren sample data nho va deterministic.

### Data tests

Dung cho:

- Unique key.
- Not null.
- Accepted values.
- Referential integrity.
- Freshness.
- Reconciliation.

Data tests co the chay trong dbt, Great Expectations, Soda, hoac plain SQL.

### End-to-end tests

Dung cho critical pipeline:

```text
sample raw input -> pipeline -> target table -> expected output
```

Khong nen E2E qua nang trong moi PR neu lam CI cham. Co the chay nightly hoac truoc release.

## GitHub Actions pattern

Workflow co ban:

```yaml
name: ci

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - run: pytest
```

Data pipeline CI tot hon can:

- Lint/format.
- Unit tests.
- Spin up Postgres service.
- Run migrations/schema.
- Run dbt compile/test.
- Validate Docker build.
- Scan secrets.

## Environment separation

Dev:

- Data nho.
- Developer co quyen thu nghiem.
- Chi phi thap.

Staging:

- Giong prod ve schema.
- Sample/filtered prod data neu duoc phep.
- Dung de test deployment.

Prod:

- Restricted access.
- Approval required.
- Monitoring/alerts.
- Backup/rollback plan.

Loi nghiem trong:

- Dev script ket noi nham prod.
- CI test overwrite prod table.
- Secret prod dung trong local.

Prevention:

- Environment-specific service accounts.
- Naming ro: `project_dev`, `project_prod`.
- IaC config review.
- Deployment approval.
- Guardrail trong code: khong cho write prod neu env khong dung.

## Secrets management

Khong bao gio commit:

- `.env`
- service account JSON
- database password
- API token
- private key

Nen dung:

- GitHub Secrets.
- Cloud Secret Manager.
- Workload identity/OIDC neu co.
- `.env.example` chi chua key names.

Secret leakage scenario:

1. Developer commit service account key.
2. GitHub public/private repo bi clone.
3. Key van con valid ke ca sau khi xoa commit.
4. Attacker dung key truy cap cloud.

Fix:

- Revoke/rotate key ngay.
- Remove from git history neu can.
- Audit logs.
- Them secret scanning.
- Dung short-lived credentials neu co the.

## Deployment strategy

### Code deployment

- Merge vao main.
- Build artifact/image.
- Deploy DAG/job/dbt package.
- Run smoke tests.
- Monitor.

### Data deployment

Data deployment phuc tap hon code vi output co state.

Rui ro:

- Model moi ghi sai data.
- Schema change pha dashboard.
- Incremental logic moi corrupt target.
- Backfill overwrite lich su.

An toan hon:

- Deploy vao staging schema truoc.
- Compare row count/metrics voi prod.
- Swap view/table sau khi validate.
- Backup old table/partition.
- Roll forward fix neu rollback data kho.

### Blue/green cho data

Pattern:

```text
marts_v1.fct_orders -> current prod
marts_v2.fct_orders -> new build
validate v2
switch view marts.fct_orders to v2
```

Phu hop cho critical marts. Ton storage hon nhung giam rui ro.

## Rollback

Rollback code:

- Revert commit.
- Redeploy old image/DAG.

Rollback data:

- Restore table snapshot.
- Rebuild partition.
- Reprocess from raw.
- Swap view back.
- Apply compensating fix.

Rollback data kho hon vi:

- Downstream da consume data sai.
- Incremental target da bi merge.
- Dashboard cache da update.
- External system da nhan output.

Production pipeline nen co raw immutable layer de reprocess.

## Broken deployment scenarios

### Scenario 1: dbt model deploy sai grain

Symptoms:

- CI pass.
- Revenue tang 30%.

Cause:

- Model join fact voi item-level table, metric duplicate.

Prevention:

- Data diff in CI.
- Grain tests.
- Reconciliation checks.
- Review query plan/logic.

### Scenario 2: Secret leak

Symptoms:

- Secret scanner alert.
- Cloud audit co truy cap bat thuong.

Response:

- Revoke key.
- Rotate credentials.
- Review access logs.
- Add/prevent secret scanning.
- Replace key-based auth bang OIDC neu co.

### Scenario 3: Rollback fails

Symptoms:

- Revert code nhung table da bi overwrite.

Cause:

- Khong co table snapshot.
- Khong co raw reprocess.
- Deployment ghi truc tiep vao prod table.

Prevention:

- Write to temp/staging table.
- Validate before publish.
- Snapshot critical table.
- Partition-level overwrite.

## Production readiness checklist

Truoc khi coi pipeline production-ready:

- [ ] Code co tests.
- [ ] SQL/dbt co data tests.
- [ ] Secrets khong nam trong repo.
- [ ] Dev/staging/prod tach rieng.
- [ ] Job idempotent.
- [ ] Co retry/backoff.
- [ ] Co alert va owner.
- [ ] Co runbook.
- [ ] Co backfill strategy.
- [ ] Co rollback/reprocess plan.
- [ ] Co cost guardrails.
- [ ] README co architecture va run command.

## Cost considerations

CI/CD cung ton chi phi:

- Runner minutes.
- Docker build time.
- Test database.
- Cloud test queries.
- Duplicate staging/prod data.

Toi uu:

- Unit tests chay moi PR.
- Integration tests chay khi file lien quan thay doi.
- E2E chay nightly/release.
- Dung sample data nho.
- Tranh query full warehouse trong CI.
- Cache dependencies hop ly.

## Exercises

1. Tao `pytest` cho function normalize status.
2. Tao Docker Compose Postgres cho integration test.
3. Viet SQL data tests: duplicate, not null, accepted values.
4. Tao GitHub Actions chay unit tests.
5. Them service Postgres vao GitHub Actions va chay integration test.
6. Them secret scanning step.
7. Tao staging/prod config files.
8. Viet rollback plan cho dbt model sai.
9. Viet runbook khi deployment lam dashboard sai.

## Mini project

Build production-ready CI/CD cho ecommerce pipeline:

```text
PR
 |
 v
lint + unit tests
 |
 v
integration test with Postgres
 |
 v
dbt compile/test on sample data
 |
 v
merge
 |
 v
deploy staging
 |
 v
validate metrics
 |
 v
promote prod
```

Yeu cau:

- `.github/workflows/ci.yml`.
- `tests/`.
- `docker-compose.yml` cho test DB.
- `.env.example`.
- `RUNBOOK.md`.
- `DEPLOYMENT.md`.
- README giai thich rollback.

## Interview questions

- CI/CD trong data engineering khac software backend o dau?
- Unit, integration, data, E2E tests khac nhau the nao?
- Lam sao test dbt model trong CI?
- Lam sao tranh CI ghi nham prod?
- Secret leak thi xu ly sao?
- Rollback code va rollback data khac nhau the nao?
- Deployment model moi lam metric sai, ban lam gi?
- Khi nao can staging environment?
- Blue/green deployment cho data la gi?
- Production readiness checklist cua ban gom gi?

## GitHub outputs

Repo production-minded nen co:

- `.github/workflows/ci.yml`.
- `tests/unit/`.
- `tests/integration/`.
- `quality/` hoac dbt tests.
- `.env.example`.
- `RUNBOOK.md`.
- `DEPLOYMENT.md`.
- `SECURITY.md` ngan.
- `README.md` co architecture, setup, test, deploy.

## Production upgrade: CI/CD blueprint

### Example GitHub Actions pipeline

```yaml
name: data-platform-ci

on:
  pull_request:
  push:
    branches: [main]

jobs:
  python:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -e ".[dev]"
      - run: ruff check .
      - run: pytest

  dbt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pip install dbt-core dbt-postgres
      - run: dbt parse
      - run: dbt build --select state:modified+ --defer --state ./artifacts

  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: terraform fmt -check -recursive infra/
      - run: terraform -chdir=infra/envs/dev init -backend=false
      - run: terraform -chdir=infra/envs/dev validate
```

This is a pattern, not copy-paste production. Real prod needs secrets, backend, approvals and environment protection.

### Promotion strategy

```text
dev branch/PR
  -> CI tests
  -> merge main
  -> deploy dev
  -> integration validation
  -> promote to staging
  -> approval
  -> deploy prod
```

Data systems often need promotion of:

- Code.
- dbt artifacts.
- Terraform plans.
- Schema migrations.
- Backfill plans.

### Rollback data vs rollback code

Rollback code:

- Revert commit.
- Redeploy previous image/DAG/model.

Rollback data:

- Harder.
- Need backup/snapshot.
- Need partition restore or rebuild from raw.
- Need downstream correction if wrong data was consumed.

Operational lesson:

- For risky transforms, publish to shadow table first.
- Compare row count/metrics.
- Swap/publish only after validation.

### Ephemeral environments

Ephemeral envs help test PR changes without touching prod:

- Temporary schema per PR.
- Sample data subset.
- dbt target schema based on branch/PR number.
- Auto cleanup after merge/close.

Cost risk:

- Temp schemas/tables not cleaned up.
- CI full refresh on large data.

Prevention:

- Expiration labels.
- Sample data.
- Slim CI.

### Terraform plan gates

Prod IaC changes should expose:

- Resources to create/update/delete.
- IAM changes.
- Public access risk.
- Estimated cost impact.
- Destructive replacements.

Rule:

- Plan with destroy/replace for stateful resources requires explicit approval.
