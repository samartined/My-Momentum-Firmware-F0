#!/usr/bin/env bash
# check-git-checkout-clean.sh — chequea si el árbol git está limpio antes de
# permitir `git checkout <branch-existente>` (D14, capa 4 de guardrails).
#
# Uso:
#   .claude/scripts/check-git-checkout-clean.sh
#
# Salida:
#   - Si árbol limpio: exit 0 (permitir checkout).
#   - Si hay cambios sin commit: imprime resumen en stderr y exit 1
#     (Claude Code muestra el resumen y pide aprobación al usuario antes
#     de seguir con el git checkout).
#
# Diseñado para invocarse desde el hook PreToolUse de Claude Code configurado
# en .claude/settings.json (Fase 1.D-hooks, paso 6 del bootstrap).

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: no estás dentro de un repositorio git." >&2
  exit 2
}

cd "$REPO_ROOT"

# git status --porcelain devuelve vacío si el árbol está limpio.
DIRTY="$(git status --porcelain)"

if [[ -z "$DIRTY" ]]; then
  # Árbol limpio: permitir.
  exit 0
fi

# Filtrar artefactos de build (build/, *.fap, *.fal, etc.) — son binarios
# que cambian con cada compilación y no representan "trabajo en progreso".
RELEVANT_DIRTY="$(echo "$DIRTY" | grep -vE '^.M (build/|.*\.(fap|fal|elf|elf\.map)$)' || true)"

if [[ -z "$RELEVANT_DIRTY" ]]; then
  # Solo cambios en artefactos de build: permitir.
  exit 0
fi

# Hay cambios relevantes sin commit. Bloquear con diagnóstico.
{
  echo "ÁRBOL GIT NO LIMPIO — el checkout puede sobrescribir trabajo no commiteado."
  echo ""
  echo "Cambios relevantes detectados:"
  echo "$RELEVANT_DIRTY" | head -20
  echo ""
  echo "Antes de hacer git checkout a otra branch existente:"
  echo "  1. Commitea estos cambios, o"
  echo "  2. Stashealos: git stash push -m '<motivo>'"
  echo "  3. O confirma explícitamente al usuario que vas a perder los cambios."
} >&2

exit 1
