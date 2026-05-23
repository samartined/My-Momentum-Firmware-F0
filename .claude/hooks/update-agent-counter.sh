#!/usr/bin/env bash
# Hook SubagentStop: incrementa `invocation_count` del agente <name>
# en .claude/state/counters.json. Actualiza también `last_modified_commit`
# (hash del último commit que tocó .claude/agents/<name>.md) y
# `last_invocation_at` (timestamp ISO 8601).
#
# Resolución del Concilio: D13 (mecanismo de conteo para graduación
# experimental → stable tras 5 invocaciones sin modificación) + D20.
#
# Uso:
#   .claude/hooks/update-agent-counter.sh <agent_name>
#
# Input stdin: JSON del hook (no se usa directamente para extraer info;
# el nombre del agente viene como argumento porque el JSON de SubagentStop
# no expone el nombre del subagente que terminó).
#
# Salida: exit 0 siempre (hook no bloqueante). Errores van a stderr.

set -uo pipefail

AGENT_NAME="${1:-}"
if [[ -z "$AGENT_NAME" ]]; then
  echo "WARN: update-agent-counter.sh invocado sin agent_name como argumento." >&2
  exit 0
fi

# Consumir stdin para evitar EPIPE en Claude Code (no usamos el contenido directamente)
cat >/dev/null 2>&1 || true

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
STATE_DIR="$SCRIPT_DIR/../state"
COUNTERS_FILE="$STATE_DIR/counters.json"

mkdir -p "$STATE_DIR"

# Crear el archivo si no existe
if [[ ! -f "$COUNTERS_FILE" ]]; then
  echo '{"agents": {}}' > "$COUNTERS_FILE"
fi

# Calcular last_modified_commit del archivo del agente
AGENT_FILE_RELATIVE=".claude/agents/${AGENT_NAME}.md"
REPO_ROOT="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel 2>/dev/null || echo '')"

LAST_MODIFIED="unknown"
if [[ -n "$REPO_ROOT" && -f "$REPO_ROOT/$AGENT_FILE_RELATIVE" ]]; then
  LAST_MODIFIED="$(git -C "$REPO_ROOT" log -1 --format='%h' -- "$AGENT_FILE_RELATIVE" 2>/dev/null || echo 'unknown')"
  [[ -z "$LAST_MODIFIED" ]] && LAST_MODIFIED="unknown"
fi

TIMESTAMP="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

# Actualizar atomically con jq.
# Si el commit cambió respecto al guardado anterior, reiniciamos invocation_count
# (regla D13: "Si el agente se modifica antes de alcanzar N, el contador se reinicia").
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
  echo "ERROR: jq falló actualizando $COUNTERS_FILE" >&2
  exit 0
fi

# Verificar que el resultado es JSON válido
if ! jq empty "$TMP_FILE" >/dev/null 2>&1; then
  echo "ERROR: resultado no es JSON válido" >&2
  exit 0
fi

mv "$TMP_FILE" "$COUNTERS_FILE"
exit 0
