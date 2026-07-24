# Diseño del sistema multi-agente — Momentum Firmware / Flipper Zero

## Propósito

Este sistema construye un equipo de agentes de Claude hiperespecializados en el firmware Momentum del Flipper Zero para añadir features, optimizar, corregir bugs y sugerir mejoras. El sistema es auto-extensible: puede crear nuevos agentes especializados bajo control humano estricto. Todas las decisiones quedan versionadas en git dentro del repo personal del usuario (`samartined/My-Momentum-Firmware-F0`). El clone oficial (`Next-Flip/Momentum-Firmware`) no recibe ningún artefacto del sistema agente.

---

## Decisiones cerradas

| ID | Decisión | Motivación |
|----|----------|------------|
| D1 | Eliminar el `AGENTS.md` heredado del repo personal del usuario | El repo personal es propiedad del usuario; la política anti-AI del oficial no aplica aquí. El clone oficial mantiene su `AGENTS.md` intacto y se respeta no subiendo nada allí. |
| D2 | Modelos por rol: Opus con `effort: max` para razonamiento/diseño/análisis (master, architect, concejales del Concilio); Sonnet con `effort: medium` para especialistas de dominio. La terminología original "thinking máximo/medio" se canoniza al campo oficial `effort` en frontmatter (ver sección "Mapeo de modelos por rol") | El razonamiento profundo justifica el coste de Opus solo donde aporta valor real; los especialistas necesitan velocidad y contexto de dominio más que razonamiento general. |
| D3 | Arquitectura: orquestador `flipper-master` que delega en especialistas, más meta-agente `agent-architect` que puede crear nuevos especialistas bajo límites | Aislar contexto entre dominios evita contaminación, y escalar capacidad sin diluir el prompt del master. |
| D4 | Concilio Tripartito: 3 instancias Opus invocadas en paralelo para razonamiento global, diseño y tareas cross-dominio. Decisión por votación de los 3 concejales; el master sintetiza pero NO vota (refinado por aprendizaje meta 2). Las perspectivas originales fijas (Pragmático, Visionario, Escéptico) quedan superadas por catálogo dinámico de ángulos en D18 | Evitar groupthink y forzar consideración explícita de trade-offs; el catálogo dinámico evita el sesgo predecible de roles fijos. |
| D5 | El `agent-architect` está limitado por 4 capas: overlap check, casos de uso obligatorios, voto del Concilio, aprobación humana explícita | Prevenir spam de agentes, redundancia y agentes mal diseñados. |
| D6 | Los agentes pueden ejecutar build (`./fbt`, `./fbt fap_*`, `./fbt format`) sin pedir aprobación humana cada vez | El build es no destructivo y se necesita iterar rápido. |
| D7 | Operaciones destructivas (flash, push a remote, borrado, `rm -rf`, `git reset --hard`, `git clean -fd`, force-push) requieren aprobación humana explícita en cada invocación | Estas acciones pueden perder trabajo, dañar hardware o exponer código al repo equivocado. |
| D8 | Implementación por fases con checkpoints en archivos para no perder contexto entre sesiones | El contexto de una conversación es finito; el estado del proyecto debe persistir en disco. |
| D9 | Todo lo del sistema agente (`.claude/**`, `CLAUDE.md`) se versiona en el repo personal. NUNCA en el clone oficial | Alineamiento con la política del oficial y propiedad clara del trabajo en el repo del usuario. |
| D10 | Extended-thinking activado a nivel de proyecto en `.claude/settings.json` (no global) | Aísla la configuración al firmware sin contaminar otros proyectos del usuario. Resolución de P1. |
| D11 | Quorum del Concilio: 2-de-3 SÍ para decisiones normales; unanimidad SÍ para decisiones con acciones destructivas (además de aprobación humana). La cláusula original "segunda ronda con veredictos compartidos" queda **derogada** por aprendizaje meta 3: la ronda 2 anclada se elimina porque colapsa la deliberación en groupthink. En su lugar, la regla 1-de-3 SÍ dispara escalado directo al usuario (ver D21). Si se necesita refinar veredictos, se hace mediante voto sobre síntesis sin compartir veredictos completos | Balancea robustez (mayoría diversa) con coste (no exigir unanimidad cuando no es crítico). Resolución de P2. |
| D12 | Quotas del `agent-architect`: máximo 1 agente nuevo por sesión (modo prudente). El techo total fue revisado al alza por D17 (techo único de 20, no 15) para acomodar la planificación de Fases 2-3. La regla de velocidad de creación (1/sesión) se mantiene | Restricción conservadora para evitar proliferación y forzar consolidación. Resolución de P3 (revisada por D17). |
| D13 | Periodo experimental: N=5 invocaciones sin modificación para que el architect proponga graduar a `stable` | Umbral suficiente para detectar problemas reales en uso sin retrasar la consolidación. Resolución de P4. |
| D14 | Permisos `.claude/settings.json`: build libre; git no destructivo libre (`git add`, `git commit`, `git checkout -b <nueva>`); `git checkout <branch-existente>` libre solo con árbol limpio; flash/push/destructivos siempre piden aprobación; push a `Next-Flip/Momentum-Firmware` bloqueado por hook | Build necesita iteración rápida sin fricción; acciones destructivas necesitan revisión humana; el oficial necesita protección dura para evitar fugas accidentales. Resolución de P5. |
| D15 | Comandos atajo: `/flipper-quick <task>` salta el Concilio y va directo al especialista; `/flipper-council <question>` fuerza convocar al Concilio aunque el master no lo consideraría necesario | Permite control manual al usuario sobre cuándo activar el coste del Concilio. Resolución de P6. |
| D16 | Arranque de Fase 1: a orden expresa del usuario, no automático tras cerrar el resto de puntos | El usuario quiere control explícito sobre el momento de pasar de planificación a implementación. Resolución de P7. |
| D17 | Quota del architect: techo único de 20 agentes en `.claude/agents/`. Lista cerrada de "core agents" mantenida en `system-design.md` (editable solo por PR humano). El hook que cuenta agentes considera todos los archivos contra el techo único | Resolución del Concilio G1: distinción categorial sin enforcement formal sería evadible; un techo único auditable es robusto sin overhead. |
| D18 | Catálogo cerrado de ángulos del Concilio en `.claude/design/council-angles.md` con IDs estables. 1 wildcard máx por sesión con justificación expandida al log. Comando `/flipper-review-wildcards` opt-in para promover recurrentes | Resolución del Concilio G2: catálogo cerrado elimina sesgo del master al elegir ángulos; el wildcard preserva flexibilidad ante casos atípicos del firmware embedded. |
| D19 | Lista cerrada de operaciones irreversibles en `.claude/design/irreversibility.md` (9 entradas). Script de verificación automática por regex que dispara L3 sin juicio subjetivo del master. Extensión vía PR humano | Resolución del Concilio G3: definición operativa enumerada permite que el matching sea automático, no dependa de disciplina del modelo. |
| D20 | Auditoría de clasificaciones L1/L2: Fase 1 solo log JSONL en `.claude/state/decisions.jsonl` (gitignored) con schema versionado en `.claude/design/decisions-schema.md`. Activación del auditor Sonnet en Fase 2+ condicionada a evidencia empírica: ratio L1+L2/total > 95% durante ventana mínima de N=100 decisiones | Resolución del Concilio G4: construir auditor sin datos sería sobreingeniería; activación empírica con umbral explícito evita falsas alarmas. |
| D21 | Regla 1-de-3 SÍ del Concilio: escalado obligatorio al usuario (nivel L4) | Resolución del Concilio G5: cuando solo un concejal vota SÍ, la deliberación automatizada no tiene legitimidad; transparencia al humano es la única respuesta defendible. |
| D22 | Framework `pre-commit` (Python ya es dependencia del firmware vía fbt) + script `./setup.sh` invocable como una línea sin flags + validación binaria de existencia de archivos esperados (no suite de tests) + mensaje de diagnóstico si falla | Resolución del Concilio G6: `pre-commit` es estándar maduro y la dependencia ya está pagada; setup mínimo verificable cubre el caso de uso individual. |
| D23 | `/devils-advocate` como L2 articulado explícitamente como "deliberación intermedia barata, no sustituto del Concilio". Hard rule estructural: si la operación matchea la lista G3 (irreversibles), L1 y L2 quedan deshabilitados — solo L3 o L4 son válidos. Matching automático vía script G3, no juicio del master | Resolución del Concilio G7: la lista G3 actúa como invariante estructural que impide la degradación de L3 a L2 sin requerir disciplina del modelo. |
| D24 | Techo de coste: Fase 1 soft warning al 60% del presupuesto + hard cap configurable en `.claude/design/cost-policy.md` (default $50/sesión) + log granular por invocación con tokens in/out y coste estimado en `.claude/state/costs.jsonl` + tabla tokens→USD con fecha de última actualización y fuente | Resolución del Concilio G8: warning sin enforcement se ignora; hard cap muy alto es safety net contra patologías sin fricción en uso normal. |
| D25 | Modelo de dos clones físicos formalizado en README + hook `pre-push` bloqueante (exit != 0) que matchea `Next-Flip/*` + override consciente vía variable de entorno + mensaje de stderr imprime literalmente el comando de override en la primera línea al bloquear | Resolución del Concilio G9: la separación física de credenciales es la barrera real; el hook bloqueante con override visible es defensa en profundidad sin fricción crónica. |
| D26 | Failure modes de routing: comando `/flipper-redirect <especialista>` manual + flag binario obligatorio `out_of_scope: bool` en cada respuesta de especialista. Si `out_of_scope: true`, master reasigna automáticamente al architect. Log de redirecciones para mejora longitudinal. Sin `confidence` per-respuesta en Fase 1 | Resolución del Concilio G10: flag binario es auditable y suficiente; score de confianza sería ruido sin valor empírico demostrado. |
| D27 | Reconstrucción obligatoria del dossier antes de cada L3 a `.claude/decisions/pending/<id>/dossier.md` con schema mínimo (enunciado, archivos consultados con paths absolutos, alternativas consideradas, criterio de irreversibilidad invocado). Tope blando 10 archivos / hasta 20 con justificación expandida en sección "Por qué excedo el tope". Comando `/flipper-reset` disponible como opt-in del usuario | Resolución del Concilio A1: el master como conversación principal arrastra contexto contaminante; reconstruir dossier desde cero es la salvaguarda más barata; tope blando previene inflación defensiva. |

