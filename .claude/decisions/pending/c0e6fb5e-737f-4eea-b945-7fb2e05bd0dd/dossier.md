# Dossier — Self-protection of the G3 enforcement layer

- **Decision ID**: `c0e6fb5e-737f-4eea-b945-7fb2e05bd0dd`
- **Date**: 2026-07-25
- **Level**: **L4** (direct operator approval)
- **Criterion invoked**: `IRREV-2` (edits `.claude/design/`) + `IRREV-10` (edits `CLAUDE.md` and `.claude/scripts/`, i.e. the entry this very act creates)

## Statement

An inventory of the agent system before starting Phase 2 found that the layer
enforcing the G3 irreversibility list did not protect itself, that one entry
covered less than its own stated reason, and that a design paragraph had drifted
out of sync with the implementation. Three verified gaps: `CLAUDE.md` and
`.claude/scripts/` matched no pattern, so the master's instruction file and the
matcher script could be edited at L1; `.claude/state/counters.json` matched no
pattern (IRREV-9 covered only `*.jsonl`), leaving the D13 graduation substrate
open to tampering with no git history to audit against; and IRREV-5's pattern was
case-sensitive, so `.claude/agents/evil.MD` slipped through.

The master initially also proposed **exempting `REGISTRY.md` from IRREV-5**. That
proposal was refuted by adversarial review and is recorded here as rejected,
because the master proposing an exemption to a constraint on the master is
precisely the case the audit trail exists for.

Resolution: apply the three tightenings, add a procedure governing relaxations
(which did not exist), correct the stale paragraph, and reject the exemption.

## Files consulted

1. `CLAUDE.md` — states the G3 policy at directory granularity; the list of paths
   requiring approval was missing `.claude/scripts/` and `.claude/hooks/`.
2. `.claude/design/irreversibility.md` — the closed list; has a procedure for
   *adding* entries and none for narrowing them.
3. `.claude/scripts/check-irreversibility.sh` — the actual regexes; the
   authoritative source of what is enforced, as opposed to what is documented.
4. `.claude/hooks/update-agent-counter.sh` — lines 32 and 79 show the only write
   target is `.claude/state/counters.json`; refutes the friction premise.
5. `.claude/agents/REGISTRY.md` — line 14 confirms counters live in
   `counters.json` and the ledger is a snapshot; line 3 states it is the
   auditable, version-controlled record.
6. `.claude/agents/agent-architect.md` — lines 98 and 103 assign `REGISTRY.md` to
   the human: "do NOT touch `REGISTRY.md`".
7. `.claude/design/system-design.md` — the counting-mechanism paragraph, stale;
   claimed counters were incremented inside `REGISTRY.md`.
8. `.claude/design/phases.md` — Phase 2 done criteria; establishes that the
   registry backfill is Phase-1.B debt, not a Phase 2 criterion.
9. `.claude/settings.json` — shows `check-irreversibility.sh` appears only under
   `permissions.allow`, never wired to a hook.

## Alternatives considered

**A. Exempt `REGISTRY.md` from IRREV-5 (the master's initial proposal) — REJECTED.**
Trade-off as presented: less deliberation friction for ledger edits, at the cost
of a narrower guardrail. Refuted on five grounds, each verified against the repo:
the entry's stated reason *is* registry integrity; the policy is written at
directory granularity so the pattern under-matches rather than over-matches; the
architect definition assigns the ledger to the human; the friction premise was
factually false (the hook never writes to the ledger); and the measured benefit
was zero — both commits in history that touched `REGISTRY.md` also touched agent
definitions, so IRREV-5 fired anyway. The lookahead-free implementation
(`[a-z0-9-]+`) was tested and would have exempted `Flipper-Evil.md` and
`AGENT_evil.md` from Council review.

**B. Do nothing; record all four findings as known debt.** Trade-off: zero risk
of regression in the matcher, and Phase 2 starts immediately. Rejected because
the gaps are cheap to close and one of them (a forgeable `counters.json`) is the
substrate for automatic graduation of agents to `stable`.

**C. Also wire the matcher to a blocking `PreToolUse` hook — DEFERRED by operator
decision.** This is the only change that would make the invariant mechanical
rather than advisory, which is what `system-design.md` already claims it is.
Trade-off: it changes daily ergonomics (every edit to a protected path blocks,
including legitimate Phase 2 work) and carries a self-lockout risk if the hook's
exit-code semantics are wrong. Scoped out of this act as needing its own design
and validation; recorded as open debt in `irreversibility.md` → Entry 1.

**D. Move the ledger out of `.claude/agents/`** so the directory holds only agent
definitions. Assessed and rejected: every destination is worse. `.claude/design/`
matches IRREV-2, so identical friction with no gain; `.claude/` root or repo root
matches nothing, which opens exactly the hole the exemption would have opened;
`.claude/state/` is gitignored, which destroys the property that makes it a
ledger at all.

## Operative principle recorded

**A G3 approval authorizes a change set, not a single file.** Ledger rows that
accompany an approved agent creation require no separate deliberation. This
removes the only real motivation alternative A ever had, and it governs the
Phase 2 registry backfill: the 2 core rows are filled inside the Phase 2 change
set, justified as closing Phase-1.B debt.

## Verification performed

Matcher tested on 24 inputs after the change: 9 new closures all match
(`CLAUDE.md`, the script itself, the hooks dir, `counters.json`, `rm` of it, the
three case/underscore evasions, `REGISTRY.md`); all 10 pre-existing entries still
match (no regression); 5 controls still do not match, including
`.claude/docs/*.md` — confirming the Phase 2 curated docs remain L1 and only the
4 agent definition files require deliberation. `bash -n` passes.
