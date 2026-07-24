---
description: Forces the convening of the Tripartite Council over $ARGUMENTS, even if the master would not consider it necessary on its own. Useful when the user wants explicit adversarial deliberation.
---

# Flipper Council (force Council)

You have been invoked via `/flipper-council`. The user has explicitly requested that the decision go through the Tripartite Council (L3) even though your classification criteria would have placed it at L1 or L2.

## User's question / decision

$ARGUMENTS

## Mandatory procedure

1. **Build the mandatory dossier** per `CLAUDE.md > "Before every L3: mandatory dossier"`:
   - Read only relevant files from the codebase (do NOT use the conversational history as a source).
   - Write to `.claude/decisions/pending/<UUIDv7>/dossier.md` with schema: statement (≤200 words), files consulted (≤10 / ≤20 with justification), alternatives considered (≥2), irreversibility criterion invoked (in this case: "user forced /flipper-council").
2. **Select 3 angles** from the catalog `.claude/design/council-angles.md`. For decisions forced by the user without a G3 criterion, typical angles: `ROB`, `SIM`, `SEC` — but adjust according to the nature of the task. Maximum 1 ad-hoc wildcard with expanded justification (3-5 lines to the log `.claude/state/wildcards.jsonl`).
3. **Launch 3 parallel invocations** of the `council-member` subagent with their assigned angles. Give them the Council ID so they write their verdict to `.claude/decisions/pending/<id>/concejal-N.md`.
4. **Collect the 3 verdicts** from the files (not from the conversational memory of the invocations).
5. **Synthesize but do NOT vote**. Apply the resolution rules of D11+D21:
   - Unanimous YES or 2-of-3 YES → proceed; close the ADR at `.claude/decisions/ADR-NNNN-<slug>.md`.
   - 1-of-3 YES → **mandatory** escalation to the user (L4). Present the dossier + 3 verdicts to the user without deciding.
   - 0-of-3 YES → proposal rejected, ADR documented as such.
6. **Log to `.claude/state/decisions.jsonl`** with `level: "L3"`, `criterion_invoked: "user-forced"`, `council_id: <UUIDv7>`.

## Valid shortcuts within the Council

- If in round 1 there is unanimous YES with no conditions, you can skip round 2 and close directly.
- If there are conditions, launch round 2 (vote on synthesis without sharing full verdicts).
- If in round 2 there are new or cross conditions, launch round 3 (cross-validation).
- After round 3, if there is no 2/3 convergence, escalate to the user.
