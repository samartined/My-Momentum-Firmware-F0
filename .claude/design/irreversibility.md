# Lista de operaciones irreversibles

Este documento es la lista cerrada de operaciones consideradas "irreversibles" por el sistema agente. Cualquier operación que matchee uno de los patrones aquí descritos dispara automáticamente clasificación L3 (Concilio Tripartito) y deshabilita L1 (master solo) y L2 (`/devils-advocate`).

Resolución del Concilio: D19.

## Patrón de uso

- El matching es automático vía script (regex sobre el comando o la operación que el master propone ejecutar).
- El script vive en `.claude/scripts/check-irreversibility.sh` (creado en Fase 1).
- Si el script reporta match positivo, el master debe convocar al Concilio (L3) o escalar al usuario (L4); no puede decidir solo (L1) ni invocar `/devils-advocate` (L2).
- Extensión de la lista: vía PR humano. No se permite añadir patrones en runtime.

## Lista cerrada (9 entradas)

| # | Operación | Patrón regex (orientativo) | Razón |
|---|-----------|----------------------------|-------|
| 1 | `git push --force` o reescritura de historia publicada | `git\s+push\s+.*--force` o `git\s+push\s+-f` | Pérdida irrecuperable del historial remoto. |
| 2 | Modificación o eliminación de archivos en `.claude/design/` | path matches `\.claude/design/.*` | Auto-modificación del sistema agente. |
| 3 | Borrado de archivos versionados sin equivalente en backup obvio | `rm\s+.*` sobre paths versionados | Pérdida sin trazabilidad. |
| 4 | Cambio en `targets/` o `furi/` que afecte ABI o layout de memoria del firmware | path matches `targets/.*` o `furi/.*` (con análisis adicional) | Rompe binarios desplegados. |
| 5 | Creación o eliminación de subagente | path matches `\.claude/agents/.*\.md` | Delta sobre el registry, afecta routing. |
| 6 | Modificación de hooks o `settings.json` que altere policy de permisos | path matches `\.claude/settings\.json` o `\.githooks/.*` | Cambia el modelo de seguridad. |
| 7 | Flash del dispositivo Flipper físico (bootloader, fuses, secure region) | `./fbt flash.*` o `dfu-util.*` | Brick potencial del hardware. |
| 8 | Push a remote `Next-Flip/Momentum-Firmware` | URL matches `Next-Flip/` | Exposición de código al repo oficial bloqueado. |
| 9 | Eliminación de logs de auditoría (`.claude/state/*.jsonl`) | `rm.*\.claude/state/.*\.jsonl` | Destruye observabilidad del sistema. |

## Extensión de la lista

Para añadir una nueva entrada:

1. Abrir PR al fork personal modificando este archivo y `.claude/scripts/check-irreversibility.sh`.
2. La justificación del PR debe incluir un incidente concreto o riesgo identificado, no hipótesis genéricas.
3. El PR pasa por el Concilio (L3) antes de mergear.

## Historial de extensiones

(Esta sección se actualiza al final de cada PR que extienda la lista.)