---

## Estructura de archivos prevista

```
My-personal-momentum-F0-firmware/
├── CLAUDE.md                              # base auto-cargado; instrucciones del master
├── .pre-commit-config.yaml                # config del framework pre-commit (D22)
├── .githooks/                             # hooks git versionados (D22, D25)
│   ├── pre-push                           # bloqueante para Next-Flip/*
│   └── pre-tool-use-checkout              # valida árbol limpio antes de git checkout
├── .claude/
│   ├── settings.json                      # permisos + alwaysThinkingEnabled (versionado)
│   ├── settings.local.json                # preferencias locales (en .gitignore)
│   ├── design/                            # documentación viva del sistema agente
│   │   ├── system-design.md               # este documento — fuente de verdad
│   │   ├── phases.md                      # plan de fases de implementación
│   │   ├── CHANGELOG.md                   # registro de cambios al sistema agente
│   │   ├── council-angles.md              # catálogo cerrado de 12 ángulos (D18)
│   │   ├── irreversibility.md             # lista cerrada de 9 patrones (D19)
│   │   ├── decisions-schema.md            # schema del log decisions.jsonl (D20)
│   │   └── cost-policy.md                 # techo y tabla tokens→USD (D24)
│   ├── agents/                            # subagentes (techo 20 — D17)
│   │   ├── REGISTRY.md                    # registro auditable de agentes
│   │   ├── agent-architect.md             # META-AGENTE: crea nuevos agentes
│   │   ├── council-member.md              # Concejal parametrizable (3× en paralelo)
│   │   ├── flipper-rf-subghz.md           # SubGHz / CC1101
│   │   ├── flipper-nfc.md                 # NFC / ISO14443/15693 / MFC
│   │   ├── flipper-rfid-ibutton.md        # LFRFID 125kHz + 1-Wire
│   │   ├── flipper-ble.md                 # Bluetooth LE
│   │   ├── flipper-ir.md                  # Infrarrojos
│   │   ├── flipper-badusb-hid.md          # BadUSB / HID
│   │   ├── flipper-app-builder.md         # Apps externas, .fam, scenes/views
│   │   ├── flipper-c-furi.md              # C bajo nivel + FuriOS/FreeRTOS
│   │   ├── flipper-build-fbt.md           # SCons / fbt / toolchain / OTA
│   │   ├── flipper-companion-hw.md        # ESP32 (Marauder/GhostESP), GPIO
│   │   └── flipper-js-mjs.md              # apps JS (mJS) / JS bindings
│   ├── skills/
│   │   └── devils-advocate/               # nivel L2: 1× Opus multi-ángulo (D23)
│   ├── commands/
│   │   ├── flipper.md                     # /flipper → entra en modo Flipper
│   │   ├── flipper-quick.md               # atajo: salta el Concilio (D15)
│   │   ├── flipper-council.md             # fuerza convocar al Concilio (D15)
│   │   ├── flipper-redirect.md            # corrige routing en runtime (D26)
│   │   ├── flipper-review-wildcards.md    # revisa wildcards del Concilio (D18)
│   │   ├── flipper-reset.md               # opt-in: limpia contexto del master (D27)
│   │   ├── flipper-new-app.md
│   │   ├── flipper-spawn-agent.md
│   │   ├── flipper-promote-prompt.md
│   │   └── flipper-build.md
│   ├── decisions/                         # ADRs (versionados)
│   │   ├── README.md
│   │   ├── ADR-NNNN-<slug>.md             # un archivo por ADR cerrado
│   │   └── pending/<id>/                  # artefactos intermedios del Concilio (D27)
│   │       ├── dossier.md                 # del master, schema en sección "Dossier"
│   │       ├── concejal-1.md              # veredicto ángulo 1
│   │       ├── concejal-2.md              # veredicto ángulo 2
│   │       └── concejal-3.md              # veredicto ángulo 3
│   ├── scripts/                           # scripts del sistema agente
│   │   ├── check-irreversibility.sh       # matcher regex sobre lista G3 (D19)
│   │   └── setup.sh                       # bootstrap: pre-commit install + validación
│   ├── state/                             # estado runtime (en .gitignore, local al clone)
│   │   ├── decisions.jsonl                # log de clasificaciones L1-L4 (D20)
│   │   ├── counters.json                  # invocation_count por agente
│   │   ├── costs.jsonl                    # log granular tokens/USD (D24)
│   │   └── wildcards.jsonl                # ángulos ad-hoc del Concilio
│   ├── prompts/
│   │   ├── README.md
│   │   ├── golden/                        # prompts probados y versionados
│   │   └── drafts/                        # prompts en evaluación
│   └── docs/                              # conocimiento curado del firmware
│       ├── architecture-furios.md
│       ├── subghz-internals.md
│       ├── nfc-stack.md
│       └── adding-an-app-checklist.md
```

