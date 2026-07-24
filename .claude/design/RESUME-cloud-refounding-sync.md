# RESUME — Cloud portability, fork refounding, and upstream sync

## Ultra-short summary

Session focused on making the fork **usable from Claude Code Cloud** and **syncable with the official firmware**. Achieved: (1) auto-bootstrap on every session start; (2) diagnosis that the fork was a snapshot with no history shared with upstream; (3) **refounding** of the fork on the real history of `upstream/dev`; (4) branch renaming so the clean default is called `my-momentum-firmware`; (5) preservation of the only real customization (GhostESP ESP32-S2 binaries); (6) validation on hardware (compiled + flashed); (7) upstream sync workflow via PR, hardened with a PAT after adversarial investigation.

This RESUME is self-contained: a new session (local or cloud) can read `CLAUDE.md` + this file and continue without any further history.

---

## Repo status (as of 2026-07-24)

### Branches (remote `origin` = `samartined/My-Momentum-Firmware-F0`, the ONLY remote)

| Branch | Role | History base |
|---|---|---|
| **`my-momentum-firmware`** (DEFAULT) | Go-forward line. Clean base from upstream + customizations. | Real history of `upstream/dev` (shares an ancestor → syncable) |
| `legacy/snapshot-2026-02` | Archive of the old fork (flattened snapshot, Feb 2026). Do NOT delete without cause. | Orphan history, unrelated to upstream |
| `sync/upstream-dev` | Mirror branch of `upstream/dev` maintained by the sync workflow. | Mirror of upstream |
| `my-momentum/feature/multi-agent-system-v1` | Historical working branch of the agent system. **Based on the old orphan history** → do NOT merge against the default. | Old history |

**IMPORTANT:** new agent-system work goes on **`my-momentum-firmware`** (the refounded default), NOT the old feature branch (which stayed anchored to the orphan history).

### Key content present on `my-momentum-firmware`

- `.claude/**` + `CLAUDE.md` — full multi-agent system.
- `.github/workflows/sync-upstream.yml` — sync workflow (see below).
- `custom/ghostesp-s2/` — GhostESP ESP32-S2 binaries (`bootloader.bin`, `partition-table.bin`, `Ghost_ESP_IDF.bin`) + `README.md` + `deploy-to-esp-flasher.sh`. This is the ONLY real firmware customization; it lives outside the `applications/external` submodule (which points to the official `Next-Flip/Momentum-Apps`).
- No `build/` or `toolchain/` under version control (uses the official structure with 14 submodules).

### Hardware validation (done)

Clean worktree + `git submodule update --init --recursive` + `./fbt` → `firmware.dfu` OK. The `ghost_esp` and `esp_flasher` FAPs build (APPCHK OK). Flashed to the Flipper with `./fbt flash_usb` successfully.
Linux host gotcha: `cdc_acm` wasn't loaded → `sudo modprobe cdc_acm` + a physical replug for `/dev/ttyACM0` to appear.

---

## Auto-bootstrap for the cloud (CHANGELOG 0.1.6)

- `SessionStart` hook in `.claude/settings.json` → runs `.claude/scripts/bootstrap.sh` on every startup.
- `bootstrap.sh` (idempotent, dependency-free): `git config core.hooksPath .githooks` (activates the pre-push guardrail without `pre-commit`), +x permissions, seeds `.claude/state/` (gitignored).
- Caveat: it's not 100% guaranteed that every headless cloud mode triggers `SessionStart`; benign degradation (run `bootstrap.sh`/`setup.sh` by hand).

---

## Upstream sync workflow (CHANGELOG 0.1.7)

File: `.github/workflows/sync-upstream.yml`. Trigger: `schedule` (Monday 06:00 UTC) + `workflow_dispatch`.

**What it does:** on an ephemeral GitHub runner it adds the `Next-Flip/Momentum-Firmware` remote (ONLY on the runner, never in the clone → respects D9/D25), runs `git fetch dev`, counts new commits vs `my-momentum-firmware`, pushes the mirror branch `sync/upstream-dev`, and opens/updates a `sync/upstream-dev → my-momentum-firmware` PR for human review. Strictly inbound direction.

