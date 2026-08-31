# Subagent REGISTRY of the multi-agent system

This file registers **all** subagents in `.claude/agents/`. It is auditable and version-controlled. The `SubagentStop` hook (configured in `settings.json` during Phase 1.D) updates the counters after each invocation.

## Schema of each entry

Each subagent has an entry with the following fields:

- **agent_name**: filename without extension (e.g. `agent-architect`).
- **model**: `opus | sonnet | haiku`.
- **effort**: `low | medium | high | xhigh | max`.
- **status**: `experimental | stable`. After 5 invocations without modification, the architect proposes graduating it (D13).
- **core**: `true | false`. Core agents cannot be retired by the architect (D17).
- **invocation_count**: number of times the master has delegated a task to this agent. Tracked in `.claude/state/counters.json` (gitignored); this file reflects the last known snapshot after a commit.
- **last_modified_commit**: short hash of the last commit that touched `.claude/agents/<agent>.md`.
- **created_at**: ISO 8601 timestamp of creation.
- **motivo**: why was it created? (1 line)
- **casos_de_uso**: 3 use cases approved by the Council.
- **council_votes**: Council votes that approved its creation.
- **approval_commit**: hash of the commit where it was added.

## Count against the ceiling (D17)

- **Single ceiling**: 20 agents in `.claude/agents/`.
- **Core (cannot be automatically retired)**: 2 — `agent-architect`, `council-member`.
- **Specialists planned for Phases 2-3**: 11.
- **Total after Phase 3**: 13.
- **Margin for creation by the architect under supervised operation (Phase 4)**: 7.

## Agent creation policy

A new agent is only added after passing the 4 control layers of the `agent-architect` (see `system-design.md`):

1. Overlap check (no existing agent covers it).
2. Mandatory use cases (3 real, not hypothetical).
3. Council vote (2-of-3 YES, with typical angles `ORT` + `MNT` + `COS`).
4. Explicit human approval.

Each agent is born with `status: experimental`. After 5 invocations without subsequent modification, the architect proposes graduating it to `status: stable` (D13).

## Registered agents

| Agent | Model | Effort | Status | Core | Invocations | Last modified | Created at |
|--------|--------|--------|--------|------|-------------|---------------|------------|
| `agent-architect` | opus | max | experimental | true | 2 | `9f369579` | 2026-07-24 |
| `council-member` | opus | max | experimental | true | 1 | `9f369579` | 2026-07-24 |

Both core entries were backfilled on 2026-08-31; they had been left as
`_(pending Phase 1.B)_` since the agents shipped on 2026-07-24, so this file
under-reported the system for five weeks. The next 4 entries arrive in Phase 2 and
the remaining 7 in Phase 3.

### Per-entry detail

**`agent-architect`** — created `b4c117ec` (2026-07-24), approved by the same commit.
Motivo: meta-agent that proposes new specialists under the 4 control layers (D5), so
the roster can grow without the master inventing agents ad hoc. Casos de uso: propose
a specialist for an uncovered domain with 3+ real tasks as evidence; propose
graduating an agent from `experimental` to `stable` after 5 unmodified invocations
(D13); propose retiring a non-core agent that stopped being used. Council votes: N/A —
core agent, created as a Phase 1 deliverable rather than by proposal.

**`council-member`** — created `b4c117ec` (2026-07-24), approved by the same commit.
Motivo: single parametrizable implementation of a Council member, replacing the
original three fixed files (Pragmatic/Visionary/Skeptic) per D18. Casos de uso:
invoked 3x in parallel for an L3 decision with angles from the closed catalog;
re-invoked for a further round when round 1 does not reach 2-of-3; used for the
adversarial review of a design before implementation. Council votes: N/A — core agent,
Phase 1 deliverable.

Both are `status: experimental` because neither has reached the 5 unmodified
invocations D13 requires for the architect to propose graduation.

> **On the invocation counts:** `.claude/state/` is gitignored (`.gitignore:9`), so
> `counters.json` is per-clone and these numbers are the snapshot visible from the
> clone that last updated this file, not a global total. Treat them as a floor.
