# Agent system changelog

This document records changes to the Claude multi-agent system for this repo (`.claude/**`, `CLAUDE.md`). It does NOT document changes to the Flipper Zero firmware itself — those go in the firmware's CHANGELOG.md.

Format based on Keep-a-Changelog. Dates in YYYY-MM-DD format.

---

## [0.1.11] — 2026-07-25

Pays the debt left open by 0.1.10 — the G3 matcher was advisory, not mechanical —
but **not** in the way originally proposed. The master's design for a blocking
`PreToolUse` hook was rejected by adversarial review and replaced with native
permission rules.

### Added

- **11 path-scoped `Edit(...)` rules in `permissions.ask`** (`settings.json`),
  covering `CLAUDE.md`, `.claude/design/`, `.claude/agents/`, `.claude/scripts/`,
  `.claude/hooks/`, `.claude/commands/`, `.claude/skills/`, both settings files,
  `.claude/state/`, `.githooks/`. A write to any of them now prompts the operator.
  This is the mechanical component the system previously claimed to have.
  - Spelled `Edit(...)` deliberately: verified against the docs, a single
    `Edit(path)` rule governs the `Edit`, `Write` **and** `NotebookEdit` tools,
    whereas `Write(path)` / `NotebookEdit(path)` / `Glob(path)` rules are
    *accepted but never matched* and emit startup warnings.
  - Leading single slash anchors at the settings source (the project root), not
    the filesystem root — so `Edit(/.claude/design/**)` is correct and
    path-structural, which avoids the enclosing-directory false positives a
    substring matcher suffers.
- Sections in `irreversibility.md` recording two properties that cost real effort
  to rediscover: the matcher's **inverted exit codes** (0 = matched), including the
  fact that the sibling helper `check-git-checkout-clean.sh` uses the opposite
  convention so the two are not interchangeable templates; and the **path-shaped
  vs command-shaped** split, with the consequence that IRREV-1/3/7/8 can never be
  enforced by a path matcher. A prominent warning block was added to the script's
  own header.

### Changed

- **`IRREV-6` extended to `.claude/settings.local.json`.** Verified hole, and the
  most serious one found: that file has *higher precedence* than the protected
  `settings.json`, so a single `Write` of `{"disableAllHooks": true}` switched off
  every hook — using the very tool a hook would be watching, with no shell
  redirection needed.
- **`IRREV-10` extended to `.claude/commands/` and `.claude/skills/`**, and
  reframed from "the enforcement layer" to "the layer governing the master's
  behaviour". `.claude/commands/flipper-quick.md` is the file that tells the master
  when it may skip the Council: the rule for bypassing deliberation was itself
  editable without deliberation.
- **`system-design.md`: four false claims corrected** (D19, and the three
  narrative assertions that the invariant is "structural, not by convention" /
  "not dependent on its discipline" / "structurally disables L1/L2"). These are
  claims about *classification*, which no write-time mechanism can make true.
  Replaced with the three-part split: the verdict is deterministic, invocation is
  a convention, the permission layer is the mechanical part.
- `CLAUDE.md`: approval list updated with the three newly covered paths, plus an
  explicit instruction not to restate the "structural" claim.
- **`RESUME-phase2-bootstrap.md` continuity data refreshed** (the plan itself was
  left intact — it is still valid). It had gone two months stale and named
  `my-momentum/feature/multi-agent-system-v1` as the current branch: that branch is
  anchored to the pre-refounding orphan history, so a fresh session reading the
  document in good faith would have started Phase 2 disconnected from upstream.
  Also: the three open decisions are marked resolved (direct creation, L4,
  build-fbt → app-builder → nfc → rf-subghz); the `7a8a91f2` hash and `0.1.5`
  version check were replaced with commands that verify state rather than assert
  it; the new G3 surface is described, including that `.claude/docs/` is
  deliberately unprotected so the 4 curated docs stay L1; and the document's own
  incorrect claim that updating `REGISTRY.md` is a Phase 2 done criterion is
  corrected to Phase-1.B debt.

### Removed

- **`Bash(find:*)` from `permissions.allow`.** `find … -exec sh -c '…' \;` is
  unconditional arbitrary code execution, auto-approved. No mechanism scoped to
  `Edit`/`Write` can be called enforcement while that line exists. `Glob` and
  `Grep` are the dedicated tools for the legitimate use and remain allowed.

### Rejected (the original proposal)

