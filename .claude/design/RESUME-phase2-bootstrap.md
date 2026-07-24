# RESUME — Arranque de Fase 2 (Especialistas críticos)

## Resumen ultracorto

**Fase 1 cerrada y verificada.** Sistema multi-agente operativo end-to-end. ADR-0001 cerrado y materializado. Próximo paso por orden expresa del usuario: arrancar **Fase 2** = crear 4 especialistas críticos + sus docs curados.

Este RESUME es autocontenido: una sesión nueva (local, web, codespaces) puede leerlo + `CLAUDE.md` + `.claude/design/phases.md` y arrancar Fase 2 sin más contexto histórico.

---

## Estado del sistema (a 2026-05-23, commit `7a8a91f2`)

### Lo que ya está hecho

- **Fase 0** (planificación): completa. Diseño en `.claude/design/system-design.md` con 27 decisiones + 4 aprendizajes meta.
- **Fase 1** (núcleo mínimo viable): completa. Los 4 criterios funcionales de done están verificados:
  - V1 (L1 single-domain): pasado.
  - V2 (L3 Concilio end-to-end): pasado (esta sesión → ADR-0001).
  - V3 (G3 forzado): pasado.
  - V4 (push a Next-Flip bloqueado): pasado.
- **2 core agents operativos** en `.claude/agents/`:
  - `agent-architect` (Opus, effort: max).
  - `council-member` (Opus, effort: max, parametrizable con ángulo del catálogo).
- **Catálogo del Concilio**: 13 ángulos vigentes (12 + `COR` añadido en ADR-0001).
- **Hooks**: `SubagentStop`, `PreToolUse`, `pre-push` activos.
- **decisions.jsonl**: 3 entradas registradas (V1 L1, V3 L3 sin council_id, V2 L3 con council_id).

### Revisiones calendarizadas pendientes

- **`2026-08-23`**: Auditoría a 3 meses del ángulo `COR` (Revisión 1 en `phases.md` → "Calendario activo de revisiones"). Owner: `agent-architect`. Dispara retirada (OR): <2 invocaciones reales o >30% solape `ROB`+`COR`.

---

## Plan de arranque de Fase 2

Según `phases.md` → Fase 2, los entregables son:

### Agentes especialistas (4)

| Archivo | Dominio | Modelo sugerido |
|---|---|---|
| `.claude/agents/flipper-rf-subghz.md` | SubGHz, OOK, radio CC1101, slots `.sub` | Opus, effort: max |
| `.claude/agents/flipper-nfc.md` | NFC (ISO14443 A/B, MIFARE, NTAG, NDEF, plugins) | Opus, effort: max |
| `.claude/agents/flipper-app-builder.md` | Estructura de apps (`application.fam`, gui, scenes, views, FAP) | Opus, effort: max |
| `.claude/agents/flipper-build-fbt.md` | Sistema de build (fbt, scons, toolchain, firmware vs apps) | Sonnet, effort: medium |

### Docs curados (4)

| Archivo | Contenido esperado |
|---|---|
| `.claude/docs/subghz-internals.md` | Stack SubGHz: protocolos soportados, formato `.sub`, mapeo a TX worker, integración con app SubGHz |
| `.claude/docs/nfc-stack.md` | Stack NFC: capas (lib/nfc, plugins), tipos soportados, ISO14443 A/B, MIFARE, NTAG, custom apps |
| `.claude/docs/adding-an-app-checklist.md` | Pasos verificados para añadir una app FAP (application.fam, entry point, scenes, build) |
| `.claude/docs/build-system.md` | fbt, scons, targets `f7-firmware-C` vs apps, comandos comunes (`./fbt`, `./fbt fap_X`, `./fbt firmware_flash`) |

### Criterios de done de Fase 2

