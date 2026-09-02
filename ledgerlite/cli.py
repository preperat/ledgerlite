"""Command line entry point for ledgerlite."""

import json
import sys

from ledgerlite.reconcile import load_rows, reconcile


def main(argv=None):
    argv = argv if argv is not None else sys.argv[1:]
    if len(argv) != 2:
        print("usage: python -m ledgerlite.cli <a.csv> <b.csv>")
        return 1

    with open("config.json") as handle:
        config = json.load(handle)
    limits = config["limits"]

    rows_a = load_rows(argv[0])
    rows_b = load_rows(argv[1])

    if len(rows_a) > limits["max_rows"] or len(rows_b) > limits["max_rows"]:
        print("input exceeds max_rows limit")
        return 1

    mismatches = reconcile(rows_a, rows_b)

    if not mismatches:
        print("no mismatches found")
        return 0

    for line in mismatches:
        print(line)
    return 0


if __name__ == "__main__":
    sys.exit(main())
