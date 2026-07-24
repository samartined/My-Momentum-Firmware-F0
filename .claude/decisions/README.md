# ADRs del sistema multi-agente

Este directorio contiene los **Architecture Decision Records (ADRs)** generados por el Concilio Tripartito (L3) o por escalado del usuario (L4) durante la operación del sistema.

## Distinción importante

- `.claude/design/system-design.md` documenta **el sistema agente** (cómo funciona). Sus decisiones D1-D27 son sobre la arquitectura del sistema mismo.
- Los **ADRs en este directorio** documentan **decisiones operativas tomadas POR el sistema** sobre el firmware o sobre su propia evolución durante operación normal (Fase 2 en adelante).

Si la decisión es "cómo funciona el sistema agente", va a `system-design.md`. Si la decisión es "qué hacemos con esta feature/refactor/agente concreto", va aquí como ADR.

## Nombrado y numeración

- Cada ADR: `ADR-NNNN-<slug>.md`
- `NNNN`: número monotónico (0001, 0002, ...) en orden de creación.
- `<slug>`: kebab-case del título (ej. `add-subghz-protocol-x`).

## Estructura de un ADR

Cada ADR tiene las siguientes secciones obligatorias:

1. **Header**: título, status, fecha, decision-level (L3/L4), council-id (si L3), referencia al dossier en `pending/<id>/`.
2. **Status**: `proposed | accepted | superseded by ADR-NNNN | deprecated`.
3. **Context**: descripción del problema o decisión a tomar, reconstruida desde el dossier (no desde memoria conversacional).
4. **Alternatives considered**: ≥2 alternativas reales con sus trade-offs explícitos.
5. **Decision**: la opción elegida + por qué.
6. **Council votes** (solo L3): tabla con concejal, ángulo, voto (`SÍ` / `NO` / `SÍ-CON-CONDICIONES`), razones y riesgos. Voto minoritario se documenta explícitamente como riesgo conocido si la decisión procedió con 2-de-3.
7. **Consequences**: positivas, negativas/riesgos asumidos, reversibilidad (¿matchea G3? ¿cómo se deshace?).
8. **Follow-ups**: tareas o decisiones derivadas dependientes.

## Directorio `pending/<id>/`

Mientras el Concilio está en curso (antes de cerrar el ADR), los artefactos intermedios viven en `.claude/decisions/pending/<UUIDv7>/`:

- `dossier.md`: construido por el master antes de invocar al Concilio (schema definido en `system-design.md` → sección "Dossier obligatorio antes de L3").
- `concejal-1.md`, `concejal-2.md`, `concejal-3.md`: veredictos paralelos de la ronda 1.
- `synthesis.md` (si aplica): síntesis del master sobre los 3 veredictos para ronda 2.
- `vote-round-2.md`, `vote-round-3.md`: votos sobre síntesis y validación cruzada de condiciones.

Al cerrar el ADR (`status: accepted` tras 2-de-3 SÍ o unanimidad), los artefactos de `pending/<id>/` pueden archivarse o mantenerse según política de retención. Eliminarlos matchea G3 #9 (logs de auditoría) — solo por PR humano.

## Plantilla

Una plantilla base se añade aquí cuando se cierre el primer ADR real (Fase 2 o posterior). Hasta entonces, este README es la referencia.

## ADRs cerrados

(Ningún ADR aún. El primero llegará cuando el Concilio cierre su primera deliberación operativa.)
