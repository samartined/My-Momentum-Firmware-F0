#!/usr/bin/env bash
# Wrapper de Claude Code PreToolUse hook sobre Bash.
#
# Filtra a `git checkout <branch-existente>` (excluyendo `git checkout -b/-B`)
# y verifica que el árbol git esté limpio antes de permitir el comando.
#
# Resolución del Concilio: D14 (capa 4 de guardrails — git checkout condicional).
#
# Input: stdin JSON con campos session_id, cwd, hook_event_name, tool_name,
#        tool_input.command (el comando bash completo).
#
# Salida:
# - exit 0: permitir el comando (no es git checkout, o es git checkout -b,
#   o el árbol está limpio).
# - exit 2: bloquear el comando con mensaje a stderr; Claude Code lo mostrará
#   al usuario que decide si reformular la operación.

set -uo pipefail

# Leer JSON del hook desde stdin
INPUT="$(cat 2>/dev/null || echo '{}')"

# Extraer el comando bash con jq
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"

if [[ -z "$COMMAND" ]]; then
  # Sin comando, no podemos validar. Permitir por defecto.
  exit 0
fi

# Filtrar: solo procesar comandos que contienen `git checkout`
if ! echo "$COMMAND" | grep -qE '(^|[[:space:]&|;])git[[:space:]]+checkout([[:space:]]|$)'; then
  exit 0
fi

# Excluir creación de branch: `git checkout -b <name>` o `git checkout -B <name>`
if echo "$COMMAND" | grep -qE 'git[[:space:]]+checkout[[:space:]]+(-b|-B)([[:space:]]|$)'; then
  exit 0
fi

# Excluir checkout de archivos específicos (no de branch): `git checkout -- <file>` o `git checkout <branch> -- <file>`
# Estos sí son potencialmente destructivos sobre archivos, pero el guardrail principal
# es para el cambio de branch. Los matcheamos al script estándar pero permitimos por ahora.
# (Heurística: si hay un `--` se asume restore de archivos, no de branch.)
if echo "$COMMAND" | grep -qE 'git[[:space:]]+checkout[[:space:]]+.*--[[:space:]]'; then
  exit 0
fi

# Llegamos aquí: es `git checkout <branch-existente>`. Validar árbol limpio.
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
HELPER="$SCRIPT_DIR/../scripts/check-git-checkout-clean.sh"

if [[ ! -x "$HELPER" ]]; then
  echo "WARN: $HELPER no encontrado o no ejecutable. Permitiendo por defecto." >&2
  exit 0
fi

# Cambiar al cwd que viene en el input para que el helper opere en el repo correcto
CWD="$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
if [[ -n "$CWD" && -d "$CWD" ]]; then
  cd "$CWD" || exit 0
fi

# Invocar helper. Si exit != 0, bloqueamos con exit 2 (Claude Code mostrará el stderr).
if ! "$HELPER"; then
  # El helper ya imprimió diagnóstico en stderr. Propagamos como exit 2.
  exit 2
fi

exit 0
