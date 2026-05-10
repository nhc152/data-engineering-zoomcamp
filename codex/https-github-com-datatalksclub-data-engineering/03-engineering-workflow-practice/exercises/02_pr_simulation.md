# Exercise 02 - PR Simulation

## Goal

Practice writing a useful PR description for a data pipeline change.

## Steps

Create a branch:

```bash
cd sample-project
git switch -c feature/update-revenue-definition
```

Edit `dbt/models/marts/fct_orders.sql` and add a comment above the revenue logic explaining cancelled/refunded orders.

Inspect diff:

```bash
git diff
```

Commit:

```bash
git add dbt/models/marts/fct_orders.sql
git commit -m "Document recognized revenue business rule"
```

Now write a PR description using:

```text
../templates/PULL_REQUEST_TEMPLATE.md
```

## Expected PR Content

The PR must include:

- what changed
- why
- validation
- data impact
- rollback plan

## Bad Sign

A PR that says only "updated revenue" is not reviewable.

