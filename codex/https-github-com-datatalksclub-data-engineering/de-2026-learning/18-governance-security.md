# Governance va Security cho Data Engineering

## Vai tro

Data platform khong chi can chay dung. No phai duoc quan tri, bao mat, audit duoc va su dung dung muc dich. Khi data platform lon len, van de lon nhat thuong khong phai "thieu tool", ma la:

- khong biet dataset nao dang tin
- khong biet owner la ai
- metric bi tinh khac nhau
- PII bi expose
- schema thay doi pha downstream
- data lineage khong ro
- access cap qua rong

Governance tot giup team di nhanh hon vi co trust, ownership va guardrails.

## Muc tieu can dat

- Hieu data governance trong production.
- Thiet ke access control theo least privilege.
- Biet PII classification, masking, tokenization.
- Biet data catalog, lineage, ownership, data contracts.
- Biet security cho warehouse/lakehouse.
- Biet audit, retention, compliance mindset.
- Biet thiet ke governance ma khong lam team bi nghe.

## Khai niem can nam

- IAM.
- RBAC.
- ABAC.
- Least privilege.
- Service account.
- Secret management.
- Data catalog.
- Data lineage.
- Data owner.
- Data steward.
- PII.
- Masking.
- Tokenization.
- Encryption at rest/in transit.
- Row-level security.
- Column-level security.
- Data retention.
- Data contract.
- Audit log.

## Architecture mindset

Governance nen nam trong architecture, khong phai spreadsheet ngoai le.

```text
sources
  -> ingestion contracts
  -> raw restricted zone
  -> classified datasets
  -> curated trusted marts
  -> governed BI/ML/API access
```

Moi dataset quan trong can co:

- owner
- description
- grain
- freshness SLA
- classification
- tests
- lineage
- retention policy
- access policy

Neu khong co owner, dataset do khong nen duoc xem la production.

## Security mindset

Nguyen tac:

- Least privilege.
- Separate human access and service access.
- No secrets in code.
- No direct BI access to raw sensitive data.
- Mask PII by default.
- Audit all privileged access.
- Treat development and production differently.

Security khong chi la "ai xem duoc table". No bao gom:

- ai co the export data
- ai co the run query ton tien
- ai co the thay doi pipeline
- ai co the access raw PII
- ai co the rotate secrets
- ai co the backfill/delete data

## Data classification

Classification goi y:

- Public: co the cong khai.
- Internal: dung noi bo.
- Confidential: business-sensitive.
- Restricted: PII, payment, health, legal, credentials.

PII examples:

- email
- phone
- address
- full name
- national ID
- precise location
- device identifiers
- payment details

Moi classification nen co policy:

- storage allowed
- access allowed
- masking required
- retention period
- sharing restrictions

## Access control patterns

### Dataset-level access

Phu hop khi:

- team ownership ro
- data khong qua nhay cam trong dataset

Rui ro:

- mot table co PII lam ca dataset bi restricted

### Table-level access

Phu hop:

- curated marts
- domain ownership

### Column-level security

Dung cho:

- email
- phone
- revenue confidential
- fraud signals

### Row-level security

Dung khi:

- regional access
- customer-specific access
- multi-tenant analytics

Trade-off:

- Fine-grained access an toan hon nhung kho debug va quan ly hon.
- Qua nhieu policy co the lam query behavior kho hieu.

## Data contracts

Data contract la thoa thuan giua producer va consumer:

- schema
- primary key
- semantics
- freshness
- allowed values
- change policy
- owner

Contract can co voi:

- application events
- CDC tables
- API payloads
- critical warehouse marts

Schema change policy:

- Add nullable column: usually safe.
- Rename column: breaking.
- Change type: breaking.
- Remove column: breaking.
- Change meaning: dangerous even if schema same.

## Catalog va lineage

Catalog tra loi:

- dataset nay la gi?
- owner la ai?
- grain la gi?
- co PII khong?
- freshness ra sao?
- dung cho metric nao?

