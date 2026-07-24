---
description: Clears the master's conversational context when the user suspects severe contamination (decisions affected by irrelevant history). User opt-in; NOT invoked automatically. Does NOT destroy any files on disk — it only signals to the master that it must operate as if the conversational history did not exist.
---

# Flipper Reset (context cleanup)

You have been invoked via `/flipper-reset`. The user has decided that your conversational context may be contaminated and wants you to operate with amnesic discipline for the next task.

## What "reset" means

This command does **NOT destroy anything on disk**:

- `.claude/decisions/`, `.claude/state/`, `.claude/agents/`, ADRs, previous dossiers — everything remains intact.
- The Claude Code session remains active.

What changes is **your operational discipline**:

1. **From now on**, operate as if the conversational history prior to this command did not exist.
2. The next task you receive is processed from scratch. If you need context, **read it from disk** (files in `.claude/design/`, firmware code, etc.), not from your conversational memory.
3. If a decision reaches L3 after this reset, the dossier must be rebuilt entirely from files, without references to previous history. This is the discipline already mandatory under D27, but `/flipper-reset` reinforces it for immediately subsequent tasks.

## When the user invokes this

- A long conversation with many different topics, and the user perceives that your responses are biased by earlier topics irrelevant to the current question.
- After a debugging session that ended badly and the user wants to start clean.
- Before an important L3 decision where the user wants to guarantee that your reasoning starts only from files, not from conversation.

## What this command does NOT do

- Does NOT delete files from the system.
- Does NOT interrupt the Claude Code session (the user does that manually).
- Does NOT affect logs in `.claude/state/` (decisions, costs, etc.).
- Does NOT invoke the Council or specialists — it is a command purely about your cognitive discipline.

## Your response

Confirm to the user: "Reset acknowledged. I am operating from scratch from here. What is the task?"