- **A blocking `PreToolUse` hook returning `exit 2` on a G3 match.** Designed by
  the master, contrasted by an adversarial reviewer, and ranked *below doing
  nothing*. Six independent defects, all verified:
  1. **The core safety claim was unfounded.** The design asserted a hook failure
     fails open. The default `command`-hook timeout is **600 s**, and what happens
     when it is exceeded is **not documented at all** — two independent reviews
     reached opposite conclusions. Building a guardrail on an undocumented failure
     mode, with a 10-minute worst case on every file edit, is not acceptable.
  2. **`ask` and `deny` were both unusable**: hook-returned `ask` has undocumented
     behaviour under `-p`, and `deny` blocks even in `bypassPermissions` mode and
     with `--dangerously-skip-permissions`, so a buggy `deny` is unescapable.
  3. **One unmatched `Write` disabled it** — the `settings.local.json` hole above.
  4. **Two of three natural implementations invert the guardrail**, because of the
     inverted exit codes plus a sibling template using the opposite convention.
     The `set -e` variant is permanently inert *and silent*.
  5. **92% false-friction surface.** Mechanizing IRREV-4 would protect 246 tracked
     files, 227 of them ordinary `.c`/`.h` firmware sources and 8 provably
     spurious (`applications/debug/unit_tests/tests/furi/furi_*_test.c` — unit
     tests, zero ABI impact, caught only because their path contains `furi/`).
     Governance surface without IRREV-4: **21 files**, touched in 5 of 263 commits.
  6. **It would have taught the bypass 7–11 times during Phase 2**, since each
     blocked write is answered by one `cat >` line, and it contradicts the
     change-set principle recorded in 0.1.10 once per file.

### Deliberation

Level **L4** (direct operator approval), in two commits: correcting the record
first, then the mechanism. Matches `IRREV-2`, `IRREV-6` and `IRREV-10`. The design
was submitted to an adversarial reviewer before implementation at the operator's
explicit instruction, and the review changed the outcome from "build a hook" to
"do not build it".

### Verification

`settings.json` valid JSON; 11 `Edit(...)` rules present; zero rules in the
never-matched `Write(...)`/`NotebookEdit(...)`/`Glob(...)` forms; `Bash(find:*)`
absent. Matcher: the three newly covered paths now match, all 10 pre-existing
entries still match, and `lib/nfc/`, `.claude/docs/`, `.claude/decisions/` still
do not. `bash -n` passes.

### Meta-learning (candidate for `system-design.md`)

**Two adversarial passes in one session, two proposals from the master defeated,
both in the direction of the master's own convenience or ambition.** In 0.1.10 it
was a guardrail relaxation resting on a stale document; here it was a guardrail
*mechanism* resting on an undocumented failure mode, whose first contact with real
work would have demonstrated its own bypass. The pattern worth institutionalising
is not "the master proposes badly" — it is that **the review only worked because it
was told to attack the framing, not merely to evaluate the options.** Both times
the decisive finding was outside the option set presented.

Second, an evidential asymmetry named by the reviewer and accepted: this repo
demands measured harm from a logged incident before *relaxing* a guardrail. The
same bar should apply before *mechanising* one. Observed incidents of a protected
file being edited without L3/L4: **zero**, across 5 commits that touched
`.claude/`. The motivation was a theoretical gap in a document, which is precisely
the kind of evidence the repo rejects in the other direction.

### Pending

- **Empirical check still owed**: confirm the `Edit(...)` `ask` rules actually fire
  in the installed version. If they do not, the advisory hook below becomes the
  primary mechanism rather than an optional complement.
- **Advisory hook, deliberately not built.** An `exit 0` hook that prints the
  IRREV verdict to the model's context on a match — no blocking, no lockout
  surface. It is the only mechanism that works when no human is present to answer
  a prompt, which is exactly the unattended case where `ask` behaviour is
  undocumented. Deferred pending the check above. If built, it must be added to
  `bootstrap.sh`'s `EXEC_FILES` in the same commit or it lands non-executable in
  every fresh clone, silently inactive.
- **`Bash(cat:*)` remains in `permissions.allow`** and is the residual write
  bypass (`cat > protected_file <<'EOF'`). Left untouched because it was not part
  of the approved scope; whether Claude Code routes shell redirections through
  file-write permission checks is unverified.
- **Duplication accepted, drift not yet detected mechanically**: the protected
  paths now exist both as regexes in the matcher and as `Edit(...)` rules in
  `settings.json`. A cross-check in `bootstrap.sh` (which is a `SessionStart` hook
  and therefore cannot be blocked) would make drift loud; not implemented.
- D17's cap of 20 agents is still documentation-only.
- Phase 2 (4 specialists + 4 curated docs) still not started.

---

## [0.1.10] — 2026-07-25

Pre-Phase-2 inventory of the system. Four misalignments found, all closed. The
substantive one: **the G3 enforcement layer did not protect itself.**

### Added

- **`IRREV-10`** in `irreversibility.md` + `check-irreversibility.sh`: covers
  `CLAUDE.md`, `.claude/scripts/`, `.claude/hooks/`. Verified gap —
  `check-irreversibility.sh "CLAUDE.md"` returned no match, so the master's own
  instruction file and the matcher script itself were editable at L1. The system
  could have silently disabled its own guardrail without deliberation or trace.
