---
id: ADR-0001
title: Añadir ángulo `COR` (Correctness) al catálogo cerrado del Concilio Tripartito
status: accepted
date: 2026-05-23
decision-level: L3
council-id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
dossier: .claude/decisions/pending/62978df1-a1f9-4e2d-8706-750d0ac18c3c/dossier.md
synthetic: true
synthetic-purpose: Validación funcional V2 de Fase 1.G — ejercicio end-to-end del Concilio
materialization-status: materialized
materialization-date: 2026-05-23
materialization-files:
  - .claude/design/council-angles.md (ROB reformulado, COR añadido, sección "Notas operacionales para COR", entrada 1 en historial)
  - .claude/design/decisions-schema.md (campo opcional eligible_for_cor)
  - .claude/design/phases.md (Revisión 1 calendarizada para 2026-08-23)
---

# ADR-0001 — Añadir ángulo `COR` (Correctness) al catálogo del Concilio

## Status

`accepted` (3-de-3 SÍ tras ronda 3 de validación cruzada de condiciones; unanimidad sin vetos).

**Nota meta**: esta deliberación fue construida como **decisión sintética** para la validación funcional V2 de Fase 1.G del sistema multi-agente. Tras cierre del Concilio con unanimidad, el usuario decidió **materializarla efectivamente** (opción (a), 2026-05-23). El cambio está aplicado en los siguientes archivos:

- `.claude/design/council-angles.md`: `ROB` reformulado, `COR` añadido (catálogo a 13 ángulos), sección "Notas operacionales para `COR`" con rail disjunto, definición operacional de elegibilidad y guard de co-invocación; entrada 1 en "Historial de cambios al catálogo" con definición congelada, comparador semántico y cláusula de retirada.
- `.claude/design/decisions-schema.md`: campo opcional `eligible_for_cor` añadido (C2-N1).
- `.claude/design/phases.md`: "Calendario activo de revisiones" → "Revisión 1" calendarizada para `2026-08-23` con owner `agent-architect` (C2-N3, C3-N1).

## Context

El catálogo cerrado de ángulos del Concilio Tripartito (D18 en `system-design.md`, definido en `.claude/design/council-angles.md`) cuenta con 12 ángulos vigentes, incluyendo `ROB` (Robustez), cuya pregunta clave actual es "¿qué propiedad del sistema queda verificable tras este cambio?".

La propuesta evalúa si añadir un ángulo `COR` (Correctness) que cubra específicamente la sub-propiedad "la operación produce el resultado funcionalmente correcto sin pérdida o corrupción de datos", separada operacionalmente de la robustez estructural. Casos del firmware Momentum donde un ángulo dedicado aportaría valor: lectura/escritura NFC sin perder bits, deserialización del keystore SubGHz, parsing FAT, integridad de migraciones (`flipper_migrate_files()` en `furi/flipper.c:58`), persistencia de slots SubGHz/iButton/IR.

El criterio de irreversibilidad invocado es **IRREV-2** (la decisión modifica archivos bajo `.claude/design/`), lo que estructuralmente fuerza nivel L3 (Concilio) según el script `check-irreversibility.sh` (D23 — hard rule).

## Alternatives considered

### Alternativa A — Añadir `COR` como nuevo ángulo del catálogo cerrado (la propuesta principal)

Crear entrada `COR` con pregunta clave operacional y "aplicable cuando" restringido a I/O comparable bit-a-bit.

- **+** Distinción explícita robustez (verificabilidad estructural) vs correctitud (resultado funcional).
- **+** Reduce wildcards en I/O y parsing, frecuentes en firmware embedded.
- **−** Catálogo crece a 13 ángulos: más espacio combinatorio para sesgo del master (C(13,3)=286 vs C(12,3)=220, +30%).
- **−** Riesgo de solape con `ROB` si las definiciones no son operacionalmente disjuntas.

### Alternativa B — No añadir; usar wildcard ad-hoc cuando aparezca

