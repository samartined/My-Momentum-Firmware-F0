---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-3
angulo: MNT
ronda: 1
timestamp: 2026-05-23T16:23:57Z
---

# Council Member 3's verdict — MNT angle (Maintainability)

## Recommendation
MODIFY

## Reasons (maximum 3)

1. **The proposed "key question" for `COR` lacks sufficient operationalization to survive 6 months.** The text "Does the operation produce the functionally correct result without loss or corruption of data?" uses three undefined terms: "functionally correct", "loss", and "corruption". Without a rubric delimiting what counts as "correct" versus a verifiable structural property (already covered by `ROB`), a future master — or Edgar's own Q4-2026 self, without the fresh memory of this deliberation — will classify the same decision sometimes under `ROB` and sometimes under `COR` depending on the day. By contrast, current catalog angles like `BIN` ("Does it fit in available flash and RAM?") or `COS` ("How many model calls does it add and of what tier?") are **measurable**: a number, a threshold, a verdict. `COR` as currently worded is not. The difference between `ROB` ("verifiable property") and `COR` ("functionally correct result without loss/corruption") is an **interpretive** distinction, not an operational one, and interpretive debt accumulates in every subsequent ADR.

2. **The catalog's "Applicable when" field is the structural rail that fights drift, and in the proposal it is too lax.** The list "reading/writing protocols (NFC/SubGHz/RFID/IR), file parsing, migrations, code that serializes/deserializes" covers an enormous fraction of the Momentum firmware (literally most of the specialists planned in CLAUDE.md: `flipper-rf-subghz`, `flipper-nfc`, `flipper-rfid-ibutton`, `flipper-ir`, `flipper-c-furi`). When a rail applies to "almost everything that touches hardware", it stops being a rail. Compare with `ENE` ("Code that touches radio, display, GPIO") or `THR` ("Code that touches FreeRTOS, interrupts, hardware") — these are specific by **subsystem**. `COR` as proposed overlaps in applicability with `ROB` (which already says "Decisions that touch the firmware runtime or the agent system"). Keeping two angles whose "applicable when" fields overlap this much will produce retroactive inconsistency: ADRs closed with `ROB` covering correctness will be indistinguishable from future ADRs with `COR` covering the same thing, with no note.

3. **The "Catalog change history" section of `council-angles.md` itself is empty, and the proposal does not specify a changelog entry.** This is a maintainability symptom: the catalog was designed with a longitudinal traceability mechanism (the table itself, the history section) but the proposal does not include what entry goes into that section — date, ID of the Council session that approved it, exact definition frozen at that moment. Without that record, in 6 months it will not be possible to answer "what did `COR` mean when it was introduced?". This is exactly the risk Alternative C correctly flags (retroactive change of meaning with no note) — but Alternative A does not avoid it: it simply pushes it into the future. Every time `COR`'s definition is refined in a later PR, prior ADRs will become orphaned unless the catalog's changelog is disciplined, and nothing in the proposal guarantees that.

## Risks detected from my angle

- **Interpretive drift between contemporary council members**. In the same Council session, two council members assigned to `COR` and `ROB` may reason about the same case (e.g. "does the SubGHz keystore deserialization preserve the bits") and argue the same thing from both angles, nullifying the value of the trio. The master has no mechanical rule to detect this at runtime: the closed catalog's anti-bias discipline (D18) presupposes that each angle covers a **disjoint** portion of the critical space, and `COR`/`ROB` as proposed is not disjoint.

- **Erosion of the test-question in a future master**. When the master classifies a decision and selects 3 angles, it performs a mental "test question": what concrete question do I want answered? If an angle's key question is vague, the master tends to either avoid it (ambiguity-aversion bias) or pick it out of inertia. In 6 months, without the memory of this session, `COR` will either be overused (because "correctness" sounds universal and applies to almost everything) or avoided (because its question is hard to instrument). Neither scenario is good.

- **Catalog maintenance cost grows super-linearly**. Each new angle does not add additive work: it adds work of **coherence with the 12 existing ones** (checking overlap with each one, maintaining the changelog, updating agents that invoke the catalog, training the master on when to apply which). Going from 12 to 13 angles is not expensive by itself; going to 13 with an ambiguously overlapping pair is. Alternative B (recurring wildcard) has a maintainability advantage underestimated in the dossier: the wildcard *forces* the 3-5 line justification to be written every time, which acts as empirical data on whether the category is really necessary and well-defined before crystallizing it. The `/flipper-review-wildcards` command is exactly the maintainability tool designed for this.

- **The dossier's meta note reduces the incentive to make the entry robust**. The dossier says "any of the 3 alternatives is defensible" because the real decision is subordinate to the system's V2 validation. If `COR` is approved with its current entry without strengthening it, it stays permanently in the closed catalog — and the closed catalog is by design hard to modify (requires a human PR, D18). The quality bar for catalog entry must be proportional to the cost of exit, not to the value of the deliberation that introduces it.

## Vote
YES-WITH-CONDITIONS

## Conditions (only if YES-WITH-CONDITIONS)

- **Condition 1 (operational key question)**: Reformulate `COR`'s key question so it is instrumentable. Concrete proposal: *"Is there a concrete input case where the output differs from the expected one by ≥1 bit, ≥1 byte, or ≥1 record, and that case is not covered by an existing test or invariant?"*. This turns "correctness" into a verifiable predicate (does a case exist? yes/no) and mechanically distinguishes it from `ROB` (`ROB` asks about the existence of the guarantee, `COR` asks about the existence of the counterexample).

- **Condition 2 (applicability rail disjoint from `ROB`)**: Restrict `COR`'s "Applicable when" field to cases where **the result of the operation is comparable bit-by-bit or byte-by-byte with an expected value**: deserialization of structured formats (FAT, NFC dumps, SubGHz keystore, `.sub`, `.nfc`, `.ir` files), schema-based file migrations, parsing of protocols with a defined frame. **Explicitly exclude**: control logic, state machines, UI, scheduling — those remain `ROB` territory. This restriction must be written in the "Applicable when" field of the table, not only in the closing ADR.

- **Condition 3 (mandatory history entry)**: The catalog modification must include, in the "Catalog change history" section of `council-angles.md`, an entry with: date (`2026-05-23`), council_id (`62978df1-...`), closing ADR ID, exact approved definition of `COR` (full text of the key question and applicability — inline, not by reference), and explicit delimitation against `ROB` (one sentence: *"`COR` applies when there is a concrete comparable expected value; `ROB` applies when a property is asserted without a concrete counterexample"*). This entry remains **frozen**: any future refinement of `COR`'s definition requires a new history entry, not in-place editing of the table. Without this condition, future ADRs invoking `COR` will carry retroactive interpretive debt the first time the definition is refined.
