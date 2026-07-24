---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
ronda: 2
synthesized_by: master (conversación principal Opus)
synthesized_at: 2026-05-23T16:45:00Z
note: |
  Reconstruido retroactivamente vía Bash heredoc tras fallo sistemático de
  la tool Write en esta sesión. El contenido coincide con la descripción
  pasada en los prompts de los 3 concejales de ronda 2, sobre la que
  emitieron sus votos.
---

# Síntesis del master para ronda 2

## Propuesta refinada

Adoptar la **Alternativa A** (añadir `COR` al catálogo cerrado de ángulos del Concilio) **con las siguientes condiciones obligatorias incorporadas al PR de modificación de `.claude/design/council-angles.md`**:

### 1. Reformulación simultánea de `ROB`

La entrada de `ROB` se actualiza en el mismo PR para excluir explícitamente correctitud funcional:

> **ROB — Robustez**: ¿Qué invariante estructural del sistema (lifecycle, estado, recuperación de fallos, manejo de errores) queda verificable tras este cambio? No cubre correctitud del resultado funcional — ver `COR`.

Si esta reformulación no se incluye en el PR, la propuesta entera no procede (precondición dura).

### 2. Pregunta clave operacional para `COR`

> **COR — Correctness**: ¿Existe un caso de entrada concreto donde el output sea distinto del esperado en ≥1 bit, ≥1 byte, o ≥1 registro, y ese caso no esté cubierto por un test o invariante existente?

Predicado verificable (existe contraejemplo: sí/no) que se distingue mecánicamente de `ROB` (que pregunta por la existencia de la garantía, no del contraejemplo).

### 3. Rail de aplicabilidad disjunto con `ROB`

`COR` aplica solo cuando el resultado de la operación es comparable bit-a-bit o byte-a-byte con un esperado:

- Deserialización de formatos estructurados (FAT, NFC dumps, SubGHz keystore, archivos `.sub`/`.nfc`/`.ir`).
- Migraciones de archivos con esquema definido.
- Parsing de protocolos con frame definido.

Se excluye explícitamente (escrito en el catálogo, no solo en el ADR):

- Lógica de control.
- Máquinas de estado.
- UI / scenes / views.
- Scheduling / threading / timing (esto último es `THR`).

Estos casos permanecen en territorio de `ROB`.

### 4. Entrada congelada en el historial del catálogo

La sección "Historial de cambios al catálogo" de `council-angles.md` recibe una entrada con:

- Fecha: `2026-05-23`.
- `council_id`: `62978df1-a1f9-4e2d-8706-750d0ac18c3c`.
- ID del ADR de cierre: `ADR-0001`.
- Definición exacta congelada de `COR` aprobada (texto completo, no por referencia).
- Delimitación explícita frente a `ROB`.

Entrada inmutable; refinamientos futuros generan nueva entrada de historial, no edición in-place.

## Sobre el voto minoritario del Concejal 2

El Concejal 2 votó NO en ronda 1 (YAGNI). La síntesis incorpora la objeción como criterio de retirada empírica documentado en el ADR de cierre:

> Cláusula de retirada: si tras 3 meses de operación del sistema (medido en `decisions.jsonl`) el ángulo `COR` se ha invocado en menos del 10% de las decisiones L3 que tocan dominios elegibles (NFC, SubGHz, storage, parsing), el `agent-architect` debe proponer su retirada del catálogo vía PR humano.

Esto convierte el riesgo en mecanismo de auto-corrección observable.

## Resumen ejecutivo

- Procede la Alternativa A con 4 condiciones obligatorias.
- `ROB` y `COR` se redefinen simultáneamente para garantizar disjunción operacional.
- El catálogo crece a 13 ángulos.
- El voto NO del Concejal 2 se documenta como riesgo conocido + cláusula de retirada empírica a 3 meses.
- Si los 4 puntos no se incluyen íntegros en el PR, la propuesta no procede.
