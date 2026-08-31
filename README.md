# ledgerlite

ledgerlite is a small command line tool that reconciles two CSV exports and
reports rows that do not match. It is meant for quick sanity checks between
two systems that should agree on the same set of records, such as a source
export and a downstream copy.

Run it with `python -m ledgerlite.cli samples/a.csv samples/b.csv`. It reads
both files, matches rows by their id column, and prints any rows that are
missing from one side or have differing values on the other side. Settings
such as row and mismatch caps live in `config.json`.

BACKLOG.md is the single source of truth for what is next. Do not treat this
README as a status page: if you want to know what is planned or in progress,
read BACKLOG.md, not this file.
