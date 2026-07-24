# RESUME — Portabilidad a la nube, re-fundación del fork y sync con upstream

## Resumen ultracorto

Sesión centrada en que el fork sea **usable desde Claude Code Cloud** y **sincronizable con el firmware oficial**. Se logró: (1) auto-bootstrap en cada arranque de sesión; (2) diagnóstico de que el fork era un snapshot sin historia compartida con upstream; (3) **re-fundación** del fork sobre la historia real de `upstream/dev`; (4) renombrado de ramas para que la default limpia se llame `my-momentum-firmware`; (5) preservación de la única personalización real (binarios GhostESP ESP32-S2); (6) validación en hardware (compiló + flasheado); (7) workflow de sincronización con upstream vía PR, endurecido con un PAT tras investigación adversarial.

Este RESUME es autocontenido: una sesión nueva (local o nube) puede leer `CLAUDE.md` + este archivo y continuar sin más historial.

---

## Estado del repo (a 2026-07-24)

### Ramas (remoto `origin` = `samartined/My-Momentum-Firmware-F0`, ÚNICO remote)

| Rama | Rol | Base de historia |
|---|---|---|
| **`my-momentum-firmware`** (DEFAULT) | Línea go-forward. Base limpia de upstream + personalizaciones. | Historia real de `upstream/dev` (comparte ancestro → sincronizable) |
| `legacy/snapshot-2026-02` | Archivo del fork viejo (snapshot aplanado feb-2026). NO borrar sin motivo. | Historia huérfana, sin relación con upstream |
| `sync/upstream-dev` | Rama espejo de `upstream/dev` que mantiene el workflow de sync. | Espejo de upstream |
| `my-momentum/feature/multi-agent-system-v1` | Rama de trabajo histórica del sistema agente. **Basada en la historia vieja huérfana** → NO fusionar contra la default. | Historia vieja |

**IMPORTANTE:** el trabajo nuevo del sistema agente va sobre **`my-momentum-firmware`** (la default re-fundada), NO sobre la vieja feature branch (que quedó anclada a la historia huérfana).

### Contenido clave presente en `my-momentum-firmware`

- `.claude/**` + `CLAUDE.md` — sistema multi-agente completo.
- `.github/workflows/sync-upstream.yml` — workflow de sync (ver abajo).
- `custom/ghostesp-s2/` — binarios GhostESP ESP32-S2 (`bootloader.bin`, `partition-table.bin`, `Ghost_ESP_IDF.bin`) + `README.md` + `deploy-to-esp-flasher.sh`. Es la ÚNICA personalización de firmware real; vive fuera del submódulo `applications/external` (que apunta al oficial `Next-Flip/Momentum-Apps`).
- Sin `build/` ni `toolchain/` versionados (usa la estructura del oficial con 14 submódulos).

### Validación en hardware (hecha)

Worktree limpio + `git submodule update --init --recursive` + `./fbt` → `firmware.dfu` OK. FAPs `ghost_esp` y `esp_flasher` compilan (APPCHK OK). Flasheado al Flipper con `./fbt flash_usb` con éxito.
Gotcha del host Linux: `cdc_acm` no estaba cargado → `sudo modprobe cdc_acm` + replug físico para que aparezca `/dev/ttyACM0`.

---

## Auto-bootstrap para la nube (CHANGELOG 0.1.6)

- Hook `SessionStart` en `.claude/settings.json` → ejecuta `.claude/scripts/bootstrap.sh` en cada arranque.
- `bootstrap.sh` (idempotente, dependency-free): `git config core.hooksPath .githooks` (activa el guardrail pre-push sin `pre-commit`), permisos +x, siembra `.claude/state/` (gitignored).
- Salvedad: no está 100% garantizado que todos los modos headless de la nube disparen `SessionStart`; degradación benigna (correr `bootstrap.sh`/`setup.sh` a mano).

---

## Workflow de sincronización con upstream (CHANGELOG 0.1.7)

Archivo: `.github/workflows/sync-upstream.yml`. Trigger: `schedule` (lunes 06:00 UTC) + `workflow_dispatch`.

**Qué hace:** en un runner efímero de GitHub añade el remote `Next-Flip/Momentum-Firmware` (SOLO en el runner, nunca en el clon → respeta D9/D25), hace `git fetch dev`, cuenta commits nuevos vs `my-momentum-firmware`, empuja la rama espejo `sync/upstream-dev`, y abre/actualiza un PR `sync/upstream-dev → my-momentum-firmware` para revisión humana. Dirección estrictamente inbound.

**Autenticación (clave):** usa un **PAT** guardado como secret **`SYNC_PAT`** (fine-grained: Contents RW + Pull requests RW + Workflows RW, solo este repo) tanto en el `checkout` (para el push del mirror) como en `gh pr create`.

**Por qué PAT y no el `GITHUB_TOKEN` del bot** (resultado de investigación adversarial, ver ADR-0002):
1. El bot no puede crear PRs por defecto (ajuste repo "Allow GitHub Actions to create and approve pull requests"; estaba OFF por defecto en cuenta personal; ya activado — hubo latencia de propagación que explicó los fallos iniciales).
2. **Bug latente decisivo:** el bot NUNCA puede empujar cambios en `.github/workflows/*` (no existe scope `workflows` para el `GITHUB_TOKEN`). El mirror de upstream incluye ficheros de workflow → el push del bot se rompería en cuanto upstream los tocara. El PAT (identidad de usuario) sí puede.

**Estado de verificación:** smoke test verde (checkout con PAT OK, detecta "al día"). El camino completo push+PR con delta real **aún no se ha ejercitado** (el fork está en la punta de upstream → 0 commits nuevos). Se ejercitará en el próximo delta real del oficial o al pulsar "Run workflow" cuando haya novedades.

**Activación ya hecha:** repo Settings → Actions → General → "Allow GitHub Actions to create and approve pull requests" activado; `default_workflow_permissions: write`.

---

## Pendientes

1. **Ejercitar el sync completo** (push+PR con delta real) en el próximo cambio de upstream. Si falla la creación del PR, el fallback previsto es imprimir la URL de compare.
2. **Fase 2 del sistema agente** (NO empezada): 4 especialistas (`flipper-rf-subghz`, `flipper-nfc`, `flipper-app-builder`, `flipper-build-fbt`) + 4 docs curados. Ver `phases.md` y `RESUME-phase2-bootstrap.md`.
3. **Revisión 1 calendarizada:** `2026-08-23`, auditoría a 3 meses del ángulo `COR` (ver `phases.md` → "Calendario activo de revisiones").

---

## Trampas y notas de continuidad

- **`decisions.jsonl` es gitignored → NO viaja** entre máquinas. La narrativa importante está en CHANGELOG + ADRs (que sí viajan). Decisión de mantenerlo gitignored (2026-07-24) por riesgo de conflictos de merge en un log append-only.
- **Ficheros de memoria** (`~/.claude/.../memory/`) son LOCALES a la máquina, no viajan. Este RESUME + CHANGELOG + ADR son la fuente que sí viaja.
- **Consistencia eventual de GitHub:** tanto el renombrado de la default como la activación del ajuste de PRs mostraron latencia de propagación. Si algo "debería funcionar según el API" pero falla, reintenta tras unos minutos antes de diagnosticar.
- **Guardrail intacto:** nunca se añadió el remote `Next-Flip` al clon; el sync lo hace solo dentro del runner de GitHub.
