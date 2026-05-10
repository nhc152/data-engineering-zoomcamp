FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY pyproject.toml README.md ./
COPY src ./src
COPY sql ./sql
COPY data ./data

RUN pip install --no-cache-dir -e .

CMD ["python", "-m", "src.main", "--source", "csv", "--input-path", "data/sample/orders.csv", "--run-date", "2026-05-09"]

