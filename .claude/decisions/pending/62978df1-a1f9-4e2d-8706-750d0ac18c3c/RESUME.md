# RESUME — Continuación de V2 (Validación funcional Fase 1.G)

## Resumen ultracorto

El Concilio está en **ronda 2 completada**; falta **ronda 3 + ADR + log decisions.jsonl**. La sesión anterior se interrumpió por un bug de Claude Code (tool `Write` retorna `Path must be a string, received undefined` para cualquier path). Workaround: Bash heredoc.

## Contexto del Concilio

- **Council ID**: `62978df1-a1f9-4e2d-8706-750d0ac18c3c`
- **Decisión sintética**: ¿añadir un ángulo `COR` (Correctness) al catálogo cerrado de `.claude/design/council-angles.md`?
- **Criterio de irreversibilidad invocado**: `IRREV-2` (modifica `.claude/design/`)
- **Propósito**: validación funcional **V2** de Fase 1.G (último de los 4 criterios de "done"; V1, V3, V4 ya pasaron).
- **Coste hasta ahora**: 6 invocaciones Opus (3 ronda 1 + 3 ronda 2). Ronda 3 son 3 más → total ~9.

## Estado de archivos en disco

```
.claude/decisions/pending/62978df1-a1f9-4e2d-8706-750d0ac18c3c/
├── dossier.md                  # entrada original al Concilio
├── concejal-1.md               # veredicto ronda 1 ángulo ORT (MODIFICAR / SÍ-CON-CONDICIONES)
├── concejal-2.md               # veredicto ronda 1 ángulo SIM (RECHAZAR / NO)
├── concejal-3.md               # veredicto ronda 1 ángulo MNT (MODIFICAR / SÍ-CON-CONDICIONES)
├── synthesis-round-2.md        # síntesis del master (Alternativa A + 4 condiciones + cláusula retirada)
├── vote-round-2-concejal-1.md  # ronda 2 ángulo ORT (SÍ-CON-CONDICIONES-NUEVAS, 2 cond)
├── vote-round-2-concejal-2.md  # ronda 2 ángulo SIM (SÍ-CON-CONDICIONES-NUEVAS, 3 cond) — cambió de NO a SÍ
├── vote-round-2-concejal-3.md  # ronda 2 ángulo MNT (SÍ-CON-CONDICIONES-NUEVAS, 2 cond)
└── RESUME.md                   # este archivo
```

Conteo final ronda 2: **3 SÍ-CON-CONDICIONES-NUEVAS / 0 NO**. Las 7 condiciones nuevas son compatibles entre sí y convergen en operacionalizar la cláusula de retirada empírica a 3 meses.

## Las 7 condiciones nuevas (resumen)

- **C1-N1** (ORT): métrica explícita de disjunción ROB↔COR en la auditoría a 3 meses (tasa de co-asignación con solape >70%).
- **C1-N2** (ORT): el master debe registrar en cada dossier que invoque ROB+COR una justificación de una línea de por qué requiere ambas lentes.
- **C2-N1** (SIM): umbral de retirada (<10%) implementado como query reproducible sobre `decisions.jsonl`, no prosa.
- **C2-N2** (SIM): "elegible para COR" definido operacionalmente en `council-angles.md` (criterios objetivos: I/O protocolos, parsing, migración, serialización).
- **C2-N3** (SIM): revisión a 3 meses obligatoria calendarizada, no opcional.
- **C3-N1** (MNT): owner = `agent-architect`, sink = entrada en "Historial de cambios al catálogo" con formato fijo.
- **C3-N2** (MNT): umbral numérico congelado ex ante = "menos de 2 invocaciones reales en ventana de 3 meses".

Lee los archivos `vote-round-2-concejal-*.md` para texto completo.

---

## INSTRUCCIONES PARA LA SESIÓN NUEVA

### Paso 1 — Verificar bug del Write

Antes de seguir, comprueba si `Write` funciona:

```
Tool Write con file_path = /tmp/test_write.txt, content = "ok"
```

Si funciona → continúa normalmente. Si falla con el mismo error → usa Bash heredoc para crear archivos.

### Paso 2 — Lanzar ronda 3 (validación cruzada de condiciones)

