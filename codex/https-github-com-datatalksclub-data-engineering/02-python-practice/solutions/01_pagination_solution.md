# Solution: Pagination Bug

Correct behavior:

- Start with `page_1.json`.
- Read `next_page`.
- Continue until `next_page` is null.
- Log page count and records per page.

Implemented in:

```text
src/extract.py::fetch_simulated_api_pages
```

Verification:

```powershell
python -m src.main --source api --api-pages-dir data/sample/api_pages --run-date 2026-05-09
```

Expected:

- 5 records extracted from 3 pages.
- `O5004` appears twice in raw but one latest record is loaded after dedup.

