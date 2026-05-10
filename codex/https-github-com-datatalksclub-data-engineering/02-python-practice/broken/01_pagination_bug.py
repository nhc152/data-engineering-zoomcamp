"""Broken example: pagination stops after the first page.

Expected failure:
- API source has 3 pages.
- This extractor returns only records from page 1.
- Target row count is lower than source.
"""

from pathlib import Path

from src.extract import retry_call, _load_api_page


def fetch_only_first_page(pages_dir: Path) -> list[dict]:
    payload = retry_call(
        lambda: _load_api_page(pages_dir / "page_1.json"),
        max_attempts=3,
        base_seconds=0.1,
        max_seconds=1.0,
    )
    return payload["data"]


if __name__ == "__main__":
    records = fetch_only_first_page(Path("data/sample/api_pages"))
    print(f"records_returned={len(records)}")

