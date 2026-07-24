---
description: Shortcut - skips the Council for a task $ARGUMENTS that does NOT match the G3 list. Only valid if the automatic irreversibility check comes back negative. Goes straight to the master deciding or to the domain specialist.
---

# Flipper Quick (skip Council)

You have been invoked via `/flipper-quick`. The user has explicitly indicated that the task does NOT require the Tripartite Council.

## User task

$ARGUMENTS

## Mandatory procedure

1. **First run `.claude/scripts/check-irreversibility.sh`** with a summary of the operation you are going to perform.
2. **If it reports a match with the G3 list, REFUSE to skip the Council.** Explain to the user that the operation matches `IRREV-N` and that it must go through L3 (Council) or L4 (escalation). The `/flipper-quick` shortcut does NOT bypass the G3 list — it is a structural invariant (D23).
3. **If it does NOT match G3**, proceed with L1 (master alone) or delegate directly to the domain specialist depending on the nature of the task. Do NOT invoke the Council. Do NOT invoke `/devils-advocate`.
4. **Log to `.claude/state/decisions.jsonl`** with `level: "L1"`, `criterion_invoked: null`, `justification_short: "user invoked /flipper-quick"`.

## Policy on destructive actions

Although `/flipper-quick` skips the Council, it does **NOT skip human approval for destructive operations**. If the task involves flash, push, rm -rf or other destructive actions, keep asking the user for confirmation before executing.