1. Los 4 archivos de agentes creados con frontmatter válido (model, effort, description, tools).
2. Los 4 docs creados con contenido útil verificable contra el codebase.
3. **Validación**: el master delega correctamente al especialista correspondiente en una tarea real del firmware (ej. "implementa lectura del protocolo X de SubGHz" → delega a `flipper-rf-subghz`).
4. Registry actualizado: cada especialista añadido a `.claude/agents/REGISTRY.md`.

---

## Decisiones que el master debe tomar al arrancar Fase 2

### 1. ¿Crear los 4 especialistas vía `agent-architect` o directamente?

**Opción A (vía architect)**: el master pide al `agent-architect` que proponga cada uno. El architect aplica sus 4 capas de control (descripción, herramientas, modelo, justificación). El usuario aprueba en lote o uno a uno. Este es el flujo "canónico" de creación de agentes (D5).

- **+** Disciplina del proceso de creación de agentes.
- **+** Cada especialista pasa por 4 capas de control.
- **−** Cuota D12 dice "máximo 1 agente nuevo por sesión" → habría que ejecutar 4 sesiones de architect, o relajar la cuota explícitamente para Fase 2 (entregable planificado, no propuesta espontánea).

**Opción B (directa, sin architect)**: el master crea los 4 agentes manualmente porque son entregables planificados en `phases.md`, no propuestas reactivas del architect.

- **+** Más rápido (1 sesión vs 4).
- **+** La cuota del architect es para propuestas espontáneas, no para entregables de plan.
- **−** Salta el control del architect. Hay que justificar bien por qué.

**Recomendación**: **Opción B con commit consolidado**. Razón: el architect existe para detectar gaps de cobertura no planificados; los 4 especialistas de Fase 2 ya están explícitamente en `phases.md` como entregables fijos. Saltarlos vía architect es duplicar disciplina. Sin embargo, debe consultarse al usuario antes (decisión meta).

### 2. ¿Es Fase 2 un L3 consolidado o 4 L3 separados?

**Crear archivos en `.claude/agents/` matchea G3** (CLAUDE.md: "Modificación de `.claude/agents/`... matchea G3 → fuerza L3").

**Opción A (4 L3 separados)**: un Concilio por especialista. Mucho coste (~12 invocaciones Opus solo para Fase 2 Concilios). Inadecuado para entregables planificados ex ante.

**Opción B (1 L3 consolidado "Fase 2 bootstrap")**: un solo Concilio que delibera sobre el conjunto de 4 especialistas como bootstrap. Más razonable porque la deliberación es "¿están bien definidos los 4 nuevos especialistas?", no 4 preguntas separadas.

**Opción C (sin L3, escalado directo L4)**: el master construye dossier mínimo, lo presenta al usuario directo, y el usuario aprueba sin Concilio porque es entregable planificado. Esto es legítimo: el script `check-irreversibility.sh` fuerza L3 estructuralmente, pero el usuario puede aprobar explícitamente L4 sin pasar por Concilio (D21 — "1-de-3 SÍ → escalado L4" es la ruta normal, pero L4 directo también es válido si el usuario lo pide).

**Recomendación**: depende del nivel de disciplina del usuario. Si quiere todo el flujo, **Opción B**. Si quiere arrancar Fase 2 rápido y confía en el plan de `phases.md`, **Opción C**.

### 3. ¿Orden de creación?

**Sugerencia**: `flipper-build-fbt` primero (cualquier app necesita saber buildear), luego `flipper-app-builder` (estructura general), luego los dos de dominio (`flipper-nfc`, `flipper-rf-subghz`). Pero el usuario puede pedir otro orden si tiene una tarea concreta pendiente.

---

## Trampas conocidas y precedentes

### Trampa 1: bug del `Write` (precedente V2)

En la sesión anterior a esta, el `Write` falló sistemáticamente. Workaround documentado: usar `Bash` con heredoc. En la sesión actual el bug está resuelto. Si vuelve a aparecer, ver `.claude/decisions/pending/62978df1-.../RESUME.md` (el original de V2).

