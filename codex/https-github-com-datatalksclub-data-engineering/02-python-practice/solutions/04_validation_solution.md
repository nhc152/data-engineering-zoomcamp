# Solution: Validation Failures

Validation strategy:

- Required columns are checked before transform.
- Bad records are rejected when possible.
- Severe schema errors fail the job.
- Rejected rows are written to `rejected_records`.

Implemented in:

```text
src/validate.py
src/main.py
```

Production rule:

- Missing required columns usually means source contract break and should fail fast.
- A few bad records can be isolated if the schema itself is valid.

