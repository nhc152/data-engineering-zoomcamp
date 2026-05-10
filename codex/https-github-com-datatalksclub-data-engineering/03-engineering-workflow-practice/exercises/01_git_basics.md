# Exercise 01 - Git Basics

## Goal

Practice safe daily Git workflow.

## Commands

From the lab root:

```bash
cd sample-project
git init
git config user.name "Your Name"
git config user.email "you@example.com"
git status
git add .
git commit -m "Initial data pipeline project"
git log --oneline
```

Create a feature branch:

```bash
git switch -c feature/document-orders-pipeline
```

Edit `README.md`, then inspect:

```bash
git status
git diff
git add README.md
git commit -m "Document orders pipeline run commands"
```

## Expected Output

- `git status` should be clean after commit.
- `git log --oneline` should show two commits.

## Reflection

Before committing, ask:

- Did I accidentally include secrets?
- Did I include generated data?
- Is my commit message meaningful?

