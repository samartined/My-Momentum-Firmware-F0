# GhostESP — firmware ESP32-S2 (personalización personal)

Estos son los binarios de firmware **GhostESP para ESP32-S2** que mantengo versionados
como personalización personal. **No forman parte del Momentum oficial** ni del submódulo
`applications/external` (Momentum-Apps) — por eso viven aquí, en el superproyecto, fuera
del submódulo.

## Archivos

| Archivo | Qué es | Offset típico (ESP-IDF, ESP32-S2) |
|---|---|---|
| `bootloader.bin` | Second-stage bootloader | `0x1000` |
| `partition-table.bin` | Tabla de particiones | `0x8000` |
| `Ghost_ESP_IDF.bin` | Aplicación GhostESP | `0x10000` |

> ⚠️ Verifica los offsets para tu placa concreta antes de flashear. Los de arriba son
> los valores por defecto de ESP-IDF para ESP32-S2; otras variantes (S3/C3/C6) difieren.

## Cómo flashear

### A) Por terminal (esptool) — flujo para firmware personalizado

```bash
esptool.py --chip esp32s2 -p /dev/ttyACM0 -b 460800 write_flash \
  0x1000  bootloader.bin \
  0x8000  partition-table.bin \
  0x10000 Ghost_ESP_IDF.bin
```

Ajusta el puerto (`-p`) y, si hace falta, los offsets.

### B) Desde el Flipper (app esp_flasher)

El app `esp_flasher` lee los binarios desde la SD del Flipper en:
`apps_data/esp_flasher/assets/ghostesp/s2/`

Usa `./deploy-to-esp-flasher.sh` para copiarlos a la ruta de recursos del app
(dentro del submódulo, tras `git submodule update --init`), y luego despliega los
recursos a la SD con `./fbt`.

### C) Flasher web oficial

Para volver temporalmente al GhostESP oficial, usa el flasher web oficial por USB.
No necesita estos binarios.

## Procedencia

Extraídos de la rama `my-momentum-firmware` (pre-refundación), donde estaban embebidos
en los recursos aplanados de `esp_flasher`. Preservados aquí al re-fundar el fork sobre
la historia real de upstream (ver `.claude/design/` y el CHANGELOG del sistema agente).
