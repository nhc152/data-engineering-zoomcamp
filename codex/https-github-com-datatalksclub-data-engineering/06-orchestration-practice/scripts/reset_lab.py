from __future__ import annotations

import shutil

from common import MARTS_DIR, RAW_DIR, STATE_DIR


def main() -> None:
    for path in [RAW_DIR, MARTS_DIR, STATE_DIR]:
        if path.exists():
            shutil.rmtree(path)
    print("lab outputs reset")


if __name__ == "__main__":
    main()

