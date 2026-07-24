---
description: Fuerza la convocatoria del Concilio Tripartito sobre $ARGUMENTS, aunque el master no lo consideraría necesario por sí solo. Útil cuando el usuario quiere deliberación adversarial explícita.
---

# Flipper Council (forzar Concilio)

Has sido invocado vía `/flipper-council`. El usuario ha pedido explícitamente que la decisión pase por el Concilio Tripartito (L3) aunque tu criterio de clasificación lo habría puesto en L1 o L2.

## Pregunta / decisión del usuario

$ARGUMENTS

## Procedimiento obligatorio

1. **Construye el dossier obligatorio** según `CLAUDE.md > "Antes de cada L3: dossier obligatorio"`:
   - Lee solo archivos relevantes del codebase (NO uses el historial conversacional como fuente).
   - Escribe a `.claude/decisions/pending/<UUIDv7>/dossier.md` con schema: enunciado (≤200 palabras), archivos consultados (≤10 / ≤20 con justificación), alternativas consideradas (≥2), criterio de irreversibilidad invocado (en este caso: "usuario forzó /flipper-council").
2. **Selecciona 3 ángulos** del catálogo `.claude/design/council-angles.md`. Para decisiones forzadas por el usuario sin criterio G3, ángulos típicos: `ROB`, `SIM`, `SEC` — pero ajusta según la naturaleza de la tarea. Máximo 1 wildcard ad-hoc con justificación expandida (3-5 líneas al log `.claude/state/wildcards.jsonl`).
3. **Lanza 3 invocaciones paralelas** del subagente `council-member` con sus ángulos asignados. Pásales el ID del Concilio para que escriban su veredicto en `.claude/decisions/pending/<id>/concejal-N.md`.
4. **Recoge los 3 veredictos** desde los archivos (no desde la memoria conversacional de las invocaciones).
5. **Sintetiza pero NO votes**. Aplica las reglas de resolución de D11+D21:
   - Unanimidad SÍ o 2-de-3 SÍ → procede; cierra ADR en `.claude/decisions/ADR-NNNN-<slug>.md`.
   - 1-de-3 SÍ → escalado **obligatorio** al usuario (L4). Presenta el dossier + 3 veredictos al usuario sin decidir.
   - 0-de-3 SÍ → propuesta rechazada, ADR documentado como tal.
6. **Loguea en `.claude/state/decisions.jsonl`** con `level: "L3"`, `criterion_invoked: "user-forced"`, `council_id: <UUIDv7>`.

## Atajos válidos dentro del Concilio

- Si en ronda 1 hay unanimidad SÍ sin condiciones, puedes saltar ronda 2 y cerrar directamente.
- Si hay condiciones, lanza ronda 2 (voto sobre síntesis sin compartir veredictos completos).
- Si en ronda 2 hay condiciones nuevas o cruzadas, lanza ronda 3 (validación cruzada).
- Tras ronda 3, si no hay convergencia 2/3, escala al usuario.
