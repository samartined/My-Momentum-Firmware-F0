# RESUME — Starting Phase 2 (Critical specialists)

## Ultra-short summary

**Phase 1 closed and verified.** Multi-agent system operational end-to-end. ADR-0001 closed and materialized. Next step, on the user's explicit order: start **Phase 2** = create 4 critical specialists + their curated docs.

This RESUME is self-contained: a new session (local, web, codespaces) can read it + `CLAUDE.md` + `.claude/design/phases.md` and start Phase 2 without any further historical context.

---

## System status (as of 2026-05-23, commit `7a8a91f2`)

### What's already done

- **Phase 0** (planning): complete. Design in `.claude/design/system-design.md` with 27 decisions + 4 meta-learnings.
- **Phase 1** (minimum viable core): complete. All 4 functional done criteria are verified:
  - V1 (L1 single-domain): passed.
  - V2 (L3 Council end-to-end): passed (this session → ADR-0001).
  - V3 (G3 forced): passed.
  - V4 (push to Next-Flip blocked): passed.
- **2 operational core agents** in `.claude/agents/`:
  - `agent-architect` (Opus, effort: max).
  - `council-member` (Opus, effort: max, parametrizable with an angle from the catalog).
- **Council catalog**: 13 active angles (12 + `COR` added in ADR-0001).
- **Hooks**: `SubagentStop`, `PreToolUse`, `pre-push` active.
- **decisions.jsonl**: 3 entries logged (V1 L1, V3 L3 with no council_id, V2 L3 with council_id).

### Pending scheduled reviews

- **`2026-08-23`**: 3-month audit of the `COR` angle (Review 1 in `phases.md` → "Active review calendar"). Owner: `agent-architect`. Triggers withdrawal (OR): <2 real invocations or >30% `ROB`+`COR` overlap.

---

## Phase 2 startup plan

Per `phases.md` → Phase 2, the deliverables are:

### Specialist agents (4)

| File | Domain | Suggested model |
|---|---|---|
| `.claude/agents/flipper-rf-subghz.md` | SubGHz, OOK, CC1101 radio, `.sub` slots | Opus, effort: max |
| `.claude/agents/flipper-nfc.md` | NFC (ISO14443 A/B, MIFARE, NTAG, NDEF, plugins) | Opus, effort: max |
| `.claude/agents/flipper-app-builder.md` | App structure (`application.fam`, gui, scenes, views, FAP) | Opus, effort: max |
| `.claude/agents/flipper-build-fbt.md` | Build system (fbt, scons, toolchain, firmware vs apps) | Sonnet, effort: medium |

### Curated docs (4)

| File | Expected content |
|---|---|
| `.claude/docs/subghz-internals.md` | SubGHz stack: supported protocols, `.sub` format, mapping to the TX worker, integration with the SubGHz app |
| `.claude/docs/nfc-stack.md` | NFC stack: layers (lib/nfc, plugins), supported types, ISO14443 A/B, MIFARE, NTAG, custom apps |
| `.claude/docs/adding-an-app-checklist.md` | Verified steps for adding a FAP app (application.fam, entry point, scenes, build) |
| `.claude/docs/build-system.md` | fbt, scons, `f7-firmware-C` vs apps targets, common commands (`./fbt`, `./fbt fap_X`, `./fbt firmware_flash`) |

### Phase 2 done criteria

1. The 4 agent files created with valid frontmatter (model, effort, description, tools).
2. The 4 docs created with useful content verifiable against the codebase.
3. **Validation**: the master correctly delegates to the right specialist on a real firmware task (e.g. "implement reading of protocol X for SubGHz" → delegates to `flipper-rf-subghz`).
4. Registry updated: each specialist added to `.claude/agents/REGISTRY.md`.

---

## Decisions the master must make when starting Phase 2

### 1. Create the 4 specialists via `agent-architect` or directly?

**Option A (via architect)**: the master asks `agent-architect` to propose each one. The architect applies its 4 layers of control (description, tools, model, justification). The user approves in batch or one by one. This is the "canonical" agent-creation flow (D5).

- **+** Discipline in the agent-creation process.
- **+** Each specialist goes through 4 layers of control.
- **−** The D12 quota says "maximum 1 new agent per session" → would require running 4 architect sessions, or explicitly relaxing the quota for Phase 2 (a planned deliverable, not a spontaneous proposal).

**Option B (direct, no architect)**: the master creates the 4 agents manually because they are deliverables planned in `phases.md`, not reactive proposals from the architect.

- **+** Faster (1 session vs 4).
- **+** The architect's quota is for spontaneous proposals, not for planned deliverables.
- **−** Skips the architect's control. Needs a good justification.

**Recommendation**: **Option B with a consolidated commit**. Reason: the architect exists to detect unplanned coverage gaps; the 4 Phase 2 specialists are already explicitly listed in `phases.md` as fixed deliverables. Routing them through the architect would duplicate discipline. However, the user should be consulted first (a meta-decision).

### 2. Is Phase 2 a single consolidated L3 or 4 separate L3s?