Lineage tra loi:

- table nay den tu source nao?
- neu source thay doi, downstream nao bi anh huong?
- dashboard sai thi trace nguoc den dau?

Tools:

- DataHub
- OpenMetadata
- Amundsen
- dbt docs
- cloud-native catalogs

## Production mindset

Governance tot phai gan vao workflow:

- PR review check data contract.
- CI check schema breaking changes.
- dbt docs generate lineage.
- PII scanner gan classification.
- Access request co approval va expiry.
- Dataset production phai co owner.

Khong nen tao governance chi bang tai lieu doc lap ma khong enforcement.

## Debugging mindset

Khi co data incident:

1. Dataset nao bi anh huong?
2. Owner la ai?
3. Lineage upstream/downstream la gi?
4. Co schema change gan day khong?
5. Co access/policy change khong?
6. Co PII leak khong?
7. Co can revoke/rotate/export audit khong?

Khi dashboard sai:

- Kiem tra certified dataset hay ad hoc dataset.
- Kiem tra metric definition.
- Trace lineage.
- Kiem tra data contract.
- Kiem tra freshness and quality tests.

## Real-world failures

- Raw table co email/phone duoc cap access cho toan cong ty.
- Data scientist export customer PII ra local laptop.
- Source team doi meaning cua `status` nhung khong doi schema.
- BI dashboard dung table deprecated vi catalog khong ro.
- Service account dung chung giua dev/prod.
- Delete request GDPR khong propagate den lake backup.

## Trade-offs

- Strict governance tang trust nhung co the lam cham delivery.
- Open data access tang speed nhung tang risk.
- Centralized governance nhat quan hon nhung co the thanh bottleneck.
- Federated ownership scale tot hon nhung can standards manh.
- Masking bao ve data nhung co the lam testing/debug kho hon.

## Cost considerations

Governance cung anh huong cost:

- Query quotas theo team.
- Dataset ownership giup cost attribution.
- Retention policy giam storage.
- Access control tranh BI query raw lon.
- Catalog giup tai su dung dataset thay vi build duplicate.

Khong co governance, cost thuong tang vi:

- duplicate tables
- duplicate metrics
- orphan datasets
- unknown dashboards
- long retention khong can thiet

## Security architecture

Production data platform nen co:

- separate dev/staging/prod projects/accounts
- service accounts per pipeline
- secret manager
- network restrictions
- audit logs
- encryption
- data classification
- access review cadence

Access flow:

```text
user requests access
  -> owner approval
  -> policy applied
  -> expiry/review date
  -> audit log
```

## Exercises

1. Classify ecommerce tables by sensitivity.
2. Design access policy for raw, staging, marts.
3. Write data contract for `orders` event.
4. Identify breaking vs non-breaking schema changes.
5. Design PII masking for customer table.
6. Create incident response checklist for PII exposure.
7. Draw lineage from source orders to revenue dashboard.

## Mini project

Design governance layer for ecommerce warehouse:

- classify raw customers/payments/orders
- define owners
- define access groups
- define masking policy
- define retention policy
- define data contract for orders
- define lineage and certified marts

Output should include:

- access matrix
- PII classification
- contract examples
- incident runbook
- cost ownership model

## Interview questions

- Data governance la gi trong data platform?
- Data contract giai quyet van de gi?
- Column-level security vs masking khac nhau ra sao?
- Lam sao xu ly PII trong warehouse?
- Lineage giup debug incident nhu the nao?
- Least privilege ap dung cho pipeline ra sao?
- Neu source doi schema thi ban bao ve downstream the nao?
- Certified dataset la gi?

## GitHub outputs

- `governance/access_matrix.md`
- `governance/data_contract_orders.md`
- `governance/pii_classification.md`
- `governance/retention_policy.md`
- `governance/incident_runbook.md`

## Production governance upgrade

### Data classification policy

Khong the bao ve du lieu neu khong phan loai du lieu. Toi thieu nen co 4 cap:

