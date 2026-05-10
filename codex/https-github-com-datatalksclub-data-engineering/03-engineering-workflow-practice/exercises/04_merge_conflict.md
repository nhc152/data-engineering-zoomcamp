# Exercise 04 - Merge Conflict in SQL/dbt

## Goal

Practice resolving a merge conflict without breaking business logic.

## Manual Simulation

Open:

```text
broken/merge_conflict_fct_orders.sql
```

Resolve the conflict into a clean SQL file that:

- keeps one row per order
- keeps recognized revenue logic
- excludes cancelled and refunded orders from recognized revenue
- preserves clear column names

Compare with:

```text
solutions/merge_conflict_fct_orders.sql
```

## Real Git Simulation

From `sample-project`:

```bash
git switch -c feature/revenue-cancelled-rule
```

Edit `dbt/models/marts/fct_orders.sql`, then commit.

```bash
git add dbt/models/marts/fct_orders.sql
git commit -m "Clarify cancelled order revenue rule"
```

Switch back and create another branch:

```bash
git switch main
git switch -c feature/revenue-refund-rule
```

Edit the same lines differently, commit, then merge the first branch:

```bash
git add dbt/models/marts/fct_orders.sql
git commit -m "Clarify refunded order revenue rule"
git merge feature/revenue-cancelled-rule
```

Resolve conflict, then:

```bash
git status
git diff
git add dbt/models/marts/fct_orders.sql
git commit
```

## Expected Learning

Conflict resolution in data code is not text editing only. You must preserve grain and business metric semantics.