**Creating files under `.claude/agents/` matches G3** (CLAUDE.md: "Modification of `.claude/agents/`... matches G3 → forces L3").

**Option A (4 separate L3s)**: one Council per specialist. High cost (~12 Opus invocations for Phase 2 Councils alone). Inadequate for ex-ante planned deliverables.

**Option B (1 consolidated "Phase 2 bootstrap" L3)**: a single Council that deliberates on the set of 4 specialists as a bootstrap. More reasonable because the deliberation is "are the 4 new specialists well defined?", not 4 separate questions.

**Option C (no L3, direct escalation to L4)**: the master builds a minimal dossier, presents it directly to the user, and the user approves without a Council because it's a planned deliverable. This is legitimate: the `check-irreversibility.sh` script structurally forces L3, but the user can explicitly approve L4 without going through the Council (D21 — "1-of-3 YES → escalate to L4" is the normal route, but direct L4 is also valid if the user asks for it).

**Recommendation**: depends on the user's desired level of discipline. If they want the full flow, **Option B**. If they want to start Phase 2 quickly and trust the `phases.md` plan, **Option C**.

### 3. Order of creation?

**Suggestion**: `flipper-build-fbt` first (any app needs to know how to build), then `flipper-app-builder` (general structure), then the two domain-specific ones (`flipper-nfc`, `flipper-rf-subghz`). But the user may request a different order if they have a specific pending task.

---

## Known traps and precedents

### Trap 1: the `Write` bug (V2 precedent)

In the session before this one, `Write` failed systematically. Documented workaround: use `Bash` with a heredoc. In the current session the bug is resolved. If it reappears, see `.claude/decisions/pending/62978df1-.../RESUME.md` (the original from V2).

### Trap 2: architect quotas (D12)

If you choose Option A from step 1, remember the "1 new agent per session" quota may block you. There are two paths:

- Run 4 separate architect sessions.
- Relax the quota for this specific session with an explicit justification in `decisions.jsonl` and a mention to the user.

### Trap 3: unverified curated docs

The 4 docs (`.claude/docs/*.md`) must be built by reading the real codebase, not by making things up. Use `Explore` (subagent) to map each subsystem before writing the doc. Precedent: the `architecture-furios.md` doc from Phase 1 was built this way.

### Trap 4: upstream's anti-AI policy

`Next-Flip/Momentum-Firmware` has an anti-AI policy. Your fork (`samartined/...`) is safe; but the Phase 2 docs are yours and never go to upstream. The `pre-push` hook blocks any attempt. Confirmed in V4.

---

## How to start the new session

### Step 1 — Verify context

```bash
git status                                          # should be clean or have build-related changes (not relevant)
git log --oneline -3                                # last commit should be 7a8a91f2 (V2 close)
cat .claude/design/CHANGELOG.md | head -50          # confirms version 0.1.5 in the header
cat .claude/decisions/ADR-0001-add-cor-angle.md     # confirms the ADR was materialized
```

### Step 2 — Confirm the plan with the user

Ask the user which decisions they want for the 3 open points (via architect vs direct, 4 L3s vs 1 L3 vs direct L4, order of creation). Do not start creating files until you have their answer.

### Step 3 — If Option C (direct L4)

- Build a minimal "Phase 2 bootstrap" dossier at `.claude/decisions/pending/<new-uuid>/dossier.md`.
- Log L4 in `decisions.jsonl` with `criterion_invoked: "user-direct-approval-planned-deliverable"`.
- Create the 4 agent files in the agreed order.
- Create the 4 curated docs (use the `Explore` subagent to map the real code).
- Update `REGISTRY.md`.
- Consolidated commit `feat(.claude): bootstrap Phase 2 specialists (subghz, nfc, app-builder, build-fbt)`.

### Step 4 — Final validation

- Run a real test task (e.g. "explain how the SubGHz TX worker works") and verify the master delegates to the correct specialist.
- Log the validation in `decisions.jsonl`.
- Update `CHANGELOG.md` with a 0.1.6 entry closing Phase 2.

---

## Important continuity information

- **Current branch**: `my-momentum/feature/multi-agent-system-v1`.
- **Remote**: only `origin` → `git@github.com:samartined/My-Momentum-Firmware-F0.git`. There is NO `Next-Flip` remote in this clone.
- **Last commit**: `7a8a91f2 validate(v2): close Council deliberation ADR-0001 (Phase 1.G done)`.
- **Push to origin**: done on `2026-05-23`. The branch is reachable from any cloud session that clones this fork.
- **decisions.jsonl**: gitignored. Does NOT travel with the repo. The new session will start with its own `decisions.jsonl` (local to its clone). If you need strict log continuity, see the options discussed in conversation or change the gitignore.

## About the master session

Claude Code's main conversation assumes the role of master of the multi-agent system (CLAUDE.md). Any new session on any device (local, claude.ai/code web, Codespaces, VM) that loads `CLAUDE.md` automatically assumes that role. There is no "persistent master session" — the role lives in the file, not in an instance.
