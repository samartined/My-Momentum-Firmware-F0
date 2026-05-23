---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
created_at: 2026-05-23T16:21:00Z
master_model: claude-opus-4-7
classified_level: L3
criterion_invoked: IRREV-2
context: V2 functional validation of Phase 1.G — synthetic decision designed to exercise the Council end-to-end
---

# Dossier — Decisión: añadir ángulo `COR` al catálogo del Concilio

## Enunciado

¿Debe añadirse un ángulo `COR` (Correctness — integridad funcional/datos) al catálogo cerrado de 12 ángulos del Concilio Tripartito (D18, definido en `.claude/design/council-angles.md`)?

El catálogo actual ya incluye `ROB` (Robustez, definida como "¿qué propiedad del sistema queda verificable tras este cambio?"). La propuesta es que `COR` cubra específicamente la subpropiedad "la operación produce el resultado funcionalmente correcto sin pérdida o corrupción de datos", separada de la robustez general.

Casos reales del firmware Momentum donde un ángulo dedicado a correctness aportaría valor: lectura/escritura NFC sin perder bits, deserialización del keystore SubGHz sin truncamiento, parsing de archivos FAT en SD, integridad de migraciones de archivos al boot (ej. `flipper_migrate_files()` en `furi/flipper.c:58`), persistencia de slots SubGHz/iButton/IR sin corrupción.

## Archivos consultados

- `.claude/design/council-angles.md` — catálogo cerrado actual con 12 ángulos. Relevante porque define los ángulos vigentes (incluido `ROB`) y la regla del wildcard. Es el archivo que se modificaría si la propuesta procede.
- `.claude/design/system-design.md` — sección "El Concilio Tripartito" (líneas 215-277) y decisión D18. Relevante porque explica el rol del catálogo, la disciplina anti-sesgo en la selección de ángulos por parte del master, y por qué el catálogo es cerrado.
- `.claude/design/decisions-schema.md` — schema del log `decisions.jsonl`. Relevante para confirmar que añadir un ángulo no cambia ningún campo del schema (el log no enumera ángulos invocados, solo el nivel y criterio).

Tres archivos consultados, dentro del tope blando de 10 (D27).

## Alternativas consideradas

### Alternativa A — Añadir `COR` como nuevo ángulo del catálogo cerrado (la propuesta principal)

Crear entrada `COR` en `.claude/design/council-angles.md` con:

- **Pregunta clave**: "¿La operación produce el resultado funcionalmente correcto sin pérdida o corrupción de datos?"
- **Aplicable cuando**: lectura/escritura de protocolos (NFC/SubGHz/RFID/IR), parsing de archivos, migraciones, código que serializa/deserializa.

Trade-offs:

- **+** Distinción explícita entre robustez (verificabilidad estructural) y correctitud (resultado funcional).
- **+** Reduce el uso de wildcard en casos de I/O y parsing, que son frecuentes en este firmware embedded.
- **−** El catálogo crece a 13 ángulos. Más opciones que elegir significa más espacio para sesgo del master al seleccionar el trío.
- **−** Riesgo de solape con `ROB` si las definiciones no son lo suficientemente disjuntas. Un concejal podría preguntarse "¿esto es mi ángulo o el de COR?".

### Alternativa B — NO añadir; usar wildcard ad-hoc cuando aparezca

Dejar el catálogo en 12. Cuando una decisión requiera un ángulo de correctness explícito, el master crea un wildcard `WILD-<timestamp>` con justificación expandida (3-5 líneas) escrita a `.claude/state/wildcards.jsonl` según D18.

Trade-offs:

- **+** El catálogo permanece pequeño y disciplinado.
- **+** El proceso de wildcard ya está diseñado precisamente para casos atípicos legítimos.
- **−** Si correctness es relevante en muchas decisiones del firmware (probable en NFC/SubGHz/storage), los wildcards recurrentes inflarán el log. El comando `/flipper-review-wildcards` propondrá promover el ángulo igualmente. Termina en la Alternativa A pero con retraso y datos empíricos.

### Alternativa C — Reformular `ROB` para incluir correctness explícitamente

Cambiar la definición de `ROB` de "¿qué propiedad del sistema queda verificable tras este cambio?" a "¿qué propiedad funcional o estructural queda verificable y correcta tras este cambio?".

Trade-offs:

- **+** Mantiene el catálogo en 12.
- **+** "Robustez" en sentido amplio históricamente incluye correctness en muchas literaturas (Lamport, Lynch, etc.).
- **−** Diluye `ROB`: el concejal asignado a ROB tendría que cubrir dos sub-propiedades distintas en una sola respuesta. Pierde foco.
- **−** Cambia retroactivamente la definición de un ángulo ya en uso. Cualquier ADR futuro o histórico con `ROB` quedaría con una definición distinta de la documentada al momento de su emisión.

## Criterio de irreversibilidad invocado

`IRREV-2` — la decisión modifica `.claude/design/council-angles.md` (Alternativas A y posiblemente C también tocan `system-design.md`). El matching automático del script `.claude/scripts/check-irreversibility.sh` fuerza el nivel L3 estructuralmente (D23 hard rule); el master no puede decidir solo (L1) ni invocar `/devils-advocate` (L2).

## Ángulos seleccionados para los 3 concejales

- **Concejal 1**: `ORT` (Ortogonalidad). Pregunta: ¿el ángulo propuesto es ortogonal a los existentes (especialmente `ROB`) o introduce solape problemático?
- **Concejal 2**: `SIM` (Simplicidad). Pregunta: ¿el catálogo gana o pierde claridad operacional al añadir un ángulo más?
- **Concejal 3**: `MNT` (Mantenibilidad). Pregunta: ¿quién decide cuándo aplicar `COR` vs `ROB` en runtime? ¿la distinción es operacionalmente útil dentro de 6 meses cuando los archivos consultados no se recuerden de memoria?

No se invoca wildcard en esta sesión del Concilio.

## Nota meta

Esta deliberación es la **validación funcional V2** de Fase 1.G (el último de los 4 criterios de "done" definidos en `.claude/design/phases.md`). Su decisión real es subordinada al objetivo principal de la sesión, que es ejercitar end-to-end el Concilio para confirmar que el sistema funciona. Cualquiera de las 3 alternativas es defendible; los concejales deben razonar como si la decisión tuviera impacto real para que la validación sea rigurosa.
