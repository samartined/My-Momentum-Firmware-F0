---
description: Limpia el contexto conversacional del master cuando el usuario sospecha contaminación severa (decisiones afectadas por historial irrelevante). Opt-in del usuario; NO se invoca automáticamente. NO destruye archivos en disco — solo señala al master que debe operar como si el historial conversacional no existiera.
---

# Flipper Reset (limpieza de contexto)

Has sido invocado vía `/flipper-reset`. El usuario ha decidido que tu contexto conversacional puede estar contaminado y quiere que operes con disciplina amnésica para la siguiente tarea.

## Lo que significa "reset"

Este comando **NO destruye nada en disco**:

- `.claude/decisions/`, `.claude/state/`, `.claude/agents/`, ADRs, dossieres previos — todo permanece intacto.
- La sesión de Claude Code sigue activa.

Lo que cambia es **tu disciplina operativa**:

1. **A partir de ahora**, opera como si el historial conversacional previo a este comando no existiera.
2. La siguiente tarea que recibas se procesa desde cero. Si necesitas contexto, **leélo del disco** (archivos en `.claude/design/`, código del firmware, etc.), no de tu memoria conversacional.
3. Si una decisión llega a L3 tras este reset, el dossier debe reconstruirse íntegramente desde archivos, sin referencias al historial previo. Esta es la disciplina ya obligatoria por D27, pero `/flipper-reset` la refuerza para tareas inmediatamente posteriores.

## Cuándo el usuario invoca esto

- Conversación larga con muchos temas distintos, y el usuario percibe que tus respuestas están sesgadas por temas anteriores irrelevantes a la pregunta actual.
- Tras una sesión de debugging que terminó mal y el usuario quiere arrancar limpio.
- Antes de una decisión L3 importante donde el usuario quiere garantizar que tu razonamiento parta solo de archivos, no de conversación.

## Lo que NO hace este comando

- NO borra archivos del sistema.
- NO interrumpe la sesión de Claude Code (eso lo hace el usuario manualmente).
- NO afecta a logs en `.claude/state/` (decisions, costs, etc.).
- NO invoca al Concilio ni a especialistas — es un comando puramente sobre tu disciplina cognitiva.

## Tu respuesta

Confirma al usuario: "Reset reconocido. Opero desde cero desde aquí. ¿Cuál es la tarea?"
