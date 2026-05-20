# Fases de implementación del sistema multi-agente

## Estado actual

Fase 0 completada en su componente de diseño. El diseño está plasmado en `system-design.md` y los 7 puntos abiertos fueron resueltos por el usuario (decisiones D10-D16 en `system-design.md`). El sistema está listo para arrancar Fase 1; el arranque se hace por orden expresa del usuario (D16), no automáticamente.

---

## Fase 0 — Planificación (en curso)

**Objetivo**: alinear con el usuario el diseño completo del sistema agente.

### Entregables

- `.claude/design/system-design.md`
- `.claude/design/phases.md`
- `.claude/design/CHANGELOG.md`

### Criterios de "done"

- Diseño plasmado en archivos.
- Los 7 puntos abiertos resueltos por el usuario.

---

## Fase 1 — Núcleo mínimo viable

**Objetivo**: tener el orquestador, el meta-agente, el concilio, los guardrails y la documentación base operativos.

### Entregables

- Eliminar el `AGENTS.md` heredado del repo personal (con backup en git history).
- `CLAUDE.md` con instrucciones base + **rol del master (la conversación principal asume la orquestación, NO existe como subagente)** + guardrails de operaciones destructivas + política sobre el repo oficial + referencia a las 5 capas de guardrails (ver `system-design.md`).
- `.claude/settings.json` con permisos versionados (`permissions.ask` para destructivos) + `alwaysThinkingEnabled: true` (D10).
- `.claude/agents/agent-architect.md` (Opus, `effort: max`, con las 4 capas de control D5 + quotas D12/D17).
- `.claude/agents/council-member.md` (Opus, `effort: max`, parametrizable: recibe ángulo asignado del catálogo G2 al invocarse **3 veces en paralelo** desde la conversación principal). Reemplaza la idea original de 3 archivos fijos (Pragmático/Visionario/Escéptico) por una sola implementación parametrizable según D18.
- `.claude/agents/REGISTRY.md` (vacío con esquema y plantilla de entrada).
- `.claude/decisions/README.md` (cómo se escriben ADRs en este proyecto).
- `.claude/docs/architecture-furios.md` (resumen del runtime FuriOS, curado leyendo el codebase).
- `.claude/commands/flipper.md` (comando `/flipper` que delega al master).
- `.claude/design/council-angles.md` (catálogo cerrado + reglas de wildcard).
- `.claude/design/irreversibility.md` (lista cerrada de 9 entradas).
- `.claude/design/decisions-schema.md` (schema del JSONL).
- `.claude/design/cost-policy.md` (techo y tabla tokens→USD).
- `.claude/scripts/check-irreversibility.sh` (matcher regex sobre lista G3).
- `.claude/scripts/setup.sh` (una línea: `pre-commit install` + validación binaria).
- `.pre-commit-config.yaml` (config del framework).
- `.githooks/pre-push` (hook bloqueante para `Next-Flip/*` con override vía variable de entorno).
- `.githooks/pre-tool-use-checkout` (hook PreToolUse que valida árbol limpio antes de `git checkout` a branch existente).
- Hook `SubagentStop` que actualiza `.claude/state/counters.json` con `invocation_count` y `last_modified_commit` por agente.
- Hook `PostToolUse` que escribe a `.claude/state/costs.jsonl` por invocación y emite warning al cruzar 60% del budget.
- `.claude/commands/flipper-redirect.md` (`/flipper-redirect <especialista>`).
- `.claude/commands/flipper-review-wildcards.md` (`/flipper-review-wildcards`).
- `.claude/commands/flipper-reset.md` (`/flipper-reset` opt-in para limpiar contexto del master).
- `.claude/skills/devils-advocate/` (skill para nivel L2).

### Criterios de "done"

