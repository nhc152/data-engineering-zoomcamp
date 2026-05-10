# Infrastructure as Code cho Data Engineering

## Vai tro

Infrastructure as Code IaC giup data platform co the recreate, review, version, audit va deploy mot cach nhat quan. Neu ha tang duoc tao tay tren UI, production se gap:

- khong biet ai tao gi
- dev/prod khac nhau
- permissions drift
- bucket/table/warehouse settings khong ro
- disaster recovery kho
- onboarding cham
- security review yeu

Data Engineer khong can thanh platform engineer day du ngay, nhung can hieu IaC cho data platform.

## Muc tieu can dat

- Hieu vi sao IaC quan trong.
- Biet Terraform basics cho cloud data resources.
- Biet thiet ke dev/staging/prod environments.
- Biet quan ly state, variables, secrets.
- Biet deploy GCS/BigQuery/service accounts/IAM.
- Biet IaC review workflow.
- Biet trade-off giua Terraform, Pulumi, CloudFormation, CDK.

## Khai niem can nam

- Declarative infrastructure.
- Terraform provider.
- Resource.
- Module.
- Variable.
- Output.
- State.
- Remote backend.
- Plan/apply.
- Drift.
- Workspace/environment.
- IAM.
- Service account.
- Least privilege.
- Secret manager.

## Architecture mindset

IaC cho data platform nen cover:

```text
cloud project/account
  -> network/security baseline
  -> storage buckets
  -> warehouse datasets
  -> service accounts
  -> IAM roles
  -> orchestration resources
  -> monitoring/alerts
```

IaC khong nen chi tao compute. No phai tao guardrails:

- labels/tags
- retention
- lifecycle policies
- encryption
- access policies
- budget alerts

## Production mindset

IaC production rules:

- No manual prod changes except emergency.
- Every change via PR.
- `terraform plan` reviewed.
- Remote state locked.
- Secrets not stored in git.
- Separate state per environment.
- Least privilege service accounts.
- Naming convention.
- Labels for ownership/cost.

## Terraform workflow

Common workflow:

```text
edit code
  -> terraform fmt
  -> terraform validate
  -> terraform plan
  -> review
  -> terraform apply
```

In CI/CD:

- PR runs fmt/validate/plan.
- Merge/apply requires approval.
- Prod apply restricted.

## Environment design

Recommended:

```text
envs/
  dev/
  staging/
  prod/
modules/
  storage_bucket/
  bigquery_dataset/
  service_account/
  iam_binding/
```

Dev:

- cheaper
- smaller quotas
- relaxed data retention
- fake/masked data

Prod:

- strict IAM
- audit logs
- retention policy
- budget alerts
- backup/recovery

Avoid:

- one shared environment for all
- manual differences between dev and prod
- prod service accounts used in dev

## Data resources to manage

### Object storage

Manage:

- bucket name
- region
- lifecycle
- versioning
- encryption
- access
- labels

Decisions:

- raw bucket immutable?
- retention period?
- delete temp files after how long?
- multi-region vs region?

### Warehouse

Manage:

- datasets/schemas
- location
- access
- default table expiration
- labels
- reservations/warehouses if applicable

Decisions:

- raw/staging/marts separation
- dev/prod dataset naming
- BI access to marts only
- cost attribution labels

### Service accounts

Pattern:

- one service account per pipeline/app
- least privilege
- no shared admin service account
- rotate credentials or use workload identity where possible

### Orchestration

IaC can manage:

- Airflow environment
- secrets
- connections
- worker sizes
- schedules sometimes via code repo
- alert channels

## State management

Terraform state is sensitive because it records infrastructure and sometimes secret-like values.

Production state should be:

- remote
- encrypted
- access-controlled
- locked
- backed up

Do not:

- commit state file
- share local state
- edit state manually without expertise

## Drift management

Drift la khi real infra khac code.

Causes:

