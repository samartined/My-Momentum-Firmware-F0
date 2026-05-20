# Política de coste y techo presupuestario

Este documento define el techo de coste por sesión del sistema multi-agente y la tabla de conversión tokens→USD usada por los hooks de logging.

Resolución del Concilio: D24.

## Niveles de actuación

| Umbral | Acción | Mecanismo |
|--------|--------|-----------|
| 60% del presupuesto | Soft warning | Hook `PostToolUse` imprime aviso al usuario tras la siguiente respuesta |
| 100% del presupuesto | (Fase 1) Continúa con warning persistente | Hook sigue emitiendo cada N invocaciones |
| 200% del presupuesto (hard cap) | Bloqueo de invocaciones a subagentes Opus (architect, concilio) — solo Sonnet permitido | Hook `PreToolUse` aborta invocaciones que excederían el cap |

En Fase 1, el hard cap solo dispara en patologías. La calibración de soft warning y hard cap se ajusta empíricamente en Fase 2+ con datos reales del log.

## Presupuesto

| Parámetro | Valor por defecto | Configurable |
|-----------|-------------------|--------------|
| `session_budget_usd` | 50.00 | Sí, en este archivo |
| `warning_threshold_pct` | 0.60 | Sí |
| `hard_cap_pct` | 2.00 (es decir, 2x del budget) | Sí |

## Tabla tokens→USD

**Última actualización**: 2026-05-20  
**Fuente**: https://docs.anthropic.com/en/docs/about-claude/pricing (a confirmar manualmente)

| Modelo | Input ($/M tokens) | Output ($/M tokens) | Cache write ($/M) | Cache read ($/M) |
|--------|---------------------|---------------------|-------------------|------------------|
| claude-opus-4-7 | (pendiente) | (pendiente) | (pendiente) | (pendiente) |
| claude-sonnet-4-6 | (pendiente) | (pendiente) | (pendiente) | (pendiente) |
| claude-haiku-4-5-20251001 | (pendiente) | (pendiente) | (pendiente) | (pendiente) |

(Los valores numéricos los completa el usuario manualmente desde la pricing page actual.)

## Schema del log de costes

Una línea = un objeto JSON = una invocación de subagente. Archivo: `.claude/state/costs.jsonl` (append-only, gitignored).

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `timestamp` | string (ISO 8601) | |
| `invocation_id` | string (UUIDv7) | |
| `agent_name` | string | Nombre del subagente invocado |
| `model` | string | Identificador del modelo |
| `tokens_in` | integer | |
| `tokens_out` | integer | |
| `cost_usd` | float | Calculado vía tabla arriba |
| `parent_context` | string | Sesión / decisión / task ID padre |
