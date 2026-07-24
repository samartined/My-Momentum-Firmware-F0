# Catalog of Tripartite Council angles

This document is the closed catalog of angles that the master can assign to the 3 council members when convening the Council (level L3). Each angle has a stable ID so deliberation logs are parseable longitudinally.

Council resolution: D18.

## Usage rules

- The master selects exactly 3 angles from the catalog when convening the Council.
- Each council member receives a single assigned angle and must argue from it.
- Maximum 1 ad-hoc wildcard angle (outside the catalog) per session, with an expanded 3-5 line justification written to the deliberation log.
- Promotion of a wildcard to the catalog: opt-in user command `/flipper-review-wildcards`.
- Catalog extension: via human PR. Adding angles at runtime is not allowed.

## Catalog (13 current angles)

| ID | Angle | Key question | Applicable when |
|----|--------|----------------|------------------|
| ROB | Robustness | What structural invariant of the system (lifecycle, state, failure recovery, error handling) remains verifiable after this change? Does not cover functional-result correctness — see `COR`. | Decisions that touch the firmware runtime or the agent system, except input→output transformations with a comparable expected result |
| COR | Correctness | Is there a concrete input case where the output differs from the expected value by ≥1 bit, ≥1 byte, or ≥1 record, and that case is not covered by an existing test or invariant? | Deserialization of structured formats (FAT, NFC dumps, SubGHz keystore, `.sub`/`.nfc`/`.ir` files); schema-based file migrations; parsing of protocols with a defined frame. See "Operational notes for `COR`". |
| SIM | Simplicity | What is the minimal implementation that covers the case? | Refactors, new features, control mechanisms |
| SEC | Security | What attack vector or leak does this decision open or close? | Anything that touches credentials, cryptography, ACLs |
| REV | Reversibility | How much does it cost to undo this decision if it turns out to be bad? | Decisions with impact > 1 day of work |
| COS | Token cost | How many model calls does this add and at what tier? | Any mechanism that invokes subagents |
| UPS | Upstream compatibility | Does this close the door to contributing to the official firmware? | Refactors that touch code shared with Next-Flip |
| MNT | Maintainability | Who maintains this in 6 months? | Decisions with new dependencies or frameworks |
| UX | User ergonomics | Does it add friction for the Flipper operator? | Any UI, slash command, user flow |
| ORT | Orthogonality | Is this feature orthogonal to existing ones, or does it couple them? | Firmware architecture decisions |
| ENE | Energy/battery | Does it affect device consumption? | Code that touches radio, display, GPIO |
| BIN | Binary size | Does it fit within available flash and RAM? | New apps, libraries, assets |
| THR | Threading/timing | Are there race conditions or timing violations? | Code that touches FreeRTOS, interrupts, hardware |

## Operational notes for `COR`

Added by ADR-0001 (`2026-05-23`). These notes are part of the frozen definition of the angle and must always be read whenever the master considers assigning it.

### Explicitly excluded from `COR`

`COR` **does not apply** to:

- Control logic and state machines.
- UI, scenes, views.
- Scheduling, threading, timing (the latter falls under `THR`).
- Resource lifecycle, failure recovery, structural error handling (that is `ROB`).

`COR` applies only when the result of the operation is comparable bit-for-bit or byte-for-byte against a concrete expected value.

### Operational definition of "eligible for `COR`"

An L3 decision is **eligible for `COR`** (field `eligible_for_cor: true` in `decisions.jsonl`) if and only if its dossier statement mentions, verifiably by inspection, at least one of the following objective criteria:

- Involves **physical protocol I/O**: NFC, SubGHz, RFID, iButton, IR, BLE at its frame/payload layer.
- Involves **parsing** of structured files with a schema (FAT, `.sub`/`.nfc`/`.ir` files, asset dumps).
- Involves **migration** of files or structures with a defined schema.
- Involves **serialization/deserialization** between representations (keystore, saved slots, persisted configurations).

