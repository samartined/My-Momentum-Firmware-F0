---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-1
angulo: ORT
ronda: 1
timestamp: 2026-05-23T16:35:00Z
---

# Council Member 1's verdict — ORT angle (Orthogonality)

## Recommendation
MODIFY

## Reasons (maximum 3)

1. **The conceptual overlap between the proposed `ROB` and `COR` is not disjoint at the operational level; it is separated only by a fragile semantic nuance.** The current definition of `ROB` is "which system property remains verifiable after this change?". Functional correctness ("the operation produces the functionally correct result without loss or corruption of data") is exactly *one verifiable property* of the system. The dossier tries to resolve the overlap via "structural verifiability vs. functional correctness" (Alternative A, trade-off `-`), but this dichotomy does not appear in the cataloged definition of `ROB`: the catalog does not say "structural verifiability", it just says "verifiable property". By construction, a verifiable functional property falls under `ROB` as currently worded. For `COR` to be genuinely orthogonal, `ROB` must be reformulated at the same time to explicitly exclude functional correctness — and this reformulation is not included in the main proposal (Alternative A).

2. **The real firmware cases listed in the dossier (NFC without losing bits, SubGHz deserialization without truncation, `flipper_migrate_files()`, slot persistence) are simultaneously problems of `ROB` *and* of the proposed `COR`, so at runtime the assigned council members would compete over the same sub-question.** Concrete example: for "deserialization of the SubGHz keystore without truncation", the `ROB` council member legitimately asks "which invariant remains verifiable: preserved length, valid checksum, intact structure?" — and the `COR` council member asks "is the functional result correct, without loss of bits?". These two questions are the same question with different labels. The dossier does not present a single case where `COR` would produce a critique that `ROB` would not also produce, which is the definitive test for non-orthogonality. This violates the catalog's implicit principle: each angle must illuminate a dimension that no other angle illuminates.

3. **Alternative C makes the overlap explicit (it admits that correctness is a sub-property of robustness in the Lamport/Lynch literature) and Alternative A replicates it without admitting it.** The dossier itself acknowledges in C that "robustness in the broad sense historically includes correctness". If the formal literature treats correctness as a subset of robustness, separating `COR` from `ROB` as co-equal catalog angles inverts the conceptual hierarchy and creates an inconsistent taxonomy. Future council members, without access to this dossier, will read only the catalog and see two angles that overlap without clear guidance on which applies when. The "firmware architecture decisions" criterion of `ORT` and the implicit "I/O and parsing" criterion of `COR` will clash in any architectural decision touching parsing/serialization — frequent in this firmware.

## Risks detected from my angle

- **Risk of covert double assignment.** If the master assigns `ROB` and `COR` to the same trio (which is structurally legitimate under Alternative A), the two council members will produce near-identical verdicts on the same property, reducing the effective Council to 2 independent voices instead of 3. Rule D21 (2-of-3 YES) is affected because two correlated votes count as one informative vote. This degrades the Council's anti-bias mechanism without the master noticing.

- **Risk of taxonomic erosion of the closed catalog.** Once an angle is admitted whose distinction from an existing one requires a clarifying paragraph not written in the catalog, a precedent is opened: future wildcards will be able to argue "we already have `COR` separate from `ROB`, so this sub-distinction also deserves its own angle". The closed catalog (D18) protects precisely against this dynamic. The integrity of the "extension only via human PR" rule depends on every new angle added being unambiguously orthogonal to all previous ones.

- **Risk of raised selection cost for the master.** Going from 12 to 13 angles is not a minor arithmetic growth when two of them share a fuzzy boundary. The master, when choosing 3 angles per session, will have to invest additional reasoning at every convocation on "is this `ROB`, `COR`, or both?". This cognitive cost is exactly the bias the closed catalog is meant to bound (D18 — "more options to choose from means more room for master bias"). The dossier acknowledges this trade-off in Alternative A but does not resolve it.

## Vote
YES-WITH-CONDITIONS

## Conditions (only if YES-WITH-CONDITIONS)

- **Condition 1: Mandatory and simultaneous reformulation of `ROB` to exclude functional correctness.** In the same PR that introduces `COR`, the `ROB` entry in `.claude/design/council-angles.md` must be changed to something like: "Which *structural invariant* of the system (lifecycle, state, failure recovery, error handling) remains verifiable after this change? *Does not cover correctness of the functional result — see `COR`.*". Without this explicit, co-published reformulation, the two angles overlap by construction and the vote turns into a NO.

- **Condition 2: The `COR` entry must include a "Not applicable when" field that clearly delimits what belongs to `ROB`.** Suggested text: "Not applicable when the question is resource lifecycle, failure recovery, structural error handling, or state invariants — those cases are `ROB`. `COR` applies only to input→output transformations where the success criterion is the content of the output." This forces verifiable operational disjunction.

- **Condition 3: The catalog change history (final section of `council-angles.md`) must explicitly document the date, the `council_id` of this Council session, and the justification for the `ROB`/`COR` split, so that a future council member can reconstruct the intent without access to the dossier. The longitudinal traceability (which the document is careful to maintain with "stable IDs so logs stay parseable") requires this documentation.

- **Condition 4: Before the next Council convocation that could involve `COR`, the master must verify that the `.claude/scripts/check-irreversibility.sh` script (if it has angle-disambiguation logic) or any routing doc reflects the new delimitation. If no such script exists for angles, this condition is informative: the human-in-the-loop master must internalize the boundary before delegating.
