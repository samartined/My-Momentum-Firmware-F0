#!/usr/bin/env bash
# check-irreversibility.sh — checks whether an operation matches the G3 list (D19)
#
# Usage:
#   .claude/scripts/check-irreversibility.sh "<command or path>"
#
# Output:
#   - If it matches one or more patterns: prints "MATCH IRREV-N: <description>"
#     (one line per match) and exit 0.
#   - If it matches none: exit 1 (no output).
#   - If argument is missing: exit 2 (usage error).
#
# Pattern source: .claude/design/irreversibility.md
# Council resolution: D19, D23.
#
# Convention: the master must pass a textual summary of the operation it is
# about to execute (a full shell command, a touched path, etc.). Matching
# is done via bash extended regex over that text.

set -uo pipefail

INPUT="${1:-}"
if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 \"<command or path>\"" >&2
  exit 2
fi

# Patterns in ID order (correspond to the 9 entries in irreversibility.md)
IDS=(IRREV-1 IRREV-2 IRREV-3 IRREV-4 IRREV-5 IRREV-6 IRREV-7 IRREV-8 IRREV-9)

PATTERNS=(
  'git[[:space:]]+push[[:space:]]+(.+[[:space:]])?(--force|-f([[:space:]]|$))'
  '\.claude/design/'
  'rm[[:space:]]+-[rRfF]+'
  '(targets|furi)/'
  '\.claude/agents/.*\.md'
  '(\.claude/settings\.json|\.githooks/)'
  '((\./)?fbt[[:space:]]+flash|dfu-util)'
  '([Nn]ext-[Ff]lip)/'
  '\.claude/state/.*\.jsonl'
)

DESCRIPTIONS=(
  'git push --force / rewriting published history'
  'modification of .claude/design/ (self-modification of the system)'
  'recursive or forced deletion with rm -r/-f'
  'change in targets/ or furi/ with potential ABI impact'
  'creation or removal of a subagent in .claude/agents/'
  'modification of hooks or .claude/settings.json (permission policy)'
  'flashing the physical Flipper (./fbt flash or dfu-util)'
  'push to the Next-Flip/Momentum-Firmware remote'
  'deletion of audit logs .claude/state/*.jsonl'
)

MATCH_COUNT=0
for i in "${!IDS[@]}"; do
  if [[ "$INPUT" =~ ${PATTERNS[$i]} ]]; then
    echo "MATCH ${IDS[$i]}: ${DESCRIPTIONS[$i]}"
    MATCH_COUNT=$((MATCH_COUNT+1))
  fi
done

if [[ $MATCH_COUNT -gt 0 ]]; then
  exit 0
fi
exit 1