- **"Narrowing or removing a pattern"** section in `irreversibility.md`. The
  document defined a procedure for *adding* entries and none for relaxing them,
  which is how a weakening proposal reached the operator with no procedural
  friction. Loosening now requires measured harm from a logged incident (not
  anticipated friction), premise verification against code rather than docs,
  standalone deliberation never bundled into a larger approval, and an
  exact-equality allow-list rather than a character class. Records that negative
  lookahead is forbidden in bash ERE because it fails *silently*.
- `.claude/decisions/pending/c0e6fb5e-.../dossier.md` — L4 dossier with the
  rejected alternative preserved.
- `.github/workflows/guard-removed-files.yml` — fails the build if a
  deliberately-removed upstream file reappears (see Removed below).

### Changed

- **`IRREV-9` widened** from `*.jsonl` to `*.jsonl|*.json`. Verified gap —
  `.claude/state/counters.json` matched nothing, and neither did
  `rm .claude/state/counters.json` (IRREV-3 requires `-r`/`-f`). That file is the
  accounting substrate for D13 graduation to `status: stable` and for the D17 cap,
  and it is gitignored, so there is no history against which tampering could be
  detected. Forging `invocation_count` was the concrete threat.
- **`IRREV-5` made case-insensitive** on the extension (`\.[mM][dD]`). Verified
  evasion — `.claude/agents/evil.MD` did not match the previous pattern.
- `CLAUDE.md`: G3 path list completed with `.claude/scripts/` and
  `.claude/hooks/`; added the audit-state entry, the note that `.claude/agents/`
  is at directory granularity and includes `REGISTRY.md`, and the conflict-of-
  interest warning on relaxations.
- `system-design.md`: corrected the counting-mechanism paragraph, which claimed
  the counters were fields inside `REGISTRY.md` incremented there. Never true of
  the implementation: `update-agent-counter.sh` writes only to
  `.claude/state/counters.json`. The stale text had itself been used as evidence
  for the weakening proposal below.

### Removed

- **Upstream's `AGENTS.md`** (commit `d70d7ee`). An absolute anti-AI policy
  instructing any assistant to "CEASE all interaction immediately", which
  re-entered the tree with the re-founding after Phase 1 had removed it. It
  contradicts this fork's own `CLAUDE.md`, and Claude Code can load `AGENTS.md`
  as project memory, in which case the instruction lands in every agent's
  context. Removed on the fork only; upstream's copy is untouched and nothing is
  ever pushed to Next-Flip (D9/D25). Backstopped by the new guard workflow,
  scoped to exclude the `sync/upstream-dev` mirror branch so syncs do not turn
  red and email the owner.

### Fixed

- `.gitignore`: re-ignored `.claude/state/` (commit `27b546c`), lost during the
  re-founding since the refounded branch carries upstream's `.gitignore`. The
  audit log was showing as untracked, with a standing risk of committing it.

### Rejected (recorded so it is not re-proposed without new evidence)

