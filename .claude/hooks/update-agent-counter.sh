#!/usr/bin/env bash
# SubagentStop hook: increments `invocation_count` of agent <name>
# in .claude/state/counters.json. Also updates `last_modified_commit`
# (hash of the last commit that touched .claude/agents/<name>.md) and
# `last_invocation_at` (ISO 8601 timestamp).
#
# Council resolution: D13 (counting mechanism for graduation
# experimental → stable after 5 invocations without modification) + D20.
#
# Usage:
#   .claude/hooks/update-agent-counter.sh <agent_name>
#
# Stdin input: hook JSON (not used directly to extract info;
# the agent name comes as an argument because the SubagentStop JSON
# does not expose the name of the subagent that finished).
#
# Output: always exit 0 (non-blocking hook). Errors go to stderr.

set -uo pipefail

AGENT_NAME="${1:-}"
if [[ -z "$AGENT_NAME" ]]; then
  echo "WARN: update-agent-counter.sh invoked without agent_name as an argument." >&2
  exit 0
fi

# Consume stdin to avoid EPIPE in Claude Code (we don't use the content directly)
cat >/dev/null 2>&1 || true

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
STATE_DIR="$SCRIPT_DIR/../state"
COUNTERS_FILE="$STATE_DIR/counters.json"

mkdir -p "$STATE_DIR"

# Create the file if it doesn't exist
if [[ ! -f "$COUNTERS_FILE" ]]; then
  echo '{"agents": {}}' > "$COUNTERS_FILE"
fi

# Compute last_modified_commit of the agent's file
AGENT_FILE_RELATIVE=".claude/agents/${AGENT_NAME}.md"
REPO_ROOT="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel 2>/dev/null || echo '')"

LAST_MODIFIED="unknown"
if [[ -n "$REPO_ROOT" && -f "$REPO_ROOT/$AGENT_FILE_RELATIVE" ]]; then
  LAST_MODIFIED="$(git -C "$REPO_ROOT" log -1 --format='%h' -- "$AGENT_FILE_RELATIVE" 2>/dev/null || echo 'unknown')"
  [[ -z "$LAST_MODIFIED" ]] && LAST_MODIFIED="unknown"
fi

TIMESTAMP="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

# Update atomically with jq.
# If the commit changed relative to the previously stored one, we reset the counter
# (rule D13: "If the agent is modified before reaching N, the counter resets").
TMP_FILE="$(mktemp)"
trap "rm -f $TMP_FILE" EXIT

if ! jq --arg agent "$AGENT_NAME" \
       --arg ts "$TIMESTAMP" \
       --arg commit "$LAST_MODIFIED" \
       '.agents[$agent] = (
          (.agents[$agent] // {invocation_count: 0, last_modified_commit: $commit, last_invocation_at: null})
          | if .last_modified_commit != $commit then .invocation_count = 0 else . end
          | .invocation_count += 1
          | .last_modified_commit = $commit
          | .last_invocation_at = $ts
        )' "$COUNTERS_FILE" > "$TMP_FILE" 2>/dev/null; then
  echo "ERROR: jq failed updating $COUNTERS_FILE" >&2
  exit 0
fi

# Verify the result is valid JSON
if ! jq empty "$TMP_FILE" >/dev/null 2>&1; then
  echo "ERROR: result is not valid JSON" >&2
  exit 0
fi

mv "$TMP_FILE" "$COUNTERS_FILE"
exit 0
