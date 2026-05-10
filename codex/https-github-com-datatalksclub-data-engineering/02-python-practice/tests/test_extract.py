from pathlib import Path

import pytest

from src.extract import read_csv_records, read_jsonl_records


def test_read_csv_records() -> None:
    records = read_csv_records(Path("data/sample/orders.csv"))
    assert len(records) == 6
    assert records[0]["order_id"] == "O2001"


def test_read_jsonl_rejects_malformed_line() -> None:
    with pytest.raises(ValueError, match="Malformed JSONL"):
        read_jsonl_records(Path("data/bad/orders_bad_jsonl.jsonl"))