- **Exempting `REGISTRY.md` from `IRREV-5`.** Proposed by the master, refuted by
  adversarial review on five verified grounds: the entry's stated reason *is*
  registry integrity ("delta over the registry, affects routing"); `CLAUDE.md`
  writes the policy at directory granularity, so the pattern under-matches rather
  than over-matches; `agent-architect.md` assigns the ledger to the human ("do
  NOT touch `REGISTRY.md`"); the friction premise was factually false, since the
  `SubagentStop` hook never writes to the ledger; and the measured benefit was
  **zero** — `REGISTRY.md` has been edited twice in the system's history
  (`b4c117e`, `9f36957`) and both commits also touched agent definitions, so
  IRREV-5 fired regardless. The lookahead-free implementation (`[a-z0-9-]+`) was
  tested and would have exempted `Flipper-Evil.md` and `AGENT_evil.md` from
  Council review — a worse hole than the non-problem it solved.

### Meta-learning (candidate for `system-design.md`)

**The constrained party proposing its own exemption is a structural conflict of
interest, and the mechanism caught it — but only because it was asked to.** The
master reached the operator with a weakening dressed as a bug fix, resting on a
stale doc, with a benefit that evaporated on contact with `git log`. What stopped
it was an adversarial reviewer explicitly instructed to attack the master's
framing rather than only its options. Two structural consequences applied here:
relaxations now need their own procedure and their own deliberation, and no
weakening may ride inside a bundled approval. Generalizable rule: **verify
premises against code, never against the system's own documentation** — three of
the four findings in this release were doc-vs-implementation drift.

### Deliberation

Level **L4** (direct operator approval). Matches `IRREV-2` and the new
`IRREV-10`: the enforcement layer amending itself should terminate at the human,
not at three instances of the system. Scope was set by the operator after the
adversarial review; the blocking-hook item (below) was explicitly deferred.
Logged in `.claude/state/decisions.jsonl`.

### Verification

Matcher tested on 24 inputs: 9 new closures match, all 10 pre-existing entries
still match (no regression), 5 controls still do not — including
`.claude/docs/*.md`, confirming the Phase 2 curated docs remain L1 and only the 4
agent definition files require deliberation. `bash -n` passes; both workflows
parse as YAML; the guard script exits 0 with the file absent and 1 with an
annotation when present.

### Pending

- **The matcher is still advisory, not mechanical.** `check-irreversibility.sh`
  appears only under `permissions.allow` in `settings.json` (permission to run
  it, not invocation), and no hook fires on `Edit`/`Write` against a protected
  path. So `system-design.md`'s claim that the invariant is "structural, not by
  convention" remains **false as implemented**; today it is model discipline.
  Wiring it to a `PreToolUse` hook was deferred by operator decision — it changes
  daily ergonomics and risks self-lockout, so it needs its own design.
- `REGISTRY.md` backfill of the 2 core rows: to be done inside the Phase 2 change
  set, justified as Phase-1.B debt (it is not a Phase 2 done criterion in
  `phases.md`).
- D17's cap of 20 agents is documentation-only; nothing counts agents anywhere.
- Phase 2 (4 specialists + 4 curated docs) still not started.

---

## [0.1.9] — 2026-07-24

### Fixed

- **Restored `.githooks/pre-push` + `.pre-commit-config.yaml`** on `my-momentum-firmware` (commit `b2f9e4291`). The Layer-2 push guardrail (blocks pushes to `Next-Flip/*`) had been dropped during the re-founding, leaving it inactive on the default branch. Restored with logic byte-identical to the original (same regex, override var `MOMENTUM_ALLOW_NEXT_FLIP_PUSH`, exit codes); comments/messages in English per the language policy. Verified: `bootstrap.sh` sets `core.hooksPath .githooks`, hook present/executable/tracked, blocks Next-Flip / allows the fork / respects the override. Layer 2 active again.

### Changed

- **Disabled the inherited Momentum `Webhook` workflow** (`gh workflow disable`, state `disabled_manually`, no commit). It is Momentum's Discord notification bot (`webhook.py`, needs `BUILD_WEBHOOK`/`DEV_WEBHOOK` secrets that the fork lacks) and failed on every push, emailing the owner (~21 failure emails accumulated). The `disabled_manually` state is GitHub-side metadata separate from the file and persists across upstream syncs that update `webhook.yml`. `Build` and `Lint` kept active as real CI. Reversible via `gh workflow enable "Webhook"`.

### Note

- Orphaned `advtest-pr-probe*` workflow entries remain visible (from the adversarial PR-block investigation); their branches were deleted so they cannot trigger. GitHub does not allow easy deletion of orphaned workflow entries.

---

## [0.1.8] — 2026-07-24

### Changed

- **Full corpus translated to English.** All project-authored text (`CLAUDE.md`, every `.claude/**` file, `custom/**` docs, workflow YAML comments, shell script comments) was translated Spanish → English. Done via 6 Sonnet/medium subagents that produced proposals into a separate directory; the master reviewed every proposal (no logic altered, functional tokens preserved) before applying. Verified: guardrail `check-irreversibility.sh` regex byte-identical and behavior confirmed, all scripts pass `bash -n`, YAML/JSON valid, 0 residual accented characters, all decision/angle/IRREV codes preserved. `settings.json` untouched (JSON config, no prose).

### Added

- **Language policy (mandatory)** in `CLAUDE.md` and in both agent definitions (`agent-architect`, `council-member`): everything written to disk/repo (code, comments, docs, commit messages) MUST be in English, regardless of the language used to converse with the operator. Keeps the codebase single-language and portable.

### Note

- Collateral finding (not fixed here): `.githooks/pre-push` is absent from `my-momentum-firmware` (not carried over during the re-founding), so the Layer-2 push guardrail is currently inactive on this branch. Tracked as a follow-up.

---

## [0.1.7] — 2026-07-24

### Added

- **Fork refounding on top of upstream** (see [`ADR-0002`](../decisions/ADR-0002-fork-refounding-and-pat-sync.md)): the default branch `my-momentum-firmware` now builds on the real history of `upstream/dev` (previously it was a flattened snapshot with no common ancestor with the official repo → not syncable). The old fork is kept as `legacy/snapshot-2026-02`.
- `custom/ghostesp-s2/`: GhostESP ESP32-S2 binaries (`bootloader.bin`, `partition-table.bin`, `Ghost_ESP_IDF.bin`) + `README.md` + `deploy-to-esp-flasher.sh`. The only real firmware customization, preserved outside the `applications/external` submodule.
- `.github/workflows/sync-upstream.yml`: inbound sync workflow with `Next-Flip/Momentum-Firmware@dev` (Monday 06:00 UTC schedule + manual trigger). The upstream remote lives only in the ephemeral runner → respects D9/D25.
- `.claude/design/RESUME-cloud-refounding-sync.md`: self-contained RESUME of this session for inter-session/inter-machine continuity.

### Changed

- `.github/workflows/sync-upstream.yml`: uses a PAT (`secrets.SYNC_PAT`, fine-grained: Contents+PullRequests+Workflows RW, this repo only) for the mirror push and `gh pr create`, instead of the bot's `GITHUB_TOKEN`.

### Verified (adversarial investigation)

- Root cause of the initial `createPullRequest: Resource not accessible by integration` failure: the repo setting "Allow GitHub Actions to create and approve pull requests" is OFF by default on personal accounts, plus propagation latency after enabling it. The "unresolvable inconsistency" hypothesis and the account-level cap hypothesis were both refuted (5 controlled experiments).
- **Latent bug identified and fixed:** the `GITHUB_TOKEN` cannot push changes to `.github/workflows/*` (no `workflows` scope exists); the upstream mirror includes them → this would have broken the sync. Hence the PAT.
- Refounded fork validated on hardware: `./fbt` OK, the `ghost_esp`/`esp_flasher` FAPs build, flashed to the Flipper successfully.

### Deliberation

- Level **L4** (direct user approval). Irreversible operations (rewriting the default branch, force-push, renaming, flashing) confirmed step by step. See ADR-0002.

### Pending

- Exercise the full sync (push+PR with a real delta) on the next upstream change.
- Phase 2 (specialists) still hasn't started.

---

## [0.1.6] — 2026-07-24

### Added

- `.claude/scripts/bootstrap.sh`: idempotent, dependency-free startup for the agent system. Activates the versioned git hooks via `git config core.hooksPath .githooks` (without depending on the `pre-commit` framework), grants execute permissions, and seeds `.claude/state/` (`counters.json` + `decisions.jsonl`). Contract: always `exit 0` (non-blocking hook), clean stdout on success so as not to pollute the master's context, diagnostics to stderr.
- `SessionStart` hook in `.claude/settings.json` → automatically runs `bootstrap.sh` on every session start. Since `settings.json` is versioned, bootstrap fires on its own in any fresh clone (local, Codespaces, Claude Code Cloud) without manual steps.

### Changed

- `.claude/settings.json`: added `hooks.SessionStart` (points to `bootstrap.sh`) and `Bash(./.claude/scripts/bootstrap.sh)` to `permissions.allow`.
- `.claude/scripts/setup.sh`: refactored to a "manual superset". It now delegates hook activation to `bootstrap.sh` (avoids the `core.hooksPath` vs `pre-commit install` conflict), and `pre-commit` becomes **optional** (a warning instead of `exit 3`) because the pre-push guardrail is already active via `core.hooksPath`. `bootstrap.sh` added to `EXPECTED_FILES`.

### Motivation

Prepare the project for work from Claude Code Cloud. Prior diagnosis: a fresh clone recovered all of the versioned `.claude/**` and the Claude Code hooks (they travel in `settings.json`), but **guardrail layer 2 (the `pre-push` git hook against Next-Flip) remained inactive** until `setup.sh` was run by hand — and `setup.sh` depended on `pre-commit`. Auto-bootstrap closes that gap without external dependencies.

### Deliberation

- **Level L4** (direct user approval, D21 route). The change modifies `.claude/settings.json` → matches `IRREV-6` (G3), which structurally forbids L1/L2. The user approved directly without a Council, a legitimate route for planned infrastructure. Logged in `.claude/state/decisions.jsonl`.

### Verification

- `settings.json` validated as JSON.
- `bootstrap.sh` tested as idempotent (2nd run silent, `exit 0`).
- Pre-push guardrail confirmed active via `core.hooksPath`: blocks `Next-Flip/*` URLs (`exit 1`) and allows the fork's `samartined/*` URL (`exit 0`).

---

## [0.1.5] — 2026-05-23

### Added

- `.claude/decisions/ADR-0001-add-cor-angle.md`: the system's first closed ADR. A synthetic decision for the V2 functional validation of Phase 1.G — the Tripartite Council deliberated across 3 rounds on whether to add a `COR` (Correctness) angle to the closed catalog. Result: unanimous 3/3 YES with 11 mandatory conditions (4 from synthesis + 7 new ones accepted in round 3 with no vetoes). Materialization decided by the user (option (a), 2026-05-23).
- `.claude/decisions/pending/62978df1-.../`: the Council's full artifacts (dossier, 3 round-1 verdicts, master's round-2 synthesis, 3 round-2 votes, 3 round-3 votes). Longitudinal audit documentation.
- `.claude/state/decisions.jsonl`: V2 entry with `level: "L3"`, `criterion_invoked: "IRREV-2"`, `council_id: 62978df1-...` (closing V2 of the 4 functional criteria of Phase 1.G).

