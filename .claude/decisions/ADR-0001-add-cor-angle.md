---
id: ADR-0001
title: Add `COR` (Correctness) angle to the Tripartite Council's closed catalog
status: accepted
date: 2026-05-23
decision-level: L3
council-id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
dossier: .claude/decisions/pending/62978df1-a1f9-4e2d-8706-750d0ac18c3c/dossier.md
synthetic: true
synthetic-purpose: Phase 1.G functional validation V2 — end-to-end Council exercise
materialization-status: materialized
materialization-date: 2026-05-23
materialization-files:
  - .claude/design/council-angles.md (ROB reworded, COR added, "Operational notes for COR" section, entry 1 in history)
  - .claude/design/decisions-schema.md (optional field eligible_for_cor)
  - .claude/design/phases.md (Review 1 scheduled for 2026-08-23)
---

# ADR-0001 — Add `COR` (Correctness) angle to the Council catalog

## Status

`accepted` (3-of-3 YES after round 3 cross-validation of conditions; unanimity with no vetoes).

**Meta note**: this deliberation was built as a **synthetic decision** for the Phase 1.G functional validation V2 of the multi-agent system. After the Council closed with unanimity, the user decided to **materialize it for real** (option (a), 2026-05-23). The change has been applied to the following files:

- `.claude/design/council-angles.md`: `ROB` reworded, `COR` added (catalog now at 13 angles), "Operational notes for `COR`" section with a disjoint rail, an operational eligibility definition and a co-invocation guard; entry 1 in the "Catalog change history" with the frozen definition, semantic comparator, and withdrawal clause.
- `.claude/design/decisions-schema.md`: optional field `eligible_for_cor` added (C2-N1).
- `.claude/design/phases.md`: "Active review calendar" → "Review 1" scheduled for `2026-08-23` with owner `agent-architect` (C2-N3, C3-N1).

## Context

The Tripartite Council's closed catalog of angles (D18 in `system-design.md`, defined in `.claude/design/council-angles.md`) has 12 active angles, including `ROB` (Robustness), whose current key question is "what system property remains verifiable after this change?".

The proposal evaluates whether to add a `COR` (Correctness) angle that specifically covers the sub-property "the operation produces the functionally correct result without loss or corruption of data", operationally separated from structural robustness. Cases in the Momentum firmware where a dedicated angle would add value: NFC read/write without losing bits, SubGHz keystore deserialization, FAT parsing, migration integrity (`flipper_migrate_files()` in `furi/flipper.c:58`), persistence of SubGHz/iButton/IR slots.

The irreversibility criterion invoked is **IRREV-2** (the decision modifies files under `.claude/design/`), which structurally forces level L3 (Council) per the `check-irreversibility.sh` script (D23 — hard rule).

## Alternatives considered

### Alternative A — Add `COR` as a new angle in the closed catalog (the main proposal)

Create a `COR` entry with an operational key question and an "applicable when" scope restricted to bit-for-bit comparable I/O.

- **+** Explicit distinction between robustness (structural verifiability) and correctness (functional result).
- **+** Reduces wildcards in I/O and parsing, which are common in embedded firmware.
- **−** The catalog grows to 13 angles: more combinatorial space for the master's selection bias (C(13,3)=286 vs C(12,3)=220, +30%).
- **−** Risk of overlap with `ROB` if the definitions aren't operationally disjoint.

### Alternative B — Don't add it; use an ad-hoc wildcard when it comes up

Leave the catalog at 12. When a correctness angle is needed, the master creates a wildcard with an expanded justification in `.claude/state/wildcards.jsonl` (D18). Opt-in promotion via `/flipper-review-wildcards` once recurrence appears.

- **+** The catalog stays small and disciplined. Minimal implementation (zero lines).
- **+** The wildcard mechanism already exists precisely for atypical cases.
- **−** If correctness comes up often, recurring wildcards will bloat the log; ends up at A anyway, just later.

### Alternative C — Reword `ROB` to explicitly include correctness

Change `ROB`'s definition to "what functional or structural property remains verifiable and correct after this change?".

- **+** Keeps the catalog at 12.
- **+** Robustness in the formal literature (Lamport, Lynch) has historically included correctness.
- **−** Dilutes `ROB`: an assigned council member would have to cover two distinct sub-properties in a single response.
- **−** Retroactively changes the definition of an angle already in use (historical ADRs referencing `ROB` end up with a different definition).

