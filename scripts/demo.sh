#!/usr/bin/env bash
# Stages the recording so the only thing typed on camera is the reviewer prompt.
# Usage: scripts/demo.sh          stage the demo tab
#        scripts/demo.sh --reset  tear it down and restore the repo
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && git rev-parse --show-toplevel)"
STATE="$REPO/.git/herdr-demo-tab"
PRIME='Read README.md, BACKLOG.md, config.json, git log, and git status, then reply with the single word DONE.'

die() { printf 'demo.sh: %s\n' "$*" >&2; exit 1; }

# macOS ships no coreutils timeout, so guard non-blocking herdr calls ourselves.
with_timeout() {
  local secs="$1"; shift
  "$@" & local pid=$!
  ( sleep "$secs"; kill "$pid" 2>/dev/null ) & local watchdog=$!
  local rc=0; wait "$pid" || rc=$?
  kill "$watchdog" 2>/dev/null; wait "$watchdog" 2>/dev/null || true
  [ "$rc" -ne 143 ] || die "timed out after ${secs}s: $*"
  return "$rc"
}

# herdr control commands print JSON by default; only status and session list take --json.
field() { grep -o "\"$1\":\"[^\"]*\"" | head -1 | cut -d'"' -f4; }

# 1. Refuse to run outside a herdr pane, or inside any session other than "demo".
[ "${HERDR_ENV:-}" = 1 ] || die "not inside a herdr pane (HERDR_ENV is not 1)"
[ "${HERDR_SESSION:-}" = demo ] || die "HERDR_SESSION is '${HERDR_SESSION:-unset}', refusing to touch anything but 'demo'"
live="$(with_timeout 10 herdr status --json | field session)"
[ "$live" = demo ] || die "herdr server reports session '$live', expected 'demo'"

if [ "${1:-}" = "--reset" ]; then
  tab="$(cat "$STATE" 2>/dev/null || true)"
  [ -n "$tab" ] || tab="$(with_timeout 10 herdr tab list --workspace "$HERDR_WORKSPACE_ID" \
    | grep -o '{[^{}]*"label":"ledgerlite-demo"[^{}]*}' | field tab_id || true)"
  [ -n "$tab" ] || die "no demo tab recorded and none labelled ledgerlite-demo; nothing to reset"
  for a in builder reviewer; do
    with_timeout 10 herdr agent send-keys "$a" ctrl+c ctrl+c >/dev/null 2>&1 || true
  done
  sleep 2
  with_timeout 10 herdr tab close "$tab" >/dev/null
  rm -f "$STATE"
  (cd "$REPO" && git checkout .)
  echo "Reset done: agents stopped, tab $tab closed, repo restored, untracked decision record kept."
  exit 0
fi

[ -f "$STATE" ] && die "demo tab $(cat "$STATE") already staged; run with --reset first"

# 2. Ensure the untracked, unfinished decision record exists.
"$REPO/scripts/setup-demo.sh"

# 3. Fresh tab in the current workspace, then split it side by side.
out="$(with_timeout 10 herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$REPO" --label ledgerlite-demo --no-focus)"
tab="$(printf '%s' "$out" | field tab_id)"
left="$(printf '%s' "$out" | field pane_id)"
[ -n "$tab" ] && [ -n "$left" ] || die "could not read tab or root pane ID from: $out"
printf '%s\n' "$tab" > "$STATE"

out="$(with_timeout 10 herdr pane split --pane "$left" --direction right --cwd "$REPO" --no-focus)"
right="$(printf '%s' "$out" | field pane_id)"
if [ -z "$right" ] || [ "$right" = "$left" ]; then
  right="$(with_timeout 10 herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
    | grep -o '{[^{}]*}' | grep "\"tab_id\":\"$tab\"" | field pane_id | grep -v "^$left\$" | head -1)"
fi
[ -n "$right" ] || die "could not determine the right pane ID"

# 4. Start the agents. 5. Names are given at start, so no separate rename is needed.
with_timeout 90 herdr agent start builder --kind claude --pane "$left" --timeout 60000 >/dev/null
with_timeout 90 herdr agent start reviewer --kind codex --pane "$right" --timeout 60000 >/dev/null

# 6. Both idle before anything is sent.
with_timeout 90 herdr agent wait builder --until idle --timeout 60000 >/dev/null
with_timeout 90 herdr agent wait reviewer --until idle --timeout 60000 >/dev/null

# 7. Prime the builder off camera so its answer on camera is fast.
with_timeout 200 herdr agent prompt builder "$PRIME" --wait --timeout 180000 >/dev/null

# 8. Redraw both screens. ctrl+l clears the display without wiping the conversation,
#    which a /clear command would do and lose the priming.
with_timeout 10 herdr agent send-keys builder ctrl+l >/dev/null
with_timeout 10 herdr agent send-keys reviewer ctrl+l >/dev/null

# 9.
echo "Created tab $tab with builder in $left (left) and reviewer in $right (right)."
echo "Ready. Focus the reviewer pane and type the recording prompt from DEMO.md."
