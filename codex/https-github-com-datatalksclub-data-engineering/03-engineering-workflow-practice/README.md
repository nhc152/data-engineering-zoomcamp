# Engineering Workflow Practice Lab

## Goal

This lab teaches Git, Linux, and engineering workflow for Data Engineering projects. It is designed for production-style habits, not just memorizing Git commands.

You will practice:

- branch workflow
- commit discipline
- reviewing `git diff`
- `.gitignore`
- `.env.example`
- PR template
- CODEOWNERS concept
- data pipeline code review checklist
- Linux commands for data/log inspection
- merge conflict simulation
- secret accidentally committed scenario

## Lab Architecture

```text
03-engineering-workflow-practice/
  sample-project/      small data pipeline repo to practice on
  exercises/           step-by-step exercises with commands
  broken/              intentionally bad examples
  solutions/           fixed versions and explanations
  templates/           PR, review, runbook, CODEOWNERS templates
```

The sample project is intentionally small:

```text
sample-project/
  data/
    raw/orders.csv
    processed/.gitkeep
  logs/sample_pipeline.log
  scripts/inspect_logs.sh
  scripts/inspect_logs.ps1
  sql/stg_orders.sql
  dbt/models/marts/fct_orders.sql
  README.md
  RUNBOOK.md
  .env.example
  .gitignore
```

## Prerequisites

Required:

- Git
- Bash-compatible shell, WSL, Git Bash, or Linux/macOS terminal
- `grep`, `sed`, `awk`, `tail`, `head`

Optional:

- `rg` / ripgrep
- VS Code

Check tools:

```bash
git --version
bash --version
grep --version
```

On Windows, prefer WSL2 Ubuntu for this lab.

## How to Use This Lab

Work from inside this folder:

```bash
cd 03-engineering-workflow-practice
```

Create a temporary Git repo inside `sample-project`:

```bash
cd sample-project
git init
git status
git add .
git commit -m "Initial data pipeline project"
```

If Git asks for identity:

```bash
git config user.name "Your Name"
git config user.email "you@example.com"
```

Then follow the exercises:

```text
exercises/01_git_basics.md
exercises/02_pr_simulation.md
exercises/03_secret_incident.md
exercises/04_merge_conflict.md
exercises/05_log_debugging.md
exercises/06_review_checklist.md
```

## Learning Outcomes

After this lab, you should be able to:

- work in feature branches
- write meaningful commits
- inspect diffs before committing
- avoid committing secrets and generated data
- simulate and resolve merge conflicts in SQL/dbt files
- inspect logs with shell commands
- write PR descriptions with data impact and rollback plan
- review a data pipeline change like a Data Engineer
- write a basic runbook

## Production Mindset

Git and Linux are not "extra tools". In production Data Engineering, they are control and debugging surfaces.

A bad workflow can create real incidents:

- `.env` committed to GitHub leaks credentials.
- generated output committed to repo bloats history.
- branch merged without reviewing data impact changes a metric.
- merge conflict resolved incorrectly changes grain.
- README missing run commands makes pipeline unreproducible.
- manual production config change causes environment drift.

## Debugging Workflow

When a pipeline fails:

1. Identify the run ID and failing step.
2. Inspect logs around the first error.
3. Check code version with Git.
4. Check environment variables.
5. Check input files and output paths.
6. Check permissions.
7. Check recent commits.
8. Write the fix and prevention.

Useful commands:

```bash
git status
git diff
git log --oneline --decorate -5
git show --stat HEAD

tail -n 100 logs/sample_pipeline.log
grep -n "ERROR" logs/sample_pipeline.log
sed -n '7,14p' logs/sample_pipeline.log
awk -F',' 'NR > 1 {print $1, $4}' data/raw/orders.csv
```

On PowerShell:

```powershell
git status
git diff
git log --oneline --decorate -5
git show --stat HEAD

Get-Content logs/sample_pipeline.log -Tail 100
Select-String -Path logs/sample_pipeline.log -Pattern "ERROR"
Get-Content logs/sample_pipeline.log | Select-Object -Index 7..11
.\scripts\inspect_logs.ps1
```

If `rg` is available:

```bash
rg "ERROR|Traceback|timeout|failed" logs/
```

## Failure Scenarios Included

The `broken/` folder includes:

- `committed_secret.env`
- `bad_gitignore`
- `generated_data_committed.md`
- `merge_conflict_fct_orders.sql`
- `bad_pr_description.md`
- `accidental_prod_config.yml`
- `readme_missing_run_commands.md`

The `solutions/` folder explains how to fix and prevent each problem.

## Expected GitHub Deliverables

By the end of the lab, your practice repo should include:

- `.gitignore`
- `.env.example`
- `README.md`
- `RUNBOOK.md`
- `templates/PULL_REQUEST_TEMPLATE.md`
- `templates/CODE_REVIEW_CHECKLIST.md`
- `templates/RUNBOOK_TEMPLATE.md`
- `templates/CODEOWNERS.example`
- clean commit history
- one resolved merge conflict exercise
- one incident note for committed secret

## Interview Practice

Be ready to answer:

- How do you review a PR that changes a data model?
- What do you check before committing?
- How do you handle a secret committed by mistake?
- Why is `git reset --hard` dangerous?
- How do you debug a failed pipeline from logs?
- What should a data pipeline PR description include?
- How do you resolve a merge conflict in a dbt model?