**Authentication (key point):** uses a **PAT** stored as the secret **`SYNC_PAT`** (fine-grained: Contents RW + Pull requests RW + Workflows RW, this repo only) both for the `checkout` (to push the mirror) and for `gh pr create`.

**Why a PAT and not the bot's `GITHUB_TOKEN`** (result of adversarial investigation, see ADR-0002):
1. The bot cannot create PRs by default (repo setting "Allow GitHub Actions to create and approve pull requests"; was OFF by default on the personal account; already enabled now — there was propagation latency that explained the initial failures).
2. **Decisive latent bug:** the bot can NEVER push changes to `.github/workflows/*` (there is no `workflows` scope for the `GITHUB_TOKEN`). The upstream mirror includes workflow files → the bot's push would break as soon as upstream touched them. The PAT (a user identity) can.

**Verification status:** smoke test green (checkout with PAT OK, detects "up to date"). The full push+PR path with a real delta **has not been exercised yet** (the fork is at the tip of upstream → 0 new commits). It will be exercised on the next real upstream delta, or by pressing "Run workflow" once there's something new.

**Activation already done:** repo Settings → Actions → General → "Allow GitHub Actions to create and approve pull requests" enabled; `default_workflow_permissions: write`.

---

## Language policy & guardrail/CI hardening (CHANGELOG 0.1.8–0.1.9)

- **The whole project corpus is now in English** (`CLAUDE.md`, all `.claude/**`, `custom/**`, workflow/script comments). A mandatory **Language policy** in `CLAUDE.md` + both agent definitions requires everything written to disk/repo to be in English, regardless of the language used to converse with the operator. `settings.json` untouched.
- **`.githooks/pre-push` restored** on the default branch (commit `b2f9e4291`): the Layer-2 push guardrail (blocks pushes to `Next-Flip/*`) is active again. It had been dropped during the re-founding.
- **Inherited `Webhook` workflow disabled** (`gh workflow disable`, `disabled_manually`): it is Momentum's Discord notification bot, needs secrets the fork lacks, and failed on every push (email spam). The disabled state persists across upstream syncs. `Build`/`Lint` kept active as real CI.

---

## Pending items

1. **Exercise the full sync** (push+PR with a real delta) on the next upstream change. If PR creation fails, the planned fallback is to print the compare URL.
2. **Phase 2 of the agent system** (NOT started): 4 specialists (`flipper-rf-subghz`, `flipper-nfc`, `flipper-app-builder`, `flipper-build-fbt`) + 4 curated docs. See `phases.md` and `RESUME-phase2-bootstrap.md`.
3. **Scheduled Review 1:** `2026-08-23`, 3-month audit of the `COR` angle (see `phases.md` → "Active review calendar").

---

## Traps and continuity notes

- **`decisions.jsonl` is gitignored → does NOT travel** between machines. The important narrative is in the CHANGELOG + ADRs (which do travel). Decision to keep it gitignored (2026-07-24) due to the risk of merge conflicts in an append-only log.
- **Memory files** (`~/.claude/.../memory/`) are LOCAL to the machine, they don't travel. This RESUME + CHANGELOG + ADR are the source that does travel.
- **GitHub eventual consistency:** both the default-branch rename and enabling the PR setting showed propagation latency. If something "should work according to the API" but fails, retry after a few minutes before diagnosing.
- **Guardrail intact:** the `Next-Flip` remote was never added to the clone; the sync does it only inside the GitHub runner.
- **Inherited CI:** the Momentum `Webhook` workflow is disabled (Discord bot, useless in the fork). `Build`/`Lint` stay active and may email on genuine failures. Only re-enable `Webhook` if you add the `BUILD_WEBHOOK`/`DEV_WEBHOOK` secrets. Orphaned `advtest-pr-probe*` workflow entries are inert (branches deleted).
