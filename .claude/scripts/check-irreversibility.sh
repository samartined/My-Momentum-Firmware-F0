#!/usr/bin/env bash
# check-irreversibility.sh — chequea si una operación matchea la lista G3 (D19)
#
# Uso:
#   .claude/scripts/check-irreversibility.sh "<comando o path>"
#
# Salida:
#   - Si matchea uno o más patrones: imprime "MATCH IRREV-N: <descripción>"
#     (una línea por match) y exit 0.
#   - Si no matchea ninguno: exit 1 (no output).
#   - Si argumento ausente: exit 2 (error de uso).
#
# Fuente de patrones: .claude/design/irreversibility.md
# Resolución del Concilio: D19, D23.
#
# Convención: el master debe pasar un resumen textual de la operación que va
# a ejecutar (un comando shell completo, un path tocado, etc.). El matching
# es por regex extendida de bash sobre ese texto.

set -uo pipefail

INPUT="${1:-}"
if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 \"<comando o path>\"" >&2
  exit 2
fi

# Patrones en orden de IDs (corresponden a las 9 entradas de irreversibility.md)
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
  'git push --force / reescritura de historia publicada'
  'modificación de .claude/design/ (auto-modificación del sistema)'
  'borrado recursivo o forzado con rm -r/-f'
  'cambio en targets/ o furi/ con impacto potencial ABI'
  'creación o eliminación de subagente en .claude/agents/'
  'modificación de hooks o .claude/settings.json (policy de permisos)'
  'flash del Flipper físico (./fbt flash o dfu-util)'
  'push a remote Next-Flip/Momentum-Firmware'
  'eliminación de logs de auditoría .claude/state/*.jsonl'
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
