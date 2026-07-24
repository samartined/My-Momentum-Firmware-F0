# Catálogo de ángulos del Concilio Tripartito

Este documento es el catálogo cerrado de ángulos que el master puede asignar a los 3 concejales al convocar al Concilio (nivel L3). Cada ángulo tiene un ID estable para que los logs de deliberación sean parseables longitudinalmente.

Resolución del Concilio: D18.

## Reglas de uso

- El master selecciona exactamente 3 ángulos del catálogo cuando convoca al Concilio.
- Cada concejal recibe un único ángulo asignado y debe argumentar desde él.
- Máximo 1 ángulo wildcard ad-hoc (fuera de catálogo) por sesión, con justificación expandida de 3-5 líneas escrita al log de deliberaciones.
- Promoción de wildcard al catálogo: comando `/flipper-review-wildcards` opt-in del usuario.
- Extensión del catálogo: vía PR humano. No se permite añadir ángulos en runtime.

## Catálogo (13 ángulos vigentes)

| ID | Ángulo | Pregunta clave | Aplicable cuando |
|----|--------|----------------|------------------|
| ROB | Robustez | ¿Qué invariante estructural del sistema (lifecycle, estado, recuperación de fallos, manejo de errores) queda verificable tras este cambio? No cubre correctitud del resultado funcional — ver `COR`. | Decisiones que tocan el runtime del firmware o el sistema agente, exceptuando transformaciones input→output con esperado comparable |
| COR | Correctness | ¿Existe un caso de entrada concreto donde el output sea distinto del esperado en ≥1 bit, ≥1 byte, o ≥1 registro, y ese caso no esté cubierto por un test o invariante existente? | Deserialización de formatos estructurados (FAT, NFC dumps, SubGHz keystore, archivos `.sub`/`.nfc`/`.ir`); migraciones de archivos con esquema; parsing de protocolos con frame definido. Ver "Notas operacionales para `COR`". |
| SIM | Simplicidad | ¿Cuál es la implementación mínima que cubre el caso? | Refactors, nuevas features, mecanismos de control |
| SEC | Seguridad | ¿Qué vector de ataque o fuga abre o cierra esta decisión? | Cualquier cosa que toque credenciales, criptografía, ACL |
| REV | Reversibilidad | ¿Cuánto cuesta deshacer esta decisión si resulta mala? | Decisiones con impacto > 1 día de trabajo |
| COS | Coste-token | ¿Cuántas llamadas a modelo añade y de qué tier? | Cualquier mecanismo que invoca subagentes |
| UPS | Compatibilidad upstream | ¿Esto cierra la puerta a contribuir al firmware oficial? | Refactors que tocan código compartido con Next-Flip |
| MNT | Mantenibilidad | ¿Quién mantiene esto dentro de 6 meses? | Decisiones con nuevas dependencias o frameworks |
| UX | Ergonomía de usuario | ¿Añade fricción para el operador del Flipper? | Cualquier UI, slash command, flujo del usuario |
| ORT | Ortogonalidad | ¿Esta feature se ortogona con las existentes o las acopla? | Decisiones de arquitectura del firmware |
| ENE | Energía/batería | ¿Afecta consumo del dispositivo? | Código que toca radio, display, GPIO |
| BIN | Tamaño binario | ¿Cabe en flash y RAM disponibles? | Nuevas apps, librerías, assets |
| THR | Threading/timing | ¿Hay condiciones de carrera o violaciones de timing? | Código que toca FreeRTOS, interrupciones, hardware |

## Notas operacionales para `COR`

Añadido por ADR-0001 (`2026-05-23`). Estas notas son parte de la definición congelada del ángulo y deben leerse siempre que el master considere asignarlo.

### Excluido explícitamente de `COR`

`COR` **no aplica** a:

- Lógica de control y máquinas de estado.
- UI, scenes, views.
- Scheduling, threading, timing (esto último cae en `THR`).
- Lifecycle de recursos, recuperación de fallos, manejo de errores estructurales (eso es `ROB`).

`COR` aplica solo cuando el resultado de la operación es comparable bit-a-bit o byte-a-byte con un esperado concreto.

### Definición operacional de "elegible para `COR`"

Una decisión L3 es **elegible para `COR`** (campo `eligible_for_cor: true` en `decisions.jsonl`) si y solo si su enunciado del dossier menciona, de manera verificable por inspección, al menos uno de los siguientes criterios objetivos:

- Involucra **I/O de protocolos físicos**: NFC, SubGHz, RFID, iButton, IR, BLE en su capa de frame/payload.
- Involucra **parsing** de archivos estructurados con esquema (FAT, archivos `.sub`/`.nfc`/`.ir`, dumps de assets).
- Involucra **migración** de archivos o estructuras con esquema definido.
- Involucra **serialización/deserialización** entre representaciones (keystore, slots guardados, configuraciones persistidas).