### Changed

- `.claude/design/council-angles.md`:
  - Catalog of **12 → 13 active angles** (added `COR` — Correctness).
  - `ROB` reworded to explicitly exclude functional correctness and focus on structural invariants (lifecycle, state, failure recovery).
  - `COR`'s operational key question: "Is there a concrete input case where the output differs from the expected result by ≥1 bit, ≥1 byte, or ≥1 record, and that case is not covered by an existing test or invariant?".
  - New section "Operational notes for `COR`" with disjoint rail, an operational definition of "eligible for COR", and a co-invocation guard for `ROB`+`COR`.
  - New "Catalog change history" section, opened with **Entry 1**: frozen definition of `COR`, delimitation against `ROB`, empirical withdrawal clause with OR triggers (C3-N2 low usage + C1-N1 high overlap), semantic comparator (closed 7-subtopic checklist or token diff).
- `.claude/design/decisions-schema.md`: added optional field `eligible_for_cor: boolean | null` (C2-N1) so the master can flag COR-eligibility for each L3 and the 3-month audit is reproducible against the log.
- `.claude/design/phases.md`: new "Active review calendar" section with **Review 1** scheduled for `2026-08-23` (3 months out), owner `agent-architect`, triggers and sink specified.

### Closed

- **Phase 1.G functional validation V2**: the Council was exercised end-to-end with a synthetic decision matching G3 (IRREV-2 — modifies `.claude/design/`). The `check-irreversibility.sh` script structurally forced L3, the master could not degrade to L2, and the full flow (dossier → 3 parallel council members round 1 → round-2 synthesis → round-2 votes → round-3 cross-validation votes → closed ADR → decisions.jsonl log) worked.
- **Phase 1.G complete**: all 4 functional criteria (V1 L1, V2 L3, V3 G3-forced, V4 push blocked) are closed.

