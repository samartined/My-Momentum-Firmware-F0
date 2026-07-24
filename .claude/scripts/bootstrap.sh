#!/usr/bin/env bash
# bootstrap.sh — arranque idempotente del sistema multi-agente (D22)
#
# Diseñado para ejecutarse AUTOMÁTICAMENTE en cada SessionStart de Claude Code
# (ver hook en .claude/settings.json) y también manualmente tras un `git clone`.
#
# Objetivo: que un clon nuevo (local, Codespaces, Claude Code Cloud) quede con
# paridad funcional COMPLETA sin pasos manuales — en particular, que la capa 2
# de guardrails (git hook pre-push contra Next-Flip) quede activa sin depender
# del framework `pre-commit`.
#
# Hace, de forma idempotente:
#   1. Activa los git hooks versionados vía `core.hooksPath = .githooks`.
#   2. Otorga permisos de ejecución a scripts y hooks.
#   3. Crea y siembra .claude/state/ (gitignored, no viaja con el repo).
#   4. Validación binaria rápida de archivos críticos (aviso, no bloqueo).
#
# Contrato de salida:
#   - SIEMPRE exit 0 (hook no bloqueante — nunca debe impedir arrancar sesión).
#   - stdout LIMPIO en éxito (para no contaminar el contexto del master en cada
#     arranque). Todo el diagnóstico humano va a stderr.
#   - Solo actúa donde haga falta: si ya está configurado, no repite trabajo.

set -uo pipefail

# --- Resolver repo root (silencioso si no es un repo git) ---------------------
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
[[ -z "$REPO_ROOT" ]] && exit 0
cd "$REPO_ROOT" || exit 0

CHANGED=0

# --- 1. Activar git hooks versionados vía core.hooksPath ----------------------
# Preferimos core.hooksPath a `pre-commit install`: dependency-free y viaja
# igual en cualquier entorno (incluida la nube headless).
if [[ -d ".githooks" ]]; then
  CURRENT_HOOKSPATH="$(git config --local --get core.hooksPath 2>/dev/null || echo '')"
  if [[ "$CURRENT_HOOKSPATH" != ".githooks" ]]; then
    git config --local core.hooksPath .githooks && CHANGED=1
    echo "bootstrap: core.hooksPath -> .githooks (pre-push guardrail activo)" >&2
  fi
fi

# --- 2. Permisos de ejecución -------------------------------------------------
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

# --- 3. Sembrar .claude/state/ (gitignored, local a cada clon) ----------------
STATE_DIR=".claude/state"
mkdir -p "$STATE_DIR" 2>/dev/null || true

COUNTERS_FILE="$STATE_DIR/counters.json"
if [[ ! -f "$COUNTERS_FILE" ]]; then
  echo '{"agents": {}}' > "$COUNTERS_FILE" 2>/dev/null && {
    CHANGED=1
    echo "bootstrap: sembrado $COUNTERS_FILE" >&2
  }
fi

DECISIONS_FILE="$STATE_DIR/decisions.jsonl"
if [[ ! -f "$DECISIONS_FILE" ]]; then
  : > "$DECISIONS_FILE" 2>/dev/null && {
    CHANGED=1
    echo "bootstrap: creado $DECISIONS_FILE (vacío)" >&2
  }
fi

# --- 4. Validación binaria rápida de archivos críticos ------------------------
# No bloquea (exit 0 siempre); solo avisa por stderr si el clon está incompleto.
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
  echo "bootstrap: AVISO — faltan archivos críticos del sistema agente:" >&2
  for f in "${MISSING[@]}"; do echo "  - $f" >&2; done
  echo "  Posible clon parcial o rama anterior a Fase 1." >&2
fi

[[ "$CHANGED" == "1" ]] && echo "bootstrap: sistema multi-agente listo." >&2

exit 0
