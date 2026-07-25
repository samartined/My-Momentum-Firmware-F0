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
# !! THE EXIT CODES ARE INVERTED relative to normal shell semantics: 0 means
# !! MATCHED (i.e. BLOCKED), 1 means clean. Any caller must capture the code and
# !! branch on it explicitly:
# !!
# !!     OUT="$(check-irreversibility.sh "$P")"; RC=$?
# !!     case "$RC" in 0) blocked ;; 1) allowed ;; *) usage/internal error ;; esac
# !!
# !! `if check-irreversibility.sh "$P"; then` reads as "allowed" when it means
# !! "blocked" and yields a perfectly inverted guardrail. `set -e` in a caller is
# !! forbidden for the same reason: exit 1 is a normal answer, not a failure.
# !! Note that check-git-checkout-clean.sh, in this same directory, uses the
# !! OPPOSITE convention (0 = allow), so the two are not interchangeable
# !! templates. See irreversibility.md -> "Matching pattern".
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

# Patterns in ID order (correspond to the 10 entries in irreversibility.md)
#
# NEVER use a negative lookahead here: bash ERE does not support it and fails
# SILENTLY — the pattern stops matching what it should and starts matching the
# literal lookahead text, disabling the entry instead of raising an error.
IDS=(IRREV-1 IRREV-2 IRREV-3 IRREV-4 IRREV-5 IRREV-6 IRREV-7 IRREV-8 IRREV-9 IRREV-10)

PATTERNS=(
  'git[[:space:]]+push[[:space:]]+(.+[[:space:]])?(--force|-f([[:space:]]|$))'
  '\.claude/design/'
  'rm[[:space:]]+-[rRfF]+'
  '(targets|furi)/'
  '\.claude/agents/.*\.[mM][dD]'
  '(\.claude/settings(\.local)?\.json|\.githooks/)'
  '((\./)?fbt[[:space:]]+flash|dfu-util)'
  '([Nn]ext-[Ff]lip)/'
  '\.claude/state/.*\.(jsonl|json)'
  '(CLAUDE\.md|\.claude/(scripts|hooks|commands|skills)/)'
)

DESCRIPTIONS=(
  'git push --force / rewriting published history'
  'modification of .claude/design/ (self-modification of the system)'
  'recursive or forced deletion with rm -r/-f'
  'change in targets/ or furi/ with potential ABI impact'
  'creation or removal of a subagent in .claude/agents/ (REGISTRY.md included)'
  'modification of hooks or a settings file, incl. the higher-precedence settings.local.json (permission policy)'
  'flashing the physical Flipper (./fbt flash or dfu-util)'
  'push to the Next-Flip/Momentum-Firmware remote'
  'deletion or tampering with audit state .claude/state/*.{jsonl,json}'
  'modification of the layer governing the master (CLAUDE.md, .claude/{scripts,hooks,commands,skills}/)'
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
