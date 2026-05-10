# CI/CD Practice Lab

## Goal

Practice CI/CD for Data Engineering projects:

```text
Python transform code
  -> unit tests with pytest
  -> dbt compile/build/test on sample data
  -> GitHub Actions
  -> environment separation
  -> deployment gates
  -> rollback/runbook thinking
```

This lab is local-first and safe. It contains no real secrets and no production credentials.

## What You Will Learn

- Python unit tests with `pytest`.
- dbt build/test on a local DuckDB sample project.
- GitHub Actions workflow for data projects.
- Environment separation: dev/staging/prod.
- Secrets management rules.
- Deployment gates.
- Rollback thinking.
- Difference between code rollback and data rollback.
- Failure scenarios and prevention.

## Folder Structure

```text
12-cicd-practice/
  README.md
  .github/
    workflows/
  src/
  tests/
  dbt_sample/
  exercises/
  broken/
  solutions/
  runbook/
```

## Prerequisites

Recommended:

- Python 3.11 or 3.12.
- Git.

Install dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

On Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Local Commands

Run Python tests:

```bash
pytest -q
```

Run dbt compile/build/test:

```bash
cd dbt_sample
dbt deps
dbt seed --profiles-dir .
dbt build --profiles-dir .
```

Run all local checks from repo root:

```bash
pytest -q
cd dbt_sample && dbt seed --profiles-dir . && dbt build --profiles-dir .
```

## CI Workflow

GitHub Actions workflow:

```text
.github/workflows/ci.yml
```

It runs:

- checkout
- Python setup
- dependency install
- pytest
- dbt seed
- dbt build

The workflow uses only local DuckDB files. It does not need cloud credentials.

## Environment Separation

This lab uses safe local naming:

```text
dev: local developer machine
ci: GitHub Actions runner with DuckDB temp file
prod: not used by this lab
```

Production rules:

- CI for pull requests must not use prod credentials.
- Prod deployment should require approval.
- Prod data writes must use prod-specific service account.
- dbt models should deploy to staging schema first when possible.
- Rollback code and rollback data are separate actions.

## Secrets Rules

Never commit:

- `.env`
- service account JSON
- database passwords
- API tokens
- SSH private keys

This lab includes:

- `.env.example`
- broken secret scenario in `broken/04_secret_committed.md`
- prevention notes in `solutions/04_secret_response.md`

## Recommended Learning Order

1. `exercises/level_01_pytest.md`
2. `exercises/level_02_dbt_ci.md`
3. `exercises/level_03_github_actions.md`
4. `exercises/level_04_env_secrets.md`
5. `exercises/level_05_deploy_rollback.md`

## Failure Scenarios

Broken scenarios:

- CI uses production credentials.
- dbt deploy breaks dashboard.
- Rollback code does not rollback data.
- Secret committed.
- Test data differs too much from production.

For each scenario, identify:

1. Symptom.
2. Root cause.
3. Blast radius.
4. Immediate mitigation.
5. Long-term prevention.

## GitHub Deliverables

Your finished lab should show:

- Python transform tests.
- dbt sample project with tests.
- Complete GitHub Actions workflow.
- Environment/secrets checklist.
- Deployment checklist.
- Rollback runbook.
- Broken scenarios and solutions.