- Todos los archivos anteriores creados y commiteados en una rama dedicada.
- Validación funcional 1: tarea de prueba sobre 1 dominio (esperada L1). El master clasifica L1, no convoca al Concilio, ejecuta. Log en `decisions.jsonl` muestra `level: "L1"`.
- Validación funcional 2: tarea de prueba cross-dominio (esperada L3). El master clasifica L3, convoca al Concilio, recoge 3 veredictos, compone ADR en `.claude/decisions/`. Log muestra `level: "L3"` con `council_id` no nulo.
- Validación funcional 3: tarea sintética que matchea la lista G3 (ej. propuesta de modificar `.claude/design/`). El script automático detecta el match, fuerza L3, el master no puede degradar a L2.
- Validación funcional 4: intento de push a `Next-Flip/*` desde el clone personal. El hook bloquea con exit != 0 y el mensaje de stderr imprime el comando de override en la primera línea.

---

## Fase 2 — Especialistas críticos

**Objetivo**: cubrir las áreas más usadas del firmware con agentes especializados y documentación curada.

### Entregables

- `.claude/agents/flipper-rf-subghz.md`
- `.claude/agents/flipper-nfc.md`
- `.claude/agents/flipper-app-builder.md`
- `.claude/agents/flipper-build-fbt.md`
- `.claude/docs/subghz-internals.md`
- `.claude/docs/nfc-stack.md`
- `.claude/docs/adding-an-app-checklist.md`
- `.claude/docs/build-system.md`

### Criterios de "done"

- Cada especialista tiene su archivo de agente y su documento de conocimiento curado.
- Validación: el master delega correctamente al especialista correspondiente en una tarea real del firmware.

---

## Fase 3 — Especialistas restantes + commands + golden prompts

**Objetivo**: completar el sistema con todos los especialistas restantes, comandos atajo y la infraestructura de prompts.

### Entregables

- `.claude/agents/flipper-rfid-ibutton.md`
- `.claude/agents/flipper-ble.md`
- `.claude/agents/flipper-ir.md`
- `.claude/agents/flipper-badusb-hid.md`
- `.claude/agents/flipper-c-furi.md`
- `.claude/agents/flipper-companion-hw.md`
- `.claude/agents/flipper-js-mjs.md`
- `.claude/docs/<area>.md` correspondiente a cada especialista anterior
- `.claude/commands/flipper-new-app.md`
- `.claude/commands/flipper-spawn-agent.md`
- `.claude/commands/flipper-promote-prompt.md`
- `.claude/commands/flipper-quick.md`
- `.claude/commands/flipper-council.md`
- `.claude/commands/flipper-build.md`
- `.claude/prompts/README.md`
- `.claude/prompts/golden/` (carpeta inicial con plantilla de prompt golden)
- `.claude/prompts/drafts/` (carpeta inicial)

### Criterios de "done"

- Sistema completo y funcional con todos los agentes y comandos.
- Validación: una tarea real cross-dominio (ejemplo: "crea una app que combine lectura NFC con una UI nueva") ejercita al master, convoca al Concilio y delega correctamente a los especialistas.

---

## Fase 4 — Operación supervisada y auto-extensión

**Objetivo**: usar el sistema en tareas reales del firmware y dejar que el `agent-architect` proponga nuevos agentes cuando detecte huecos de cobertura.

### Entregables

Agentes y documentos adicionales propuestos por el architect bajo supervisión del usuario. No hay un conjunto fijo; cada propuesta aprobada se convierte en entregable.

### Criterios de "done"

No aplica una fase de "done" cerrada: esta es operación continua. Cada propuesta del architect que el usuario apruebe se commitea como cambio independiente con su ADR justificativo en `.claude/decisions/`.

---

## Cómo no perdemos contexto entre fases

- Cada fase termina con un commit limpio y una actualización de `CHANGELOG.md` que registra qué se completó y por qué.
- Al iniciar una nueva sesión, Claude Code carga `CLAUDE.md` automáticamente; desde ahí navega a `.claude/design/` para recuperar el estado del sistema.
- El archivo `system-design.md` se mantiene como referencia actualizada al final de cada fase; nunca queda desincronizado con la implementación real.
