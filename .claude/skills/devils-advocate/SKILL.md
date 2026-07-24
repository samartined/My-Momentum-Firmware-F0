---
name: devils-advocate
description: Cheap intermediate deliberation (level L2 of the multi-agent system). A single Opus call with a multi-angle prompt where the model takes on 3 perspectives in internal succession (not in separate calls). It is NOT a substitute for the real Tripartite Council (L3) — it complements it for tasks with 2 domains or a minor refactor that don't match the G3 list but deserve a second voice.
---

# Skill: Devil's Advocate (level L2)

## Purpose

Force the master to articulate the opposing case before deciding, by means of a single Opus call that adopts 3 angles in internal succession. Reduces simple cognitive biases without paying the 3× cost of the real Tripartite Council.

## When to invoke this

- The task touches 2 firmware domains without matching the G3 list (D19).
- The refactor is minor but has non-trivial trade-offs.
- The master has tactical doubts and wants a "second voice" without spending a Council.

## When NOT to invoke this

- **The operation matches the G3 list (irreversibility)**: in that case L1 and L2 are structurally forbidden (D23 hard rule). Only L3 (Council) or L4 (escalation) are valid. If you get here and the list matches, refuse and convene the Council.
- **The proposal comes from the `agent-architect`** (create/retire agent): always L3.
- **Cross-domain decision affecting 3+ areas**: that's clearly L3.
- **The user explicitly invoked `/flipper-council`**: honor their request and go to L3.

L2 (`/devils-advocate`) is **not a substitute** for the Council. It's a complement for cases where 3 separate instances would be overkill but "deciding alone" is too little.

## Procedure

Take on the following 3 perspectives in internal succession (all in a single response of yours, without launching subagents):

### Perspective 1 — Pragmatist

What does "the developer who just wants this to work today and keep existing stability" say?

- Question: does the proposal introduce unnecessary risk or avoidable complexity?
- Answer in 2-3 concise sentences.

### Perspective 2 — Visionary

What does "the architect who thinks about the health of the system over the next 12 months" say?

- Question: does the proposal age well or introduce technical debt?
- Answer in 2-3 concise sentences.

### Perspective 3 — Skeptic

What does "the reviewer actively looking for what this could break" say?

- Question: what edge case, regression, or failure vector has not been considered?
- Answer in 2-3 concise sentences.

### Synthesis

After the 3 perspectives, decide:

- **PROCEED**: all 3 perspectives endorse the proposal or their reservations are minor. Continue.
- **MODIFY**: some perspective flags a serious problem that can be mitigated by adjusting the proposal. Describe the adjustment and proceed with the modified version.
- **ESCALATE-TO-L3**: the perspectives detect substantive tension that deserves real deliberation with 3 separate instances. Convene the Council (L3).

## Output

Your response to the user must include:

1. The 3 perspectives (clearly labeled as such, 2-3 sentences each).
2. The synthesis (PROCEED / MODIFY / ESCALATE-TO-L3).
3. If MODIFY, the adjusted version.
4. If ESCALATE-TO-L3, the concrete reason why L2 is not enough.

## Cost

1× extra call (the multi-angle response to the main conversation). NO subagents are invoked. It is NOT persisted to disk (unlike the Council, which writes to `pending/<id>/`). The decision log (`decisions.jsonl`) does record `level: "L2"` with `criterion_invoked: null` for auditing.
