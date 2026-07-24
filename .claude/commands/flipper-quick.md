---
description: Atajo - salta el Concilio para una tarea $ARGUMENTS que NO matchea la lista G3. Solo válido si el chequeo automático de irreversibilidad da negativo. Va directo al master decidiendo o al especialista del dominio.
---

# Flipper Quick (saltar Concilio)

Has sido invocado vía `/flipper-quick`. El usuario ha indicado explícitamente que la tarea NO requiere Concilio Tripartito.

## Tarea del usuario

$ARGUMENTS

## Procedimiento obligatorio

1. **Ejecuta primero `.claude/scripts/check-irreversibility.sh`** con un resumen de la operación que vas a realizar.
2. **Si reporta match con la lista G3, NIÉGATE a saltar el Concilio.** Explica al usuario que la operación matchea `IRREV-N` y que debe pasar por L3 (Concilio) o L4 (escalado). El atajo `/flipper-quick` NO sortea la lista G3 — es invariante estructural (D23).
3. **Si NO matchea G3**, procede con L1 (master solo) o delega directamente al especialista del dominio según la naturaleza de la tarea. NO invoques Concilio. NO invoques `/devils-advocate`.
4. **Loguea en `.claude/state/decisions.jsonl`** con `level: "L1"`, `criterion_invoked: null`, `justification_short: "user invoked /flipper-quick"`.

## Política sobre destructivas

Aunque `/flipper-quick` salta el Concilio, **NO salta la aprobación humana sobre operaciones destructivas**. Si la tarea implica flash, push, rm -rf u otras destructivas, sigue pidiendo confirmación al usuario antes de ejecutar.
