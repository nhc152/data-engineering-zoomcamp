# Level 05 - Image Build Hygiene

## Goal

Understand Dockerfile layer caching and why build context matters.

## Broken Dockerfile

Open:

```text
broken/Dockerfile.slow
```

Problems:

- Copies all files before installing dependencies.
- Does not benefit from dependency layer cache.
- Can accidentally include unnecessary files if `.dockerignore` is missing.

## Exercise

1. Compare `broken/Dockerfile.slow` with root `Dockerfile`.
2. Explain why root `Dockerfile` copies `requirements.txt` first.
3. Inspect `.dockerignore`.
4. Add a large temporary file under `data/` and reason whether it enters the build context.

## Fix

Read:

```text
solutions/dockerfile_build_fix.md
```

