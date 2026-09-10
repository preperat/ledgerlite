# ledgerlite

This is a staged demo repository with deliberately planted discrepancies. It was
built for a screen recording of one AI coding agent auditing another inside
herdr, a terminal workspace manager for coding agents.

## Reproduce it

1. Clone the repository.
2. Run `scripts/setup-demo.sh` to recreate the untracked decision record.
3. Follow DEMO.md for the setup, dry run, and recording steps.

## The project

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
