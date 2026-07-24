#!/usr/bin/env bash
# setup.sh — setup COMPLETO/manual del sistema multi-agente tras git clone (D22)
#
# Uso:
#   ./.claude/scripts/setup.sh
#
# NOTA: el arranque MÍNIMO e idempotente lo hace ahora bootstrap.sh, que además
# corre automáticamente en cada SessionStart de Claude Code (hook en
# settings.json). setup.sh es el superset MANUAL: hace todo lo de bootstrap.sh
# + validación exhaustiva + instalación OPCIONAL del framework pre-commit.
#
# Hace:
#   1. Ejecuta bootstrap.sh (core.hooksPath, permisos, siembra de state/).
#   2. Verifica que TODOS los archivos esperados del sistema agente existen.
#   3. Instala pre-commit si está disponible (OPCIONAL — no falla si no lo está;
#      el guardrail pre-push ya queda activo vía core.hooksPath en el paso 1).
#
# Salida:
#   - exit 0: setup completado, sistema agente listo.
#   - exit != 0: diagnóstico claro en stderr indicando qué falla.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: este script debe ejecutarse dentro de un repositorio git." >&2
  exit 2
}

cd "$REPO_ROOT"

echo "==> Setup del sistema multi-agente Momentum Firmware"

# 1. Arranque idempotente (activa git hooks vía core.hooksPath, permisos, state/)
echo "    [1/3] Ejecutando bootstrap idempotente..."
if [[ -x ".claude/scripts/bootstrap.sh" ]]; then
  ./.claude/scripts/bootstrap.sh
else
  bash ".claude/scripts/bootstrap.sh"
fi
echo "          OK (core.hooksPath -> .githooks, state/ sembrado)"

# 1b. pre-commit OPCIONAL — el guardrail ya está activo vía core.hooksPath.
if command -v pre-commit >/dev/null 2>&1; then
  echo "    [1b] pre-commit detectado — instalando hooks adicionales..."
  pre-commit install --install-hooks --hook-type pre-commit --hook-type pre-push >/dev/null 2>&1 \
    && echo "          OK" \
    || echo "          AVISO: 'pre-commit install' falló (no crítico; core.hooksPath ya cubre el guardrail)." >&2
else
  echo "    [1b] 'pre-commit' no instalado — se omite (opcional)." >&2
  echo "          El guardrail pre-push ya está activo vía core.hooksPath." >&2
fi

# 2. Validación binaria: existen los archivos esperados del sistema agente
echo "    [2/3] Verificando archivos del sistema agente..."

EXPECTED_FILES=(
  "CLAUDE.md"
  ".claude/settings.json"
  ".claude/agents/REGISTRY.md"
  ".claude/agents/agent-architect.md"
  ".claude/agents/council-member.md"
  ".claude/design/system-design.md"
  ".claude/design/phases.md"
  ".claude/design/CHANGELOG.md"
  ".claude/design/council-angles.md"
  ".claude/design/irreversibility.md"
  ".claude/design/decisions-schema.md"
  ".claude/design/cost-policy.md"
  ".claude/decisions/README.md"
  ".claude/scripts/bootstrap.sh"
  ".claude/scripts/check-irreversibility.sh"
  ".claude/scripts/check-git-checkout-clean.sh"
  ".claude/skills/devils-advocate/SKILL.md"
  ".claude/commands/flipper.md"
  ".claude/commands/flipper-quick.md"
  ".claude/commands/flipper-council.md"
  ".claude/commands/flipper-redirect.md"
  ".claude/commands/flipper-review-wildcards.md"
  ".claude/commands/flipper-reset.md"
  ".githooks/pre-push"
  ".pre-commit-config.yaml"
)

MISSING=()
for f in "${EXPECTED_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    MISSING+=("$f")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "ERROR: faltan los siguientes archivos esperados del sistema agente:" >&2
  for f in "${MISSING[@]}"; do
    echo "  - $f" >&2
  done
  echo "" >&2
  echo "Posible causa: clone parcial, .gitignore mal configurado, o estás en una rama anterior a la Fase 1." >&2
  exit 5
fi
echo "          OK (${#EXPECTED_FILES[@]} archivos verificados)"

# 3. Permisos de ejecución
echo "    [3/3] Otorgando permisos de ejecución..."
EXEC_FILES=(
  ".claude/scripts/check-irreversibility.sh"
  ".claude/scripts/check-git-checkout-clean.sh"
  ".claude/scripts/setup.sh"
  ".githooks/pre-push"
)
for f in "${EXEC_FILES[@]}"; do
  if [[ -f "$f" && ! -x "$f" ]]; then
    chmod +x "$f"
  fi
done
echo "          OK"

echo ""
echo "==> Setup completado. El sistema multi-agente está listo."
echo "    Próximos pasos:"
echo "      - Lee CLAUDE.md para entender tu rol como master de la conversación principal."
echo "      - Lee .claude/design/system-design.md para el diseño completo (D1-D27)."
exit 0
