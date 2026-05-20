# Changelog del sistema agente

Este documento registra los cambios al sistema multi-agente de Claude para este repo (`.claude/**`, `CLAUDE.md`). NO documenta cambios al firmware del Flipper Zero — esos van en el CHANGELOG.md del firmware.

Formato basado en Keep-a-Changelog. Fechas en formato YYYY-MM-DD.

---

## [0.1.4] — 2026-05-20

### Modificado

- `system-design.md`: anotada D2 con la canonización a `effort: max/medium` (terminología oficial del frontmatter de Claude Code).
- `system-design.md`: anotada D4 para reflejar que (a) el master sintetiza pero NO vota (aprendizaje meta 2) y (b) las perspectivas fijas originales quedan superadas por el catálogo dinámico D18.
- `system-design.md`: anotada D11 con la derogación de la "segunda ronda con veredictos compartidos" — sustituida por la regla 1-de-3 SÍ → escalado al usuario (D21) y voto sobre síntesis sin anclaje (aprendizaje meta 3).
- `system-design.md`: anotada D12 con la revisión al alza del techo total (15 → 20 por D17), manteniendo la regla de "1 agente nuevo por sesión".
- `system-design.md`: tabla "Roles de agentes" actualizada — eliminada la fila `flipper-master` (el master ya no es subagente), unificadas las 3 filas `council-pragmatist/visionary/skeptic` en una sola fila `council-member` parametrizable, columna `Thinking` renombrada a `Effort` con valores `max/medium` (canonización).
- `system-design.md`: añadida subsección "Lista cerrada de core agents" dentro de "Roles de agentes" (2 core: `agent-architect` + `council-member`).
- `system-design.md`: sección "El Concilio Tripartito" rehecha completamente para reflejar D18 (catálogo dinámico), D27 (dossier obligatorio), aprendizaje meta 2 (master no vota), aprendizaje meta 3 (sin ronda 2 anclada), procedimiento de 3 rondas (propuestas → voto sobre síntesis → validación cruzada), persistencia obligatoria en `.claude/decisions/pending/<id>/`.
- `system-design.md`: subsección "Quotas" del agent-architect actualizada (techo 15 → 20, referencia a la lista cerrada de core agents).
- `system-design.md`: sección "Operaciones destructivas y guardrails" expandida de 3 capas a 5 (añadidas: capa 1 dos clones físicos D25, capa 3 lista G3 + script regex D19/D23). Añadida tabla resumen de operaciones cubiertas por capa.
- `system-design.md`: "Estructura de archivos prevista" actualizada con todos los archivos nuevos (`.claude/state/`, `.claude/scripts/`, `.claude/skills/devils-advocate/`, `.claude/decisions/pending/`, `.githooks/`, `.pre-commit-config.yaml`, 4 docs de design, 3 commands nuevos, `council-member.md` en lugar de los 3 fijos, sin `flipper-master.md`).
- `system-design.md`: añadida sección nueva "Niveles de deliberación L1-L4" con diagrama de decisión, tabla de niveles, mención a auditoría (D20) y hard rule G3 (D23).
- `system-design.md`: añadida sección nueva "Dossier obligatorio antes de L3" con schema mínimo, tope blando 10 / duro 20, disciplina contra contaminación y comando `/flipper-reset`.
- `phases.md` (Fase 1): eliminada referencia a `flipper-master.md` (master no es subagente). Reemplazadas las 3 líneas de concejales fijos por una sola línea de `council-member.md` parametrizable. Actualizada la línea de `CLAUDE.md` para mencionar explícitamente el rol del master como conversación principal. Actualizada la línea de `settings.json` para mencionar `alwaysThinkingEnabled: true` (D10).

### Motivación

La revisión personal de los archivos plasmados por el agente Sonnet en v0.1.3 detectó 14 inconsistencias internas:

- Decisiones antiguas (D2, D4, D11, D12) contradecían a las nuevas (D17-D27) sin anotación de superación.
- Secciones narrativas (Concilio, agent-architect > Quotas, Guardrails, Roles de agentes, Estructura de archivos) reflejaban el diseño pre-Concilio y no las decisiones D17-D27.
- Conceptos centrales (niveles L1-L4, dossier obligatorio, lista de core agents) vivían dispersos en filas de la tabla de decisiones sin desarrollo formal en secciones propias.

Sin esta reconciliación, un lector fresco del documento — o el master arrancando Fase 1 — encontraría un texto que se contradice a sí mismo y no podría operar de forma coherente. La reconciliación se hizo manualmente (no delegada a subagente) para preservar control granular sobre las anotaciones y evitar regresiones por interpretación.

### Pendiente

