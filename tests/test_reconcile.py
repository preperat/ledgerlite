import unittest

from ledgerlite.reconcile import reconcile


class ReconcileTest(unittest.TestCase):
    def test_reconcile_finds_mismatches(self):
        rows_a = [{"id": "x", "amount": "1.00"}, {"id": "y", "amount": "2.00"}]
        rows_b = [{"id": "x", "amount": "1.00"}, {"id": "z", "amount": "3.00"}]

        result = reconcile(rows_a, rows_b)

        self.assertIn("y: missing from b", result)
        self.assertIn("z: missing from a", result)


if __name__ == "__main__":
    unittest.main()