### Motivation

V2 was the last functional criterion of Phase 1.G still to validate. After V1, V3, and V4 passed in prior sessions, the full Council still had to be run on a decision that matched G3. The `COR` decision was designed as a synthetic exercise — its content could have been discarded after validation, but the user chose to materialize it because (a) the Momentum firmware lives mainly in bit-level I/O domains (NFC, SubGHz, RFID, IR, parsing, migrations), exactly the territory where `COR` applies; (b) the 3-month empirical withdrawal clause acts as a reversible safety net if the angle doesn't pay for itself.

### V2 meta-learnings (material for a future `system-design.md`)

- **3 Council rounds on an L3 worked**: round 1 (independence), round 2 (master's synthesis + reconsideration), round 3 (cross-validation of conditions — preserves reasoned independence by reading only conditions, not the other members' reasoning).
- **Minority vote overturned by mechanism, not by argument**: Council Member 2 (SIM) voted NO in round 1 citing YAGNI; they switched to YES in round 2 because the synthesis added the empirical withdrawal clause. The objection was incorporated into the design, not rhetorically rebutted. A replicable pattern.
- **Mid-session `Write` bug** (from a previous session): documented in RESUME.md as a precedent for inter-session continuity when the harness has occasional failures.

### Pending

- Start **Phase 2** (critical specialists: `flipper-rf-subghz`, `flipper-nfc`, `flipper-app-builder`, `flipper-build-fbt`) — awaiting explicit order from the user.
- Run **Review 1** on `2026-08-23` (3-month audit of the `COR` angle).

---

## [0.1.4] — 2026-05-20

### Changed

