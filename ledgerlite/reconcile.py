"""Core reconciliation logic for ledgerlite."""

import csv


def load_rows(path):
    with open(path, newline="") as handle:
        return list(csv.DictReader(handle))


def _validate_row(row, line_number):
    if not row.get("id", "").strip():
        raise ValueError(f"row {line_number} is missing an id")
    if not row.get("amount", "").strip():
        raise ValueError(f"row {line_number} is missing an amount")


def index_by_id(rows):
    for number, row in enumerate(rows, start=1):
        _validate_row(row, number)
    return {row["id"]: row for row in rows}


def reconcile(rows_a, rows_b):
    """Return a list of mismatch descriptions between two row sets."""
    left = index_by_id(rows_a)
    right = index_by_id(rows_b)
    mismatches = []

    for row_id, row in left.items():
        if row_id not in right:
            mismatches.append(f"{row_id}: missing from b")
        elif row["amount"] != right[row_id]["amount"]:
            mismatches.append(f"{row_id}: amount differs ({row['amount']} vs {right[row_id]['amount']})")

    for row_id in right:
        if row_id not in left:
            mismatches.append(f"{row_id}: missing from a")

    return sorted(mismatches)