Dejar el catálogo en 12. Cuando se requiera ángulo de correctness, master crea wildcard con justificación expandida en `.claude/state/wildcards.jsonl` (D18). Promoción opt-in vía `/flipper-review-wildcards` cuando aparezca recurrencia.

- **+** Catálogo permanece pequeño y disciplinado. Implementación mínima (cero líneas).
- **+** El mecanismo de wildcard ya existe precisamente para casos atípicos.
- **−** Si correctness es frecuente, los wildcards recurrentes inflarán el log; termina en A pero con retraso.

### Alternativa C — Reformular `ROB` para incluir correctness explícitamente

Cambiar la definición de `ROB` a "¿qué propiedad funcional o estructural queda verificable y correcta tras este cambio?".

- **+** Mantiene el catálogo en 12.
- **+** Robustez en literatura formal (Lamport, Lynch) históricamente incluye correctness.
- **−** Diluye `ROB`: un concejal asignado tendría que cubrir dos sub-propiedades distintas en una sola respuesta.
- **−** Cambia retroactivamente la definición de un ángulo ya en uso (ADRs históricos con `ROB` quedan con definición distinta).

## Decision

**Alternativa A**, con **11 condiciones obligatorias** que el Concilio fijó a través de 3 rondas de deliberación.

### Condiciones de síntesis (master, ronda 2, condensando ronda 1)

**S1. Reformulación simultánea de `ROB`** en el mismo PR que introduce `COR`:

> **ROB — Robustez**: ¿Qué invariante estructural del sistema (lifecycle, estado, recuperación de fallos, manejo de errores) queda verificable tras este cambio? No cubre correctitud del resultado funcional — ver `COR`.

Si esta reformulación no se incluye, la propuesta no procede (precondición dura).

**S2. Pregunta clave operacional para `COR`**:

> **COR — Correctness**: ¿Existe un caso de entrada concreto donde el output sea distinto del esperado en ≥1 bit, ≥1 byte, o ≥1 registro, y ese caso no esté cubierto por un test o invariante existente?

Predicado verificable (¿existe contraejemplo? sí/no) que se distingue mecánicamente de `ROB` (existencia de garantía, no de contraejemplo).

**S3. Rail de aplicabilidad disjunto con `ROB`**. `COR` aplica solo cuando el resultado es comparable bit-a-bit o byte-a-byte con un esperado:

- Deserialización de formatos estructurados (FAT, NFC dumps, SubGHz keystore, archivos `.sub`/`.nfc`/`.ir`).
- Migraciones de archivos con esquema definido.
- Parsing de protocolos con frame definido.

Se excluye explícitamente (en el catálogo, no solo en el ADR): lógica de control, máquinas de estado, UI/scenes/views, scheduling/threading/timing (esto último es `THR`).

**S4. Entrada congelada en el historial del catálogo** (sección "Historial de cambios al catálogo" de `council-angles.md`) con: fecha, `council_id`, ID del ADR, definición exacta congelada de `COR` (texto completo, no por referencia), delimitación explícita frente a `ROB`. Entrada inmutable; refinamientos futuros generan nueva entrada, no edición in-place.

### Condiciones nuevas aceptadas (ronda 3, unanimidad)

**C1-N1 (origen: Concejal 1 — ORT)**. Métrica de disjunción operacional en la auditoría a 3 meses: contar dossieres que co-asignaron `ROB`+`COR` y cuántos veredictos resultantes fueron textualmente solapantes (>70% de razones compartidas). Si la tasa de co-asignación con solape supera el 30%, la separación se considera fallida desde ORT y se retira `COR`.

> **Nota técnica (concejal 2, ronda 3)**: calibrar el umbral 70%/30% manualmente sobre el corpus real a 3 meses (esperablemente <20 dossieres) en lugar de congelarlo como invariante ex ante.
>
> **Nota técnica (concejal 3, ronda 3)**: el comparador semántico (diff de tokens, embedding, o checklist de subtemas) debe quedar especificado en la misma entrada de historial, no diferido.

