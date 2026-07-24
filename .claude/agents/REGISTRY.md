# REGISTRY de subagentes del sistema multi-agente

Este archivo registra **todos** los subagentes en `.claude/agents/`. Es auditable y versionado. El hook `SubagentStop` (configurado en `settings.json` durante Fase 1.D) actualiza los contadores tras cada invocación.

## Schema de cada entrada

Cada subagente tiene una entrada con los siguientes campos:

- **agent_name**: nombre del archivo sin extensión (ej. `agent-architect`).
- **model**: `opus | sonnet | haiku`.
- **effort**: `low | medium | high | xhigh | max`.
- **status**: `experimental | stable`. Tras 5 invocaciones sin modificación, el architect propone graduar (D13).
- **core**: `true | false`. Los core no pueden ser retirados por el architect (D17).
- **invocation_count**: nº de veces que el master ha delegado tarea a este agente. Tracked en `.claude/state/counters.json` (gitignored); este archivo refleja el último snapshot conocido tras un commit.
- **last_modified_commit**: hash corto del último commit que tocó `.claude/agents/<agent>.md`.
- **created_at**: timestamp ISO 8601 de creación.
- **motivo**: ¿por qué se creó? (1 línea)
- **casos_de_uso**: 3 casos de uso aprobados por el Concilio.
- **council_votes**: votos del Concilio que aprobaron su creación.
- **approval_commit**: hash del commit donde se añadió.

## Conteo contra el techo (D17)

- **Techo único**: 20 agentes en `.claude/agents/`.
- **Core (no retirables automáticamente)**: 2 — `agent-architect`, `council-member`.
- **Especialistas previstos en Fases 2-3**: 11.
- **Total tras Fase 3**: 13.
- **Margen para creación por el architect en operación supervisada (Fase 4)**: 7.

## Política de creación de agentes

Un agente nuevo solo se añade tras pasar las 4 capas de control del `agent-architect` (ver `system-design.md`):

1. Overlap check (no hay agente existente que cubra).
2. Casos de uso obligatorios (3 reales, no hipotéticos).
3. Voto del Concilio (2-de-3 SÍ, con ángulos típicos `ORT` + `MNT` + `COS`).
4. Aprobación humana explícita.

Cada agente nace con `status: experimental`. Tras 5 invocaciones sin modificación posterior, el architect propone graduarlo a `status: stable` (D13).

## Agentes registrados

| Agente | Modelo | Effort | Status | Core | Invocations | Last modified | Created at |
|--------|--------|--------|--------|------|-------------|---------------|------------|
| _(pendiente Fase 1.B)_ | | | | | | | |

Las primeras 2 entradas se añaden al completar Fase 1.B (`agent-architect` y `council-member`). Las siguientes 4 en Fase 2 y las 7 restantes en Fase 3.