## Decision

**Alternative A**, with **11 mandatory conditions** set by the Council over 3 rounds of deliberation.

### Synthesis conditions (master, round 2, condensing round 1)

**S1. Simultaneous rewording of `ROB`** in the same PR that introduces `COR`:

> **ROB — Robustness**: What structural invariant of the system (lifecycle, state, failure recovery, error handling) remains verifiable after this change? Does not cover the correctness of the functional result — see `COR`.

If this rewording isn't included, the proposal does not proceed (a hard precondition).

**S2. Operational key question for `COR`**:

> **COR — Correctness**: Is there a concrete input case where the output differs from the expected result by ≥1 bit, ≥1 byte, or ≥1 record, and that case is not covered by an existing test or invariant?

A verifiable predicate (does a counterexample exist? yes/no) that is mechanically distinguishable from `ROB` (existence of a guarantee, not of a counterexample).

**S3. Applicability rail disjoint from `ROB`**. `COR` applies only when the result is comparable bit-for-bit or byte-for-byte against an expected value:

- Deserialization of structured formats (FAT, NFC dumps, SubGHz keystore, `.sub`/`.nfc`/`.ir` files).
- File migrations with a defined schema.
- Parsing of protocols with a defined frame.

Explicitly excluded (in the catalog itself, not just in this ADR): control logic, state machines, UI/scenes/views, scheduling/threading/timing (the latter is `THR`).

**S4. Frozen entry in the catalog history** (the "Catalog change history" section of `council-angles.md`) with: date, `council_id`, ADR ID, the exact frozen definition of `COR` (full text, not by reference), explicit delimitation against `ROB`. The entry is immutable; future refinements generate a new entry, not an in-place edit.

### New conditions accepted (round 3, unanimity)

**C1-N1 (origin: Council Member 1 — ORT)**. Operational disjointness metric for the 3-month audit: count dossiers that co-assigned `ROB`+`COR` and how many of the resulting verdicts were textually overlapping (>70% shared reasoning). If the co-assignment overlap rate exceeds 30%, the separation is considered a failure from ORT's standpoint and `COR` is withdrawn.

> **Technical note (council member 2, round 3)**: calibrate the 70%/30% threshold manually against the real corpus at 3 months (expected <20 dossiers) rather than freezing it as an ex-ante invariant.
>
> **Technical note (council member 3, round 3)**: the semantic comparator (token diff, embedding, or subtopic checklist) must be specified in the same history entry, not deferred.

**C1-N2 (origin: Council Member 1 — ORT)**. Until the first 3-month audit, the master must record in the dossier of every L3 that invokes `ROB`+`COR` simultaneously a one-line justification of why the decision needs both lenses and cannot be expressed with just one. Light traceability; the datapoints feed the audit.

**C2-N1 (origin: Council Member 2 — SIM)**. The withdrawal threshold (<10% eligible, see C2-N2) implemented as a **reproducible query** over `decisions.jsonl`, not as prose. Every L3 entry includes a field `eligible_for_cor: true|false` set by the master at classification time.

**C2-N2 (origin: Council Member 2 — SIM)**. The operational definition of "eligible for COR" documented in `council-angles.md` alongside the angle's entry, with objective criteria verifiable by inspecting the dossier's statement: involves protocol I/O, parsing, migration, serialization. Without this, the denominator of the "<10%" ratio remains undefined.

**C2-N3 (origin: Council Member 2 — SIM)**. Mandatory 3-month review scheduled (cron, reminder in `phases.md`, or equivalent), not optional. Withdrawal clauses that depend on proactive initiative systematically never get executed.

**C3-N1 (origin: Council Member 3 — MNT)**. Owner of the 3-month measurement = `agent-architect`. Sink for the result = an additional entry in "Catalog change history" with a fixed format: `{date, origin_council_id, invocations_observed, decision: keep | withdraw | reassess-at-6m}`, even if the decision is to keep it unchanged.

**C3-N2 (origin: Council Member 3 — MNT)**. Numeric threshold frozen ex ante: **fewer than 2 real invocations of `COR` in a 3-month window counted from approval** triggers a withdrawal proposal. The threshold cannot be modified without a new changelog entry.

