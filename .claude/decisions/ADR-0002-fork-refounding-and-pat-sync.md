---
id: ADR-0002
title: Re-fundación del fork sobre upstream + sincronización inbound vía PAT
status: accepted
date: 2026-07-24
decision-level: L4
council-id: null
dossier: null
synthetic: false
materialization-status: materialized
materialization-date: 2026-07-24
materialization-files:
  - my-momentum-firmware (rama re-fundada sobre upstream/dev; default del repo)
  - legacy/snapshot-2026-02 (archivo del fork viejo)
  - custom/ghostesp-s2/ (binarios GhostESP + helper)
  - .github/workflows/sync-upstream.yml (sync inbound vía PAT)
---

# ADR-0002 — Re-fundación del fork sobre upstream + sincronización inbound vía PAT

## Status

`accepted` — decisión operativa de nivel **L4** (aprobación directa del usuario; no Concilio). Materializada el 2026-07-24. Toca operaciones irreversibles (reescritura de la rama por defecto, force-push, borrado de ramas remotas) → matchea G3; se procedió por aprobación humana explícita paso a paso (ruta D21 de escalado directo).

## Context

El objetivo del usuario: mantener su fork personal actualizado con el firmware oficial `Next-Flip/Momentum-Firmware` y poder trabajar desde Claude Code Cloud. Al construir un workflow de sync se descubrió que **el fork no compartía historia git con el upstream**: `my-momentum-firmware` era un **snapshot aplanado** (~feb-2026), solo 16 commits, sin ancestro común con `upstream/dev`, y con submódulos (mbedtls, FreeRTOS, nanopb, stm32wb…), `build/`, `toolchain/` y `__pycache__` versionados como ficheros planos. Consecuencia: cualquier merge/PR con upstream era inviable (historias no relacionadas).

Análisis de la personalización real: `ghost_esp` y `esp_flasher` son apps ESTÁNDAR del oficial (viven en el submódulo `applications/external` → `Next-Flip/Momentum-Apps`). La ÚNICA personalización genuina eran 3 binarios de firmware GhostESP ESP32-S2 añadidos a los recursos de `esp_flasher`, ausentes en el oficial.

## Alternatives considered

**Decisión A — cómo hacer el fork sincronizable:**
1. **Re-fundar sobre la historia real de upstream (elegida).** Nueva rama basada en `upstream/dev` + personalizaciones re-aplicadas encima. Da historia compartida → sync limpio.
   - Trade-off: reescribe la rama por defecto (irreversible); requiere re-aplicar personalizaciones.
2. Mantener snapshots (copiar ficheros del upstream sin merge git). Feo, sin beneficios de git, conflictos manuales.
3. No cambiar nada. Objetivo de sync incumplible.

**Decisión B — nomenclatura final:** en vez de dejar `-rebased` como default (rechazado por el usuario), renombrar: vieja `my-momentum-firmware` → `legacy/snapshot-2026-02`; `my-momentum-firmware-rebased` → `my-momentum-firmware` (toma el nombre canónico); fijar default. La vieja se conserva como archivo.

**Decisión C — autenticación del workflow de sync:**
1. **PAT (`SYNC_PAT`) para push + PR (elegida).** Robusto.
2. Solo `GITHUB_TOKEN`. Rechazada: el bot no puede empujar cambios en `.github/workflows/*` (no existe scope `workflows`) → el sync se rompería cuando upstream tocara workflows.
3. Mirror + PR manual (un clic, sin secretos). Rechazada porque el push del mirror seguiría dependiendo del `GITHUB_TOKEN` y toparía con el mismo bug latente.

## Decision

Re-fundar el fork sobre `upstream/dev` en una rama nueva, renombrar para que la default limpia se llame `my-momentum-firmware`, archivar la vieja como `legacy/snapshot-2026-02`, preservar los binarios GhostESP en `custom/ghostesp-s2/` (fuera del submódulo), y sincronizar con upstream vía un workflow inbound autenticado con un PAT fine-grained (`SYNC_PAT`).

## Council votes

N/A — decisión L4 (aprobación directa del usuario, sin Concilio). Cada paso irreversible (push, renombrado de default, borrado de ramas de prueba, flasheo) se confirmó explícitamente con el usuario.

## Consequences

**Positivas:**
- Fork sincronizable de verdad con el oficial (historia compartida; PRs mergeables — verificado: un PR de prueba salió MERGEABLE con 253 commits).
- ~35.000 ficheros de bloat eliminados (submódulos aplanados, build/, toolchain/).
- Trabajo desde la nube viable; personalización GhostESP preservada y validada en hardware.

**Negativas / riesgos asumidos:**
- La default fue reescrita (irreversible); mitigado conservando `legacy/snapshot-2026-02`.
- El PAT es una credencial; mitigado con scope fine-grained mínimo (un repo) y caducidad.
- El camino completo push+PR del sync aún no se ejercitó con delta real (solo smoke test).

**Reversibilidad:** matchea G3. La vieja historia se recupera desde `legacy/snapshot-2026-02`. El PAT se revoca en github.com.

## Follow-ups

- Ejercitar el sync completo (push+PR) en el próximo delta real de upstream; añadir fallback de URL de compare si falla la creación del PR.
- Fase 2 del sistema agente (4 especialistas + docs) sigue pendiente.
- Verificación adversarial de la causa del fallo `createPullRequest` documentada: default-OFF del ajuste de PRs + latencia de propagación; bug latente del push de workflows → motivo real del PAT.
