---
description: Lists the ad-hoc Council wildcards that have not yet been promoted to the closed catalog of angles. Useful for deciding whether a recurring wildcard deserves to be formalized as a stable angle. User opt-in, not scheduled.
---

# Flipper Review Wildcards

You have been invoked via `/flipper-review-wildcards`. The user wants to review the wildcard angles that the master has used in Council convenings.

## Procedure

1. **Read `.claude/state/wildcards.jsonl`** (gitignored). Each line contains:
   - `timestamp`
   - `council_id`
   - `wildcard_id` (typically `WILD-<timestamp>`)
   - `description`: name of the ad-hoc angle
   - `justification`: 3-5 lines explaining why the 12 catalog angles didn't apply
2. **Group the wildcards by similar semantic description** (not by ID — each wildcard has a unique ID but they may deal with the same conceptual angle using different wording).
3. **Present the user with a table**:

   | Description (grouped) | Occurrences | Council IDs | Representative justifications |
   |------------------------|-------------|-------------|--------------------------------|
   | ... | N | [...] | [...] |

4. **Recommend to the user**:
   - Wildcards with **3 or more occurrences**: candidates for promotion to the catalog. Suggest a stable ID (3 uppercase letters) and propose an entry in `.claude/design/council-angles.md`.
   - Wildcards with 1-2 occurrences: leave as is — they may be legitimate atypical cases that don't need formalization.
5. **Do not promote to the catalog without user approval**. The promotion is a modification of `.claude/design/council-angles.md`, which matches G3 #2 → requires L3. The process is:
   - You propose to the user which wildcards to promote.
   - The user approves.
   - You convene the Council (L3) on "adding angle X to the catalog" — the Council decides whether the promotion proceeds.
   - After 2-of-3 YES and human approval, the catalog is modified via PR.

## If the file is empty or does not exist

Report to the user: "No wildcards registered. This means the master hasn't needed to step outside the 12-angle catalog in Council convenings. Possibilities: (a) the catalog covers real cases well; (b) the master is avoiding wildcards out of inertia. I suggest reviewing the last N councils to see whether the angle choice was always from the catalog."