**C1-N2 (origen: Concejal 1 — ORT)**. Hasta la primera auditoría a 3 meses, el master debe registrar en el dossier de cada L3 que invoque `ROB`+`COR` simultáneamente una justificación de una línea de por qué la decisión requiere las dos lentes y no es expresable como una sola. Trazabilidad ligera; los datapoints alimentan la auditoría.

**C2-N1 (origen: Concejal 2 — SIM)**. El umbral de retirada (<10% de elegibles, ver C2-N2) implementado como **query reproducible** sobre `decisions.jsonl`, no como prosa. Cada entrada L3 incluye un campo `eligible_for_cor: true|false` marcado por el master en clasificación.

**C2-N2 (origen: Concejal 2 — SIM)**. La definición operacional de "elegible para COR" documentada en `council-angles.md` junto a la entrada del ángulo, con criterios objetivos verificables por inspección del enunciado del dossier: involucra I/O de protocolos, parsing, migración, serialización. Sin esto, el divisor del cociente "<10%" queda indeterminado.

**C2-N3 (origen: Concejal 2 — SIM)**. Revisión obligatoria a los 3 meses calendarizada (cron, recordatorio en `phases.md`, o equivalente), no opcional. Cláusulas de retirada que dependen de iniciativa proactiva sistemáticamente no se ejecutan.

**C3-N1 (origen: Concejal 3 — MNT)**. Owner de la medición a 3 meses = `agent-architect`. Sink del resultado = entrada adicional en "Historial de cambios al catálogo" con formato fijo: `{fecha, council_id_origen, invocaciones_observadas, decisión: mantener | retirar | reevaluar-a-6m}`, incluso si la decisión es mantener sin cambios.

**C3-N2 (origen: Concejal 3 — MNT)**. Umbral numérico congelado ex ante: **menos de 2 invocaciones reales de `COR` en ventana de 3 meses contados desde la aprobación** dispara propuesta de retirada. Umbral inmodificable sin nueva entrada de changelog.

> **Nota interpretativa (concejal 1, ronda 3)**: C3-N2 (umbral de uso bajo) y C1-N1 (umbral de solape alto) deben aplicarse como **OR lógico**, no AND. La retirada procede si `COR` falla en cualquiera de las dos métricas (poco uso O alto solape), no solo en ambas.

### Cláusula de retirada empírica (consolidada)

Tras 3 meses de operación desde aprobación, el `agent-architect` ejecuta auditoría sobre `decisions.jsonl` y produce entrada en historial con:

| Métrica | Disparador de retirada |
|---|---|
| Invocaciones reales de `COR` | < 2 en 3 meses (C3-N2) |
| Tasa de co-asignación `ROB`+`COR` con solape >70% | > 30% del subconjunto co-asignado (C1-N1) |

**Lógica**: OR (retira si falla cualquiera). Resultado se loguea como entrada en "Historial de cambios al catálogo".

## Council votes

### Ronda 1 (independencia preservada — concejales no ven veredictos entre sí)

| Concejal | Ángulo | Recomendación | Voto | Resumen |
|---|---|---|---|---|
| 1 | ORT (Ortogonalidad) | MODIFICAR | SÍ-CON-CONDICIONES | Solape `ROB`/`COR` no disjunto sin reformulación simultánea. 4 condiciones. |
| 2 | SIM (Simplicidad) | RECHAZAR | **NO** | YAGNI: wildcard ya es la implementación mínima; sin datapoints empíricos de recurrencia. |
| 3 | MNT (Mantenibilidad) | MODIFICAR | SÍ-CON-CONDICIONES | Pregunta clave no operacionalizada; rail demasiado laxo; historial vacío. 3 condiciones. |

Conteo ronda 1: **2 SÍ-CON-CONDICIONES / 1 NO**. Estructuralmente 2-de-3, pero las condiciones de C1 y C3 son sustantivas y el voto NO de C2 (YAGNI sin datapoints) es válido — master sintetiza para ronda 2.

