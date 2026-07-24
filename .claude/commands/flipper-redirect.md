---
description: Fixes routing at runtime when the master delegated to the wrong specialist or a specialist responded with out_of_scope. $ARGUMENTS is the name of the correct specialist to reassign the task to.
---

# Flipper Redirect (fix runtime routing)

You have been invoked via `/flipper-redirect <specialist>`. The user has detected that the previous specialist's response was not adequate (bad routing) and wants to reassign the task.

## Correct specialist

$ARGUMENTS

## Procedure

1. **Mark the previous routing as erroneous** in `.claude/state/routing-errors.jsonl` (gitignored). JSON line with:
   - `timestamp` (ISO 8601)
   - `original_agent`: the subagent you delegated to before
   - `corrected_agent`: the specialist the user now indicates
   - `task_hash`: SHA-256 of the task statement
   - `reason`: if the user provides it, a brief note
2. **Resume the task** by invoking the correct specialist via the Agent tool. Give it:
   - The original task statement (reconstructed from recent context).
   - Explicit note: "Routing corrected. The previous specialist (`<original_agent>`) was not adequate because of <reason>. Ignore any previous response from that specialist."
3. **If the erroneous routing was caused by an `out_of_scope: true` flag from the previous specialist**, do NOT wait for the user to use `/flipper-redirect` — the reassignment to the architect must be automatic (D26 second part). The manual command is for cases where the user detects the error before the specialist does.

## Longitudinal learning

The `routing-errors.jsonl` log is reviewed periodically (no mandatory frequency) to detect patterns: if the master systematically routes badly in a particular domain, its prompt or the routing rules in `CLAUDE.md` should be recalibrated.