---

## Roles de agentes

El master NO es un subagente: vive como la conversación principal de Claude Code (ver D17 implícitamente y aprendizaje meta 2). Los siguientes son los **subagentes** definidos en `.claude/agents/`:

| Agente | Modelo | Effort | Rol | Invocado cuando |
|--------|--------|--------|-----|-----------------|
| agent-architect | Opus | `max` | Diseña y propone nuevos agentes especializados | el master detecta un dominio no cubierto o el usuario lo pide vía `/flipper-spawn-agent` |
| council-member | Opus | `max` | Concejal del Concilio Tripartito. Recibe un ángulo asignado del catálogo G2 (`.claude/design/council-angles.md`) y argumenta desde él | el master convoca al Concilio (L3): el archivo se invoca **3 veces en paralelo**, cada invocación con un ángulo distinto |
| flipper-rf-subghz | Sonnet | `medium` | Experto en SubGHz/CC1101: protocolos OOK/FSK, keystore, modulaciones, extensión de bandas, decoders | tarea que toca `applications/main/subghz/`, `lib/subghz/`, o protocolos RF |
| flipper-nfc | Sonnet | `medium` | Experto en NFC: ISO14443A/B, ISO15693, MFC/MFUL/MFP, EMV, plugins NFC | `applications/main/nfc/`, `lib/nfc/` |
| flipper-rfid-ibutton | Sonnet | `medium` | Experto en LFRFID 125kHz y 1-Wire (iButton): EM4100, T55xx, HID Prox, Dallas | `applications/main/lfrfid/`, `applications/main/ibutton/`, `applications/main/onewire/`, `lib/lfrfid/`, `lib/ibutton/` |
| flipper-ble | Sonnet | `medium` | Experto en BLE: profiles, BLE spam, advertising | `lib/ble_profile/`, código BLE relacionado |
| flipper-ir | Sonnet | `medium` | Experto en infrarrojos: universal remote, capturas, parsing | `applications/main/infrared/`, `lib/infrared/` |
| flipper-badusb-hid | Sonnet | `medium` | Experto en BadUSB / HID / DuckyScript | `applications/main/bad_usb/` |
| flipper-app-builder | Sonnet | `medium` | Scaffold de apps externas, manifest `.fam`, patrones de scenes/views/ViewModel | crear nueva app, modificar manifest, refactor de scenes |
| flipper-c-furi | Sonnet | `medium` | C bajo nivel + FuriOS (FreeRTOS): mutex, threads, message queues, timers, records | código en `furi/`, `lib/`, primitivas de OS |
| flipper-build-fbt | Sonnet | `medium` | Build system: SCons, fbt, toolchain, generación de OTA, targets | tareas de build, errores de compilación, configuración de toolchain |
| flipper-companion-hw | Sonnet | `medium` | Hardware externo: ESP32 (Marauder/GhostESP), GPIO, módulos | tarea que involucra hardware compañero o GPIO |
| flipper-js-mjs | Sonnet | `medium` | Apps JS (mJS) y bindings JavaScript | applications con manifest type JS, `lib/mjs/` |

