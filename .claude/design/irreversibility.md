# List of irreversible operations

This document is the closed list of operations considered "irreversible" by the agent system. Any operation that matches one of the patterns described here automatically triggers L3 classification (Tripartite Council) and disables L1 (master alone) and L2 (`/devils-advocate`).

Council resolution: D19.

## Matching pattern

- Matching is scripted (regex over the command or operation that the master proposes to execute). The *verdict* is deterministic; **running the script is a convention the master follows**, not something the harness compels. See `system-design.md` → "Deliberation levels L1-L4" for the precise split.
- The script lives at `.claude/scripts/check-irreversibility.sh` (created in Phase 1).
- **The script's exit codes are inverted relative to normal shell semantics**: `0` = MATCHED (a G3 hit), `1` = no match, `2` = usage error. Any wrapper must capture the code explicitly and branch on it; `if check-irreversibility.sh …; then` reads as "allow" when it means "blocked" and produces a perfectly inverted guardrail. `set -e` in a wrapper is likewise forbidden, because exit `1` is a normal answer, not a failure. Note that `.claude/scripts/check-git-checkout-clean.sh`, in the same directory, uses the **opposite** convention (`0` = allow), so the two are not interchangeable templates.
- If the script reports a positive match, the master must convene the Council (L3) or escalate to the user (L4); it cannot decide alone (L1) nor invoke `/devils-advocate` (L2).
- Extending the list: via human PR. Adding patterns at runtime is not allowed.

### Path-shaped vs command-shaped entries

The list mixes two kinds of pattern, and the distinction is a **permanent property of the list**, not a temporary gap:

| Kind | Entries | Can a path matcher enforce it? |
|---|---|---|
| Path-shaped | IRREV-2, 4, 5, 6, 9, 10 | Yes — these fire on a file path. |
| Command-shaped | IRREV-1 (`git push --force`), IRREV-3 (`rm -r`), IRREV-7 (`./fbt flash`), IRREV-8 (`Next-Flip/`) | **No.** They describe shell commands. A mechanism that inspects file paths can never enforce them. |

Consequences to keep in mind before anyone tries to mechanize this list again:

- The command-shaped entries are covered by other layers: `permissions.ask` in `settings.json` (push, `rm -rf`, flash, `reset --hard`) and the `.githooks/pre-push` hook (IRREV-8).
- Feeding a bare file path to the matcher can produce **spurious** command-shaped hits, because matching is by substring: a file named `notes/git push --force.md` trips IRREV-1, and a directory named `Next-Flip/` trips IRREV-8.
- Substring matching also means an **enclosing directory** can trip a path entry. A clone placed under any directory named `furi` or `targets` makes IRREV-4 fire on every file in the repo. Path-structural rules (`permissions.ask` globs) do not have this defect; a substring matcher does.
- **IRREV-4 is not mechanizable as a blocking rule.** Its own text says "with additional analysis", and it matches **246 tracked files** (`targets/` + `furi/`), of which 227 are `.c`/`.h` ordinary firmware sources and **8 are provably spurious** — `applications/debug/unit_tests/tests/furi/furi_*_test.c`, unit tests with zero ABI impact, caught only because their path contains `furi/`. Mechanizing it would put 92% of the protected surface on ordinary development work. The entry stays in the list as a judgment trigger for the master; it is deliberately **not** wired into `permissions.ask`. This is a decision not to mechanize a pattern, **not** a narrowing of the list under "Narrowing or removing a pattern" — the G3 obligation on an ABI-relevant change is unchanged.

## Closed list (10 entries)

| # | Operation | Regex pattern (indicative) | Reason |
|---|-----------|----------------------------|-------|
| 1 | `git push --force` or rewriting published history | `git\s+push\s+.*--force` or `git\s+push\s+-f` | Unrecoverable loss of remote history. |
| 2 | Modification or deletion of files in `.claude/design/` | path matches `\.claude/design/.*` | Self-modification of the agent system. |
| 3 | Deletion of versioned files with no obvious backup equivalent | `rm\s+.*` on versioned paths | Loss without traceability. |
| 4 | Change in `targets/` or `furi/` that affects ABI or firmware memory layout | path matches `targets/.*` or `furi/.*` (with additional analysis) | Breaks deployed binaries. |
| 5 | Creation or deletion of a subagent | path matches `\.claude/agents/.*\.[mM][dD]` | Delta over the registry, affects routing. Covers the whole directory at directory granularity (`CLAUDE.md` → "Operations that require human approval"), `REGISTRY.md` included: the ledger is the reason for the entry, not collateral. The extension is matched case-insensitively so that `evil.MD` cannot slip through. |
| 6 | Modification of hooks or `settings.json` that alters permission policy | path matches `\.claude/settings\.json` or `\.githooks/.*` | Changes the security model. |
| 7 | Flashing the physical Flipper device (bootloader, fuses, secure region) | `./fbt flash.*` or `dfu-util.*` | Potential hardware brick. |
| 8 | Push to the `Next-Flip/Momentum-Firmware` remote | URL matches `Next-Flip/` | Exposes code to the blocked official repo. |
| 9 | Deletion or tampering with audit state (`.claude/state/*.jsonl`, `*.json`) | path matches `\.claude/state/.*\.(jsonl\|json)` | Destroys system observability. Covers `counters.json` as well as the JSONL logs: `counters.json` is the accounting substrate for D13 graduation and the D17 cap, it is gitignored (no history to detect tampering against), and forging `invocation_count` would fabricate a graduation to `status: stable`. |
| 10 | Modification of the enforcement layer itself (`CLAUDE.md`, `.claude/scripts/`, `.claude/hooks/`) | path matches `(CLAUDE\.md\|\.claude/scripts/\|\.claude/hooks/)` | The layer that enforces this list was not protecting itself: the master's own instructions, the matcher script, and the hooks could be edited at L1, which would let the system silently disable its own guardrail. Closes the self-protection gap. |