If an L3 decision does not fall under any of the above criteria, it is **not eligible for `COR`** and the master must mark `eligible_for_cor: false` in its log entry.

### `ROB`+`COR` co-invocation guard

Until the first 3-month audit (`2026-08-23`, see "Catalog change history"), if the master assigns `ROB` and `COR` **simultaneously** to the same Council, the dossier must include a **one-line justification** explaining why the decision requires both lenses and is not expressible as a single one.

## Wildcard

If none of the 12 angles adequately captures the critical perspective for a decision, the master may define an ad-hoc wildcard for that session. Requirements:

- Temporary identifier: `WILD-<timestamp>`.
- Expanded justification (3-5 lines) explaining why the catalog angles do not apply.
- The justification is written to `.claude/state/wildcards.jsonl` with timestamp, Council ID, wildcard angle, justification.
- If `/flipper-review-wildcards` detects the same wildcard recurring, the user decides whether to promote it to the catalog via PR.

## Catalog change history

This section is **append-only**. Each entry is frozen with the date, the originating `council_id`, the closing ADR ID, and the exact approved definition. Future refinements generate a **new entry**, not an in-place edit.

---

### Entry 1 — 2026-05-23 — Addition of the `COR` angle

- **Date**: `2026-05-23`
- **Originating `council_id`**: `62978df1-a1f9-4e2d-8706-750d0ac18c3c`
- **Closing ADR**: [`ADR-0001-add-cor-angle.md`](../decisions/ADR-0001-add-cor-angle.md)
- **Change**: added angle `COR` (Correctness); simultaneous reformulation of `ROB` to exclude functional correctness.

**Frozen definition of `COR` approved in this entry:**

> **Key question**: Is there a concrete input case where the output differs from the expected value by ≥1 bit, ≥1 byte, or ≥1 record, and that case is not covered by an existing test or invariant?
>
> **Applicable when**: Deserialization of structured formats (FAT, NFC dumps, SubGHz keystore, `.sub`/`.nfc`/`.ir` files); schema-based file migrations; parsing of protocols with a defined frame.

**Delimitation against `ROB`** (canonical phrase):

> `COR` applies when there is a concrete comparable expected value; `ROB` applies when a property is asserted without a concrete counterexample.

**Empirical withdrawal clause (3-month audit)**:

- **Owner**: `agent-architect`.
- **Audit date**: `2026-08-23` (3 months from approval).
- **Withdrawal triggers (OR logic — failing one is enough)**:
  - **C3-N2 (low usage)**: fewer than **2 real invocations** of `COR` in the 3-month window.
  - **C1-N1 (high overlap)**: more than **30% of Councils that co-assigned `ROB`+`COR`** produce verdicts with reasons textually overlapping by >70%.
- **Semantic comparator for "overlapping reasons"**: checklist of argued sub-topics (closed list: structural guarantee, concrete counterexample, lifecycle, parsing, data integrity, error handling, schema/frame). Two verdicts overlap if they share >70% of the argued sub-topic list. Alternative comparator allowed: significant-token diff with a 70% threshold. The audit documents which one was used.
- **Result sink** (fixed format, future entry in this history):
  - `{date, originating_council_id, observed_invocations, decision: keep | withdraw | reevaluate-in-6m}`
- The audit entry must be logged **even if the decision is to keep it unchanged** — the catalog's longitudinal traceability requires it.

**On the 70%/30% threshold (round-3 technical note)**: at the first audit, `agent-architect` must manually calibrate the threshold against the real corpus (expected <20 dossiers) before mechanizing it. The 70%/30% threshold is the initial proposal; reasoned adjustments are documented in the audit entry.

**Materialization status**: applied in this commit. Accompanying modifications:
- `.claude/design/decisions-schema.md`: added optional field `eligible_for_cor`.
- `.claude/design/phases.md`: added an active calendar entry for `2026-08-23`.

