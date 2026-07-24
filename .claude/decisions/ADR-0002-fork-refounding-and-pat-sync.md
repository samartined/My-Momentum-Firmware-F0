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
