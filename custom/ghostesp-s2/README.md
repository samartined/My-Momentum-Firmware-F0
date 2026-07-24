# GhostESP — ESP32-S2 firmware (personal customization)

These are the **GhostESP for ESP32-S2** firmware binaries that I keep under version control
as a personal customization. **They are not part of official Momentum** nor of the
`applications/external` submodule (Momentum-Apps) — that's why they live here, in the
superproject, outside the submodule.

## Files

| File | What it is | Typical offset (ESP-IDF, ESP32-S2) |
|---|---|---|
| `bootloader.bin` | Second-stage bootloader | `0x1000` |
| `partition-table.bin` | Partition table | `0x8000` |
| `Ghost_ESP_IDF.bin` | GhostESP application | `0x10000` |

> ⚠️ Verify the offsets for your specific board before flashing. The ones above are
> the ESP-IDF defaults for ESP32-S2; other variants (S3/C3/C6) differ.

## How to flash

### A) Via terminal (esptool) — flow for custom firmware

```bash
esptool.py --chip esp32s2 -p /dev/ttyACM0 -b 460800 write_flash \
  0x1000  bootloader.bin \
  0x8000  partition-table.bin \
  0x10000 Ghost_ESP_IDF.bin
```

Adjust the port (`-p`) and, if needed, the offsets.

### B) From the Flipper (esp_flasher app)

The `esp_flasher` app reads the binaries from the Flipper's SD card at:
`apps_data/esp_flasher/assets/ghostesp/s2/`

Use `./deploy-to-esp-flasher.sh` to copy them to the app's resource path
(inside the submodule, after `git submodule update --init`), then deploy the
resources to the SD card with `./fbt`.

### C) Official web flasher

To temporarily go back to official GhostESP, use the official web flasher over USB.
It doesn't need these binaries.

## Provenance

Extracted from the `my-momentum-firmware` branch (pre-refounding), where they were embedded
in `esp_flasher`'s flattened resources. Preserved here when the fork was refounded on
the real upstream history (see `.claude/design/` and the agent system's CHANGELOG).
