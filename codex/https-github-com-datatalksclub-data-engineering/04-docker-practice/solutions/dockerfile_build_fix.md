# Solution - Dockerfile Build Hygiene

## Problem

The broken Dockerfile copies the whole build context before installing dependencies:

```dockerfile
COPY . .
RUN pip install -r requirements.txt
```

Any code, README, or data change invalidates the dependency install layer.

## Fix

Copy dependency files first:

```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/
```

## Add `.dockerignore`

Exclude files that should not enter the build context:

```text
.git
.env
.venv
__pycache__/
data/*.parquet
data/*.tmp
```

## Production Lesson

Good Dockerfile layer order makes CI faster and reduces accidental secret/data leakage into images.

