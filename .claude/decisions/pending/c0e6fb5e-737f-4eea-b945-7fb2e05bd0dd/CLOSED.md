# CLOSED — work shipped, folder kept as the audit trail

**Annotated 2026-08-31.**

This dossier ("Self-protection of the G3 enforcement layer", L4, 2026-07-25) has only a
`dossier.md` and no verdicts, which makes it look abandoned. It is not: the work it
proposes was **implemented and shipped the same day**, recorded in
`.claude/design/CHANGELOG.md` under `[0.1.11] — 2026-07-25`.

Shipped from this dossier:

- 11 path-scoped `Edit(...)` rules in `permissions.ask` (`settings.json`), covering
  `CLAUDE.md`, `.claude/{design,agents,scripts,hooks,commands,skills,state}/`, both
  settings files and `.githooks/`.
- `IRREV-6` extended to `.claude/settings.local.json`; `IRREV-10` extended to
  `.claude/commands/` and `.claude/skills/`.
- Removal of `Bash(find:*)` from `permissions.allow`.
- Correction of four sentences in `system-design.md` that falsely asserted the G3
  invariant was "structural".
- Documentation of the matcher's inverted exit codes.

The folder is retained rather than deleted: it is the only record of the reasoning
behind those guardrail changes.

## One real gap this leaves

The change was an L4 over G3 paths and closed **without an ADR** — only `ADR-0001` and
`ADR-0002` exist. Per `.claude/decisions/README.md` the deliberation record for a G3
change belongs in an ADR, not only in the CHANGELOG. Writing `ADR-0003` retroactively
from this dossier plus the 0.1.11 entry would close that gap; it is deliberately left
as a decision for the operator rather than back-dated unilaterally.