Solo la orden expresa del usuario para arrancar Fase 1 (D16). Tras esta reconciliación, los 3 documentos (`system-design.md`, `phases.md`, `CHANGELOG.md`) son internamente consistentes con las 27 decisiones cerradas + 4 aprendizajes meta.

---

## [0.1.3] — 2026-05-20

### Añadido

- Decisiones D17-D27 en `system-design.md` (tabla "Decisiones cerradas"), una por cada gap cerrado por el Concilio Tripartito en 3 rondas (G1-G10 + A1).
- Sección "Aprendizajes meta del Concilio en vivo" en `system-design.md` con 4 observaciones derivadas de ejecutar el Concilio como ejercicio práctico de cierre de los gaps.
- `.claude/design/council-angles.md`: catálogo cerrado de 12 ángulos del Concilio con IDs estables y regla de wildcard.
- `.claude/design/irreversibility.md`: lista cerrada de 9 operaciones irreversibles que disparan L3 automáticamente.
- `.claude/design/decisions-schema.md`: schema del log `.claude/state/decisions.jsonl` + umbral de activación de auditor en Fase 2+ (ratio L1+L2/total > 0.95 con ventana mínima N=100).
- `.claude/design/cost-policy.md`: presupuesto por sesión, niveles de actuación (60% warning, 200% hard cap) y tabla tokens→USD con fecha y fuente.
- En `phases.md > Fase 1`: 15 entregables nuevos (4 docs de diseño, 2 scripts, 2 githooks, 3 hooks de Claude Code, 3 commands, 1 skill) + 4 criterios funcionales de "done" verificables.

### Modificado

- Sección "Mapeo de modelos por rol" en `system-design.md`: corregida la afirmación errónea (presente en v0.1.0 a v0.1.2) de que no existía campo `effort` en frontmatter de subagentes. Tras verificación contra documentación oficial (`code.claude.com/docs/en/subagents-and-plugins.md`), el campo existe (`low | medium | high | xhigh | max`). Se especifica `effort: max` para Opus y `effort: medium` para Sonnet.
- Sección "Puntos abiertos" en `system-design.md`: actualizada para reflejar que tras D27 el sistema queda listo para Fase 1 a orden expresa del usuario (D16).

### Resoluciones G1-G10 + A1 (mapping a decisiones cerradas)

- **G1** → D17 (techo único 20 + lista cerrada de core agents)
- **G2** → D18 (catálogo cerrado + 1 wildcard/sesión + `/flipper-review-wildcards`)
- **G3** → D19 (lista cerrada 9 entradas + script de verificación automática)
- **G4** → D20 (log JSONL en Fase 1, auditor empírico en Fase 2+)
- **G5** → D21 (1-de-3 SÍ → escalado obligatorio L4)
- **G6** → D22 (framework `pre-commit` + `setup.sh` una línea)
- **G7** → D23 (`/devils-advocate` como L2 + hard rule G3 deshabilita L1/L2)
- **G8** → D24 (warning 60% + hard cap configurable + tabla tokens→USD)
- **G9** → D25 (dos clones + hook bloqueante con override visible)
- **G10** → D26 (`/flipper-redirect` + flag binario `out_of_scope`)
- **A1** → D27 (dossier obligatorio + schema + tope blando 10/duro 20 + `/flipper-reset` opt-in)

### Motivación

Tras la verificación técnica que confirmó dos errores estructurales del diseño v0.1.0 (subagent nesting no soportado por la plataforma; campo `effort` sí existe y no se usaba), se ejecutó una reformulación arquitectural (master = conversación principal) y una dialéctica adversarial de segunda ronda que identificó 11 gaps remanentes. El Concilio Tripartito convocado para cerrarlos sirvió simultáneamente como (a) mecanismo de cierre de los gaps por unanimidad y (b) validación práctica del propio Concilio antes de su uso productivo. Los aprendizajes meta del ejercicio se incorporan al diseño (sección nueva en `system-design.md`).

### Pendiente

Solo una cosa: que el usuario dé la orden expresa de arrancar Fase 1 (D16).

---

## [0.1.2] — 2026-05-19

### Modificado

- `system-design.md`: añadidas decisiones D10–D16 a la tabla "Decisiones cerradas", correspondientes a las resoluciones de los puntos abiertos P1–P7 por parte del usuario.
- `system-design.md`: sección "Quotas" del architect fijada (máximo 1 agente nuevo por sesión, máximo 15 totales — modo prudente).
- `system-design.md`: sección "Periodo experimental" fijada en N=5 invocaciones sin modificación para graduar a `stable`.
- `system-design.md`: sección "Concilio Tripartito > Coste y atajos" actualizada para referenciar D11 en lugar de marcar "pendiente".
- `system-design.md`: sección "Puntos abiertos" reemplazada por nota de cierre (todos los puntos resueltos; arranque de Fase 1 a orden expresa del usuario).
- `phases.md`: "Estado actual" actualizado para reflejar que la Fase 0 está completa en su componente de diseño y que el arranque de Fase 1 espera la orden expresa del usuario.

