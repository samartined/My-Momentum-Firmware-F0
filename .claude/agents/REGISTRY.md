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
| _(pending Phase 1.B)_ | | | | | | | |

The first 2 entries are added upon completing Phase 1.B (`agent-architect` and `council-member`). The next 4 in Phase 2 and the remaining 7 in Phase 3.
