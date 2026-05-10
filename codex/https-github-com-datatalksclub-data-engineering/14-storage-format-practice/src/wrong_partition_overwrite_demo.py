import shutil
from pathlib import Path


DEMO_DIR = Path("data/lake/overwrite_demo")


def write_file(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def main() -> None:
    if DEMO_DIR.exists():
        shutil.rmtree(DEMO_DIR)

    safe_partition = DEMO_DIR / "orders" / "order_date=2026-05-01" / "part-00000.txt"
    other_partition = DEMO_DIR / "orders" / "order_date=2026-05-02" / "part-00000.txt"
    write_file(safe_partition, "original may 1 data\n")
    write_file(other_partition, "original may 2 data\n")

    print("Initial partitions:")
    for file in sorted(DEMO_DIR.rglob("*")):
        if file.is_file():
            print(file)

    print("\nBad behavior: overwrite table root instead of one partition.")
    shutil.rmtree(DEMO_DIR / "orders")
    write_file(DEMO_DIR / "orders" / "order_date=2026-05-01" / "part-00000.txt", "backfilled may 1 data\n")

    print("\nAfter bad overwrite, May 2 partition is gone:")
    for file in sorted(DEMO_DIR.rglob("*")):
        if file.is_file():
            print(file)

    print("\nLesson: overwrite exact partition path, not table root.")


if __name__ == "__main__":
    main()

