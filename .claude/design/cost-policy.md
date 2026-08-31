# Cost policy and budget ceiling

This document defines the per-session cost ceiling for the multi-agent system and the tokens→USD conversion table used by the logging hooks.

Council resolution: D24.

> ## ⚠ Implementation status (verified 2026-08-31)
>
> **None of the three mechanisms in the table below exists.** `settings.json` wires only
> `SessionStart`, one `PreToolUse` (git-checkout cleanliness) and two `SubagentStop`
> hooks. There is no `PostToolUse` hook, no cost-accounting `PreToolUse` hook, and
> `.claude/state/costs.jsonl` is never written by anything.
>
> So: no soft warning at 60%, no persistent warning at 100%, and **no hard cap** —
> nothing blocks Opus subagent invocations at 200% of budget. Cost control is currently
> the operator's attention, not a mechanism.
>
> This document is kept as the specification to implement, not as a description of
> present behaviour. The same distinction was forced on `system-design.md` in 0.1.11,
> where four sentences asserting the G3 invariant was "structural" were removed for
> claiming a mechanism that did not exist. Do not read the table below as active.
>
> Also unfinished: the tokens→USD table is still `(pending)` in every cell, and it lists
> `claude-opus-4-7` / `claude-sonnet-4-6`, which are not the models in use.

## Action levels

| Threshold | Action | Mechanism |
|--------|--------|-----------|
| 60% of budget | Soft warning | `PostToolUse` hook prints a notice to the user after the next response |
| 100% of budget | (Phase 1) Continues with persistent warning | Hook keeps emitting every N invocations |
| 200% of budget (hard cap) | Blocks invocations to Opus subagents (architect, council) — only Sonnet allowed | `PreToolUse` hook aborts invocations that would exceed the cap |

In Phase 1, the hard cap only triggers on pathological cases. Calibration of the soft warning and hard cap is adjusted empirically in Phase 2+ with real log data.

## Budget

| Parameter | Default value | Configurable |
|-----------|-------------------|--------------|
| `session_budget_usd` | 50.00 | Yes, in this file |
| `warning_threshold_pct` | 0.60 | Yes |
| `hard_cap_pct` | 2.00 (i.e. 2x the budget) | Yes |

## Tokens→USD table

**Last updated**: 2026-05-20  
**Source**: https://docs.anthropic.com/en/docs/about-claude/pricing (to be confirmed manually)

| Model | Input ($/M tokens) | Output ($/M tokens) | Cache write ($/M) | Cache read ($/M) |
|--------|---------------------|---------------------|-------------------|------------------|
| claude-opus-4-7 | (pending) | (pending) | (pending) | (pending) |
| claude-sonnet-4-6 | (pending) | (pending) | (pending) | (pending) |
| claude-haiku-4-5-20251001 | (pending) | (pending) | (pending) | (pending) |

(The numeric values are filled in manually by the user from the current pricing page.)

## Cost log schema

One line = one JSON object = one subagent invocation. File: `.claude/state/costs.jsonl` (append-only, gitignored). **This schema is unimplemented** — no writer exists, see the status block at the top.

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string (ISO 8601) | |
| `invocation_id` | string (UUIDv7) | |
| `agent_name` | string | Name of the invoked subagent |
| `model` | string | Model identifier |
| `tokens_in` | integer | |
| `tokens_out` | integer | |
| `cost_usd` | float | Calculated via the table above |
| `parent_context` | string | Parent session / decision / task ID |
