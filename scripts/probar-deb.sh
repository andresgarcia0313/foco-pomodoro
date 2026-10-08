#!/usr/bin/env bash
# Acceptance test of a .deb in a clean Debian or Ubuntu (container or CI): apt installs it
# with its dependencies, the menu entry and icon exist, and Foco starts without a display
# and without QML errors. Local: podman run --rm -v "$PWD:/src:ro,z" debian:trixie \
#   /src/scripts/probar-deb.sh /src/dist/foco_<version>_amd64.deb
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
deb="$(realpath "$1")"
apt-get update -qq >/dev/null
apt-get install -y -qq "$deb" >/tmp/apt.log 2>&1 || { tail -20 /tmp/apt.log; exit 1; }
desktop=/usr/share/applications/com.ingeniumcodex.foco.desktop
test -f "$desktop" && test -f /usr/share/icons/hicolor/scalable/apps/com.ingeniumcodex.foco.svg
grep -q '^Exec=foco$' "$desktop"

export QT_QPA_PLATFORM=offscreen FOCO_AUTOQUIT_MS=5000 FOCO_CONFIG_DIR=/tmp/foco
foco --mute 2>/tmp/smoke.log || { cat /tmp/smoke.log; echo "Foco terminó con error"; exit 1; }
cat /tmp/smoke.log
if grep -E "qrc:.*(Error|error|ReferenceError|TypeError|is not a type)|is not installed" /tmp/smoke.log; then
  echo "QML reportó errores"; exit 1
fi
test -f /tmp/foco/foco.json
echo "Paquete correcto: $(dpkg-query -W -f='${Package} ${Version}' foco)"