Lanza **3 invocaciones paralelas** del subagente equivalente a `council-member` (vía tool `Agent` con `subagent_type: general-purpose` y `model: opus`). Cada uno recibe el prompt template abajo, adaptado con su ángulo (ORT, SIM, MNT) y el ID de concejal (1, 2, 3).

**Prompt template ronda 3** (sustituye `{N}` por 1/2/3 y `{ANGULO}` por ORT/SIM/MNT):

```
Eres el Concejal {N} del Concilio Tripartito con ángulo {ANGULO}. Esta es la
ronda 3 (validación cruzada de condiciones) del Concilio con
council_id = 62978df1-a1f9-4e2d-8706-750d0ac18c3c.

Material que DEBES leer:
1. Tu propio veredicto y voto previo en:
   - .claude/decisions/pending/62978df1-a1f9-4e2d-8706-750d0ac18c3c/concejal-{N}.md
   - .claude/decisions/pending/62978df1-a1f9-4e2d-8706-750d0ac18c3c/vote-round-2-concejal-{N}.md
2. Las CONDICIONES NUEVAS propuestas por los OTROS 2 concejales en sus
   archivos vote-round-2-concejal-OTRO.md. Lee SOLO la sección
   "Condiciones nuevas" — NO leas sus razones para no anclarte.

Tu tarea:
Para CADA condición nueva propuesta por OTRO concejal (5 condiciones en total:
2 del primero, 3 del segundo, o las combinaciones equivalentes), decide:
- accepted: compatible con tu ángulo, no introduce problema.
- vetoed: introduce problema sustantivo desde tu ángulo. Explica en una frase.
- accepted-with-note: aceptable pero con observación menor.

Si NINGUNA condición de los otros es vetada por ti, esto es voto SÍ pleno
de tu parte sobre el paquete completo. Si vetas alguna, esa condición se
cae del ADR (no entra en el plan).

Escribe a:
.claude/decisions/pending/62978df1-a1f9-4e2d-8706-750d0ac18c3c/vote-round-3-concejal-{N}.md

Con este formato exacto:

---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-{N}
angulo: {ANGULO}
ronda: 3
timestamp: <ISO 8601 UTC>
---

# Validación cruzada del concejal {N} — ronda 3

## Evaluación de condiciones de los otros concejales

(Una sección por cada condición nueva del otro, identificada por su
referencia tipo C1-N1, C2-N1, etc.)

### Condición CX-NY (texto resumido)
- Decisión: accepted | vetoed | accepted-with-note
- Razón (si vetoed o accepted-with-note): <una frase>

### Condición CX-NZ ...
...

## Voto final de ronda 3
SÍ (todas las condiciones aceptadas) | SÍ-CON-VETOS (las condiciones X, Y vetadas)

Reglas:
- Breve y enfocado. No re-deliberes el problema.
- Sé honesto si una condición de otro concejal te parece innecesaria desde
  tu ángulo: mejor vetarla ahora que descubrirlo en operación real.
- Si todas son aceptables, dilo claro.
- Reporte conversacional al master: <=60 palabras.
- Idioma: español.
```

Lanza las 3 en paralelo (una sola message con 3 tool_use de Agent).

### Paso 3 — Componer ADR-0001

Lee `vote-round-3-concejal-1.md`, `vote-round-3-concejal-2.md`, `vote-round-3-concejal-3.md`.

Identifica:
- Cuáles condiciones fueron aceptadas por **todos** los concejales (van al ADR).
- Cuáles fueron vetadas por al menos uno (se caen del ADR).
- Si TODOS votaron SÍ pleno (cero vetos) → unanimidad SÍ del Concilio.

Compón `.claude/decisions/ADR-0001-add-cor-angle.md` siguiendo el formato definido en `.claude/decisions/README.md`. Incluye:

