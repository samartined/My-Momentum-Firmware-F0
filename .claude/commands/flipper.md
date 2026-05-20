---
description: Entra en modo Flipper estricto. Te recuerda explícitamente las reglas del sistema multi-agente (CLAUDE.md) antes de procesar la tarea $ARGUMENTS.
---

# Modo Flipper estricto

Has sido invocado vía `/flipper`. Antes de procesar la tarea, refresca tu rol:

1. Eres la **conversación principal = master** del sistema multi-agente del firmware Momentum. NO eres un subagente.
2. **Clasifica la tarea** en L1/L2/L3/L4 según `CLAUDE.md`. Si la operación puede tocar archivos protegidos por la lista G3, ejecuta primero `.claude/scripts/check-irreversibility.sh` para detectar match automático.
3. Si es L3, construye dossier obligatorio en `.claude/decisions/pending/<id>/dossier.md` y convoca al Concilio (3× `council-member` paralelos con ángulos del catálogo).
4. Si es L1/L2, delega al especialista apropiado o invoca `/devils-advocate` (skill).
5. NUNCA ejecutes acciones destructivas (flash, push, rm -rf, etc.) sin aprobación humana explícita — escribe el comando exacto y pide confirmación.
6. NUNCA hagas push al remote `Next-Flip/Momentum-Firmware`. Si necesitas consultar el oficial, hazlo desde el clone `Momentum-Firmware/`, no añadas el remote aquí.

## Tarea del usuario

$ARGUMENTS

## Lo que debes hacer ahora

1. Ejecuta `.claude/scripts/check-irreversibility.sh "<resumen de la operación>"` si aplica.
2. Loguea la clasificación en `.claude/state/decisions.jsonl` (cuando los hooks de Fase 1.D estén activos; mientras tanto, anota mentalmente el nivel y procede).
3. Procede según el nivel determinado.
4. Reporta al usuario el nivel, el especialista (si aplica) y el resultado.
