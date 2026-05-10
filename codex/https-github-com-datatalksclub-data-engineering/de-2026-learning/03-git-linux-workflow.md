# Git, Linux va Engineering Workflow

## Vai tro cua Git va Linux trong Data Engineering 2026

Data Engineer hien dai khong chi viet SQL hay keo tha ETL job. Ban se lam viec voi repo, branch, pull request, terminal, log files, SSH, server, Docker host, CI/CD va production incident. Git va Linux la nen tang van hanh hang ngay.

Trong production, nhieu van de khong duoc giai quyet bang UI:

- Pipeline fail tren server.
- Container crash nhung local khong crash.
- Credential path sai.
- File permission khong cho ghi output.
- Log qua lon can filter nhanh.
- Commit lam hong pipeline can revert hoac hotfix.
- Merge conflict giua hai nguoi cung sua DAG/dbt model.

Git giup team thay doi co kiem soat. Linux/terminal giup ban quan sat va debug he thong that.

## Muc tieu can dat

Sau module nay, ban nen lam duoc:

- Dung Git hang ngay: branch, commit, diff, log, merge, rebase co ban.
- Tao pull request co noi dung ro va de review.
- Doc diff de phat hien thay doi nguy hiem.
- Xu ly merge conflict co kiem soat.
- Recover commit sai ma khong pha work cua nguoi khac.
- Dung terminal de tim file, inspect log, check process, environment, permission.
- Hieu SSH key va remote server workflow.
- Debug production issue bang log va shell tools.
- Viet README/runbook de nguoi khac reproduce va operate pipeline.

## Khai niem can nam

Git:

- Repository.
- Commit.
- Branch.
- Remote.
- Working tree.
- Staging area.
- Merge.
- Rebase concept.
- Pull request.
- Conflict.
- Revert.
- Reset concept va rui ro.
- Tag/release concept.

Linux/shell:

- Path.
- Environment variables.
- Standard input/output/error.
- Exit code.
- Process.
- File permission.
- SSH.
- Logs.
- Pipe.
- `grep`, `rg`, `sed`, `awk`.
- `tail`, `less`, `head`.
- `ps`, `df`, `du`, `free`.
- `tmux`/`screen` concept.

## Learning roadmap

### Giai doan 1: Beginner

Muc tieu: thao tac repo va file an toan.

Can lam:

- `git status`
- `git diff`
- `git add`
- `git commit`
- `git log`
- `git branch`
- `git switch`
- `ls`, `cd`, `pwd`, `mkdir`
- `cat`, `less`, `head`, `tail`

### Giai doan 2: Implement

Muc tieu: lam feature trong branch rieng, mo PR, review diff.

Can lam:

- Tao branch `feature/api-ingestion`.
- Commit nho theo tung thay doi.
- Viet PR description.
- Xu ly comment review.
- Merge vao main.

### Giai doan 3: Productionize

Muc tieu: repo co workflow ro, secrets khong bi leak, README/runbook dung duoc.

Can lam:

- `.gitignore`.
- `.env.example`.
- Branch naming.
- Commit message ro.
- PR checklist.
- Runbook incident.
- Log/debug command collection.

### Giai doan 4: Debug

Muc tieu: tim root cause tu Git history va production logs.

Can lam:

- `git blame`.
- `git show`.
- `git bisect` concept.
- `tail -f`.
- `grep`/`rg` log.
- Check exit code.
- Check env var.
- Check permission.

### Giai doan 5: Optimize

Muc tieu: lam viec nhanh, it rui ro.

Can lam:

- Alias Git can thiet.
- Pre-commit concept.
- PR nho.
- Log filtering.
- `awk`/`sed` basics.
- `tmux` cho long-running session.

### Giai doan 6: Interview

Muc tieu: giai thich duoc workflow team va incident handling.

Can tra loi:

- Ban review PR data pipeline nhu the nao?
- Ban xu ly commit sai tren main ra sao?
- Ban debug log production nhu the nao?
- Ban tranh commit secret nhu the nao?
- Ban xu ly merge conflict trong dbt model/DAG ra sao?

## Git workflow production

### Branching strategy

Voi team nho, flow don gian:

```text
main
  feature/ingest-orders-api
  feature/dbt-fct-orders
  bugfix/fix-late-arriving-orders
  hotfix/repair-payment-revenue
```

Nguyen tac:

- `main` phai chay duoc.
- Moi thay doi co branch rieng.
- PR nho hon de review tot hon.
- Hotfix can ro root cause va rollback path.

### Commit strategy

Commit tot:

```text
Add idempotent upsert for orders ingestion
Add freshness checks for fct_orders
Fix timezone conversion for payment timestamps
```

Commit kem:

```text
update
fix
final
changes
```