```text
Public: co the cong khai, khong co rui ro.
Internal: noi bo cong ty, khong chua PII nhay cam.
Confidential: business metrics, customer-level data, contracts.
Restricted: PII, payment data, health data, secrets, credentials.
```

Moi table/cot quan trong nen co classification. Classification anh huong:

- Ai duoc truy cap.
- Co can masking/tokenization khong.
- Retention bao lau.
- Co duoc export ra local khong.
- Co duoc dung trong non-prod khong.

### PII handling

PII khong nen chi duoc "an" bang convention. Can co control.

Patterns:

- Column masking: email/phone hien partial cho user khong co quyen.
- Tokenization: thay gia tri that bang token on dinh.
- Hashing: dung cho matching/joins, nhung can salt/key management.
- Row-level security: user chi xem du lieu theo region/team.
- Separate restricted dataset: PII nam rieng, marts chi dung surrogate/customer key.

Trade-off:

- Masking giu self-service nhung co the gay confusion khi debug.
- Tokenization bao mat tot hon nhung phuc tap khi can re-identify.
- Hashing khong tu dong an toan neu domain nho, vi co the brute force.

### IAM matrix

Vi du access matrix:

```text
role                    raw         staging     marts       restricted_pii
data_engineer_dev       read        write       write       no direct read
analytics_engineer      read        write       write       masked only
analyst                 no read     no read     read        masked only
ml_engineer             read        read        read        approved case
pipeline_service_acct   read/write  write       write       least required
security_admin          audit       audit       audit       audit
```

Production rule:

- Service account khong nen dung owner/editor.
- Analyst khong nen query raw PII.
- Emergency access phai co expiry va audit.

### Row-level va column-level controls

Row-level security phu hop khi:

- Region/country-based access.
- Tenant/customer separation.
- Team chi xem domain minh.

Column-level security/masking phu hop khi:

- Bang can share rong nhung co cot nhay cam.
- Analyst can aggregate nhung khong can xem email/phone.

Failure mode:

- BI dashboard dung service account qua rong quyen, vo tinh expose PII cho tat ca user.

Fix:

- BI service account chi doc certified masked marts.
- Dashboard access gan voi group.
- Audit query logs dinh ky.

### Retention va legal hold

Retention policy can tra loi:

- Raw data giu bao lau?
- PII xoa/anonymize khi nao?
- Backup co tuan thu delete request khong?
- Legal hold co override retention khong?

Production issue hay gap:

- Xoa PII o warehouse nhung raw lake va backup van con.
- Non-prod copy tu prod chua masked.
- Data retention khong duoc enforce bang lifecycle policy.

### Data sharing vs privacy

Self-service data la muc tieu tot, nhung khong dong nghia ai cung xem moi thu.

Trade-off:

- Qua chat: team bi block, tao shadow datasets.
- Qua thoang: PII leak, compliance risk.

Balanced pattern:

- Certified marts cho analyst.
- Restricted raw/PII cho approved users.
- Access request workflow co owner approval.
- Auto-expiring access cho sensitive data.

### Breach scenario runbook

Symptom:

- Credential leak.
- Public bucket/table.
- Query logs cho thay user export PII bat thuong.

Immediate actions:

1. Revoke/rotate credentials.
2. Disable public access.
3. Freeze affected service account.
4. Identify data scope: tables, columns, time range.
5. Pull audit logs.
6. Notify security/legal theo policy.
7. Patch IaC/policy de prevent recurrence.

Post-incident questions:

- Vi sao control khong chan duoc?
- Alert co fire khong?
- Ai approve access?
- Data co duoc masked/tokenized khong?
- Non-prod co bi anh huong khong?

### Governance artifacts can co trong repo

```text
governance/
  data_classification_policy.md
  iam_matrix.md
  pii_column_inventory.md
  retention_policy.md
  access_request_workflow.md
  breach_runbook.md
  data_contract_template.md
```

Nhung artifact nay bien governance tu "noi mieng" thanh engineering practice co review duoc.
