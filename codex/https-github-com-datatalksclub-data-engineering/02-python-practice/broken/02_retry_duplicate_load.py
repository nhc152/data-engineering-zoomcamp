"""Broken example: retrying append load can duplicate rows.

This file is intentionally not used by the main pipeline. It demonstrates
why retry must be paired with an idempotent sink.
"""


def append_without_business_key(target: list[dict], records: list[dict]) -> None:
    for record in records:
        target.append(record)


if __name__ == "__main__":
    sink: list[dict] = []
    batch = [{"order_id": "O1", "amount": "10.00"}]

    append_without_business_key(sink, batch)
    append_without_business_key(sink, batch)

    print(f"row_count={len(sink)}")
    print("Expected production issue: duplicate business key O1")

