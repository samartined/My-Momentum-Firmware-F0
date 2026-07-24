#!/usr/bin/env bash
# bootstrap.sh — idempotent startup for the multi-agent system (D22)
#
# Designed to run AUTOMATICALLY on every SessionStart of Claude Code
# (see hook in .claude/settings.json) and also manually after a `git clone`.
#
# Goal: a fresh clone (local, Codespaces, Claude Code Cloud) ends up with
# FULL functional parity with no manual steps — in particular, that layer 2
# of guardrails (git hook pre-push against Next-Flip) is active without
# depending on the `pre-commit` framework.
#
# Idempotently does:
#   1. Activates the versioned git hooks via `core.hooksPath = .githooks`.
#   2. Grants execute permissions to scripts and hooks.
#   3. Creates and seeds .claude/state/ (gitignored, does not travel with the repo).
#   4. Quick binary validation of critical files (warning, not blocking).
#
# Output contract:
#   - ALWAYS exit 0 (non-blocking hook — must never prevent the session from starting).
#   - CLEAN stdout on success (so as not to pollute the master's context on every
#     startup). All human-readable diagnostics go to stderr.
#   - Only acts where needed: if already configured, does not repeat work.

set -uo pipefail

# --- Resolve repo root (silent if not a git repo) ------------------------------
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
[[ -z "$REPO_ROOT" ]] && exit 0
cd "$REPO_ROOT" || exit 0

CHANGED=0

# --- 1. Activate versioned git hooks via core.hooksPath ------------------------
# We prefer core.hooksPath over `pre-commit install`: dependency-free and
# travels the same in any environment (including headless cloud).
if [[ -d ".githooks" ]]; then
  CURRENT_HOOKSPATH="$(git config --local --get core.hooksPath 2>/dev/null || echo '')"
  if [[ "$CURRENT_HOOKSPATH" != ".githooks" ]]; then
    git config --local core.hooksPath .githooks && CHANGED=1
    echo "bootstrap: core.hooksPath -> .githooks (pre-push guardrail active)" >&2
  fi
fi

# --- 2. Execute permissions ----------------------------------------------------
EXEC_FILES=(
  ".claude/scripts/bootstrap.sh"
  ".claude/scripts/check-irreversibility.sh"
  ".claude/scripts/check-git-checkout-clean.sh"
  ".claude/scripts/setup.sh"
  ".claude/hooks/pre-tool-use-git-checkout.sh"
  ".claude/hooks/update-agent-counter.sh"
  ".githooks/pre-push"
)
for f in "${EXEC_FILES[@]}"; do
  if [[ -f "$f" && ! -x "$f" ]]; then
    chmod +x "$f" 2>/dev/null && CHANGED=1
  fi
done

# --- 3. Seed .claude/state/ (gitignored, local to each clone) ------------------
STATE_DIR=".claude/state"
mkdir -p "$STATE_DIR" 2>/dev/null || true

COUNTERS_FILE="$STATE_DIR/counters.json"
if [[ ! -f "$COUNTERS_FILE" ]]; then
  echo '{"agents": {}}' > "$COUNTERS_FILE" 2>/dev/null && {
    CHANGED=1
    echo "bootstrap: seeded $COUNTERS_FILE" >&2
  }
fi

DECISIONS_FILE="$STATE_DIR/decisions.jsonl"
if [[ ! -f "$DECISIONS_FILE" ]]; then
  : > "$DECISIONS_FILE" 2>/dev/null && {
    CHANGED=1
    echo "bootstrap: created $DECISIONS_FILE (empty)" >&2
  }
fi

# --- 4. Quick binary validation of critical files ------------------------------
# Does not block (always exit 0); only warns via stderr if the clone is incomplete.
CRITICAL_FILES=(
  "CLAUDE.md"
  ".claude/settings.json"
  ".claude/agents/REGISTRY.md"
  ".claude/design/system-design.md"
  ".claude/scripts/check-irreversibility.sh"
  ".githooks/pre-push"
)
MISSING=()
for f in "${CRITICAL_FILES[@]}"; do
  [[ -f "$f" ]] || MISSING+=("$f")
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "bootstrap: WARNING — missing critical files of the agent system:" >&2
  for f in "${MISSING[@]}"; do echo "  - $f" >&2; done
  echo "  Possible partial clone or branch predating Phase 1." >&2
fi

[[ "$CHANGED" == "1" ]] && echo "bootstrap: multi-agent system ready." >&2

exit 0
