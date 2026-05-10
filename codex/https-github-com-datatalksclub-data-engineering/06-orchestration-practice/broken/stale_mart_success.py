from __future__ import annotations

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1] / "scripts"))

from common import log_event, parse_args


def main() -> None:
    args = parse_args()
    # Broken: this task marks success without checking whether marts contain run_date.
    log_event("validate_marts_broken", args.run_date, "success", "did not actually validate mart freshness")


if __name__ == "__main__":
    main()
