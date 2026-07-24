# Decision classification log schema

This document specifies the format of the `.claude/state/decisions.jsonl` file (append-only, gitignored, local to the clone) in which the master records every L1/L2/L3/L4 classification decision.

Council resolution: D20.

## Format

One line = one JSON object = one classified decision. UTF-8 encoding, LF line separator.

## Required fields

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string (ISO 8601) | Moment of the decision, with explicit timezone |
| `decision_id` | string (UUIDv7) | Unique identifier of the decision |
| `task_hash` | string (SHA-256 hex) | Hash of the task statement (not the full statement, to avoid bloating the log) |
| `level` | string (enum) | `"L1"` \| `"L2"` \| `"L3"` \| `"L4"` |
| `criterion_invoked` | string \| null | ID of the entry in `irreversibility.md` that triggered L3 (e.g. `"IRREV-7"`), or `null` if the classification was not based on the closed list |
| `domains_touched` | array<string> | List of affected firmware domains (`["subghz"]`, `["nfc", "build"]`, etc.) |
| `justification_short` | string (≤200 chars) | One line explaining why this level |
| `model_version` | string | Identifier of the model that made the decision (e.g. `"claude-opus-4-7"`) |

## Optional fields

| Field | Type | Description |
|-------|------|-------------|
| `council_id` | string (UUIDv7) \| null | If `level == "L3"`, the ID of the associated Council |
| `cost_estimate_tokens` | integer \| null | Estimated tokens consumed by this decision |
| `cost_estimate_usd` | float \| null | Monetary estimate derived from the table in `cost-policy.md` |
| `eligible_for_cor` | boolean \| null | `true` if the decision meets the objective criteria for invoking the `COR` angle (see `council-angles.md` → "Operational definition of 'eligible for `COR`'"). `false` if not. `null` if the classification predates the introduction of this field (ADR-0001, 2026-05-23). Its aggregate feeds the empirical withdrawal audit scheduled for `2026-08-23`. |

## Automated auditor activation (Phase 2+)

The Sonnet auditor is activated when **all** of the following conditions are met:

- Minimum window: 100 recorded decisions (`N >= 100`).
- Ratio `(L1 + L2) / N > 0.95` during the window.
- Or manual detection by the user of misclassifications during a review.

Once activated:

- Random 5% sampling of L1+L2 decisions, re-evaluated by a `council-auditor` subagent (Sonnet, without context from the original session).
- Discrepancies accumulate; if > 15% of the samples are reclassified upward within a 30-day window, the system escalates to the user for recalibration of the master's prompt.

## Retention policy

- The JSONL is append-only.
- Rotation: once it exceeds 100 MB, it is moved to `.claude/state/decisions-YYYYMM.jsonl.gz` (compressed).
- It is never deleted (deletion matches D19 entry 9).