### Lista cerrada de core agents (fijada por D17)

Los siguientes 2 agentes son **core** — el architect no puede proponer su retiro automáticamente, solo por PR humano. Cuentan contra el techo de 20:

- `agent-architect`
- `council-member`

(Originalmente se planificaron 5 core: master + architect + 3 concejales. La cifra real es 2 porque el master ya no es subagente y los 3 concejales se unificaron en un solo archivo parametrizable `council-member`. La planificación de Fases 2-3 añade 11 especialistas — total: 13 agentes, dejando margen de 7 para el architect en operación supervisada.)

### Áreas no cubiertas por especialista dedicado

Algunas áreas del firmware no tienen un agente especializado propio. Quedan cubiertas implícitamente por agentes adyacentes hasta que el `agent-architect` proponga (con justificación) crear un especialista dedicado:

- **U2F** (`applications/main/u2f/`): cubierto provisionalmente por `flipper-c-furi` (lógica de bajo nivel) y `flipper-app-builder` (UI/scenes). Candidato claro a especialista propio si la demanda lo justifica.
- **Archive** (`applications/main/archive/`): visor de archivos del sistema. Cubierto por `flipper-app-builder` y `flipper-c-furi`. No se prevé especialista dedicado salvo refactor mayor.
- **GPIO** (`applications/main/gpio/`): parcialmente cubierto por `flipper-companion-hw`. Si crece la demanda específica de GPIO sin hardware externo, candidato a especialista propio.
- **momentum_app** (`applications/main/momentum_app/`): app de configuración interna del firmware. Cubierta por `flipper-app-builder` y `flipper-c-furi`. No se prevé especialista dedicado.

Esta lista se revisa al final de cada fase. Criterio de promoción: si surgen 3 o más tareas reales sobre un área no cubierta, el architect propone formalmente crear su especialista siguiendo las 4 capas de control.

---

## Niveles de deliberación L1-L4

Toda decisión que el master enfrenta se clasifica en uno de 4 niveles según impacto. Esta clasificación es central al sistema porque controla cuánto coste de modelo se gasta en cada decisión y qué mecanismos de control se activan.

### Diagrama de decisión

