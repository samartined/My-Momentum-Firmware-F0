# Multi-agent system implementation phases

## Current status

Phase 0 completed in its design component. The design is captured in `system-design.md` and the 7 open points were resolved by the user (decisions D10-D16 in `system-design.md`). The system is ready to start Phase 1; the start happens by express order of the user (D16), not automatically.

---

## Phase 0 — Planning (in progress)

**Objective**: align the full agent system design with the user.

### Deliverables

- `.claude/design/system-design.md`
- `.claude/design/phases.md`
- `.claude/design/CHANGELOG.md`

### "Done" criteria

- Design captured in files.
- The 7 open points resolved by the user.

---

## Phase 1 — Minimum viable core

**Objective**: have the orchestrator, the meta-agent, the council, the guardrails, and the base documentation operational.

### Deliverables

- Remove the legacy `AGENTS.md` inherited from the personal repo (with backup in git history).
- `CLAUDE.md` with base instructions + **master role (the main conversation takes on orchestration, does NOT exist as a subagent)** + destructive-operation guardrails + policy on the official repo + reference to the 5 guardrail layers (see `system-design.md`).
- `.claude/settings.json` with versioned permissions (`permissions.ask` for destructive operations) + `alwaysThinkingEnabled: true` (D10).
- `.claude/agents/agent-architect.md` (Opus, `effort: max`, with the 4 control layers D5 + quotas D12/D17).
- `.claude/agents/council-member.md` (Opus, `effort: max`, parametrizable: receives an assigned angle from catalog G2 when invoked **3 times in parallel** from the main conversation). Replaces the original idea of 3 fixed files (Pragmatic/Visionary/Skeptic) with a single parametrizable implementation per D18.
- `.claude/agents/REGISTRY.md` (empty, with schema and entry template).
- `.claude/decisions/README.md` (how ADRs are written in this project).
- `.claude/docs/architecture-furios.md` (summary of the FuriOS runtime, curated by reading the codebase).
- `.claude/commands/flipper.md` (`/flipper` command that delegates to the master).
- `.claude/design/council-angles.md` (closed catalog + wildcard rules).
- `.claude/design/irreversibility.md` (closed list of 9 entries).
- `.claude/design/decisions-schema.md` (JSONL schema).
- `.claude/design/cost-policy.md` (ceiling and tokens→USD table).
- `.claude/scripts/check-irreversibility.sh` (regex matcher over the G3 list).
- `.claude/scripts/setup.sh` (one line: `pre-commit install` + binary validation).
- `.pre-commit-config.yaml` (framework config).
- `.githooks/pre-push` (blocking hook for `Next-Flip/*` with override via environment variable).
- `.githooks/pre-tool-use-checkout` (PreToolUse hook that validates a clean tree before `git checkout` to an existing branch).
- `SubagentStop` hook that updates `.claude/state/counters.json` with `invocation_count` and `last_modified_commit` per agent.
- `PostToolUse` hook that writes to `.claude/state/costs.jsonl` per invocation and emits a warning when crossing 60% of the budget.
- `.claude/commands/flipper-redirect.md` (`/flipper-redirect <specialist>`).
- `.claude/commands/flipper-review-wildcards.md` (`/flipper-review-wildcards`).
- `.claude/commands/flipper-reset.md` (opt-in `/flipper-reset` to clear the master's context).
- `.claude/skills/devils-advocate/` (skill for level L2).

### "Done" criteria

- All the above files created and committed on a dedicated branch.
- Functional validation 1: test task over 1 domain (expected L1). The master classifies L1, does not convene the Council, executes. Log in `decisions.jsonl` shows `level: "L1"`.
- Functional validation 2: cross-domain test task (expected L3). The master classifies L3, convenes the Council, collects 3 verdicts, drafts an ADR in `.claude/decisions/`. Log shows `level: "L3"` with a non-null `council_id`.
- Functional validation 3: synthetic task that matches the G3 list (e.g. a proposal to modify `.claude/design/`). The automatic script detects the match, forces L3, the master cannot downgrade to L2.
- Functional validation 4: attempted push to `Next-Flip/*` from the personal clone. The hook blocks with exit != 0 and the stderr message prints the override command on the first line.

---

## Phase 2 — Critical specialists

**Objective**: cover the most-used firmware areas with specialized agents and curated documentation.

### Deliverables

- `.claude/agents/flipper-rf-subghz.md`
- `.claude/agents/flipper-nfc.md`
- `.claude/agents/flipper-app-builder.md`
- `.claude/agents/flipper-build-fbt.md`
- `.claude/docs/subghz-internals.md`
- `.claude/docs/nfc-stack.md`
- `.claude/docs/adding-an-app-checklist.md`
- `.claude/docs/build-system.md`

### "Done" criteria

- Each specialist has its agent file and its curated knowledge document.
- Validation: the master correctly delegates to the corresponding specialist on a real firmware task.

---

## Phase 3 — Remaining specialists + commands + golden prompts

**Objective**: complete the system with all remaining specialists, shortcut commands, and the prompt infrastructure.

### Deliverables

- `.claude/agents/flipper-rfid-ibutton.md`
- `.claude/agents/flipper-ble.md`
- `.claude/agents/flipper-ir.md`
- `.claude/agents/flipper-badusb-hid.md`
- `.claude/agents/flipper-c-furi.md`
- `.claude/agents/flipper-companion-hw.md`
- `.claude/agents/flipper-js-mjs.md`
- `.claude/docs/<area>.md` corresponding to each of the above specialists
- `.claude/commands/flipper-new-app.md`
- `.claude/commands/flipper-spawn-agent.md`
- `.claude/commands/flipper-promote-prompt.md`
- `.claude/commands/flipper-quick.md`
- `.claude/commands/flipper-council.md`
- `.claude/commands/flipper-build.md`
- `.claude/prompts/README.md`
- `.claude/prompts/golden/` (initial folder with golden prompt template)
- `.claude/prompts/drafts/` (initial folder)

### "Done" criteria

- Complete and functional system with all agents and commands.
- Validation: a real cross-domain task (example: "build an app that combines NFC reading with a new UI") exercises the master, convenes the Council, and delegates correctly to the specialists.

---

## Phase 4 — Supervised operation and self-extension

**Objective**: use the system on real firmware tasks and let `agent-architect` propose new agents when it detects coverage gaps.

### Deliverables

Agents and additional documents proposed by the architect under user supervision. There is no fixed set; each approved proposal becomes a deliverable.

### "Done" criteria

No closed "done" phase applies: this is continuous operation. Each architect proposal the user approves is committed as an independent change with its justifying ADR in `.claude/decisions/`.

---

## How we avoid losing context between phases

- Each phase ends with a clean commit and a `CHANGELOG.md` update recording what was completed and why.
- When starting a new session, Claude Code loads `CLAUDE.md` automatically; from there it navigates to `.claude/design/` to recover the system's state.
- The `system-design.md` file is kept as an up-to-date reference at the end of each phase; it never falls out of sync with the actual implementation.

---

## Active review calendar

This section records mandatory scheduled reviews derived from closed ADRs. Each entry remains active until the review is executed and the result is logged in the corresponding file.

### Review 1 — 3-month audit of the `COR` angle

- **Date**: `2026-08-23` (3 months from approval of ADR-0001).
- **Owner**: `agent-architect`.
- **Reference**: [`ADR-0001-add-cor-angle.md`](../decisions/ADR-0001-add-cor-angle.md), follow-up F3.
- **Task**: run an audit over `.claude/state/decisions.jsonl` applying the withdrawal triggers (OR logic) set in `council-angles.md` → "Catalog change history" → Entry 1:
  - **C3-N2**: < 2 real invocations of `COR` in the 3-month window.
  - **C1-N1**: > 30% of Councils that co-assigned `ROB`+`COR` with reasons overlapping >70% (semantic comparator defined in the same entry).
- **Result sink**: new entry in "Catalog change history" of `council-angles.md` with format `{date, originating_council_id, observed_invocations, decision: keep | withdraw | reevaluate-in-6m}`, even if the decision is to keep it.
- **Status**: pending.
