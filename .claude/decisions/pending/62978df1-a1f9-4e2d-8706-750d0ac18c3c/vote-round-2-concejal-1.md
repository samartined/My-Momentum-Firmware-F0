---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-1
angulo: ORT
ronda: 2
timestamp: 2026-05-23T18:45:00Z
---

# Council Member 1's vote on the synthesis — round 2

## Vote
YES-WITH-NEW-CONDITIONS

## Reasons (maximum 3, brief)

1. **The three operational conditions from my round 1 are incorporated according to the master's summary.** The simultaneous reformulation of ROB to exclude functional correctness, the "not applicable when" field in the COR entry, and the frozen entry in the catalog history — the three mechanisms I asked for so that the ROB/COR split is operationally disjoint and not merely semantic — are in the synthesis. The boundary stops being a fragile nuance and becomes verifiable by inspecting the catalog.

2. **The proposed operational key question for COR ("concrete counterexample" vs. ROB's "structural guarantee") closes the runtime overlap.** My round 1 examples (SubGHz deserialization, NFC, `flipper_migrate_files`) are no longer ambiguous: ROB asks "which invariant remains verifiable?" while COR asks "can I construct an input that breaks this result?". This produces non-redundant critiques, which was the definitive orthogonality test my round 1 reason 2 demanded.

3. **The disjoint applicability rail restricted to comparable bit-by-bit / byte-by-byte operations correctly bounds COR's scope.** My "covert double assignment" risk is mitigated: purely architectural or lifecycle decisions fall under ROB, and only input→output transformations whose success criterion is the content of the output fall under COR. The 2-of-3 YES rule recovers its anti-bias mechanics because the two angles no longer vote on the same sub-question.

## New conditions (only if YES-WITH-NEW-CONDITIONS)

- **Condition ORT-N1 (3-month audit with an explicit disjunction metric).** The 3-month empirical withdrawal clause (addressing the minority vote) must include an operational criterion measurable *from orthogonality*: review the `decisions.jsonl` log and count how many convocations assigned ROB and COR to the same trio and how many resulting verdicts were textually overlapping (>70% shared reasons). If the co-assignment-with-overlap rate exceeds 30%, the split is considered a failure from ORT and COR is withdrawn — regardless of the functional-utility criteria that might justify keeping it from other angles. This condition does not contradict the proposed withdrawal clause; it operationalizes it from my angle.

- **Condition ORT-N2 (auto-veto guard on master routing).** Until the first 3-month audit, the master must record in the dossier of every L3 that invokes both ROB and COR a one-line justification of why the decision requires both lenses and cannot be expressed as a single one. If in 3 months no dossier accumulates a credible co-invocation justification, this is additional evidence of non-orthogonality that the audit must weigh. This is light traceability, not heavy operational burden.
