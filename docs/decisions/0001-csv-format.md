# 0001: CSV export format

Both inputs are plain CSV with a header row containing `id` and `amount`.
The `id` column is treated as an opaque string key for matching rows across
the two files. The `amount` column is compared as a string, not a parsed
number, to avoid disagreements caused by rounding or formatting differences.

We chose this over a schema-aware format (JSON, Parquet) because both
upstream systems already export CSV and adding a conversion step was not
worth the complexity for a small reconciliation check.