Mot commit nen dai dien cho mot y nghia logic. Khong tron format, refactor, bugfix, config vao mot commit lon neu co the tach.

### Pull request mindset

PR khong phai thu tuc. PR la co hoi phat hien:

- Logic transform sai.
- Grain bi doi.
- Incremental model co nguy co duplicate.
- Secret bi commit.
- Query scan qua nhieu data.
- Test thieu.
- README khong reproduce duoc.

PR description nen co:

- What changed.
- Why.
- How to test.
- Data/backfill impact.
- Risk/rollback.

Vi du:

```text
Changes:
- Add fct_orders model from staging orders, items, payments.
- Add unique/not_null tests on order_id.
- Add reconciliation query for payment amount.

Validation:
- dbt build passed locally.
- Row count: 12,430 orders.
- Duplicate order_id check returned 0 rows.

Risk:
- Revenue definition excludes cancelled/refunded orders.
```

## Recovering bad commits

### Chua push

Neu commit sai chua push:

- Co the amend commit message.
- Co the reset local branch.

Can can than vi reset co the mat local changes neu dung sai.

### Da push len shared branch

Neu commit da vao branch chung/main:

- Thuong dung `git revert` de tao commit dao nguoc.
- Tranh rewrite history shared branch neu khong chac.

```bash
git revert <commit_sha>
```

### Luu y quan trong

- `git reset --hard` la lenh nguy hiem. Chi dung khi hieu ro va biet changes co the mat.
- Khong force push len branch chung neu team khong dong y.
- Khi hotfix data pipeline, can ghi ro data nao bi anh huong va co can backfill khong.

## Merge conflict handling

Conflict hay xay ra khi:

- Hai nguoi sua cung dbt model.
- Hai nguoi sua cung DAG.
- Rename file cung luc voi edit.
- Auto-generated file bi commit.

Quy trinh:

1. Doc conflict file.
2. Hieu logic cua ca hai phia.
3. Giu dung y nghia business, khong chi xoa marker.
4. Chay test/build sau khi resolve.
5. Review diff sau resolve.

Conflict marker:

```text
<<<<<<< HEAD
logic tu branch hien tai
=======
logic tu branch merge vao
>>>>>>> feature/new-logic
```

Kinh nghiem:

- Conflict trong SQL/dbt can check grain va metric.
- Conflict trong config/DAG can check schedule, retries, env.
- Sau conflict, bat buoc chay test lien quan.

## Linux command mindset

Terminal khong phai de go lenh cho vui. Trong production, terminal giup ban tra loi:

- File co ton tai khong?
- Process co chay khong?
- Disk co day khong?
- Env var co set khong?
- Log fail tai dong nao?
- Permission co cho ghi khong?
- Network/port co mo khong?

### File va path

```bash
pwd
ls -lah
find . -name "*.sql"
du -sh data/*
```

Can hieu:

- Absolute path vs relative path.
- Current working directory.
- Hidden files.
- File size.

### Inspect file va log

```bash
head -n 20 pipeline.log
tail -n 100 pipeline.log
tail -f pipeline.log
less pipeline.log
```

Dung `less` cho file lon vi khong load tat ca vao terminal.

### Search log

```bash
grep "ERROR" pipeline.log
grep "order_id=123" pipeline.log
grep -i "timeout" pipeline.log
```

Neu co `rg`, dung `rg` nhanh va tien hon:

```bash
rg "ERROR|Timeout|Traceback" logs/
```

### sed/awk basics

Dung `awk` de cat cot trong log/csv don gian:

```bash
awk -F',' '{print $1, $3}' orders.csv
```

Dung `sed` de xem range dong:

```bash
sed -n '100,140p' pipeline.log
```

Luu y: dung `sed -i` sua file production can can than; nen backup hoac review diff.

## Environment setup

### Environment variables

```bash
echo "$DATABASE_URL"
export RUN_DATE=2026-05-01
```

Trong production:

- Secret den tu secret manager/env.
- `.env` local khong commit.
- `.env.example` commit de document bien can co.

### File permissions

Kiem tra:

```bash
ls -l
```

Vi du:

```text
-rw-r--r--  1 app app  1200 May 01 extract.py
drwxr-xr-x  2 app app  4096 May 01 data
```

Can hieu:

- `r`: read.
- `w`: write.
- `x`: execute.
- Owner/group/others.

Loi thuong gap:

- Script khong executable.
- Container user khong co quyen ghi mounted volume.
- Output folder thuoc owner khac.

### SSH

SSH dung de ket noi server:

```bash
ssh user@host
```

Key files:

- Private key: giu bi mat.
- Public key: co the dat tren server.

Kinh nghiem:

- Khong share private key.
- Dung passphrase neu co the.
- Biet `~/.ssh/config` concept.
- Khi debug server, doc log va command truoc khi sua bat cu thu gi.