```
                Tarea / decisión
                       │
                       ▼
        ┌─────────────────────────────────┐
        │ ¿Operación matchea lista G3     │
        │ (irreversibility.md, D19)?      │
        │ Chequeo automático vía regex    │
        └──────┬──────────────────┬───────┘
            NO │                  │ SÍ
               ▼                  ▼
        ┌───────────────┐   ┌──────────────────┐
        │ Master        │   │ FORZADO a L3/L4  │
        │ clasifica     │   │ L1/L2 prohibidos │
        │ por impacto   │   │ estructuralmente │
        └───┬───┬───┬───┘   └────────┬─────────┘
            │   │   │                │
           L1  L2  L3 ◄──────────────┘   o L4
            │   │   │                    │
            ▼   ▼   ▼                    ▼
         Master /devils- Concilio    Escalado
         solo   advocate 3× Opus     al usuario
         decide (skill,  + ADR
                1× Opus  obligatorio
                multi-
                ángulo)
```

### Tabla de niveles

| Nivel | Mecanismo | Coste relativo | Cuándo |
|-------|-----------|----------------|--------|
| **L1** | Master decide solo, sin invocación extra | 0× | Tarea con 1 dominio claro, ergonomía menor, sin match G3 |
| **L2** | Skill `/devils-advocate`: 1× llamada Opus con prompt multi-ángulo (D23) | 1× extra | Tarea con 2 dominios, refactor menor, dudas tácticas, sin match G3 |
| **L3** | Concilio Tripartito: 3× `council-member` paralelos con ángulos del catálogo G2 + ADR | 3× extra mínimo (típicamente ~9× tras 3 rondas) | Match G3, propuesta del architect, decisión irreversible, decisión cross-dominio que el master no se siente legitimado a tomar |
| **L4** | Escalado al usuario con dossier | 0× modelo | Tras Concilio sin ≥2/3 (1-de-3 SÍ — D21), o cuando el master explícitamente no se siente legitimado |

### Auditoría de la clasificación (D20)

Cada decisión se registra en `.claude/state/decisions.jsonl` (gitignored) con el schema definido en `decisions-schema.md`. Esto permite detectar empíricamente si el master está sesgando hacia clasificaciones baratas (L1/L2) cuando debería ser L3. En Fase 1 es solo log; en Fase 2+ se activa auditor Sonnet si los datos muestran sesgo (ratio L1+L2/total > 95% durante ventana N ≥ 100, o detección manual del usuario).

### Imposibilidad de degradación de L3 (D23)

La hard rule "lista G3 → fuerza L3/L4" es **estructural, no por convención**: el script `check-irreversibility.sh` se ejecuta automáticamente y si hay match, el master no tiene la opción de elegir L1 o L2. Esto cierra el principal modo de fallo (master degradando deliberaciones costosas a baratas por presión de latencia/contexto).

---

## El Concilio Tripartito

### Composición y mecanismo base

El Concilio es el mecanismo de nivel L3 (ver sección "Niveles de deliberación L1-L4"). Está formado por **3 instancias del subagente `council-member` invocadas en paralelo** desde la conversación principal (master), cada una con un ángulo distinto asignado del catálogo `.claude/design/council-angles.md` (D18). Los 3 concejales votan; el master **sintetiza pero no vota** (refinado por aprendizaje meta 2).

Los ángulos NO son fijos: el master elige 3 ángulos del catálogo cerrado de 12 (más opcionalmente 1 wildcard ad-hoc con justificación expandida) según el tipo de decisión. Esto sustituye la idea original de roles permanentes Pragmático/Visionario/Escéptico (superada por D18) y elimina el sesgo predecible de roles fijos.

### Cuándo se invoca (criterios de L3)

El master convoca al Concilio (L3) si la tarea cumple cualquiera de:

- La operación matchea la lista cerrada de **irreversibles** (`.claude/design/irreversibility.md`, D19) — el matching es automático vía script regex, no juicio del master, y deshabilita estructuralmente L1/L2 (D23).
- La propuesta viene del `agent-architect` (crear o retirar un agente).
- El usuario lo solicita explícitamente vía `/flipper-council` (D15) o "convoca al concilio".
- La decisión es cross-dominio o implica cambio de arquitectura/convención sin matchear lista G3 (juicio del master, registrado en log para auditoría — ver D20).

Para tareas más ligeras existen niveles inferiores: L1 (master decide solo), L2 (skill `/devils-advocate`, deliberación intermedia con 1× llamada Opus multi-ángulo). Ver sección "Niveles de deliberación L1-L4".

### Procedimiento (3 rondas)

**Ronda 1 — Propuestas paralelas independientes**

1. El master construye un **dossier obligatorio** (ver sección "Dossier obligatorio antes de L3", D27) y lo escribe a `.claude/decisions/pending/<id>/dossier.md`. Schema mínimo + tope blando 10 archivos / hasta 20 con justificación expandida.
2. El master selecciona 3 ángulos del catálogo G2 (más opcionalmente 1 wildcard con justificación de 3-5 líneas al log).
3. El master lanza 3 invocaciones paralelas del subagente `council-member`, cada una con su ángulo asignado y el dossier como input. Los concejales no se ven entre sí (independencia para evitar anclaje).
4. Cada concejal produce un veredicto estructurado:
   - Recomendación: `PROCEDER` / `MODIFICAR` / `RECHAZAR`
   - Razones (≤3)
   - Riesgos detectados desde su ángulo
   - Voto: `SÍ` / `NO` / `SÍ-CON-CONDICIONES`
