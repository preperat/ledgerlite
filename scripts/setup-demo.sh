#!/usr/bin/env sh
# Recreates the deliberately untracked, unfinished decision record for the demo.
set -eu

cd "$(dirname "$0")/.."

cat > docs/decisions/0002-limits.md <<'EOF'
# 0002: reconciliation limits (draft)

We need to decide sane defaults for max_rows, max_mismatches, and
timeout_seconds. Current config.json values are a guess, not agreed.

TODO: get sign off before removing the _note in config.json.
EOF

echo "Demo state ready: docs/decisions/0002-limits.md written and left untracked."
