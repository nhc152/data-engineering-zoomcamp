# Level 05 - Tests

Goal: test transform and validation logic before running the full pipeline.

Tasks:

1. Run pytest.
2. Read `tests/test_transform.py`.
3. Add one test for a new status mapping.
4. Add one test for a rejected missing customer.

Command:

```powershell
pytest
```

Expected learning:

- Unit tests catch transform bugs faster than full pipeline tests.
- Validation rules should be testable without database.