5. Cada veredicto se escribe a `.claude/decisions/pending/<id>/concejal-N.md` antes de que el master los recoja (persistencia obligatoria — permite auditoría, re-ejecución parcial, y trazabilidad sin depender de la memoria conversacional).

**Ronda 2 — Voto sobre síntesis (sin anclaje)**

6. El master sintetiza los 3 veredictos en una propuesta unificada. La síntesis NO comparte los veredictos completos a los concejales (eso reintroduciría el anclaje de la "segunda ronda" derogada por aprendizaje meta 3).
7. El master lanza una segunda invocación paralela de los 3 concejales con la síntesis propuesta + sus propios veredictos previos. Cada uno vota `SÍ` / `NO` / `SÍ-CON-CONDICIONES` sobre la síntesis específica.

**Ronda 3 (opcional) — Validación cruzada de condiciones**

8. Si en ronda 2 alguno votó `SÍ-CON-CONDICIONES`, el master lanza una tercera invocación paralela pidiendo a cada concejal evaluar las condiciones de los otros (sin ver los veredictos completos, solo las condiciones). Resultado: aceptación o veto de cada condición.

**Resolución final**

- **Unanimidad SÍ tras ronda 2/3**: procede; ADR cerrado en `.claude/decisions/ADR-NNNN-<slug>.md`.
- **2-de-3 SÍ tras ronda 2/3**: procede; voto minoritario documentado como riesgo conocido en el ADR.
- **1-de-3 SÍ**: escalado **obligatorio** al usuario (L4) — fijado por D21. Sin ronda 2 anclada (derogada por aprendizaje meta 3).
- **Decisiones con acciones destructivas**: requieren unanimidad SÍ + aprobación explícita del usuario (D11).
- **0-de-3 SÍ**: escalado al usuario; la propuesta queda registrada como rechazada.

### Documentación

Cada sesión del Concilio que cierra (unanimidad o 2-de-3) genera un ADR en `.claude/decisions/ADR-NNNN-<slug>.md`. El directorio `.claude/decisions/pending/<id>/` contiene los artefactos intermedios (dossier + 3 veredictos por ronda); al cerrar el ADR, `pending/<id>/` puede archivarse o mantenerse según política de retención.

### Coste y atajos

El Concilio en una sola ronda son 3 llamadas Opus con `effort: max` (coste elevado). El procedimiento típico convergente son 3 rondas: ~9 llamadas Opus. Atajos:

- `/flipper-quick <task>` (D15): salta el Concilio y va directo a especialista. Solo aplicable si la operación NO matchea la lista G3 (irreversibles).
- `/flipper-council <question>` (D15): fuerza convocar al Concilio incluso cuando el master no lo consideraría necesario.
- `/devils-advocate` (D23): nivel L2, 1× llamada Opus con prompt multi-ángulo. NO sustituto del Concilio, solo deliberación intermedia barata.

Los umbrales del quorum están fijados por D11+D21 (refinados sobre la versión original).

---

## Dossier obligatorio antes de L3 (D27)

Antes de cada invocación del Concilio (L3), el master debe construir un **dossier formal escrito a disco**. Esto resuelve el riesgo de contaminación de contexto del master (ahora que es la conversación principal y arrastra historial conversacional) y garantiza que los 3 concejales reciban el mismo input verificable.

### Ubicación

`.claude/decisions/pending/<id>/dossier.md` (donde `<id>` es un UUIDv7 del Concilio).

### Schema mínimo (secciones obligatorias)

1. **Enunciado**: descripción precisa de la decisión a tomar, reconstruida desde cero — no copiada del historial conversacional. ≤200 palabras.
2. **Archivos consultados**: lista de paths absolutos de los archivos del codebase que el master leyó para informar el dossier. Cada uno con un resumen de 1-2 líneas de por qué es relevante.
3. **Alternativas consideradas**: ≥2 opciones reales (no "X" vs "no X"), cada una con trade-offs explícitos.
4. **Criterio de irreversibilidad invocado**: si la decisión llegó a L3 por match con lista G3, indicar qué entrada (`IRREV-N`). Si llegó por juicio del master, indicar criterio (cross-dominio, architect, etc.).

### Tope de archivos consultados

- **Tope blando**: 10 archivos típicamente.
- **Tope duro**: 20 archivos máximo.
- Si el master excede 10, debe incluir sección "Por qué excedo el tope" con justificación expandida.
- Si excede 20, debe escalar al usuario antes de continuar (la decisión requiere demasiado contexto para deliberar de forma estructurada).

### Disciplina contra contaminación

El master debe operar como si el contexto conversacional previo NO existiera al construir el dossier. Solo el dossier resultante es input para los concejales. El historial puede informar al master sobre el problema, pero no debe filtrarse al Concilio sin pasar por el filtro del dossier.

### Comando de escape

`/flipper-reset` está disponible como opt-in del usuario para limpiar contexto cuando se sospecha contaminación severa. NO se invoca automáticamente — la disciplina del dossier es el mecanismo primario; el reset es el secundario.

---

## El agent-architect y sus límites

### Propósito

Crear nuevos subagentes especializados cuando se detecta un dominio del firmware no cubierto por los agentes existentes.

### Cuatro capas de control en serie

1. **Overlap check**: el architect debe demostrar que ningún agente existente cubre el dominio propuesto. Para ello lista los agentes actuales (por `REGISTRY.md`) y justifica la brecha con ejemplos concretos del codebase o de peticiones del usuario.

