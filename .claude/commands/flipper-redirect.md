---
description: Corrige el routing en runtime cuando el master delegó al especialista equivocado o un especialista respondió con out_of_scope. $ARGUMENTS es el nombre del especialista correcto al que reasignar la tarea.
---

# Flipper Redirect (corrige routing en runtime)

Has sido invocado vía `/flipper-redirect <especialista>`. El usuario ha detectado que la respuesta del especialista anterior no era adecuada (mal routing) y quiere reasignar la tarea.

## Especialista correcto

$ARGUMENTS

## Procedimiento

1. **Marca el routing previo como erróneo** en `.claude/state/routing-errors.jsonl` (gitignored). Línea JSON con:
   - `timestamp` (ISO 8601)
   - `original_agent`: el subagente al que delegaste antes
   - `corrected_agent`: el especialista que el usuario indica ahora
   - `task_hash`: SHA-256 del enunciado de la tarea
   - `reason`: si el usuario lo proporciona, breve nota
2. **Reanuda la tarea** invocando el especialista correcto vía tool Agent. Pásale:
   - El enunciado de la tarea original (reconstruido desde el contexto reciente).
   - Nota explícita: "Routing corregido. El especialista anterior (`<original_agent>`) no era adecuado por <razón>. Ignora cualquier respuesta previa de aquel especialista."
3. **Si el routing erróneo fue causado por flag `out_of_scope: true` del especialista anterior**, NO esperes a que el usuario use `/flipper-redirect` — la reasignación al architect debe ser automática (D26 segunda parte). El comando manual es para casos donde el usuario detecta el error antes que el especialista.

## Aprendizaje longitudinal

El log `routing-errors.jsonl` se revisa periódicamente (sin frecuencia obligatoria) para detectar patrones: si el master rutea sistemáticamente mal en un dominio concreto, su prompt o las reglas de routing en `CLAUDE.md` deben recalibrarse.
