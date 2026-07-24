---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-3
angulo: MNT
ronda: 2
timestamp: 2026-05-23T18:48:00Z
---

# Council Member 3's vote on the synthesis — round 2

## Vote
YES-WITH-NEW-CONDITIONS

## Reasons (maximum 3, brief)

1. **The three MNT conditions from round 1 are incorporated faithfully.** The reformulated operational key question ("is there a concrete input case where the output differs from the expected one by ≥1 bit/byte/record?") is mechanically instrumentable: a yes/no predicate on the existence of a concrete counterexample. The rail restricted to comparable bit-by-bit/byte-by-byte operations eliminates the overlap with `ROB` I flagged in round 1 (deserialization with an expected value vs. asserting a property with no counterexample). The frozen history entry combats retroactive drift.

2. **The 3-month empirical withdrawal clause is a net positive addition from MNT**, not debt. A single bounded measurement of the usage ratio acts as a safety valve against the two scenarios I warned about in round 1 (over/underuse of the angle by a future master). The maintenance cost is bounded and proportional to the closed catalog's exit cost.

3. **A weak operational link remains**: the synthesis does not specify *who* performs the 3-month measurement, *what numeric threshold* triggers the withdrawal proposal, nor *where* the result is logged. Without owner, threshold, and data sink, the clause risks going orphaned — exactly the anti-MNT pattern the "Catalog change history" section was designed to prevent. That is why I vote with new conditions, not a clean YES.

## New conditions (only if YES-WITH-NEW-CONDITIONS)

- **New condition 1 (owner and sink for the 3-month measurement)**: The empirical withdrawal clause must specify (a) that the `agent-architect` is responsible for performing the measurement on the date `history_entry_date + 3 months` counted from the angle's approval entry; (b) that the result is logged as an **additional entry in the "Catalog change history"** of `council-angles.md` with the format `{date, origin_council_id, observed_invocations, decision: keep | withdraw | reevaluate-at-6m}`, even if the decision is to keep it unchanged. Without this entry, the measurement does not exist operationally and the catalog loses its longitudinal traceability property.

- **New condition 2 (minimum invocation threshold frozen ex ante)**: The synthesis must set a concrete numeric threshold that triggers the withdrawal proposal — proposal: *"fewer than 2 real `COR` invocations in a 3-month window counted from approval"*. Without a threshold fixed *ex ante*, the future architect will have to re-deliberate what counts as "low usage" and the clause becomes interpretive — exactly what round 1 sought to avoid for the angle's own definition. The threshold must be frozen in the same history entry as the angle's definition, so that it is unmodifiable without a new changelog entry.