### Trampa 2: cuotas del architect (D12)

Si decides Opción A del paso 1, recuerda que la cuota de "1 agente nuevo por sesión" puede bloquear. Hay dos vías:

- Ejecutar 4 sesiones separadas del architect.
- Relajar la cuota para esta sesión específica con justificación explícita en `decisions.jsonl` y mención al usuario.

### Trampa 3: docs curados sin verificación

Los 4 docs (`.claude/docs/*.md`) deben construirse leyendo el codebase real, no inventando. Usar `Explore` (subagent) para mapear cada subsistema antes de escribir el doc. Precedente: el doc `architecture-furios.md` de Fase 1 se construyó así.

### Trampa 4: política anti-AI del upstream

`Next-Flip/Momentum-Firmware` tiene política anti-AI. Tu fork (`samartined/...`) es safe; pero los docs de Fase 2 son tuyos y nunca van al upstream. El hook `pre-push` bloquea cualquier intento. Confirmado en V4.

---

## Cómo arrancar la sesión nueva

### Paso 1 — Verificar contexto

```bash
git status                                          # debe estar limpio o con cambios de build (no relevantes)
git log --oneline -3                                # último commit debe ser 7a8a91f2 (V2 close)
cat .claude/design/CHANGELOG.md | head -50          # confirma versión 0.1.5 en cabecera
cat .claude/decisions/ADR-0001-add-cor-angle.md     # confirma ADR materializado
```

### Paso 2 — Confirmar al usuario el plan

Pregunta al usuario qué decisiones quiere para los 3 puntos abiertos (vía architect vs directo, 4 L3 vs 1 L3 vs L4 directo, orden de creación). No empieces a crear archivos hasta tener su respuesta.

### Paso 3 — Si Opción C (L4 directo)

- Construye un dossier mínimo de "Fase 2 bootstrap" en `.claude/decisions/pending/<nuevo-uuid>/dossier.md`.
- Loguea L4 en `decisions.jsonl` con `criterion_invoked: "user-direct-approval-planned-deliverable"`.
- Crea los 4 archivos de agentes en el orden acordado.
- Crea los 4 docs curados (usa `Explore` subagent para mapear código real).
- Actualiza `REGISTRY.md`.
- Commit consolidado `feat(.claude): bootstrap Phase 2 specialists (subghz, nfc, app-builder, build-fbt)`.

### Paso 4 — Validación final

- Ejecuta una tarea de prueba real (ej. "explícame cómo funciona el TX worker de SubGHz") y verifica que el master delega al especialista correcto.
- Loguea la validación en `decisions.jsonl`.
- Actualiza `CHANGELOG.md` con entrada 0.1.6 cerrando Fase 2.

---

## Información importante de continuidad

- **Branch actual**: `my-momentum/feature/multi-agent-system-v1`.
- **Remote**: solo `origin` → `git@github.com:samartined/My-Momentum-Firmware-F0.git`. NO hay remote `Next-Flip` en este clone.
- **Último commit**: `7a8a91f2 validate(v2): close Council deliberation ADR-0001 (Phase 1.G done)`.
- **Push a origin**: realizado en `2026-05-23`. La rama está accesible desde cualquier sesión cloud que clone este fork.
- **decisions.jsonl**: gitignored. NO viaja con el repo. La nueva sesión arrancará con `decisions.jsonl` propio (local a su clone). Si necesitas continuidad estricta del log, ver opciones en la conversación o cambiar el gitignore.

## Sobre la sesión master

La conversación principal de Claude Code asume el rol de master del sistema multi-agente (CLAUDE.md). Cualquier sesión nueva en cualquier dispositivo (local, claude.ai/code web, Codespaces, VM) que cargue `CLAUDE.md` automáticamente asume ese rol. No hay "sesión master persistente" — el rol vive en el archivo, no en una instancia.