- manual console changes
- emergency fixes
- provider defaults change
- resources deleted outside Terraform

Handling:

- scheduled drift detection
- restrict manual prod access
- import existing resources
- document emergency changes and reconcile code

## Security mindset

IaC can create dangerous changes quickly. Need:

- plan review
- policy checks
- prevent broad IAM roles
- scan for secrets
- restrict apply permissions
- separate break-glass access

Anti-pattern:

- `roles/editor` cho service account.
- public bucket accidentally.
- same SA key in many pipelines.
- storing credentials in Terraform variables in git.

## Cost considerations

IaC should enforce cost controls:

- labels/tags
- budgets
- autosuspend warehouses
- table expiration
- lifecycle rules
- smaller dev resources
- prevent accidental huge clusters

Cost drift happens when:

- dev resources left running
- temp datasets never expire
- backfill cluster not destroyed
- monitoring disabled

## Debugging mindset

When IaC apply fails:

1. Read provider error.
2. Check permissions of deploy identity.
3. Check resource already exists.
4. Check region/location mismatch.
5. Check state lock.
6. Check quota.
7. Check API enabled.

When pipeline cannot access resource:

1. Identify runtime service account.
2. Check IAM binding.
3. Check dataset/bucket policy.
4. Check network restriction.
5. Check secret access.

## Real-world failures

- Terraform apply removed IAM binding used by production pipeline.
- Manual bucket created in wrong region, BigQuery load failed.
- State file lost, team could not manage resources safely.
- Dev used prod service account and wrote test data into prod bucket.
- Table expiration applied to production mart and deleted historical data.
- Public access allowed on raw bucket with PII.

## Trade-offs

- Terraform widely used, strong ecosystem, state management complexity.
- Pulumi uses programming languages, flexible but easier to overcomplicate.
- CloudFormation/CDK good for AWS-native but less multi-cloud.
- Manual UI fast for experiment, dangerous for production drift.
- One monorepo easier consistency, many repos easier ownership isolation.

## Exercises

1. Design Terraform structure for GCP data platform.
2. Define buckets: raw, staging, curated, temp.
3. Define BigQuery datasets: raw, staging, marts.
4. Define service account per pipeline.
5. Write IAM matrix.
6. Define lifecycle rules for temp/raw.
7. Write drift response procedure.

## Mini project

Create IaC design for ecommerce DE project:

- GCS buckets
- BigQuery datasets
- service accounts
- IAM roles
- labels
- budget alerts
- lifecycle policies
- dev/prod separation

README must explain:

- why each resource exists
- who owns it
- what permissions it has
- cost controls
- recovery approach

## Interview questions

- IaC giup gi cho data platform?
- Terraform state la gi va vi sao quan trong?
- Drift la gi?
- Service account nen thiet ke ra sao?
- Least privilege ap dung trong pipeline the nao?
- Dev/prod separation can gi?
- Lam sao tranh public bucket?
- IaC va CI/CD ket hop ra sao?
- Khi Terraform apply fail thi debug sao?

## GitHub outputs

- `infra/envs/dev/main.tf`
- `infra/envs/prod/main.tf`
- `infra/modules/bigquery_dataset/`
- `infra/modules/storage_bucket/`
- `infra/modules/service_account/`
- `infra/README.md`
- `infra/iam_matrix.md`

## Production IaC upgrade

### Terraform module structure

Production repo khong nen co mot file `main.tf` khong ro ownership. Nen tach modules va environments:

```text
infra/
  modules/
    storage_bucket/
      main.tf
      variables.tf
      outputs.tf
    bigquery_dataset/
      main.tf
      variables.tf
      outputs.tf
    service_account/
      main.tf
      variables.tf
      outputs.tf
  envs/
    dev/
      main.tf
      backend.tf
      variables.tf
      terraform.tfvars
    prod/
      main.tf
      backend.tf
      variables.tf
      terraform.tfvars
```

Operational lesson:

- Module reuse tot, nhung abstraction qua som lam kho review.
- Moi module nen co purpose ro va outputs can thiet.
- Prod va dev khac values, khong nen khac architecture qua nhieu.

### Remote backend va state locking

Terraform state la source of truth cua infrastructure. Local state rat rui ro trong team.

Production requirements:

- Remote backend.
- State locking.
- Versioning.
- Restricted access.
- Backup/recovery.

Failure mode:

- Hai engineer apply cung luc, state corrupt hoac resource bi overwrite.
- Laptop mat local state, Terraform muon recreate resources.

Prevention:

- GCS/S3 remote backend.
- Locking neu provider/backend ho tro.
- CI apply path duy nhat cho prod.
- Khong sua state thu cong tru khi co runbook.

### Plan/apply workflow

Safe workflow:

```text
developer branch
    -> terraform fmt/validate
    -> terraform plan
    -> PR review
    -> security/cost policy checks
    -> approval
    -> apply by CI service account
```

Prod apply khong nen chay tu laptop ca nhan neu platform da mature.

### Policy-as-code gates

Examples:

- Bucket khong duoc public.
- Dataset PII phai co restricted IAM.
- Service account khong duoc co owner/editor.
- BigQuery table lon phai co partition.
- Resources phai co labels: owner, env, cost_center.

Policy-as-code co the dung:

- OPA/Conftest.
- Terraform Cloud policies.
- Checkov/tfsec.
- Custom CI scripts.

### Terraform import

Production thuong co resource tao tay truoc khi IaC.

Import workflow:

1. Inventory resource.
2. Viet Terraform config matching resource.
3. Run `terraform import`.
4. Run plan de xem diff.
5. Reconcile drift.
6. Lock manual changes going forward.

Rui ro:

- Config khong match, plan muon replace resource critical.
- Import sai address/module.

Rule:

- Import tung resource nho.
- Review plan ky.
- Khong apply destructive change neu chua co backup/approval.

### Drift management

Drift xay ra khi resource bi sua ngoai Terraform.

Examples:

- Ai do them IAM role bang console.
- Bucket lifecycle bi tat.
- Dataset access bi thay doi.

Runbook:

1. Run plan read-only.
2. Identify drift critical vs harmless.
3. Neu console change dung, update Terraform code.
4. Neu console change sai, apply Terraform de revert.
5. Tim root cause: ai co quyen manual?

### Secret handling

Khong dua secrets vao:

- Terraform variables plain text.
- `tfvars` commit len repo.
- State neu co the tranh.
- Outputs.

Patterns:

- Secret Manager.
- CI secrets.
- Workload identity/federation.
- Short-lived credentials.

Luu y:

- Mot so Terraform resources co the ghi sensitive values vao state.
- State backend phai duoc bao ve nhu secret.

### Destructive apply runbook

Symptom:

- `terraform plan` hien `destroy`/`replace` cho bucket, dataset, service account, IAM binding quan trong.

Triage:

1. Resource nao bi destroy/replace?
2. Co data loss khong?
3. Do config rename, provider diff hay drift?
4. Co lifecycle `prevent_destroy` khong?
5. Co backup/export khong?
6. Ai approve?

Mitigation:

- Stop apply.
- Add `moved` block neu rename resource.
- Import resource neu state missing.
- Add `prevent_destroy` cho critical resources.
- Split IAM changes nho de review.

### IaC lab target

To make this module production-grade, create a runnable lab:

```text
infra/
  modules/storage_bucket
  modules/bigquery_dataset
  modules/service_account
  envs/dev
  envs/prod
  policies/
    no_public_bucket.rego
    no_owner_service_account.rego
  README.md
```

Lab resources:

- GCS raw bucket with lifecycle.
- BigQuery raw/staging/marts datasets.
- Pipeline service account.
- Least-privilege IAM.
- Labels for owner/env/cost.
- Remote backend notes.