> **Interpretive note (council member 1, round 3)**: C3-N2 (low-usage threshold) and C1-N1 (high-overlap threshold) must be applied as a logical **OR**, not AND. Withdrawal proceeds if `COR` fails on either metric (low usage OR high overlap), not only on both.

### Empirical withdrawal clause (consolidated)

After 3 months of operation from approval, `agent-architect` runs an audit against `decisions.jsonl` and produces a history entry with:

| Metric | Withdrawal trigger |
|---|---|
| Real `COR` invocations | < 2 in 3 months (C3-N2) |
| `ROB`+`COR` co-assignment rate with >70% overlap | > 30% of the co-assigned subset (C1-N1) |

**Logic**: OR (withdraw if either fails). The result is logged as an entry in "Catalog change history".

## Council votes

### Round 1 (independence preserved — council members don't see each other's verdicts)

| Council member | Angle | Recommendation | Vote | Summary |
|---|---|---|---|---|
| 1 | ORT (Orthogonality) | MODIFY | YES-WITH-CONDITIONS | `ROB`/`COR` overlap not disjoint without simultaneous rewording. 4 conditions. |
| 2 | SIM (Simplicity) | REJECT | **NO** | YAGNI: the wildcard is already the minimal implementation; no empirical recurrence datapoints. |
| 3 | MNT (Maintainability) | MODIFY | YES-WITH-CONDITIONS | Key question not operationalized; rail too loose; history empty. 3 conditions. |

Round 1 count: **2 YES-WITH-CONDITIONS / 1 NO**. Structurally 2-of-3, but C1's and C3's conditions are substantive and C2's NO vote (YAGNI with no datapoints) is valid — the master synthesizes for round 2.

### Round 2 (on the master's synthesis with 4 conditions + a 3-month empirical withdrawal clause)

| Council member | Angle | Vote | New conditions |
|---|---|---|---|
| 1 | ORT | YES-WITH-NEW-CONDITIONS | 2 (C1-N1, C1-N2) |
| 2 | SIM | **YES-WITH-NEW-CONDITIONS** (changed from NO) | 3 (C2-N1, C2-N2, C2-N3) |
| 3 | MNT | YES-WITH-NEW-CONDITIONS | 2 (C3-N1, C3-N2) |

Round 2 count: **3 YES / 0 NO**. Council member 2 (SIM) switched from NO to YES thanks to the empirical withdrawal clause, which turns a "risky permanent change" into an "experiment with an explicit stopping condition".

### Round 3 (cross-validation of the 7 new conditions)

Each council member evaluates the new conditions from the OTHER 2 (reading only the "New conditions" section to preserve reasoned independence).

| Council member | Angle | Final vote | Vetoed conditions | Notes |
|---|---|---|---|---|
| 1 | ORT | **YES** | None | Note on C3-N2 (logical OR, not AND) |
| 2 | SIM | **YES** | None | Note on C1-N1 (calibrate threshold against real corpus) |
| 3 | MNT | **YES** | None | Note on C1-N1 (specify comparator in history) |

Round 3 count: **3 YES / 0 vetoes / unanimity on the full package**. The 7 new conditions enter the ADR; the 3 technical notes are incorporated as refinements.

### Historical minority vote (round 1 → round 2 transition)

**Council Member 2 (SIM)** voted **NO** in round 1 on YAGNI/lack-of-empirical-evidence grounds. Their central objection was not rebutted but rather **incorporated as a self-correction mechanism**: the master's synthesis added the 3-month empirical withdrawal clause with measurable criteria. In round 2, C2 switched to YES-WITH-NEW-CONDITIONS, reasoning that "the clause with a measurable threshold and a defined deadline turns the decision into an experiment with an explicit stopping condition; that's exactly what SIM requires to tolerate a speculative extension of the catalog".

**This transition is documented as a known risk of the ADR**: the decision is only legitimate while the empirical withdrawal clause remains active and observable. If it ever gets diluted (no audit, no owner, no measurable thresholds), the original minority vote regains force and the decision must be revisited.

## Consequences

### Positive