2. **Casos de uso obligatorios**: el architect debe presentar 3 tareas reales, no hipotéticas, basadas en el firmware o en peticiones concretas del usuario, que se beneficiarían del nuevo agente. Tareas hipotéticas o genéricas no son válidas.

3. **Voto del Concilio**: el architect presenta la propuesta formal al Concilio. Requiere 2-de-3 SÍ para avanzar. Cuando la decisión es "crear un agente nuevo", los ángulos típicamente seleccionados del catálogo G2 son `ORT` (¿ortogonal con los existentes o redundante?), `MNT` (¿quién lo mantiene?) y `COS` (¿justifica el coste-token?), pero el master puede sustituirlos según el caso.

4. **Aprobación humana**: el master presenta el plan final al usuario (rol, prompt completo, modelo, herramientas, casos de uso aprobados, votos del Concilio). Sin OK explícito del usuario, no se escribe ningún archivo.

### Quotas

**Máximo 1 agente nuevo por sesión** (modo prudente: obliga a digerir cada propuesta antes de seguir, fijado por D12) y **techo único de 20 agentes totales** en `.claude/agents/` (fijado por D17). Los 2 agentes core (ver sección "Lista cerrada de core agents" más arriba: `agent-architect` y `council-member`) cuentan contra el techo único pero están marcados como permanentes — el architect no puede proponer su retiro automáticamente, solo por PR humano.

Si se llega al techo de 20, el architect debe proponer retirar un agente especialista existente antes de crear otro (consolidación obligatoria). El hook que cuenta agentes considera todos los archivos `*.md` en `.claude/agents/` contra el techo único.

### Registro auditable

Cada agente creado genera una entrada en `.claude/agents/REGISTRY.md` con: fecha de creación, motivo, casos de uso aprobados, votos del Concilio y commit hash donde se añadió el archivo.

### Periodo experimental

Un agente nuevo nace con `status: experimental`. Tras **5 invocaciones sin modificación posterior** (fijado por D13), el architect propone graduarlo a `status: stable`. Mientras es experimental, el master menciona "este agente está en pruebas" al invocarlo.

**Mecanismo de conteo**: cada entrada en `REGISTRY.md` lleva dos campos contadores:

- `invocation_count`: incrementado por el master cada vez que delega una tarea al agente.
- `last_modified_commit`: hash del último commit que tocó el archivo del agente.

El conteo de "usos sin modificación" es `invocation_count` desde el último cambio de `last_modified_commit`. Cuando alcanza N, el architect lanza una propuesta de graduación al usuario; tras OK explícito se actualiza `status: stable` y se reinicia el contador. Si el agente se modifica antes de alcanzar N, el contador se reinicia automáticamente al actualizarse `last_modified_commit`.

---

## Operaciones destructivas y guardrails

Cinco capas de protección en defensa en profundidad. Cada capa cubre un modo de fallo distinto; ninguna sola basta.

### Capa 1 — Modelo de dos clones físicos (D25)

Barrera primaria, no evadible desde el agente:

- Clone oficial (`Momentum-Firmware/`): sin sistema agente, con remote `Next-Flip/Momentum-Firmware`. Aquí se hace `git fetch` y se sigue el upstream. **No se versiona nada de `.claude/**` aquí**.
- Clone personal (`My-personal-momentum-F0-firmware/`): con sistema agente completo, SIN remote `Next-Flip` añadido. Solo `origin → samartined/My-Momentum-Firmware-F0`.

Sin remote configurado y sin credenciales, no hay forma técnica de push accidental al oficial desde el clone personal.

### Capa 2 — Git hooks bloqueantes (D22, D25)

Hooks versionados vía framework `pre-commit` + `.githooks/`:

- `.githooks/pre-push`: si el URL de destino matchea `Next-Flip/*`, exit code != 0 y mensaje en stderr que imprime literalmente el comando de override (variable de entorno) en la primera línea, para que el usuario consciente desbloquee con un copia-pega y el distraído lea el mensaje antes de actuar.
- `pre-commit install` ejecutado por `setup.sh` post-clone garantiza activación uniforme.

### Capa 3 — Lista G3 + script regex (D19, D23)

Invariante estructural sobre la clasificación de decisiones:

- `.claude/design/irreversibility.md` lista 9 patrones de operaciones irreversibles.
- `.claude/scripts/check-irreversibility.sh` matchea por regex sobre el comando o path antes de ejecutar.
- Si hay match positivo, L1 (master solo) y L2 (`/devils-advocate`) quedan **estructuralmente prohibidos**: solo L3 (Concilio) o L4 (escalado al usuario) son válidos. El master no puede degradar a barato — es invariante, no depende de su disciplina.

### Capa 4 — Claude Code `permissions.ask` + hook `PreToolUse`

Capa de permisos a nivel de Claude Code (D14):

- `.claude/settings.json` define `permissions.ask` para patrones de comandos destructivos: `./fbt flash*`, `git push` (cualquier remote), `git push --force`, `git reset --hard`, `git clean -fd`, `rm -rf`.
- Hook `PreToolUse` específico para `git checkout <branch-existente>`: ejecuta `git status --porcelain` antes; si el árbol no está limpio, fuerza `permissions.ask` para evitar sobrescribir trabajo no commiteado.

