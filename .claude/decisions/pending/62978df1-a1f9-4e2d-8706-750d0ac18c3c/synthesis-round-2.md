---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
ronda: 2
synthesized_by: master (main conversation, Opus)
synthesized_at: 2026-05-23T16:45:00Z
note: |
  Retroactively reconstructed via Bash heredoc after the systematic failure of
  the Write tool in this session. The content matches the description passed
  in the prompts of the 3 round-2 council members, on which they cast their
  votes.
---

# Master's synthesis for round 2

## Refined proposal

Adopt **Alternative A** (add `COR` to the Council's closed angle catalog) **with the following mandatory conditions incorporated into the PR that modifies `.claude/design/council-angles.md`**:

### 1. Simultaneous reformulation of `ROB`

The `ROB` entry is updated in the same PR to explicitly exclude functional correctness:

> **ROB — Robustness**: Which structural invariant of the system (lifecycle, state, failure recovery, error handling) remains verifiable after this change? Does not cover correctness of the functional result — see `COR`.

If this reformulation is not included in the PR, the entire proposal does not proceed (hard precondition).

### 2. Operational key question for `COR`

> **COR — Correctness**: Is there a concrete input case where the output differs from the expected one by ≥1 bit, ≥1 byte, or ≥1 record, and that case is not covered by an existing test or invariant?

Verifiable predicate (a counterexample exists: yes/no) that is mechanically distinguished from `ROB` (which asks about the existence of the guarantee, not of the counterexample).

### 3. Applicability rail disjoint from `ROB`

`COR` applies only when the result of the operation is comparable bit-by-bit or byte-by-byte with an expected value:

- Deserialization of structured formats (FAT, NFC dumps, SubGHz keystore, `.sub`/`.nfc`/`.ir` files).
- File migrations with a defined schema.
- Parsing of protocols with a defined frame.

Explicitly excluded (written in the catalog, not only in the ADR):

- Control logic.
- State machines.
- UI / scenes / views.
- Scheduling / threading / timing (the latter is `THR`).

These cases remain in `ROB` territory.

### 4. Frozen entry in the catalog history

The "Catalog change history" section of `council-angles.md` receives an entry with:

- Date: `2026-05-23`.
- `council_id`: `62978df1-a1f9-4e2d-8706-750d0ac18c3c`.
- Closing ADR ID: `ADR-0001`.
- Exact frozen definition of the approved `COR` (full text, not by reference).
- Explicit delimitation against `ROB`.

Immutable entry; future refinements generate a new history entry, not in-place editing.

## On Council Member 2's minority vote

Council Member 2 voted NO in round 1 (YAGNI). The synthesis incorporates the objection as an empirical withdrawal criterion documented in the closing ADR:

> Withdrawal clause: if after 3 months of system operation (measured in `decisions.jsonl`) the `COR` angle has been invoked in fewer than 10% of the L3 decisions touching eligible domains (NFC, SubGHz, storage, parsing), the `agent-architect` must propose its withdrawal from the catalog via human PR.

This turns the risk into an observable self-correction mechanism.

## Executive summary

- Alternative A proceeds with 4 mandatory conditions.
- `ROB` and `COR` are redefined simultaneously to guarantee operational disjunction.
- The catalog grows to 13 angles.
- Council Member 2's NO vote is documented as a known risk + 3-month empirical withdrawal clause.
- If the 4 points are not fully included in the PR, the proposal does not proceed.