### Ronda 2 (sobre síntesis del master con 4 condiciones + cláusula de retirada empírica a 3 meses)

| Concejal | Ángulo | Voto | Condiciones nuevas |
|---|---|---|---|
| 1 | ORT | SÍ-CON-CONDICIONES-NUEVAS | 2 (C1-N1, C1-N2) |
| 2 | SIM | **SÍ-CON-CONDICIONES-NUEVAS** (cambio desde NO) | 3 (C2-N1, C2-N2, C2-N3) |
| 3 | MNT | SÍ-CON-CONDICIONES-NUEVAS | 2 (C3-N1, C3-N2) |

Conteo ronda 2: **3 SÍ / 0 NO**. El concejal 2 (SIM) cambió de NO a SÍ gracias a la cláusula de retirada empírica que convierte la decisión "permanente arriesgada" en "experimento con condición de parada explícita".

### Ronda 3 (validación cruzada de las 7 condiciones nuevas)

Cada concejal evalúa las condiciones nuevas de los OTROS 2 (lee solo la sección "Condiciones nuevas" para preservar independencia razonada).

| Concejal | Ángulo | Voto final | Condiciones vetadas | Notas |
|---|---|---|---|---|
| 1 | ORT | **SÍ** | Ninguna | C3-N2 con nota (OR lógico, no AND) |
| 2 | SIM | **SÍ** | Ninguna | C1-N1 con nota (calibrar umbral sobre corpus real) |
| 3 | MNT | **SÍ** | Ninguna | C1-N1 con nota (especificar comparador en historial) |

Conteo ronda 3: **3 SÍ / 0 vetos / unanimidad sobre el paquete completo**. Las 7 condiciones nuevas entran al ADR; las 3 notas técnicas se incorporan como refinamientos.

### Voto minoritario histórico (transición de ronda 1 → ronda 2)

El **Concejal 2 (SIM)** votó **NO** en ronda 1 con argumento YAGNI/falta de evidencia empírica. Su objeción central no fue rebatida sino **incorporada como mecanismo de auto-corrección**: la síntesis del master añadió la cláusula de retirada empírica a 3 meses con criterios medibles. En ronda 2, C2 cambió a SÍ-CON-CONDICIONES-NUEVAS razonando que "la cláusula con umbral medible y plazo definido transforma la decisión en un experimento con condición de parada explícita; eso es exactamente lo que SIM exige para tolerar una extensión especulativa del catálogo".

**Esta transición se documenta como riesgo conocido del ADR**: la decisión solo es legítima mientras la cláusula de retirada empírica permanezca activa y observable. Si en algún momento se diluye (sin auditoría, sin owner, sin umbrales medibles), el voto minoritario original recupera fuerza y la decisión debe revisarse.

## Consequences

### Positivas

- Distinción operacionalmente disjunta entre robustez estructural (`ROB`) y correctitud funcional (`COR`) en el catálogo.
- Reduce wildcards recurrentes en dominios de I/O del firmware (NFC, SubGHz, RFID, IR, storage).
- Introduce primer precedente de **cláusula de retirada empírica** en el catálogo cerrado — el ratchet de catálogo (solo crecer) deja de ser monótono.
- Las 4+7=11 condiciones constituyen un patrón replicable para futuras extensiones del catálogo: pregunta clave operacional, rail disjunto, historial congelado, owner, sink, métricas de retirada.
- El voto NO→SÍ del Concejal 2 valida empíricamente el diseño de las rondas múltiples del Concilio (D18 + arquitectura general).

### Negativas / riesgos asumidos

