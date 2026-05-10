from __future__ import annotations

import argparse


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-date", required=True)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    print(f"correct logical run_date={args.run_date}")

