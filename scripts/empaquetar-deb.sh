#!/usr/bin/env bash
# Builds dist/foco_<version>_<distro>_<arch>.deb from a compiled binary, on the same
# distribution it targets: library dependencies come from dpkg-shlibdeps, so each Debian or
# Ubuntu release gets its own package linked against its own Qt.
# Usage: scripts/empaquetar-deb.sh [path/to/foco]   (default: target/release/foco)
# Needs: dpkg-dev; rsvg-convert (librsvg2-bin) is optional and adds PNG icons.
set -euo pipefail
umask 022

raiz="$(cd "$(dirname "$0")/.." && pwd)"
id="com.ingeniumcodex.foco"
binario="${1:-$raiz/target/release/foco}"
[[ -x "$binario" ]] || { echo "No existe el binario $binario" >&2; exit 1; }

. /etc/os-release
upstream="$(sed -n 's/^version = "\(.*\)"/\1/p' "$raiz/Cargo.toml" | head -1)"
version="$upstream-1~${ID}${VERSION_ID}"
arch="$(dpkg --print-architecture)"
salida="$raiz/dist"
raiz_pkg="$(mktemp -d)"
trap 'rm -rf -- "$raiz_pkg"' EXIT

install -Dm755 "$binario" "$raiz_pkg/usr/bin/foco"
install -Dm644 "$raiz/packaging/linux/$id.desktop" "$raiz_pkg/usr/share/applications/$id.desktop"
install -Dm644 "$raiz/packaging/linux/$id.metainfo.xml" "$raiz_pkg/usr/share/metainfo/$id.metainfo.xml"
install -Dm644 "$raiz/crates/foco-app/assets/foco.svg" \
  "$raiz_pkg/usr/share/icons/hicolor/scalable/apps/$id.svg"
# Some menus (older Xfce, LXDE, MATE themes) only look for bitmap icons.
if command -v rsvg-convert >/dev/null; then
  for size in 48 64 128 256; do
    dir="$raiz_pkg/usr/share/icons/hicolor/${size}x${size}/apps"
    mkdir -p "$dir"
    rsvg-convert -w "$size" -h "$size" "$raiz/crates/foco-app/assets/foco.svg" -o "$dir/$id.png"
  done
fi

doc="$raiz_pkg/usr/share/doc/foco"
install -d "$doc"
cat > "$doc/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: foco
Source: https://github.com/andresgarcia0313/foco-pomodoro

Files: *
Copyright: 2026 Andrés García <andresgarcia0313@gmail.com>
License: GPL-3+
 On Debian systems the full text is in /usr/share/common-licenses/GPL-3.

Files: qml/Foco/icons/*
Copyright: Lucide Contributors
License: ISC
EOF
printf 'foco (%s) unstable; urgency=medium\n\n  * Ver CHANGELOG.md del proyecto.\n\n -- Andrés García <andresgarcia0313@gmail.com>  %s\n' \
  "$version" "$(date -R)" | gzip -9n > "$doc/changelog.Debian.gz"

# Shared libraries from the binary itself; QML modules and plugins are loaded at run time,
# so they are listed by hand (svg plugins live in libqt6svg6 before Qt 6.8).
cd "$raiz_pkg"
mkdir -p debian && touch debian/control
libs="$(dpkg-shlibdeps -O usr/bin/foco 2>/dev/null | sed 's/^shlibs:Depends=//')"
rm -r debian
qml="qml6-module-qtquick, qml6-module-qtquick-controls, qml6-module-qtquick-templates,
 qml6-module-qtquick-layouts, qml6-module-qtquick-shapes, qml6-module-qtquick-dialogs,
 qml6-module-qtquick-window, qml6-module-qtqml-workerscript, qml6-module-qt-labs-settings,
 qml6-module-qt-labs-platform, qml6-module-qtmultimedia, qt6-svg-plugins | libqt6svg6"
install -d DEBIAN
cat > DEBIAN/control <<EOF
Package: foco
Version: $version
Section: utils
Priority: optional
Architecture: $arch
Maintainer: Andrés García <andresgarcia0313@gmail.com>
Installed-Size: $(du -sk --exclude=DEBIAN . | cut -f1)
Depends: $libs, $(echo $qml)
Recommends: qt6-wayland
Homepage: https://github.com/andresgarcia0313/foco-pomodoro
Description: Pomodoro timer for the desktop
 Focus and break cycles with tasks, statistics, tray icon, mini mode always
 on top and native notifications. Rust core with a Qt 6 QML interface; all
 data stays in local files.
EOF

mkdir -p "$salida"
# No "~" in the file name: GitHub renames release assets that contain it.
deb="$salida/foco_${upstream}_${ID}${VERSION_ID}_${arch}.deb"
dpkg-deb --root-owner-group -Zxz --build "$raiz_pkg" "$deb" >/dev/null
echo "$deb"