- **Crecimiento del catálogo a 13 ángulos** (+30% combinatoria de selección, C(13,3)=286). El sesgo de selección del master sube proporcionalmente y la mitigación depende de la disciplina del rail "aplicable cuando".
- **Riesgo de doble asignación encubierta `ROB`+`COR`**. Aunque las definiciones son disjuntas tras S1+S2+S3, el master puede asignar ambos al mismo trío. La condición C1-N2 (justificación de una línea por co-invocación) es el guard ligero; la auditoría a 3 meses es el remedio.
- **Deuda de implementación**: las condiciones C2-N1 (campo `eligible_for_cor` en `decisions.jsonl`) y C2-N3 (calendario activo de revisión) requieren cambios en herramientas de log y en `phases.md`. Hasta que se implementen, la cláusula de retirada no es efectivamente operacional.
- **Voto minoritario condicional**: la decisión solo es legítima mientras la cláusula de retirada empírica permanezca activa y observable.

### Reversibilidad

- ¿Matchea G3? **Sí — IRREV-2** (modifica `.claude/design/council-angles.md`).
- ¿Cómo se deshace? Mediante el propio mecanismo de retirada empírica fijado en este ADR: tras 3 meses, si la métrica falla (C3-N2 OR C1-N1), el `agent-architect` propone retirada vía PR humano. Cualquier retirada anticipada también requiere PR humano (D18 — el catálogo cerrado se modifica solo así).
- Coste de salida: una entrada adicional en el historial del catálogo con `decisión: retirar`. No invalida ADRs futuros que invocaron `COR` correctamente durante el periodo de prueba — quedan como histórico.

## Follow-ups

### F1 — Decisión del usuario sobre materialización [RESUELTO 2026-05-23]

Esta deliberación se construyó como **decisión sintética para la validación V2 de Fase 1.G**. El usuario eligió **opción (a) — materializar completo**.

Cambios aplicados en este commit:

- `.claude/design/council-angles.md`: `ROB` reformulado, `COR` añadido como ángulo 13, sección "Notas operacionales para `COR`" añadida, entrada 1 al "Historial de cambios al catálogo" con definición congelada + comparador semántico + cláusula de retirada empírica.
- `.claude/design/decisions-schema.md`: campo opcional `eligible_for_cor: boolean` añadido.
- `.claude/design/phases.md`: sección "Calendario activo de revisiones" añadida con "Revisión 1" calendarizada para `2026-08-23`.

### F2 — Implementación de la cláusula de retirada empírica [COMPLETADO 2026-05-23]

- ✅ Campo `eligible_for_cor: bool` añadido al schema (`.claude/design/decisions-schema.md`).
- ✅ Entrada de calendario activo en `.claude/design/phases.md` (Revisión 1, 2026-08-23).
- ✅ Comparador semántico especificado en `council-angles.md` (checklist cerrada de 7 subtemas; alternativa: diff de tokens significativos con umbral 70%).

### F3 — Auditoría a 3 meses (programada para 2026-08-23)

Fecha: `2026-08-23`. Owner: `agent-architect`. Referencia operacional: `phases.md` → "Calendario activo de revisiones" → "Revisión 1".

Disparadores de retirada (OR):
- < 2 invocaciones de `COR` en ventana.
- > 30% de co-asignaciones `ROB`+`COR` con razones solapantes >70%.

Sink: entrada en "Historial de cambios al catálogo" de `council-angles.md` con formato `{fecha, council_id_origen, invocaciones_observadas, decisión}`.

### F4 — Lecciones meta del flujo (independiente de F1)

- **3 rondas del Concilio sobre L3 funcionó**: ronda 1 (independencia), ronda 2 (síntesis del master + reconsideración), ronda 3 (validación cruzada de condiciones — preserva independencia razonada).
- **El voto minoritario rebatible vía mecanismo** (no vía argumento) es el patrón valioso: SIM cambió de NO a SÍ porque la síntesis añadió cláusula de retirada, no porque se le rebatiera el YAGNI.
- **Bug de `Write`** detectado mid-sesión y workaround vía Bash heredoc documentado en RESUME.md. En la sesión actual el bug está resuelto.
- Estas lecciones son material para enriquecer `system-design.md` o `phases.md` con un párrafo de "aprendizajes meta operacionales" — fuera del scope de este ADR.
