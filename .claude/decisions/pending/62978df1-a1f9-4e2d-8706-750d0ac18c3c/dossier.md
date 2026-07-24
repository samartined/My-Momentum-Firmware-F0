---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
created_at: 2026-05-23T16:21:00Z
master_model: claude-opus-4-7
classified_level: L3
criterion_invoked: IRREV-2
context: V2 functional validation of Phase 1.G — synthetic decision designed to exercise the Council end-to-end
---

# Dossier — Decision: add angle `COR` to the Council catalog

## Statement

Should a `COR` angle (Correctness — functional/data integrity) be added to the closed catalog of 12 angles of the Tripartite Council (D18, defined in `.claude/design/council-angles.md`)?

The current catalog already includes `ROB` (Robustness, defined as "which system property remains verifiable after this change?"). The proposal is that `COR` specifically cover the sub-property "the operation produces the functionally correct result without loss or corruption of data", separate from general robustness.

Real cases in the Momentum firmware where an angle dedicated to correctness would add value: NFC read/write without losing bits, deserialization of the SubGHz keystore without truncation, parsing of FAT files on SD, integrity of file migrations at boot (e.g. `flipper_migrate_files()` in `furi/flipper.c:58`), persistence of SubGHz/iButton/IR slots without corruption.

## Files consulted

- `.claude/design/council-angles.md` — current closed catalog with 12 angles. Relevant because it defines the angles in force (including `ROB`) and the wildcard rule. This is the file that would be modified if the proposal proceeds.
- `.claude/design/system-design.md` — section "The Tripartite Council" (lines 215-277) and decision D18. Relevant because it explains the catalog's role, the anti-bias discipline in the master's selection of angles, and why the catalog is closed.
- `.claude/design/decisions-schema.md` — schema of the `decisions.jsonl` log. Relevant to confirm that adding an angle does not change any schema field (the log does not enumerate invoked angles, only the level and criterion).

Three files consulted, within the soft cap of 10 (D27).

## Alternatives considered

### Alternative A — Add `COR` as a new angle to the closed catalog (the main proposal)

Create a `COR` entry in `.claude/design/council-angles.md` with:

- **Key question**: "Does the operation produce the functionally correct result without loss or corruption of data?"
- **Applicable when**: reading/writing protocols (NFC/SubGHz/RFID/IR), file parsing, migrations, code that serializes/deserializes.

Trade-offs:

- **+** Explicit distinction between robustness (structural verifiability) and correctness (functional result).
- **+** Reduces wildcard usage in I/O and parsing cases, which are frequent in this embedded firmware.
- **−** The catalog grows to 13 angles. More options to choose from means more room for master bias when selecting the trio.
- **−** Risk of overlap with `ROB` if the definitions are not sufficiently disjoint. A council member might wonder "is this my angle or COR's?".

### Alternative B — Do NOT add it; use an ad-hoc wildcard when it comes up

Keep the catalog at 12. When a decision requires an explicit correctness angle, the master creates a `WILD-<timestamp>` wildcard with an expanded justification, written to `.claude/state/wildcards.jsonl` per D18.

Trade-offs:

- **+** The catalog remains small and disciplined.
- **+** The wildcard process is precisely designed for legitimate atypical cases.
- **−** If correctness is relevant to many firmware decisions (likely in NFC/SubGHz/storage), recurring wildcards will inflate the log. The `/flipper-review-wildcards` command will propose promoting the angle anyway. It ends up at Alternative A but with delay and empirical data.

### Alternative C — Reformulate `ROB` to explicitly include correctness

Change the definition of `ROB` from "which system property remains verifiable after this change?" to "which functional or structural property remains verifiable and correct after this change?".

Trade-offs:

- **+** Keeps the catalog at 12.
- **+** "Robustness" in a broad sense historically includes correctness in much of the literature (Lamport, Lynch, etc.).
- **−** Dilutes `ROB`: the council member assigned to ROB would have to cover two distinct sub-properties in a single response. Loses focus.
- **−** Retroactively changes the definition of an angle already in use. Any future or historical ADR with `ROB` would end up with a definition different from the one documented at the time it was issued.

## Irreversibility criterion invoked

`IRREV-2` — the decision modifies `.claude/design/council-angles.md` (Alternatives A and possibly C also touch `system-design.md`). The automatic matching of the `.claude/scripts/check-irreversibility.sh` script structurally forces the L3 level (D23 hard rule); the master cannot decide alone (L1) nor invoke `/devils-advocate` (L2).

## Angles selected for the 3 council members

- **Council member 1**: `ORT` (Orthogonality). Question: is the proposed angle orthogonal to the existing ones (especially `ROB`) or does it introduce problematic overlap?
- **Council member 2**: `SIM` (Simplicity). Question: does the catalog gain or lose operational clarity by adding one more angle?
- **Council member 3**: `MNT` (Maintainability). Question: who decides when to apply `COR` vs `ROB` at runtime? Is the distinction operationally useful 6 months from now when the consulted files are no longer remembered from memory?

No wildcard is invoked in this Council session.

## Meta note

This deliberation is the **V2 functional validation** of Phase 1.G (the last of the 4 "done" criteria defined in `.claude/design/phases.md`). Its actual decision is subordinate to the session's main goal, which is to exercise the Council end-to-end to confirm the system works. Any of the 3 alternatives is defensible; council members must reason as if the decision had real impact so the validation is rigorous.