## Extending the list

To add a new entry:

1. Open a PR to the personal fork modifying this file and `.claude/scripts/check-irreversibility.sh`.
2. The PR's justification must include a concrete incident or identified risk, not generic hypotheses.
3. The PR goes through the Council (L3) before merging.

## Narrowing or removing a pattern

Loosening is **not** the mirror image of tightening, and it does not inherit the
procedure above. The system's constrained party — the master, an agent — is the
one that experiences a guardrail as friction, so it is also the party most likely
to propose exempting itself. Any relaxation therefore carries a structural
conflict of interest and needs a higher bar than an addition, not the same one.

Requirements, all of them:

1. **Measured harm, not anticipated friction.** A logged incident in which the
   pattern fired, blocked a legitimate operation, and the block caused real cost.
   Count the occurrences in git history before proposing: if the exemption would
   have saved zero deliberations to date, the case is closed with no further
   discussion.
2. **Verify the premise against the code**, never against the design docs. A
   stale document is a reason to fix the document, not to weaken a guardrail
   until it agrees with the document.
3. **Standalone deliberation.** A relaxation is never bundled into a larger
   approval. Riding one inside a "planned deliverable" approval launders it
   through legitimacy the relaxation itself does not have. L3 minimum; L4 when
   the change touches the enforcement layer (IRREV-10).
4. **Exact mechanism reviewed.** Note that G3 membership is binary — a match
   forces L3/L4, a non-match drops to L1 — so there is no intermediate setting
   to aim for. Any "narrowing" moves the path straight to "an agent alone,
   silently". Character-class narrowings in particular tend to exempt an
   unbounded set by accident (see Entry 1 below); prefer an exact-equality
   allow-list evaluated after the match, which requires a human PR per file.
5. **Negative lookahead is forbidden here.** Bash ERE (`[[ =~ ]]`) does not
   support it and **fails silently**: the pattern stops matching what it should
   and starts matching the literal lookahead text, disabling the entry rather
   than raising an error.

## Extension history

### Entry 1 — 2026-07-25 — Self-protection of the enforcement layer

Triggered by an inventory of the system before Phase 2, which found the
enforcement layer unprotected and one entry's coverage narrower than its stated
reason. Deliberation: **L4** (direct operator approval; the change edits
`.claude/design/`, `.claude/scripts/` and `CLAUDE.md`, i.e. the enforcement layer
amending itself, which should terminate at the human rather than at three
instances of the system).

Changes, all of them tightenings:

- **Added IRREV-10**: `CLAUDE.md`, `.claude/scripts/`, `.claude/hooks/`. Verified
  gap: `check-irreversibility.sh "CLAUDE.md"` returned no match, so the master's
  own instruction file and the matcher script could be edited at L1.
- **Widened IRREV-9** from `*.jsonl` to `*.jsonl|*.json`. Verified gap:
  `.claude/state/counters.json` matched nothing, and neither did
  `rm .claude/state/counters.json` (IRREV-3 requires `-r`/`-f`).
- **IRREV-5 made case-insensitive on the extension.** Verified evasion:
  `.claude/agents/evil.MD` did not match the previous pattern.

Rejected in the same review, recorded so it is not re-proposed without new
evidence: **exempting `REGISTRY.md` from IRREV-5.** The proposal came from the
master and was refuted on five independent grounds. (a) The stated reason for
IRREV-5 is "delta over the registry, affects routing" — the ledger is the point
of the entry. (b) `CLAUDE.md` states the policy at directory granularity, so the
pattern under-matches rather than over-matches. (c) `agent-architect.md` assigns
`REGISTRY.md` to the human ("do NOT touch `REGISTRY.md`"); the exemption would
have made it agent-writable at L1. (d) The friction premise was false: the
`SubagentStop` hook writes only to `.claude/state/counters.json`, never to the
ledger, so the recurring-edit scenario cannot occur. The premise came from a
stale paragraph in `system-design.md`, corrected in the same act. (e) Measured
benefit was zero: `REGISTRY.md` has been edited twice in the system's history
(`b4c117e`, `9f36957`) and both commits also touched agent definition files, so
IRREV-5 fired regardless. The obvious lookahead-free implementation
(`[a-z0-9-]+`) was tested and would have exempted `Flipper-Evil.md` and
`AGENT_evil.md` from Council review — a strictly worse hole than the non-problem
it solved.

Operative principle recorded so it is not re-litigated: **a G3 approval
authorizes a change set, not a single file.** Ledger rows that accompany an
approved agent creation need no separate deliberation, which removes the only
real motivation the exemption ever had.

Known debt left open on purpose (operator decision, 2026-07-25): the matcher is
still **advisory, not mechanical**. `check-irreversibility.sh` is referenced only
in `settings.json` under `permissions.allow` (permission to run it, not
invocation), and no hook fires on `Edit`/`Write` against a protected path, so
`system-design.md`'s claim that the invariant is "structural, not by convention"
remains false as implemented. Wiring the matcher to a `PreToolUse` hook was
scoped out of this act because it changes daily ergonomics and carries a
self-lockout risk; it needs its own design and validation.
