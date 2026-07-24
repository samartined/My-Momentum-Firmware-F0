#!/usr/bin/env bash
# check-git-checkout-clean.sh — checks whether the git tree is clean before
# allowing `git checkout <existing-branch>` (D14, guardrail layer 4).
#
# Usage:
#   .claude/scripts/check-git-checkout-clean.sh
#
# Output:
#   - If tree is clean: exit 0 (allow checkout).
#   - If there are uncommitted changes: prints summary to stderr and exit 1
#     (Claude Code shows the summary and asks the user for approval before
#     proceeding with the git checkout).
#
# Designed to be invoked from Claude Code's PreToolUse hook configured
# in .claude/settings.json (Phase 1.D-hooks, bootstrap step 6).

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: you are not inside a git repository." >&2
  exit 2
}

cd "$REPO_ROOT"

# git status --porcelain returns empty if the tree is clean.
DIRTY="$(git status --porcelain)"

if [[ -z "$DIRTY" ]]; then
  # Clean tree: allow.
  exit 0
fi

# Filter out build artifacts (build/, *.fap, *.fal, etc.) — these are binaries
# that change with every compile and don't represent "work in progress".
RELEVANT_DIRTY="$(echo "$DIRTY" | grep -vE '^.M (build/|.*\.(fap|fal|elf|elf\.map)$)' || true)"

if [[ -z "$RELEVANT_DIRTY" ]]; then
  # Only build-artifact changes: allow.
  exit 0
fi

# There are relevant uncommitted changes. Block with diagnostics.
{
  echo "GIT TREE NOT CLEAN — the checkout may overwrite uncommitted work."
  echo ""
  echo "Relevant changes detected:"
  echo "$RELEVANT_DIRTY" | head -20
  echo ""
  echo "Before doing a git checkout to another existing branch:"
  echo "  1. Commit these changes, or"
  echo "  2. Stash them: git stash push -m '<reason>'"
  echo "  3. Or explicitly confirm with the user that you are going to lose the changes."
} >&2

exit 1
