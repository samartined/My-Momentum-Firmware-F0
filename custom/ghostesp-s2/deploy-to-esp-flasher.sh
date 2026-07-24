#!/usr/bin/env bash
# deploy-to-esp-flasher.sh — copia los binarios GhostESP ESP32-S2 personalizados
# a la ruta de recursos del app esp_flasher (dentro del submódulo Momentum-Apps),
# para que ./fbt los despliegue a la SD del Flipper.
#
# Uso:
#   ./custom/ghostesp-s2/deploy-to-esp-flasher.sh
#
# Requisito: submódulos inicializados (git submodule update --init applications/external).
# Idempotente. exit != 0 con diagnóstico si falta el destino.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

SRC_DIR="custom/ghostesp-s2"
DEST_DIR="applications/external/esp_flasher/resources/apps_data/esp_flasher/assets/ghostesp/s2"

if [[ ! -d "applications/external/esp_flasher" ]]; then
  echo "ERROR: el app esp_flasher no está presente." >&2
  echo "  Inicializa el submódulo: git submodule update --init applications/external" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
for f in bootloader.bin partition-table.bin Ghost_ESP_IDF.bin; do
  cp "$SRC_DIR/$f" "$DEST_DIR/$f"
  echo "  ✓ $f -> $DEST_DIR/"
done

echo ""
echo "Hecho. Ahora despliega los recursos a la SD con ./fbt (p. ej. ./fbt resources)."
echo "NOTA: estos archivos quedan como cambios locales del submódulo (no los commitees allí:"
echo "      el submódulo apunta a Momentum-Apps oficial)."
