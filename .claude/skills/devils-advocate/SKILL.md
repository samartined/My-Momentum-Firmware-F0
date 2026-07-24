---
name: devils-advocate
description: Deliberación intermedia barata (nivel L2 del sistema multi-agente). 1 sola llamada Opus con prompt multi-ángulo donde el modelo asume 3 perspectivas en sucesión interna (no en llamadas separadas). NO es sustituto del Concilio Tripartito real (L3) — es complemento para tareas con 2 dominios o refactor menor que no matchean la lista G3 pero merecen una segunda voz.
---

# Skill: Devil's Advocate (nivel L2)

## Propósito

Forzar al master a articular el caso contrario antes de decidir, mediante 1 sola llamada Opus que adopta 3 ángulos en sucesión interna. Reduce sesgos cognitivos simples sin pagar el coste 3× del Concilio Tripartito real.

## Cuándo invocar esto

- La tarea toca 2 dominios del firmware sin matchear lista G3 (D19).
- El refactor es menor pero tiene trade-offs no triviales.
- El master tiene dudas tácticas y quiere una "segunda voz" sin gastar Concilio.

## Cuándo NO invocar esto

- **La operación matchea la lista G3 (irreversibilidad)**: en ese caso L1 y L2 quedan estructuralmente prohibidos (D23 hard rule). Solo L3 (Concilio) o L4 (escalado) son válidos. Si llegas aquí y la lista matchea, niégate y convoca al Concilio.
- **La propuesta viene del `agent-architect`** (crear/retirar agente): siempre L3.
- **Decisión cross-dominio que afecta 3+ áreas**: ese es claramente L3.
- **El usuario invocó `/flipper-council` explícitamente**: respeta su petición y va a L3.

L2 (`/devils-advocate`) **no es sustituto** del Concilio. Es complemento para casos donde 3 instancias separadas serían exceso pero "decidir solo" es poco.

## Procedimiento

Asume las 3 perspectivas siguientes en sucesión interna (todo en 1 sola respuesta tuya, sin lanzar subagentes):

### Perspectiva 1 — Pragmático

¿Qué dice "el desarrollador que solo quiere que esto funcione hoy y mantenga la estabilidad existente"?

- Pregunta: ¿la propuesta introduce riesgo innecesario o complejidad evitable?
- Responde en 2-3 frases concisas.

### Perspectiva 2 — Visionario

¿Qué dice "el arquitecto que piensa en la salud del sistema a 12 meses"?

- Pregunta: ¿la propuesta envejece bien o introduce deuda técnica?
- Responde en 2-3 frases concisas.

### Perspectiva 3 — Escéptico

¿Qué dice "el reviewer que busca activamente qué puede romper esto"?

- Pregunta: ¿qué edge case, regresión o vector de fallo no se ha considerado?
- Responde en 2-3 frases concisas.

### Síntesis

Tras las 3 perspectivas, decide:

- **PROCEDER**: las 3 perspectivas avalan la propuesta o sus reservas son menores. Continúa.
- **MODIFICAR**: alguna perspectiva señala un problema serio que se puede mitigar ajustando la propuesta. Describe el ajuste y procede con la versión modificada.
- **ESCALAR-A-L3**: las perspectivas detectan tensión sustantiva que merece deliberación real con 3 instancias separadas. Convoca al Concilio (L3).

## Output

Tu respuesta al usuario debe incluir:

1. Las 3 perspectivas (claramente etiquetadas como tales, 2-3 frases cada una).
2. La síntesis (PROCEDER / MODIFICAR / ESCALAR-A-L3).
3. Si MODIFICAR, la versión ajustada.
4. Si ESCALAR-A-L3, el motivo concreto por el que L2 no basta.

## Coste

1× llamada extra (la respuesta multi-ángulo a la conversación principal). NO se invocan subagentes. NO se persiste a disco (a diferencia del Concilio que escribe a `pending/<id>/`). El log de decisiones (`decisions.jsonl`) sí registra `level: "L2"` con `criterion_invoked: null` para auditoría.
