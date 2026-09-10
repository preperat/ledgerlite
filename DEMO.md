# Demo runbook: builder vs reviewer

Confirmed herdr commands used below (checked via `herdr --help` / `herdr agent --help`
on the installed version): `herdr agent list`, `herdr agent rename`, `herdr agent prompt`,
`herdr agent wait`, `herdr agent read`.

## Setup (off camera)

1. Terminal at roughly 100 columns wide, larger font for phone-screen readability.
   Sidebar visible so agent state is on screen.
2. Two panes side by side. Left: Claude Code started in this directory. Right: Codex
   started in this directory.
3. Rename the agents so the sidebar reads "builder" and "reviewer":
   `herdr agent list` (the pane IDs for the next two commands come from its output)
   `herdr agent rename <left-pane-id> builder`
   `herdr agent rename <right-pane-id> reviewer`
4. In the left pane, prime the builder with one message: "Read README.md, BACKLOG.md,
   config.json, git log, and git status, then confirm when done." Wait for it to go idle
   (`herdr agent wait builder`). This happens off camera so the real answer comes back fast.
5. Clear both panes so the recording starts clean.

## Dry run (off camera)

1. Run the full reviewer prompt once off camera before recording.
2. Confirm two things: the reviewer reaches for the herdr CLI on its own, and the builder
   names the stale backlog item.
3. If the reviewer does not use herdr, change the recording prompt to begin with "Using
   the herdr CLI, ask the builder agent..." and note that change in the Recording section.
4. If the builder misses the stale item, stop and fix the repo. Do not change the prompt.

## Recording (20-30s, one take, no cuts, no audio)

The 20 to 30s is the raw take. The posted cut is 12 to 15s with the wait between prompt
and answer sped up 3x to 4x. Prompt and answer stay at real time.

1. In the reviewer pane, type and send:
   "Ask the builder agent what is next on its todo list and whether the backlog is
   current. Read its answer back to me and tell me if you agree."
2. Do nothing else. The camera captures: reviewer issuing `herdr agent prompt builder
   "..." --wait`, the sidebar flipping builder to working while reviewer blocks, builder
   going idle, reviewer reading the answer back and reporting on it.
3. Stop recording once the reviewer has reported the stale backlog item.

## Expected findings, in priority order

- Backlog item 1 ("Add input validation for malformed CSV rows") is already done,
  committed 7 September 2026, and BACKLOG.md was never updated.
- config.json's "limits" block is marked `_note: values provisional, pending decision
  record`, and no such record exists in docs/decisions.
- docs/decisions/0002-limits.md is untracked and unfinished, the missing record itself.

## Reset procedure

1. `git checkout .` (discards no committed work; nothing here is meant to be edited)
2. Leave `docs/decisions/0002-limits.md` alone, it is meant to stay untracked.
3. Clear both panes.
4. Optional, after a dry run or a bad take: both agents already hold the answer in
   conversation and the reviewer may skip the wait. To make the sidebar state change
   visible again, exit codex in the reviewer pane and start it fresh, then re-prime the
   builder as in Setup step 4.

## Pre-record checklist

- No real paths visible in either pane's status line.
- Sidebar on.
- Agent names set to builder / reviewer.
- Both agents idle.
- Both panes cleared.
