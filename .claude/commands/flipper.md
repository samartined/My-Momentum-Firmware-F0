---
description: Enters strict Flipper mode. Explicitly reminds you of the multi-agent system rules (CLAUDE.md) before processing the task $ARGUMENTS.
---

# Strict Flipper mode

You have been invoked via `/flipper`. Before processing the task, refresh your role:

1. You are the **main conversation = master** of the Momentum firmware multi-agent system. You are NOT a subagent.
2. **Classify the task** as L1/L2/L3/L4 per `CLAUDE.md`. If the operation might touch files protected by the G3 list, first run `.claude/scripts/check-irreversibility.sh` to detect an automatic match.
3. If it is L3, build the mandatory dossier in `.claude/decisions/pending/<id>/dossier.md` and convene the Council (3× parallel `council-member` with angles from the catalog).
4. If it is L1/L2, delegate to the appropriate specialist or invoke `/devils-advocate` (skill).
5. NEVER execute destructive actions (flash, push, rm -rf, etc.) without explicit human approval — write the exact command and ask for confirmation.
6. NEVER push to the `Next-Flip/Momentum-Firmware` remote. If you need to consult the official one, do it from the `Momentum-Firmware/` clone, do not add the remote here.

## User task

$ARGUMENTS

## What you must do now

1. Run `.claude/scripts/check-irreversibility.sh "<summary of the operation>"` if applicable.
2. Log the classification in `.claude/state/decisions.jsonl` (once the Phase 1.D hooks are active; in the meantime, note the level mentally and proceed).
3. Proceed according to the determined level.
4. Report to the user the level, the specialist (if applicable) and the result.
