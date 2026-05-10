# Runbook - Sample Data Pipeline

## Pipeline Failed

### First Checks

```bash
git status
git log --oneline -5
tail -n 100 logs/sample_pipeline.log
grep -n "ERROR" logs/sample_pipeline.log
```

### Check Input Data

```bash
ls -lah data/raw/
head -n 5 data/raw/orders.csv
awk -F',' 'NR > 1 {count++} END {print count " data rows"}' data/raw/orders.csv
```

### Check Environment

```bash
test -f .env && echo ".env exists" || echo ".env missing"
grep -v "PASSWORD\\|TOKEN\\|SECRET" .env.example
```

## Common Issues

### Missing `.env`

Fix:

```bash
cp .env.example .env
```

### Generated Data Committed

Fix:

```bash
git rm --cached data/processed/<file>
git status
```

Then update `.gitignore`.

### Secret Committed

Immediate action:

1. Rotate/revoke the secret.
2. Remove the file from the repo.
3. Add the secret pattern to `.gitignore`.
4. Write an incident note.

Do not assume deleting the file in a later commit is enough.