- `system-design.md`: annotated D2 with the canonization to `effort: max/medium` (official Claude Code frontmatter terminology).
- `system-design.md`: annotated D4 to reflect that (a) the master synthesizes but does NOT vote (meta-learning 2) and (b) the original fixed perspectives are superseded by the dynamic catalog D18.
- `system-design.md`: annotated D11 with the repeal of the "second round with shared verdicts" — replaced by the 1-of-3 YES → escalate to user rule (D21) and voting on an unanchored synthesis (meta-learning 3).
- `system-design.md`: annotated D12 with an upward revision of the total cap (15 → 20 per D17), keeping the "1 new agent per session" rule.
- `system-design.md`: "Agent roles" table updated — removed the `flipper-master` row (the master is no longer a subagent), unified the 3 rows `council-pragmatist/visionary/skeptic` into a single parametrizable `council-member` row, `Thinking` column renamed to `Effort` with values `max/medium` (canonization).
- `system-design.md`: added subsection "Closed list of core agents" inside "Agent roles" (2 core: `agent-architect` + `council-member`).
- `system-design.md`: "The Tripartite Council" section fully rewritten to reflect D18 (dynamic catalog), D27 (mandatory dossier), meta-learning 2 (master doesn't vote), meta-learning 3 (no anchored round 2), 3-round procedure (proposals → vote on synthesis → cross-validation), mandatory persistence in `.claude/decisions/pending/<id>/`.
- `system-design.md`: "Quotas" subsection of the agent-architect updated (cap 15 → 20, reference to the closed list of core agents).
- `system-design.md`: "Destructive operations and guardrails" section expanded from 3 layers to 5 (added: layer 1 two physical clones D25, layer 3 G3 list + regex script D19/D23). Added a summary table of operations covered per layer.
- `system-design.md`: "Expected file structure" updated with all new files (`.claude/state/`, `.claude/scripts/`, `.claude/skills/devils-advocate/`, `.claude/decisions/pending/`, `.githooks/`, `.pre-commit-config.yaml`, 4 design docs, 3 new commands, `council-member.md` in place of the 3 fixed ones, no `flipper-master.md`).
- `system-design.md`: added new section "Deliberation levels L1-L4" with a decision diagram, level table, mention of auditing (D20), and the G3 hard rule (D23).
- `system-design.md`: added new section "Mandatory dossier before L3" with the minimum schema, soft cap 10 / hard cap 20, discipline against contamination, and the `/flipper-reset` command.
- `phases.md` (Phase 1): removed reference to `flipper-master.md` (the master is not a subagent). Replaced the 3 fixed-council-member lines with a single parametrizable `council-member.md` line. Updated the `CLAUDE.md` line to explicitly mention the master's role as the main conversation. Updated the `settings.json` line to mention `alwaysThinkingEnabled: true` (D10).

### Motivation

The personal review of the files produced by the Sonnet agent in v0.1.3 found 14 internal inconsistencies:

- Older decisions (D2, D4, D11, D12) contradicted newer ones (D17-D27) without an annotation marking the supersession.
- Narrative sections (Council, agent-architect > Quotas, Guardrails, Agent roles, File structure) reflected the pre-Council design rather than decisions D17-D27.
- Core concepts (L1-L4 levels, mandatory dossier, list of core agents) were scattered across rows of the decisions table with no formal treatment in dedicated sections.

Without this reconciliation, a fresh reader of the document — or the master starting Phase 1 — would find a self-contradictory text and would not be able to operate coherently. The reconciliation was done manually (not delegated to a subagent) to preserve granular control over the annotations and to avoid regressions from misinterpretation.

### Pending

Only the user's explicit order to start Phase 1 (D16). After this reconciliation, the 3 documents (`system-design.md`, `phases.md`, `CHANGELOG.md`) are internally consistent with the 27 closed decisions + 4 meta-learnings.

---

## [0.1.3] — 2026-05-20

### Added

- Decisions D17-D27 in `system-design.md` ("Closed decisions" table), one for each gap closed by the Tripartite Council over 3 rounds (G1-G10 + A1).
- "Meta-learnings from the live Council" section in `system-design.md` with 4 observations derived from running the Council as a practical exercise for closing the gaps.
- `.claude/design/council-angles.md`: closed catalog of 12 Council angles with stable IDs and a wildcard rule.
- `.claude/design/irreversibility.md`: closed list of 9 irreversible operations that automatically trigger L3.
- `.claude/design/decisions-schema.md`: schema for the `.claude/state/decisions.jsonl` log + activation threshold for the auditor in Phase 2+ (L1+L2/total ratio > 0.95 with minimum window N=100).
- In `phases.md > Phase 1`: 15 new deliverables (4 design docs, 2 scripts, 2 githooks, 3 Claude Code hooks, 3 commands, 1 skill) + 4 verifiable functional "done" criteria.

### Changed

- "Model-to-role mapping" section in `system-design.md`: corrected the mistaken claim (present from v0.1.0 through v0.1.2) that subagent frontmatter had no `effort` field. After verifying against the official documentation (`code.claude.com/docs/en/subagents-and-plugins.md`), the field does exist (`low | medium | high | xhigh | max`). `effort: max` is specified for Opus and `effort: medium` for Sonnet.
- "Open points" section in `system-design.md`: updated to reflect that after D27 the system is ready for Phase 1 pending the user's explicit order (D16).

### G1-G10 + A1 resolutions (mapping to closed decisions)

- **G1** → D17 (single cap of 20 + closed list of core agents)
- **G2** → D18 (closed catalog + 1 wildcard/session + `/flipper-review-wildcards`)
- **G3** → D19 (closed 9-entry list + automatic verification script)
- **G4** → D20 (JSONL log in Phase 1, empirical auditor in Phase 2+)
- **G5** → D21 (1-of-3 YES → mandatory escalation to L4)
- **G6** → D22 (`pre-commit` framework + one-line `setup.sh`)
- **G7** → D23 (`/devils-advocate` as L2 + G3 hard rule disables L1/L2)
- **G8** → D24 (60% warning + configurable hard cap + tokens→USD table)
- **G9** → D25 (two clones + blocking hook with visible override)
- **G10** → D26 (`/flipper-redirect` + binary `out_of_scope` flag)
- **A1** → D27 (mandatory dossier + schema + soft cap 10/hard cap 20 + opt-in `/flipper-reset`)

### Motivation

After the technical verification that confirmed two structural errors in the v0.1.0 design (subagent nesting not supported by the platform; the `effort` field does exist and was unused), an architectural reformulation was carried out (master = main conversation) plus a second round of adversarial dialectics that identified 11 remaining gaps. The Tripartite Council, convened to close them, served simultaneously as (a) the mechanism for closing the gaps by unanimity and (b) a practical validation of the Council itself before productive use. The meta-learnings from the exercise are folded into the design (new section in `system-design.md`).

### Pending

Just one thing: for the user to give the explicit order to start Phase 1 (D16).

---

## [0.1.2] — 2026-05-19

### Changed

- `system-design.md`: added decisions D10–D16 to the "Closed decisions" table, corresponding to the user's resolutions of open points P1–P7.
- `system-design.md`: "Quotas" section for the architect fixed (maximum 1 new agent per session, maximum 15 total — cautious mode).
- `system-design.md`: "Experimental period" section fixed at N=5 unmodified invocations to graduate to `stable`.
- `system-design.md`: "Tripartite Council > Cost and shortcuts" section updated to reference D11 instead of marking it "pending".
- `system-design.md`: "Open points" section replaced with a closing note (all points resolved; Phase 1 starts on the user's explicit order).
- `phases.md`: "Current status" updated to reflect that Phase 0 is complete on its design component and that starting Phase 1 awaits the user's explicit order.

### P1–P7 resolutions

- **P1** → Extended thinking enabled at the project level in `.claude/settings.json` (not globally). [D10]
- **P2** → Council quorum: 2/3 normal, unanimity for destructive actions, escalate to the user if there's no 2/3 after the second round. [D11]
- **P3** → Architect quotas: 1 new/session, 15 total (cautious mode). [D12]
- **P4** → Experimental period: N=5 unmodified invocations to graduate to `stable`. [D13]
- **P5** → Permissions in `settings.json` confirmed (free builds, free non-destructive git with a caveat on `checkout` to an existing branch, destructive actions require approval, push to Next-Flip blocked by hook). [D14]
- **P6** → Shortcut commands `/flipper-quick` and `/flipper-council` confirmed. [D15]
- **P7** → Phase 1 starts on the user's explicit order, not automatically. [D16]

### Motivation

Closing the 7 open points was a requirement for the system to move past planning. The resolutions are recorded as closed, traceable decisions (D10-D16), not as scattered notes, so that any future Claude Code session can reconstruct the reasoning behind each parameter without needing the original conversation.

### Pending

Only the user's explicit order to start Phase 1. Until then, no other repo file is touched and no Phase 1 agents/configurations are created.

---

## [0.1.1] — 2026-05-19

### Changed

- `system-design.md`: added subsection "Areas not covered by a dedicated specialist" (U2F, Archive, GPIO, momentum_app) with the promotion criterion to a dedicated specialist (3 or more real tasks).
- `system-design.md`: detailed the counting mechanism for "N uses without modification" in the "Experimental period" section via the `invocation_count` and `last_modified_commit` fields in `REGISTRY.md`.
- `system-design.md`: refined open point P5 to distinguish `git checkout -b <new>` (free) from `git checkout <existing-branch>` (free only with a clean tree; requires approval otherwise).

### Motivation

Personal review of the design found three minor gaps worth closing before Phase 1:

- Firmware areas with no assigned specialist (U2F, Archive, GPIO, momentum_app) would cause ambiguous delegation by the master with no explicit coverage rule.
- "N uses without modification" for graduating experimental agents was not implementable without defining how it's counted.
- The free permission for `git checkout`, without distinguishing between creating a new branch and switching to an existing one, could allow overwriting uncommitted work.

---

## [0.1.0] — 2026-05-19

### Added

- Document `.claude/design/system-design.md` with the complete initial design of the multi-agent system: orchestrator, specialists, Tripartite Council, agent-architect with 4 layers of control, guardrails for destructive operations, model-to-role mapping.
- Document `.claude/design/phases.md` with the implementation plan across 5 phases (Phase 0 to Phase 4), per-phase "done" criteria, and the mechanism for persisting context between phases.
- This file, `.claude/design/CHANGELOG.md`.

### Motivation

We are building a multi-agent system so Claude can provide hyper-specialized assistance on the Flipper Zero Momentum firmware. The user wants:

- An orchestrator that delegates to specialists so context isn't polluted across domains (RF, NFC, BLE, app-builder, build, etc.).
- A meta-agent able to create new specialists under human control when the firmware requires it.
- A Council of 3 perspectives (Pragmatist, Visionary, Skeptic) that deliberates and votes on global decisions.
- Versioning on GitHub so the agent system evolves alongside the code.
- Strong guardrails for destructive operations (flash, push, deletion) that require explicit human approval.

This first delivery captures the design in files before starting implementation, so as not to lose context between sessions and so the system itself, once started, can recall its own design.

### Pending

7 open points to resolve with the user before moving to Phase 1 (detailed in `system-design.md` → "Open points" section). Once resolved, Phase 1 begins (minimum viable core).