Si una decisión L3 no cae en ninguno de los criterios anteriores, **no es elegible para `COR`** y el master debe marcar `eligible_for_cor: false` en su entrada del log.

### Guard de co-invocación `ROB`+`COR`

Hasta la primera auditoría a 3 meses (`2026-08-23`, ver "Historial de cambios al catálogo"), si el master asigna **simultáneamente** `ROB` y `COR` al mismo Concilio, el dossier debe incluir una **justificación de una línea** explicando por qué la decisión requiere las dos lentes y no es expresable como una sola.

## Wildcard

Si ninguno de los 12 ángulos captura adecuadamente la perspectiva crítica para una decisión, el master puede definir un wildcard ad-hoc para esa sesión. Requisitos:

- Identificador temporal: `WILD-<timestamp>`.
- Justificación expandida (3-5 líneas) sobre por qué los ángulos del catálogo no aplican.
- La justificación se escribe a `.claude/state/wildcards.jsonl` con timestamp, ID del Concilio, ángulo wildcard, justificación.
- Si `/flipper-review-wildcards` detecta el mismo wildcard recurrente, el usuario decide si promoverlo al catálogo mediante PR.

## Historial de cambios al catálogo

Esta sección es **append-only**. Cada entrada queda congelada con la fecha, el `council_id` de origen, el ID del ADR de cierre y la definición exacta aprobada. Refinamientos futuros generan **nueva entrada**, no edición in-place.

---

### Entrada 1 — 2026-05-23 — Adición del ángulo `COR`

- **Fecha**: `2026-05-23`
- **`council_id` de origen**: `62978df1-a1f9-4e2d-8706-750d0ac18c3c`
- **ADR de cierre**: [`ADR-0001-add-cor-angle.md`](../decisions/ADR-0001-add-cor-angle.md)
- **Cambio**: añadido ángulo `COR` (Correctness); reformulación simultánea de `ROB` para excluir correctitud funcional.

**Definición congelada de `COR` aprobada en esta entrada:**

> **Pregunta clave**: ¿Existe un caso de entrada concreto donde el output sea distinto del esperado en ≥1 bit, ≥1 byte, o ≥1 registro, y ese caso no esté cubierto por un test o invariante existente?
>
> **Aplicable cuando**: Deserialización de formatos estructurados (FAT, NFC dumps, SubGHz keystore, archivos `.sub`/`.nfc`/`.ir`); migraciones de archivos con esquema; parsing de protocolos con frame definido.

**Delimitación frente a `ROB`** (frase canónica):

> `COR` aplica cuando hay un esperado concreto comparable; `ROB` aplica cuando se afirma una propiedad sin contraejemplo concreto.

**Cláusula de retirada empírica (auditoría a 3 meses)**:

- **Owner**: `agent-architect`.
- **Fecha de auditoría**: `2026-08-23` (3 meses desde aprobación).
- **Disparadores de retirada (lógica OR — basta con que falle uno)**:
  - **C3-N2 (uso bajo)**: menos de **2 invocaciones reales** de `COR` en la ventana de 3 meses.
  - **C1-N1 (alto solape)**: más del **30% de los Concilios que co-asignaron `ROB`+`COR`** producen veredictos con razones textualmente solapantes en >70%.
- **Comparador semántico para "razones solapantes"**: checklist de subtemas argumentados (lista cerrada: garantía estructural, contraejemplo concreto, lifecycle, parsing, integridad de datos, manejo de error, esquema/frame). Dos veredictos solapan si comparten >70% de la lista de subtemas argumentados. Comparador alternativo permitido: diff de tokens significativos con umbral 70%. La auditoría documenta cuál usó.
- **Sink del resultado** (formato fijo, entrada futura en este historial):
  - `{fecha, council_id_origen, invocaciones_observadas, decisión: mantener | retirar | reevaluar-a-6m}`
- La entrada de auditoría debe registrarse **incluso si la decisión es mantener sin cambios** — la trazabilidad longitudinal del catálogo lo exige.

**Sobre el umbral 70%/30% (nota técnica de ronda 3)**: en la primera auditoría, el `agent-architect` debe calibrar el umbral manualmente sobre el corpus real (esperablemente <20 dossieres) antes de mecanizarlo. El umbral 70%/30% es la propuesta inicial; ajustes razonados se documentan en la entrada de auditoría.

**Estado de materialización**: aplicado en este commit. Modificaciones acompañantes:
- `.claude/design/decisions-schema.md`: añadido campo opcional `eligible_for_cor`.
- `.claude/design/phases.md`: añadida entrada de calendario activo para `2026-08-23`.


