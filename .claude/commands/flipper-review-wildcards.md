---
description: Lista los wildcards ad-hoc del Concilio que aún no han sido promovidos al catálogo cerrado de ángulos. Útil para decidir si algún wildcard recurrente merece formalizarse como ángulo estable. Opt-in del usuario, no programado.
---

# Flipper Review Wildcards

Has sido invocado vía `/flipper-review-wildcards`. El usuario quiere revisar los ángulos wildcard que el master ha usado en convocatorias del Concilio.

## Procedimiento

1. **Lee `.claude/state/wildcards.jsonl`** (gitignored). Cada línea contiene:
   - `timestamp`
   - `council_id`
   - `wildcard_id` (típicamente `WILD-<timestamp>`)
   - `description`: nombre del ángulo ad-hoc
   - `justification`: 3-5 líneas explicando por qué los 12 ángulos del catálogo no aplicaban
2. **Agrupa los wildcards por descripción semántica similar** (no por ID — cada wildcard tiene un ID único pero pueden tratar del mismo ángulo conceptual con palabras distintas).
3. **Presenta al usuario una tabla**:

   | Descripción (agrupada) | Apariciones | Council IDs | Justificaciones representativas |
   |------------------------|-------------|-------------|--------------------------------|
   | ... | N | [...] | [...] |

4. **Recomienda al usuario**:
   - Wildcards con **3 o más apariciones**: candidatos a promoción al catálogo. Sugerir un ID estable (3 letras mayúsculas) y proponer entry en `.claude/design/council-angles.md`.
   - Wildcards con 1-2 apariciones: dejar como están — pueden ser casos atípicos legítimos sin necesidad de formalización.
5. **No promuevas al catálogo sin aprobación del usuario**. La promoción es modificar `.claude/design/council-angles.md`, que matchea G3 #2 → requiere L3. El proceso es:
   - Tú propones al usuario qué wildcards promover.
   - Usuario aprueba.
   - Tú convocas Concilio (L3) sobre "añadir ángulo X al catálogo" — el Concilio decide si la promoción procede.
   - Tras 2-de-3 SÍ y aprobación humana, se modifica el catálogo vía PR.

## Si el archivo está vacío o no existe

Reporta al usuario: "No hay wildcards registrados. Esto significa que el master no ha necesitado salirse del catálogo de 12 ángulos en las convocatorias del Concilio. Posibilidades: (a) el catálogo cubre bien los casos reales; (b) el master está evitando wildcards por inercia. Sugiero revisar los últimos N concilios para ver si la elección de ángulos fue siempre del catálogo."
