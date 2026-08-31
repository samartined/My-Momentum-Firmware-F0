---
id: ADR-0002
title: Refound the fork on top of upstream + inbound sync via PAT
status: accepted
date: 2026-07-24
decision-level: L4
council-id: null
dossier: null
synthetic: false
materialization-status: materialized
materialization-date: 2026-07-24
materialization-files:
  - my-momentum-firmware (branch refounded on upstream/dev; repo default)
  - legacy/snapshot-2026-02 (archive of the old fork)
  - custom/ghostesp-s2/ (GhostESP binaries + helper)
  - .github/workflows/sync-upstream.yml (inbound sync via PAT)
---

# ADR-0002 — Refound the fork on top of upstream + inbound sync via PAT

## Status

`accepted` — an operational decision at level **L4** (direct user approval; no Council). Materialized on 2026-07-24. Involves irreversible operations (rewriting the default branch, force-push, deleting remote branches) → matches G3; proceeded via explicit human approval step by step (D21's direct-escalation route).

## Context

The user's goal: keep their personal fork up to date with the official `Next-Flip/Momentum-Firmware` firmware and be able to work from Claude Code Cloud. While building a sync workflow it was discovered that **the fork shared no git history with upstream**: `my-momentum-firmware` was a **flattened snapshot** (~Feb 2026), only 16 commits, with no common ancestor with `upstream/dev`, and with submodules (mbedtls, FreeRTOS, nanopb, stm32wb…), `build/`, `toolchain/`, and `__pycache__` versioned as flat files. Consequence: any merge/PR with upstream was infeasible (unrelated histories).

Analysis of the actual customization: `ghost_esp` and `esp_flasher` are STANDARD official apps (they live in the `applications/external` submodule → `Next-Flip/Momentum-Apps`). The ONLY genuine customization was 3 GhostESP ESP32-S2 firmware binaries added to `esp_flasher`'s resources, absent from the official repo.

## Alternatives considered

**Decision A — how to make the fork syncable:**
1. **Refound on the real upstream history (chosen).** New branch based on `upstream/dev` + customizations reapplied on top. Gives shared history → clean sync.
   - Trade-off: rewrites the default branch (irreversible); requires reapplying customizations.
2. Keep snapshots (copy upstream files without a git merge). Ugly, no git benefits, manual conflicts.
3. Change nothing. Fails to meet the sync goal.

**Decision B — final naming:** instead of leaving `-rebased` as the default (rejected by the user), rename: the old `my-momentum-firmware` → `legacy/snapshot-2026-02`; `my-momentum-firmware-rebased` → `my-momentum-firmware` (takes the canonical name); set as default. The old one is kept as an archive.

**Decision C — sync workflow authentication:**
1. **PAT (`SYNC_PAT`) for push + PR (chosen).** Robust.
2. `GITHUB_TOKEN` only. Rejected: the bot cannot push changes to `.github/workflows/*` (no `workflows` scope exists) → the sync would break as soon as upstream touched workflows.
3. Mirror + manual PR (one click, no secrets). Rejected because the mirror push would still depend on `GITHUB_TOKEN` and would hit the same latent bug.

## Decision

Refound the fork on `upstream/dev` in a new branch, rename it so the clean default is called `my-momentum-firmware`, archive the old one as `legacy/snapshot-2026-02`, preserve the GhostESP binaries in `custom/ghostesp-s2/` (outside the submodule), and sync with upstream via an inbound workflow authenticated with a fine-grained PAT (`SYNC_PAT`).

## Council votes

N/A — L4 decision (direct user approval, no Council). Each irreversible step (push, default-branch rename, deletion of test branches, flashing) was confirmed explicitly with the user.

## Consequences

**Positive:**
- Fork is genuinely syncable with the official repo (shared history; mergeable PRs — verified: a test PR came back MERGEABLE with 253 commits).
- ~35,000 bloat files removed (flattened submodules, build/, toolchain/).
- Working from the cloud is viable; the GhostESP customization is preserved and validated on hardware.

**Negative / assumed risks:**
- The default branch was rewritten (irreversible); mitigated by keeping `legacy/snapshot-2026-02`.
- The PAT is a credential; mitigated with a minimal fine-grained scope (one repo) and an expiration date.
- The full push+PR sync path hasn't been exercised with a real delta yet (smoke test only).

**Reversibility:** matches G3. The old history is recoverable from `legacy/snapshot-2026-02`. The PAT can be revoked on github.com.

## Follow-ups

- Exercise the full sync (push+PR) on the next real upstream delta; add a compare-URL fallback if PR creation fails.
- Phase 2 of the agent system (4 specialists + docs) is still pending.
- Adversarial verification of the `createPullRequest` failure's root cause documented: the PR setting being OFF by default + propagation latency; the latent workflow-push bug → the real reason for the PAT.

---

## Amendment 2026-08-31 — follow-up outcomes and a corrected root cause

The decision itself stands. This section resolves two follow-ups and **corrects a
factual claim recorded in the third**, which was wrong. The original text above is
left intact on purpose: the wrong diagnosis is part of the record and the reason
this amendment exists.

### Resolved: the full push+PR path has now been exercised

Closes the first follow-up and retires the assumed risk "the full push+PR sync
path hasn't been exercised with a real delta yet (smoke test only)".

Run 11 of `sync-upstream.yml` (`workflow_dispatch`, 2026-08-31 12:34Z) completed all
8 steps, opened PR #15 from `sync/upstream-dev`, and the operator merged it as
`639cdd8` with a real merge commit. It carried 4 upstream commits (`25a10b1` NFC
Type 4 Tag, `b8757a5` GUI FileBrowser RAM, `757cca0` Archive cursor, `d3f89df` ESP
Flasher + Marauder 1.14.3). `Guard: deliberately-removed upstream files` ran on that
PR and passed, which also confirms a user identity opened it — a bot-created PR does
not trigger other workflows.

### Resolved: the compare-URL fallback exists

Also part of the first follow-up. Implemented in PR #14 (`e7f3f64`): when PR creation
fails, the step now emits the compare URL plus an explicit statement that the commits
are already safe on the mirror branch, so the failure reads as "no PR opened" rather
than "sync lost".

### CORRECTED: the recorded root cause of the `createPullRequest` failure is wrong

The third follow-up records, as adversarially verified, that the cause was "the PR
setting being OFF by default + propagation latency". **That explanation does not
hold.** It was never latency: the failure persisted unchanged for over a month.

What actually happened: `gh pr create` uses the GraphQL `createPullRequest` mutation,
and a fine-grained PAT is refused on that mutation even when it holds
`pull_requests=write`. Runs 7 (2026-08-10), 8 (08-17), 9 (08-24) and 10 (08-31)
failed byte-identically with:

```
pull request create failed: GraphQL: Resource not accessible
by personal access token (createPullRequest)
```

Decisive evidence: a REST probe of the same endpoint with `head` deliberately equal
to `base`, so nothing could be created, returned **422** (payload rejected at
validation) — not 403 — together with `x-accepted-github-permissions:
pull_requests=write`. The token was authorized all along; only the transport was
wrong. Switching both pull-request calls to the REST endpoints (PR #14) made the
next run open a PR on the first attempt.

The repo-setting explanation applies only to **run 1** (2026-07-24), whose error was
a *different* string — `Resource not accessible by integration`, i.e. the bot token,
gated on *Allow GitHub Actions to create and approve pull requests*. Conflating the
two errors is what sent the diagnosis down the wrong path: the PAT was adopted to
dodge run 1's gate and silently inherited a second, unrelated blocker.

Why it went unnoticed for a month: runs 4 (07-24), 5 (07-27) and 6 (08-03) all
reported success while **skipping the PR step entirely**, because upstream had no new
commits those weeks. The run intended to validate the PAT was itself one of those
no-ops, so three green checkmarks certified nothing. `sync-upstream.yml` now carries a
preflight step that probes PR-create capability on every run precisely so a latent
token or transport problem cannot hide behind an idle week again.

### Narrowed: "Decision C — PAT for push + PR (chosen). Robust."

Half of that claim was sound and half was never true. The PAT is genuinely required
for the **push**, and the stated reason survives intact: `GITHUB_TOKEN` cannot push
changes under `.github/workflows/*`, and the upstream mirror contains such files. For
**PR creation** the PAT was not robust — it never succeeded once via `gh pr create`.
A dual-token fallback was considered when the cause was still unknown and was
deliberately dropped: a PR opened by `GITHUB_TOKEN` does not trigger other workflows,
which would silently forfeit the `AGENTS.md` guard on exactly the PRs that need it.