### Capa 5 — Política replicada en cada subagente

CLAUDE.md y cada `.claude/agents/*.md` incluyen instrucción explícita: "Tu rol es proponer, no flashear. Cuando llegues a una acción que toca hardware, push a remoto o borrado, escribe el comando exacto y pide confirmación al usuario; no lo ejecutes tú."

Esta capa es de cultura, no de mecanismo — pero refuerza el patrón en cada subagente.

### Operaciones cubiertas por las capas

| Operación | Capas que la protegen |
|-----------|------------------------|
| Push a `Next-Flip/*` | 1 (no remote) + 2 (hook bloqueante) |
| `./fbt flash*` | 3 (lista G3 #7) + 4 (`permissions.ask`) + 5 (política) |
| `git push --force` | 3 (lista G3 #1) + 4 (`permissions.ask`) |
| `rm -rf` sobre versionados | 3 (lista G3 #3) + 4 (`permissions.ask`) + 5 |
| Modificación de `.claude/design/`, `.claude/agents/`, `settings.json`, hooks | 3 (lista G3 #2, #5, #6) — fuerza L3 |
| `git checkout <existente>` con árbol sucio | 4 (hook PreToolUse condicional) |
| Borrado de slots SubGHz/NFC/IR/RFID, SD card assets | 4 (`permissions.ask`) + 5 |

---

## Mapeo de modelos por rol

El frontmatter de subagente de Claude Code soporta los siguientes campos relevantes para este sistema:

- `name`, `description` (obligatorios)
- `tools`, `disallowedTools`
- `model`: `opus | sonnet | haiku | inherit`
- `effort`: `low | medium | high | xhigh | max` (sobreescribe el nivel de sesión)
- `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `isolation`, `color`, `initialPrompt`

Mapeo aplicado a este sistema:

| Rol | Modelo | Effort | Notas |
|-----|--------|--------|-------|
| Conversación principal (master) | Opus | n/a (controlado por `alwaysThinkingEnabled: true` en `.claude/settings.json`) | El master no es subagente |
| `agent-architect` | Opus | `max` | Diseño de nuevos agentes |
| `council-member` (invocado 3× en paralelo desde la conversación principal) | Opus | `max` | Razonamiento profundo desde el ángulo asignado del catálogo G2 |
| Especialistas de dominio | Sonnet | `medium` | Trabajo concreto, contexto curado |

Esta configuración corrige una nota técnica errónea del diseño original (versión v0.1.0 a v0.1.2) que afirmaba que no existía campo `effort` por agente. Tras verificación contra la documentación oficial de Claude Code (`code.claude.com/docs/en/subagents-and-plugins.md`) se confirma que el campo existe y se debe usar.

---

## Persistencia de decisiones

- `.claude/design/system-design.md` — documento vivo del sistema agente (este archivo). Fuente de verdad única sobre cómo está construido el sistema. Se actualiza al final de cada fase.
- `.claude/design/phases.md` — el plan de fases de implementación con criterios de "done" por fase.
- `.claude/design/CHANGELOG.md` — registro de cambios al sistema agente: qué se cambió, por qué y cuándo.
- `.claude/decisions/ADR-NNNN-<slug>.md` — decisiones operativas tomadas por el sistema (no sobre el sistema). Formato ADR: Status, Context, Decision, Consequences.

---

## Aprendizajes meta del Concilio en vivo

Al ejecutar el Concilio Tripartito como ejercicio práctico para cerrar los 11 gaps emergieron observaciones que refinan el propio mecanismo:

1. **Ronda 1 paralela funciona sin groupthink**: dos concejales Opus con posturas asignadas producen propuestas genuinamente complementarias cuando no se ven entre sí. La diversidad estructural emerge.

2. **El rol de moderador-sintetizador debe ser distinto del de los 3 concejales votantes**: en versión productiva del Concilio, el master sintetiza pero NO vota. Construye puentes entre concejales sin convertirse en cuarta voz. Esto refuerza D4 con un matiz importante.

3. **Ronda 2 de voto sobre síntesis funciona sin reintroducir anclaje**: lo que generaba groupthink era compartir veredictos completos para re-deliberar; lo que sí sirve es una ronda separada de voto SÍ / NO / SÍ-CON-CONDICIONES sobre una síntesis ya producida. La eliminación de "ronda 2 anclada" (D11) se mantiene; el voto sobre síntesis es mecanismo distinto.

4. **Convergencia típica en 3 rondas**: propuestas paralelas → voto sobre síntesis con condiciones → validación cruzada de condiciones. Coste ~3x respecto a una sola llamada al master; defendible solo para decisiones L3.

---

## Puntos abiertos

**Sin puntos abiertos.** Los 7 originales (P1-P7) fueron resueltos como D10-D16. Los 11 gaps detectados por la dialéctica adversarial (G1-G10 + A1) fueron cerrados por el Concilio Tripartito en 3 rondas (ronda 1: propuestas paralelas; ronda 2: voto sobre síntesis con condiciones; ronda 3: validación cruzada de condiciones) y plasmados como D17-D27.

El sistema está listo para arrancar Fase 1; la orden de arranque la da expresamente el usuario (D16).