- Operationally disjoint distinction between structural robustness (`ROB`) and functional correctness (`COR`) in the catalog.
- Reduces recurring wildcards in the firmware's I/O domains (NFC, SubGHz, RFID, IR, storage).
- Introduces the first precedent for an **empirical withdrawal clause** in the closed catalog — the catalog's ratchet (grow-only) stops being monotonic.
- The 4+7=11 conditions form a replicable pattern for future catalog extensions: operational key question, disjoint rail, frozen history, owner, sink, withdrawal metrics.
- Council Member 2's NO→YES vote empirically validates the design of the Council's multiple rounds (D18 + overall architecture).

### Negative / assumed risks

- **Catalog growth to 13 angles** (+30% selection combinatorics, C(13,3)=286). The master's selection bias grows proportionally, and mitigation depends on the discipline of the "applicable when" rail.
- **Risk of covert double-assignment of `ROB`+`COR`**. Even though the definitions are disjoint after S1+S2+S3, the master could still assign both to the same trio. Condition C1-N2 (a one-line justification per co-invocation) is the light guard; the 3-month audit is the remedy.
- **Implementation debt**: conditions C2-N1 (the `eligible_for_cor` field in `decisions.jsonl`) and C2-N3 (the active review calendar) require changes to logging tools and to `phases.md`. Until implemented, the withdrawal clause is not effectively operational.
- **Conditional minority vote**: the decision is only legitimate while the empirical withdrawal clause remains active and observable.

### Reversibility

- Does it match G3? **Yes — IRREV-2** (modifies `.claude/design/council-angles.md`).
- How is it undone? Via the empirical withdrawal mechanism set out in this ADR itself: after 3 months, if the metric fails (C3-N2 OR C1-N1), `agent-architect` proposes withdrawal via a human PR. Any early withdrawal also requires a human PR (D18 — the closed catalog can only be modified this way).
- Exit cost: one additional entry in the catalog history with `decision: withdraw`. Doesn't invalidate future ADRs that correctly invoked `COR` during the trial period — they remain as historical record.

## Follow-ups

### F1 — User decision on materialization [RESOLVED 2026-05-23]

This deliberation was built as a **synthetic decision for the Phase 1.G V2 validation**. The user chose **option (a) — materialize in full**.

Changes applied in this commit:

- `.claude/design/council-angles.md`: `ROB` reworded, `COR` added as angle 13, "Operational notes for `COR`" section added, entry 1 added to "Catalog change history" with the frozen definition + semantic comparator + empirical withdrawal clause.
- `.claude/design/decisions-schema.md`: optional field `eligible_for_cor: boolean` added.
- `.claude/design/phases.md`: "Active review calendar" section added with "Review 1" scheduled for `2026-08-23`.

### F2 — Implementation of the empirical withdrawal clause [COMPLETED 2026-05-23]

- ✅ Field `eligible_for_cor: bool` added to the schema (`.claude/design/decisions-schema.md`).
- ✅ Active calendar entry in `.claude/design/phases.md` (Review 1, 2026-08-23).
- ✅ Semantic comparator specified in `council-angles.md` (closed 7-subtopic checklist; alternative: significant-token diff with a 70% threshold).

### F3 — 3-month audit (scheduled for 2026-08-23)

Date: `2026-08-23`. Owner: `agent-architect`. Operational reference: `phases.md` → "Active review calendar" → "Review 1".

Withdrawal triggers (OR):
- < 2 `COR` invocations in the window.
- > 30% of `ROB`+`COR` co-assignments with >70% overlapping reasoning.

Sink: entry in `council-angles.md`'s "Catalog change history" with the format `{date, origin_council_id, invocations_observed, decision}`.

### F4 — Meta lessons from the flow (independent of F1)

- **3 Council rounds on an L3 worked**: round 1 (independence), round 2 (master's synthesis + reconsideration), round 3 (cross-validation of conditions — preserves reasoned independence).
- **The rebuttable minority vote via mechanism** (not via argument) is the valuable pattern: SIM changed from NO to YES because the synthesis added a withdrawal clause, not because their YAGNI point was rebutted.
- **`Write` bug** detected mid-session, with a Bash-heredoc workaround documented in RESUME.md. In the current session the bug is resolved.
- These lessons are material for enriching `system-design.md` or `phases.md` with an "operational meta-learnings" paragraph — out of scope for this ADR.