### Resoluciones P1–P7

- **P1** → Extended-thinking activado a nivel de proyecto en `.claude/settings.json` (no global). [D10]
- **P2** → Quorum del Concilio: 2/3 normal, unanimidad para destructivas, escalado al usuario si no hay 2/3 tras la segunda ronda. [D11]
- **P3** → Quotas del architect: 1 nuevo/sesión, 15 totales (modo prudente). [D12]
- **P4** → Periodo experimental: N=5 invocaciones sin modificación para graduar a `stable`. [D13]
- **P5** → Permisos en `settings.json` confirmados (build libre, git no destructivo libre con matiz en `checkout` a branch existente, destructivos piden aprobación, push a Next-Flip bloqueado por hook). [D14]
- **P6** → Comandos atajo `/flipper-quick` y `/flipper-council` confirmados. [D15]
- **P7** → Arranque de Fase 1 a orden expresa del usuario, no automático. [D16]

### Motivación

Cerrar los 7 puntos abiertos era requisito para que el sistema saliera de la planificación. Las resoluciones quedan plasmadas como decisiones cerradas y trazables (D10-D16), no como notas dispersas, para que cualquier sesión futura de Claude Code reconstruya el porqué de cada parámetro sin necesidad de la conversación original.

### Pendiente

Solo la orden expresa del usuario para arrancar Fase 1. Hasta entonces no se toca ningún otro archivo del repo ni se crean los agentes/configuraciones de Fase 1.

---

## [0.1.1] — 2026-05-19

### Modificado

- `system-design.md`: añadida subsección "Áreas no cubiertas por especialista dedicado" (U2F, Archive, GPIO, momentum_app) con criterio de promoción a especialista propio (3 o más tareas reales).
- `system-design.md`: detallado el mecanismo de conteo de "N usos sin modificación" en la sección "Periodo experimental" mediante los campos `invocation_count` y `last_modified_commit` en `REGISTRY.md`.
- `system-design.md`: afinado el punto P5 de "Puntos abiertos" para distinguir `git checkout -b <nueva>` (libre) de `git checkout <branch-existente>` (libre solo con árbol limpio; pide aprobación en caso contrario).

### Motivación

La revisión personal del diseño detectó tres huecos menores que conviene cerrar antes de Fase 1:

- Áreas del firmware sin especialista asignado (U2F, Archive, GPIO, momentum_app) producirían delegación ambigua del master sin una regla explícita de cobertura.
- "N usos sin modificación" para graduar agentes experimentales era no-implementable sin definir cómo se cuenta.
- El permiso libre de `git checkout` sin distinguir entre crear branch nueva y cambiar a una existente podía permitir sobrescribir trabajo sin commit.

---

## [0.1.0] — 2026-05-19

### Añadido

- Documento `.claude/design/system-design.md` con el diseño inicial completo del sistema multi-agente: orquestador, especialistas, Concilio Tripartito, agent-architect con 4 capas de control, guardrails de operaciones destructivas, mapeo de modelos por rol.
- Documento `.claude/design/phases.md` con la planificación de implementación en 5 fases (Fase 0 a Fase 4), criterios de "done" por fase y mecanismo de persistencia de contexto entre fases.
- Este archivo `.claude/design/CHANGELOG.md`.

### Motivación

Estamos construyendo un sistema multi-agente para que Claude pueda asistir hiperespecializadamente en el firmware Momentum del Flipper Zero. El usuario quiere:

- Un orquestador que delegue en especialistas para no contaminar contexto entre dominios (RF, NFC, BLE, app-builder, build, etc.).
- Un meta-agente capaz de crear nuevos especialistas bajo control humano cuando el firmware lo requiera.
- Un Concilio de 3 perspectivas (Pragmático, Visionario, Escéptico) que delibere y vote en decisiones globales.
- Versionado en GitHub para que el sistema agente evolucione junto con el código.
- Guardrails fuertes para operaciones destructivas (flash, push, borrado) que requieren aprobación humana explícita.

Esta primera entrega plasma el diseño en archivos antes de empezar a implementar, para no perder contexto entre sesiones y para que el propio sistema cuando arranque pueda autorrecordar su propio diseño.

### Pendiente

7 puntos abiertos por resolver con el usuario antes de pasar a Fase 1 (detallados en `system-design.md` → sección "Puntos abiertos"). Una vez resueltos, comienza Fase 1 (núcleo mínimo viable).
