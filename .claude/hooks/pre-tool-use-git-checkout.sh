#!/usr/bin/env bash
# Claude Code PreToolUse hook wrapper over Bash.
#
# Filters for `git checkout <existing-branch>` (excluding `git checkout -b/-B`)
# and verifies that the git tree is clean before allowing the command.
#
# Council resolution: D14 (guardrail layer 4 — conditional git checkout).
#
# Input: stdin JSON with fields session_id, cwd, hook_event_name, tool_name,
#        tool_input.command (the full bash command).
#
# Output:
# - exit 0: allow the command (it's not git checkout, or it is git checkout -b,
#   or the tree is clean).
# - exit 2: block the command with a message to stderr; Claude Code will show
#   it to the user, who decides whether to reformulate the operation.

set -uo pipefail

# Read hook JSON from stdin
INPUT="$(cat 2>/dev/null || echo '{}')"

# Extract the bash command with jq
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"

if [[ -z "$COMMAND" ]]; then
  # No command, we can't validate. Allow by default.
  exit 0
fi

# Filter: only process commands that contain `git checkout`
if ! echo "$COMMAND" | grep -qE '(^|[[:space:]&|;])git[[:space:]]+checkout([[:space:]]|$)'; then
  exit 0
fi

# Exclude branch creation: `git checkout -b <name>` or `git checkout -B <name>`
if echo "$COMMAND" | grep -qE 'git[[:space:]]+checkout[[:space:]]+(-b|-B)([[:space:]]|$)'; then
  exit 0
fi

# Exclude checkout of specific files (not a branch): `git checkout -- <file>` or `git checkout <branch> -- <file>`
# These are potentially destructive on files too, but the main guardrail
# is for branch switching. We match them against the standard script but allow for now.
# (Heuristic: if there's a `--` we assume file restore, not branch checkout.)
if echo "$COMMAND" | grep -qE 'git[[:space:]]+checkout[[:space:]]+.*--[[:space:]]'; then
  exit 0
fi

# We got here: it's `git checkout <existing-branch>`. Validate clean tree.
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
HELPER="$SCRIPT_DIR/../scripts/check-git-checkout-clean.sh"

if [[ ! -x "$HELPER" ]]; then
  echo "WARN: $HELPER not found or not executable. Allowing by default." >&2
  exit 0
fi

# Change to the cwd that comes in the input so the helper operates on the correct repo
CWD="$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
if [[ -n "$CWD" && -d "$CWD" ]]; then
  cd "$CWD" || exit 0
fi

# Invoke helper. If exit != 0, we block with exit 2 (Claude Code will show the stderr).
if ! "$HELPER"; then
  # The helper already printed diagnostics to stderr. We propagate as exit 2.
  exit 2
fi

exit 0
