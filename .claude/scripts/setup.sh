#!/usr/bin/env bash
# setup.sh — FULL/manual setup of the multi-agent system after git clone (D22)
#
# Usage:
#   ./.claude/scripts/setup.sh
#
# NOTE: the MINIMAL, idempotent startup is now handled by bootstrap.sh, which
# also runs automatically on every SessionStart of Claude Code (hook in
# settings.json). setup.sh is the MANUAL superset: it does everything
# bootstrap.sh does + exhaustive validation + OPTIONAL installation of the
# pre-commit framework.
#
# Does:
#   1. Runs bootstrap.sh (core.hooksPath, permissions, seeding of state/).
#   2. Verifies that ALL expected files of the agent system exist.
#   3. Installs pre-commit if available (OPTIONAL — does not fail if it isn't;
#      the pre-push guardrail is already active via core.hooksPath in step 1).
#
# Output:
#   - exit 0: setup complete, agent system ready.
#   - exit != 0: clear diagnostics on stderr indicating what is failing.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: this script must be run inside a git repository." >&2
  exit 2
}

cd "$REPO_ROOT"

echo "==> Setup of the Momentum Firmware multi-agent system"

# 1. Idempotent startup (activates git hooks via core.hooksPath, permissions, state/)
echo "    [1/3] Running idempotent bootstrap..."
if [[ -x ".claude/scripts/bootstrap.sh" ]]; then
  ./.claude/scripts/bootstrap.sh
else
  bash ".claude/scripts/bootstrap.sh"
fi
echo "          OK (core.hooksPath -> .githooks, state/ seeded)"

# 1b. OPTIONAL pre-commit — the guardrail is already active via core.hooksPath.
if command -v pre-commit >/dev/null 2>&1; then
  echo "    [1b] pre-commit detected — installing additional hooks..."
  pre-commit install --install-hooks --hook-type pre-commit --hook-type pre-push >/dev/null 2>&1 \
    && echo "          OK" \
    || echo "          WARNING: 'pre-commit install' failed (not critical; core.hooksPath already covers the guardrail)." >&2
else
  echo "    [1b] 'pre-commit' not installed — skipping (optional)." >&2
  echo "          The pre-push guardrail is already active via core.hooksPath." >&2
fi

# 2. Binary validation: expected agent-system files exist
echo "    [2/3] Verifying agent system files..."

EXPECTED_FILES=(
  "CLAUDE.md"
  ".claude/settings.json"
  ".claude/agents/REGISTRY.md"
  ".claude/agents/agent-architect.md"
  ".claude/agents/council-member.md"
  ".claude/design/system-design.md"
  ".claude/design/phases.md"
  ".claude/design/CHANGELOG.md"
  ".claude/design/council-angles.md"
  ".claude/design/irreversibility.md"
  ".claude/design/decisions-schema.md"
  ".claude/design/cost-policy.md"
  ".claude/decisions/README.md"
  ".claude/scripts/bootstrap.sh"
  ".claude/scripts/check-irreversibility.sh"
  ".claude/scripts/check-git-checkout-clean.sh"
  ".claude/skills/devils-advocate/SKILL.md"
  ".claude/commands/flipper.md"
  ".claude/commands/flipper-quick.md"
  ".claude/commands/flipper-council.md"
  ".claude/commands/flipper-redirect.md"
  ".claude/commands/flipper-review-wildcards.md"
  ".claude/commands/flipper-reset.md"
  ".githooks/pre-push"
  ".pre-commit-config.yaml"
)

MISSING=()
for f in "${EXPECTED_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    MISSING+=("$f")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "ERROR: the following expected agent-system files are missing:" >&2
  for f in "${MISSING[@]}"; do
    echo "  - $f" >&2
  done
  echo "" >&2
  echo "Possible cause: partial clone, misconfigured .gitignore, or you are on a branch predating Phase 1." >&2
  exit 5
fi
echo "          OK (${#EXPECTED_FILES[@]} files verified)"

# 3. Execute permissions
echo "    [3/3] Granting execute permissions..."
EXEC_FILES=(
  ".claude/scripts/check-irreversibility.sh"
  ".claude/scripts/check-git-checkout-clean.sh"
  ".claude/scripts/setup.sh"
  ".githooks/pre-push"
)
for f in "${EXEC_FILES[@]}"; do
  if [[ -f "$f" && ! -x "$f" ]]; then
    chmod +x "$f"
  fi
done
echo "          OK"

echo ""
echo "==> Setup complete. The multi-agent system is ready."
echo "    Next steps:"
echo "      - Read CLAUDE.md to understand your role as master of the main conversation."
echo "      - Read .claude/design/system-design.md for the full design (D1-D27)."
exit 0
