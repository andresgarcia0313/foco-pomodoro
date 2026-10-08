#!/usr/bin/env bash
# Installs Foco for the current user: binary in ~/.local/bin, icon and launcher in the menu.
# Usage: scripts/instalar-linux.sh [path/to/foco]   (default: target/fast/foco)
# Uninstall: scripts/instalar-linux.sh --desinstalar
set -euo pipefail

raiz="$(cd "$(dirname "$0")/.." && pwd)"
id="com.ingeniumcodex.foco"
bin_dir="${HOME:?}/.local/bin"
apps_dir="${HOME:?}/.local/share/applications"
icon_dir="${HOME:?}/.local/share/icons/hicolor/scalable/apps"

refrescar_menu() {
  update-desktop-database "$apps_dir" 2>/dev/null || true
  command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
}

if [[ "${1:-}" == "--desinstalar" ]]; then
  rm -f -- "${bin_dir:?}/foco" "${apps_dir:?}/$id.desktop" "${icon_dir:?}/$id.svg"
  refrescar_menu
  echo "Foco desinstalado (los datos en ~/.config/foco se conservan)"
  exit 0
fi

binario="${1:-$raiz/target/fast/foco}"
[[ -x "$binario" ]] || { echo "No existe el binario $binario; compile con: cargo build -p foco-app --profile fast" >&2; exit 1; }

install -Dm755 "$binario" "$bin_dir/foco"
install -Dm644 "$raiz/crates/foco-app/assets/foco.svg" "$icon_dir/$id.svg"
install -Dm644 "$raiz/packaging/linux/$id.desktop" "$apps_dir/$id.desktop"
sed -i "s|^Exec=foco$|Exec=$bin_dir/foco|" "$apps_dir/$id.desktop"
refrescar_menu
echo "Foco instalado: $bin_dir/foco y lanzador en el menú (Utilidades)"