## Production debugging mindset

### Pipeline fail tren server

Checklist:

1. Job fail o buoc nao?
2. Exit code la gi?
3. Log error dau tien la gi?
4. Code version/commit nao dang chay?
5. Env var co dung khong?
6. Input file co ton tai khong?
7. Permission co cho doc/ghi khong?
8. Disk/memory co du khong?
9. Dependency version co doi khong?

### Log debugging workflow

```bash
tail -n 200 logs/pipeline.log
rg "ERROR|Traceback|failed|timeout" logs/
rg "run_id=20260501_0100" logs/
```

Can tim:

- Error dau tien, khong chi error cuoi.
- Run id.
- Dataset/table.
- Row count.
- Duration.
- Retry attempts.

### Process va resource

```bash
ps aux
df -h
du -sh .
free -h
```

Hay gap:

- Disk full lam database/write file fail.
- Process treo.
- File output qua lon.
- Log khong rotate lam day disk.

### tmux/screen concept

`tmux`/`screen` giup giu session tren remote server khi SSH mat ket noi.

Dung khi:

- Chay backfill dai.
- Theo doi log lau.
- Debug server trong thoi gian dai.

Khong nen dung lam production scheduler. Long-running production jobs nen duoc chay boi orchestrator/system service, khong phai terminal thu cong.

## Real-world failure cases

### Commit secret len Git

Tac hai:

- Token co the bi leak.
- Can rotate secret.
- Xoa trong commit moi khong du neu history van con.

Xu ly:

- Revoke/rotate secret ngay.
- Remove secret khoi repo.
- Neu public repo, coi nhu secret da bi lo.
- Them `.gitignore`, secret scanning/pre-commit.

### Merge PR lam hong pipeline

Trieu chung:

- CI pass nhung production fail.
- Query logic sai, data mart sai.

Xu ly:

- Xac dinh commit.
- Revert neu can.
- Chay backfill/repair data.
- Them test de bat case nay lan sau.

### Permission denied khi ghi file

Trieu chung:

- `Permission denied`.
- Local chay, container/server fail.

Debug:

- `whoami`
- `ls -lah`
- Check owner volume.
- Check output path.

### Log qua lon lam day disk

Trieu chung:

- Job fail vi no space left on device.

Fix:

- Log rotation.
- Giam log spam.
- Clean temporary files.
- Monitor disk.

## Trade-offs

- Merge commit: giu lich su branch ro, nhung log co the nhieu.
- Rebase: lich su sach hon, nhung can than voi shared branch.
- Squash merge: PR thanh mot commit gon, nhung mat chi tiet commit nho.
- Trunk-based: nhanh, can CI/test tot.
- Gitflow: nhieu quy trinh, phu hop release phuc tap hon, co the nang voi team data nho.
- Shell one-liner: nhanh de debug, nhung kho reproduce neu khong document.
- Manual server fix: nhanh luc incident, nhung phai follow-up bang code/IaC de tranh drift.

## Performance considerations

Git:

- Repo khong nen commit data lon, parquet/csv generated.
- Dung `.gitignore`.
- Dung Git LFS neu bat buoc version file lon, nhung can hieu chi phi/complexity.

Linux:

- Dung `less`, `tail`, `rg` cho log lon thay vi mo editor nang.
- Dung `du -sh` de tim folder lon.
- Dung streaming tools cho file lon, tranh load ca file vao memory.
- Tranh command xoa/sua hang loat khi chua preview danh sach file.

## Hands-on exercises

### Level 1: Git basics

1. Tao branch `feature/add-orders-ingestion`.
2. Sua README.
3. Chay `git diff`.
4. Commit voi message ro.
5. Xem `git log --oneline`.

### Level 2: PR simulation

1. Tao 2 branch sua cung mot SQL file.
2. Tao conflict co chu dich.
3. Resolve conflict.
4. Chay test/query lien quan.
5. Viet PR description.

### Level 3: Recover mistake

1. Commit file `.env` gia lap.
2. Remove file khoi repo.
3. Them `.env` vao `.gitignore`.
4. Viet incident note: secret phai rotate.

### Level 4: Log debugging

1. Tao file log co INFO/WARN/ERROR.
2. Dung `grep`/`rg` tim run_id fail.
3. Dung `sed` xem 20 dong truoc/sau error.
4. Tom tat root cause.

### Level 5: Linux troubleshooting

1. Tao script khong co execute permission.
2. Debug va fix permission.
3. Gia lap output folder khong ghi duoc.
4. Debug owner/permission.

## Mini project

### De bai

Tao repo `de-workflow-practice` mo phong team workflow cho data pipeline.

Can co:

- Branch feature cho ingestion.
- Branch feature cho dbt model.
- Merge conflict duoc resolve.
- `.gitignore`.
- `.env.example`.
- `README.md`.
- `RUNBOOK.md`.
- `logs/sample_pipeline.log`.
- `docs/pr-template.md`.

### Yeu cau

- README co setup/run commands.
- RUNBOOK co cach debug pipeline fail.
- PR template co data impact/risk/rollback.
- Co command examples de inspect logs.

## Kinh nghiem thuc te

- `git status` truoc khi sua va truoc khi commit la thoi quen bat buoc.
- Doc diff truoc khi commit de tranh commit secret/file tam.
- Commit nho giup revert de hon.
- PR data pipeline phai noi ve data impact, khong chi code change.
- Debug production bat dau tu log va version dang chay.
- Manual fix tren server phai duoc dua lai vao repo, neu khong he thong se drift.
- README va RUNBOOK la cong cu van hanh, khong phai tai lieu phu.

## Loi thuong gap

- Commit `.env`, credential, data dump.
- Commit file generated qua lon.
- Sua truc tiep tren main.
- Resolve conflict bang cach xoa logic cua nguoi khac.
- Dung `reset --hard` khi chua hieu.
- Khong chay test sau merge conflict.
- Dung shell command nguy hiem khi chua preview path.
- Debug log chi nhin error cuoi, bo qua root cause dau tien.
- Chay job production bang terminal thu cong nhung khong ghi lai command.

## Cau hoi phong van

### Git workflow

- Ban dung branching strategy nao cho data pipeline?
- PR cho dbt model/DAG nen review nhung gi?
- Commit message tot la nhu the nao?
- Revert khac reset nhu the nao?
- Ban xu ly merge conflict ra sao?

### Incident va debugging

- Pipeline fail tren server, ban debug theo thu tu nao?
- Lam sao biet code version nao dang chay?
- Ban tim error trong log lon nhu the nao?
- Neu disk full lam job fail, ban xu ly sao?
- Neu secret bi commit len GitHub, ban lam gi?

### Linux

- Environment variable dung de lam gi?
- File permission `rwx` nghia la gi?
- SSH key hoat dong ra sao o muc concept?
- `grep`, `tail`, `less`, `awk` dung trong tinh huong nao?
- `tmux`/`screen` co ich khi nao?

## Dau ra can co tren GitHub

Toi thieu:

- Repo co `.gitignore`.
- `.env.example`.
- README co setup va run commands.
- Commit history ro.
- Branch/PR workflow duoc mo ta.

Tot hon:

- `RUNBOOK.md`.
- `docs/pr-template.md`.
- `logs/sample_pipeline.log`.
- `scripts/debug-log-examples.sh` hoac docs command.
- Section "data impact", "rollback", "validation" trong PR examples.

## Production upgrade: data repo workflow

### Branch protection

Data repo production nen co branch protection:

- No direct push to `main`.
- Required PR review.
- Required CI checks.
- CODEOWNERS approval cho models/pipelines quan trong.
- Signed commits optional neu cong ty yeu cau compliance.

Ly do:

- Mot SQL change co the lam sai dashboard executive.
- Mot IAM/IaC change co the expose PII.
- Mot pipeline retry change co the duplicate data.

### PR template cho data changes

```text
## What changed

## Data impact
- Tables/models affected:
- Grain changed? yes/no
- Backfill required? yes/no
- Metric definition changed? yes/no

## Validation
- Tests run:
- Row count comparison:
- Reconciliation:

## Rollback plan

## Screenshots/query results
```

Operational lesson:

- PR data khong chi review syntax.
- Reviewer can biet blast radius va rollback.

### CODEOWNERS

Vi du:

```text
/dbt/models/marts/finance/ @finance-data-owner @data-platform
/infra/ @platform-team @security-team
/orchestration/ @data-platform
/quality/ @analytics-engineering
```

CODEOWNERS giup:

- Domain owner khong bi bypass.
- Sensitive changes co dung reviewer.
- Knowledge ownership ro.

### Pre-commit hooks

Nen dung:

- Markdown lint optional.
- SQL format/lint neu team co standard.
- Python ruff.
- Secret scanning.
- Terraform fmt.
- YAML validation.

Pre-commit khong thay CI, nhung bat loi som.

### SSH keys va secret hygiene

Can biet:

- SSH key rieng cho Git.
- Khong commit private key.
- Khong paste token vao README/log.
- Secret scanning bat buoc neu repo public.

### Linux ops pitfalls

Common failures:

- Shell quoting sai lam delete/move sai file.
- Cron chay voi env khac terminal.
- Log file day disk vi khong rotate.
- Permission issue giua container/user.

Production habits:

- Script co `set -euo pipefail` neu dung bash.
- Log rotation cho long-running jobs.
- Cron/systemd docs neu chay local VM.
- Commands trong README test lai tren clean shell.