- Header: `Status: accepted` (si 2/3 SÍ o unanimidad), `Date: <hoy>`, `Decision-Level: L3`, `Council-ID: 62978df1-...`, `Dossier: .claude/decisions/pending/.../dossier.md`.
- Context: copiar del dossier.
- Alternatives considered: A/B/C del dossier con trade-offs.
- Decision: Alternativa A con las N condiciones finales aceptadas (las 4 originales de la síntesis + las nuevas no vetadas).
- Council votes: tabla con los 3 concejales (ángulo, voto final, condiciones).
- Voto minoritario histórico: Concejal 2 votó NO en ronda 1, cambió a SÍ en ronda 2 — documentar la transición.
- Consequences: positivas, negativas (cláusula de retirada empírica a 3 meses), reversibilidad.
- Follow-ups: tareas derivadas (modificar council-angles.md realmente o marcar ADR como "synthetic"; ver Paso 5).

### Paso 4 — Log final en decisions.jsonl

Append una línea JSON a `.claude/state/decisions.jsonl` (gitignored, local):

```json
{"timestamp":"<ISO 8601>","decision_id":"<UUIDv7-nuevo>","task_hash":"<sha256-del-enunciado>","level":"L3","criterion_invoked":"IRREV-2","domains_touched":["agent-system","council"],"justification_short":"V2 functional validation: synthetic decision on adding COR angle to council catalog","model_version":"claude-opus-4-7","council_id":"62978df1-a1f9-4e2d-8706-750d0ac18c3c"}
```

Usa `python3 -c 'import uuid; print(uuid.uuid4())'` para decision_id.
Hash de la tarea: `echo -n "add COR angle to council catalog" | sha256sum`.

### Paso 5 — Decidir si materializar la decisión sintética

La decisión "añadir COR al catálogo" fue **sintética para validar el flujo**. Tras V2 cerrada, hay dos opciones:

- **(a) Materializarla realmente**: aplicar las condiciones aceptadas al `.claude/design/council-angles.md` real, reformular ROB simultáneamente, añadir COR con la pregunta clave operacional, rail disjunto, entrada de historial. El sistema gana un ángulo nuevo y un compromiso de auditoría a 3 meses.
- **(b) Marcar como "synthetic — for V2 validation only — not materialized"**: dejar el catálogo en 12 ángulos. El ADR queda como ejercicio de validación, no como decisión operativa.

**Sugerencia**: pregunta al usuario antes de elegir. La decisión es honesta tras pasar el Concilio; descartarla solo por ser "de prueba" desperdicia el resultado, pero materializarla compromete al sistema con un cambio que nunca fue una necesidad real del firmware.

### Paso 6 — Cerrar Fase 1.G

Tras Paso 4 (decisions.jsonl loguado) y Paso 3 (ADR cerrado):

- Actualiza task #7 (Fase 1.G) a `completed` vía `TaskUpdate`.
- Reporta al usuario: V2 pass, los 4 criterios funcionales de Fase 1.G están completos, sistema multi-agente operativo end-to-end.
- Pregunta al usuario si arrancar Fase 2 (especialistas críticos: RF, NFC, app-builder, build-fbt).

### Paso 7 — Commit final

```bash
git add .claude/decisions/
git commit -m "validate(v2): close Council deliberation ADR-0001 (Phase 1.G done)"
```

Sin push hasta aprobación explícita del usuario.

---

## Convenciones que debes mantener

- **No leas archivos `concejal-N.md` o `vote-round-2-concejal-N.md` que no sean tu propia identidad** en cada invocación de concejal — la independencia de ronda 1 se preserva en ronda 3 también: cada concejal ve solo las CONDICIONES de los otros (no sus razones completas).
- **Persistencia obligatoria a disco**: cada veredicto/voto va al archivo correspondiente antes de que el concejal termine. El master recoge desde archivo, no desde respuesta conversacional.
- **El master sintetiza pero NO vota**: lo dice aprendizaje meta 2 del system-design.

## Si algo va mal

- Si Write sigue roto: usa Bash heredoc para todos los archivos.
- Si una invocación de concejal falla: re-lánzala (las invocaciones son idempotentes en el sentido de que el archivo se sobrescribe).
- Si hay conflicto irresoluble en ronda 3 (ej. C2 veta una condición que considera infraestructura excesiva): el conflicto va al ADR como riesgo conocido y la condición se cae.
- Si nada funciona: escala al usuario con `decisions.jsonl` `level: "L4"` documentando el estado.
