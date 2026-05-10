# Generated Data Committed Incident

Problem:

The repository includes generated files such as:

```text
data/processed/orders_clean.csv
data/processed/orders_2026_05_01.parquet
```

Why this is bad:

- Repo history grows quickly.
- Review diff becomes noisy.
- Sensitive data may leak.
- Generated output should be reproducible from source and code.

