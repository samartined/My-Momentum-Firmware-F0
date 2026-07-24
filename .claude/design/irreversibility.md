# List of irreversible operations

This document is the closed list of operations considered "irreversible" by the agent system. Any operation that matches one of the patterns described here automatically triggers L3 classification (Tripartite Council) and disables L1 (master alone) and L2 (`/devils-advocate`).

Council resolution: D19.

## Matching pattern

- Matching is automatic via script (regex over the command or operation that the master proposes to execute).
- The script lives at `.claude/scripts/check-irreversibility.sh` (created in Phase 1).
- If the script reports a positive match, the master must convene the Council (L3) or escalate to the user (L4); it cannot decide alone (L1) nor invoke `/devils-advocate` (L2).
- Extending the list: via human PR. Adding patterns at runtime is not allowed.

## Closed list (9 entries)

| # | Operation | Regex pattern (indicative) | Reason |
|---|-----------|----------------------------|-------|
| 1 | `git push --force` or rewriting published history | `git\s+push\s+.*--force` or `git\s+push\s+-f` | Unrecoverable loss of remote history. |
| 2 | Modification or deletion of files in `.claude/design/` | path matches `\.claude/design/.*` | Self-modification of the agent system. |
| 3 | Deletion of versioned files with no obvious backup equivalent | `rm\s+.*` on versioned paths | Loss without traceability. |
| 4 | Change in `targets/` or `furi/` that affects ABI or firmware memory layout | path matches `targets/.*` or `furi/.*` (with additional analysis) | Breaks deployed binaries. |
| 5 | Creation or deletion of a subagent | path matches `\.claude/agents/.*\.md` | Delta over the registry, affects routing. |
| 6 | Modification of hooks or `settings.json` that alters permission policy | path matches `\.claude/settings\.json` or `\.githooks/.*` | Changes the security model. |
| 7 | Flashing the physical Flipper device (bootloader, fuses, secure region) | `./fbt flash.*` or `dfu-util.*` | Potential hardware brick. |
| 8 | Push to the `Next-Flip/Momentum-Firmware` remote | URL matches `Next-Flip/` | Exposes code to the blocked official repo. |
| 9 | Deletion of audit logs (`.claude/state/*.jsonl`) | `rm.*\.claude/state/.*\.jsonl` | Destroys system observability. |

## Extending the list

To add a new entry:

1. Open a PR to the personal fork modifying this file and `.claude/scripts/check-irreversibility.sh`.
2. The PR's justification must include a concrete incident or identified risk, not generic hypotheses.
3. The PR goes through the Council (L3) before merging.

## Extension history

(This section is updated at the end of each PR that extends the list.)
