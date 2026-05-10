from __future__ import annotations

from datetime import date


def get_run_date() -> str:
    # Broken for backfill: every historical run uses today's date.
    return date.today().isoformat()


if __name__ == "__main__":
    print(f"broken run_date={get_run_date()}")

