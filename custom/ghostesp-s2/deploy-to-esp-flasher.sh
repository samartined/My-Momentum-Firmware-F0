#!/usr/bin/env bash
# deploy-to-esp-flasher.sh — copies the custom GhostESP ESP32-S2 binaries
# to the esp_flasher app's resource path (inside the Momentum-Apps submodule),
# so that ./fbt deploys them to the Flipper's SD card.
#
# Usage:
#   ./custom/ghostesp-s2/deploy-to-esp-flasher.sh
#
# Requirement: submodules initialized (git submodule update --init applications/external).
# Idempotent. exit != 0 with diagnostics if the destination is missing.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

SRC_DIR="custom/ghostesp-s2"
DEST_DIR="applications/external/esp_flasher/resources/apps_data/esp_flasher/assets/ghostesp/s2"

if [[ ! -d "applications/external/esp_flasher" ]]; then
  echo "ERROR: the esp_flasher app is not present." >&2
  echo "  Initialize the submodule: git submodule update --init applications/external" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
for f in bootloader.bin partition-table.bin Ghost_ESP_IDF.bin; do
  cp "$SRC_DIR/$f" "$DEST_DIR/$f"
  echo "  ✓ $f -> $DEST_DIR/"
done

echo ""
echo "Done. Now deploy the resources to the SD card with ./fbt (e.g. ./fbt resources)."
echo "NOTE: these files remain as local changes to the submodule (do not commit them there:"
echo "      the submodule points to the official Momentum-Apps)."
