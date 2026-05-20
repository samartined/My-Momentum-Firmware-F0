# Schema del log de clasificaciones de decisiones

Este documento especifica el formato del archivo `.claude/state/decisions.jsonl` (append-only, gitignored, local al clone) en el que el master registra cada decisión de clasificación L1/L2/L3/L4.

Resolución del Concilio: D20.

## Formato

Una línea = un objeto JSON = una decisión clasificada. Codificación UTF-8, separador de líneas LF.

## Campos obligatorios

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `timestamp` | string (ISO 8601) | Momento de la decisión, con timezone explícito |
| `decision_id` | string (UUIDv7) | Identificador único de la decisión |
| `task_hash` | string (SHA-256 hex) | Hash del enunciado de la tarea (no del enunciado completo, para no inflar el log) |
| `level` | string (enum) | `"L1"` \| `"L2"` \| `"L3"` \| `"L4"` |
| `criterion_invoked` | string \| null | ID de la entrada en `irreversibility.md` que disparó L3 (ej. `"IRREV-7"`), o `null` si la clasificación no se basó en lista cerrada |
| `domains_touched` | array<string> | Lista de dominios del firmware afectados (`["subghz"]`, `["nfc", "build"]`, etc.) |
| `justification_short` | string (≤200 chars) | Una línea explicando por qué este nivel |
| `model_version` | string | Identificador del modelo que tomó la decisión (ej. `"claude-opus-4-7"`) |

## Campos opcionales

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `council_id` | string (UUIDv7) \| null | Si `level == "L3"`, ID del Concilio asociado |
| `cost_estimate_tokens` | integer \| null | Estimación de tokens consumidos por esta decisión |
| `cost_estimate_usd` | float \| null | Estimación monetaria derivada de la tabla en `cost-policy.md` |

## Activación de auditor automatizado (Fase 2+)

El auditor Sonnet se activa cuando se cumple **toda** la condición:

- Ventana mínima: 100 decisiones registradas (`N >= 100`).
- Ratio `(L1 + L2) / N > 0.95` durante la ventana.
- O detección manual del usuario de clasificaciones erróneas en una revisión.

Una vez activado:

- Muestreo aleatorio del 5% de las L1+L2 reevaluado por un subagente `council-auditor` (Sonnet, sin contexto de la sesión original).
- Discrepancias acumuladas; si > 15% de las muestras son reclasificadas hacia arriba en ventana de 30 días, el sistema escala al usuario para recalibración del prompt del master.

## Política de retención

- El JSONL es append-only.
- Rotación: cuando supere 100 MB, se mueve a `.claude/state/decisions-YYYYMM.jsonl.gz` (comprimido).
- Nunca se borra (la eliminación matchea D19 entrada 9).
