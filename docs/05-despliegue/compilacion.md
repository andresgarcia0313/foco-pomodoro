---
lang: es-CO
título: Foco - Compilación y empaquetado
versión: 1.2.0
---

# Foco - Compilación y empaquetado

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Requisitos por plataforma, compilación, variables de prueba, integración continua y empaquetado |
| 1.1.0 | 2026-10-07 | Andrés García | Perfil `fast`, técnicas para compilar más rápido y medición |
| 1.2.0 | 2026-10-08 | Andrés García | Paquetes deb por distribución, instalador de Windows, Foco.app para macOS y flujo de publicación |

## 1. Requisitos

| Plataforma | Rust | Qt | Otros |
| --- | --- | --- | --- |
| Debian 12 o superior, Ubuntu 24.04 o superior | 1.85 o superior (rustup) | El de la distribución: `qt6-base-dev`, `qt6-base-dev-tools`, `qt6-declarative-dev`, `qt6-declarative-dev-tools`, `qt6-multimedia-dev`; o 6.12.0 con aqtinstall | `build-essential`, `pkg-config`, `libgl-dev`; para empaquetar `dpkg-dev` y `librsvg2-bin` |
| Windows 10 y 11 | 1.85 o superior, destino MSVC (el compilador de Microsoft) | 6.10.3 o superior con el instalador en línea de Qt o aqtinstall, kit `msvc2022_64` | Visual Studio 2022 Build Tools |
| macOS 15 | 1.85 o superior | 6.12.0, kit `macos` | Herramientas de línea de comandos de Xcode |

CXX-Qt (puente Rust y Qt de KDAB) localiza Qt con `qmake`: el primero del `PATH` o el de la
variable `QMAKE`. Con varias versiones instaladas, fíjela:

```bash
export QMAKE=/usr/bin/qmake6                       # Qt 6.10.2 del sistema
export QMAKE=$HOME/Qt/6.12.0/gcc_64/bin/qmake      # Qt 6.12.0 de aqtinstall
```

La primera compilación de `cxx-qt-lib` traduce sus archivos de C++ y puede tardar mucho en un
equipo cargado; las siguientes reutilizan `target/` y la caché de sccache (sección 3).

## 2. Compilar y ejecutar

```bash
cargo test -p foco-core                    # núcleo, sin Qt
cargo build -p foco-app --profile fast     # optimizado y rápido de compilar: target/fast/foco
cargo build -p foco-app --release          # para publicar (LTO): target/release/foco
./target/fast/foco
```

| Opción o variable | Efecto |
| --- | --- |
| `--mute` | Nunca reproduce el sonido de fin de fase |
| `FOCO_CONFIG_DIR=<carpeta>` | Usa otra carpeta de datos; aísla las pruebas de los datos reales |
| `FOCO_AUTOQUIT_MS=<ms>` | Cierra la aplicación sola tras ese tiempo; para pruebas de humo |
| `QT_QPA_PLATFORM=offscreen` | Ejecuta sin pantalla |

Prueba de humo local, sin sonido y sin tocar los datos reales:

```bash
QT_QPA_PLATFORM=offscreen FOCO_AUTOQUIT_MS=4000 FOCO_CONFIG_DIR=$(mktemp -d) \
  ./target/release/foco --mute
```

## 3. Compilar más rápido

| Técnica | Dónde | Por qué |
| --- | --- | --- |
| `cxx-qt-lib` sin `qt_full` | `crates/foco-app/Cargo.toml` | Rust solo usa tipos del núcleo de Qt; la parte gráfica la arranca `app_shim.cpp`. Se deja de compilar el C++ de los tipos gráficos, QML y Controls |
| sccache como envoltorio de `rustc` | `build.rustc-wrapper` en `~/.cargo/config.toml` | Guarda en caché las dependencias y, a través del crate `cc`, los objetos de C++ de `cxx-qt-lib`; una compilación limpia o de otro proyecto los reutiliza |
| Menos información de depuración | `[profile.dev]` del workspace | Solo tablas de líneas en el código propio y nada en dependencias: objetos más pequeños y enlazado más rápido |
| Perfil `fast` | `[profile.fast]` del workspace | Optimizado sin LTO (optimización en tiempo de enlace) ni unidad de código única, que solo se justifican al publicar |
| `jobs = 4` | `~/Desarrollo/Rust/.cargo/config.toml` | Con la RAM compartida entre varias sesiones, más trabajos en paralelo paginan en vez de acelerar |
| rust-analyzer con su propio directorio | `.vscode/settings.json` | El editor compila en `target/rust-analyzer` y no bloquea a `cargo build` |
| `avanzar cargo build ...` | Equipo de desarrollo | La compilación corre con prioridad baja y nunca queda congelada por el control de carga |

Descartadas, con motivo: `mold` (desde Rust 1.90 el enlazador por defecto en Linux ya es `lld`),
un `target/` compartido entre proyectos (bloquea compilaciones simultáneas), desactivar la
compilación incremental (sccache no la cachea, pero solo afecta a los dos crates propios, que son
pequeños) y `build-override` con optimización (puede compilar dos veces una dependencia).

Para medir: `cargo build -p foco-app --timings` deja el informe en `target/cargo-timings/`, y
`sccache --show-stats` muestra los aciertos de la caché.

## 4. Integración continua

`.github/workflows/ci.yml` corre en cada cambio:

| Trabajo | Qué hace |
| --- | --- |
| `core` | Formato, `clippy` sin advertencias y pruebas del núcleo en Linux, Windows y macOS |
| `app` | Compila la aplicación con Qt 6.12.0 en Linux y macOS y con Qt 6.10.3 en Linux y Windows; en Linux además la arranca sin pantalla y falla si QML reporta errores |

El piso de compatibilidad es Qt 6.4, el de Debian 12 y Ubuntu 24.04, y lo prueba el flujo de publicación (sección 5). Por eso la interfaz importa `Qt.labs.settings` en vez del `Settings` de QtCore, que pide Qt 6.5, y `app_shim.cpp` agrega `qrc:/qt/qml` a la ruta de módulos.
| `docs` | `scripts/validar-docs.sh` sobre todos los documentos |

## 5. Empaquetado y publicación

`.github/workflows/release.yml` arma y prueba los paquetes. Se lanza a mano (solo construye) o con
una etiqueta `v*`, que además los adjunta a la versión publicada en GitHub.

| Plataforma | Cómo se arma | Resultado | Prueba automática |
| --- | --- | --- | --- |
| Debian 12 y 13, Ubuntu 24.04 y 26.04 | Compilación dentro de cada distribución con su propio Qt y `scripts/empaquetar-deb.sh` | `foco_<versión>_<distro>_amd64.deb` | `scripts/probar-deb.sh`: instalación con apt en un sistema limpio y arranque sin pantalla |
| Windows 10 y 11 de 64 bits | `windeployqt` más las bibliotecas de C++ de Microsoft, comprimido e instalador de Inno Setup (`packaging/windows/foco.iss`) | `Foco-<versión>-windows-x64.zip` e `...-instalador.exe` | Arranque sin pantalla de la carpeta final |
| macOS 13 o superior, Apple Silicon e Intel | `Foco.app` con `packaging/macos/Info.plist`, `macdeployqt` y firma local (ad hoc) | `Foco-<versión>-macos-<arm64 o x86_64>.dmg` | Arranque sin pantalla del binario dentro de `Foco.app` |

Cada `.deb` depende de la versión exacta de Qt de su distribución (Qt expone así su interfaz
privada, que usa CXX-Qt), por eso hay un paquete por distribución y no uno común. El lanzador
sigue la especificación de freedesktop, de modo que aparece en el menú de KDE Plasma, GNOME,
Xfce, Cinnamon, MATE, LXQt y Budgie; los iconos van en SVG y en PNG para los menús que no leen
SVG, y los metadatos AppStream lo muestran en Discover y GNOME Software.

Probar un paquete en local, en un contenedor limpio:

```bash
podman run --rm -v "$PWD:/src:ro,z" docker.io/library/debian:trixie \
  /src/scripts/probar-deb.sh /src/dist/foco_0.3.0_debian13_amd64.deb
```

Sin firma de código de pago: Windows SmartScreen puede pedir "Más información, Ejecutar de todas
formas" y macOS pide abrir Foco con clic derecho, Abrir, la primera vez.

## 6. Datos del usuario

`foco.json` vive en `~/.config/foco` (Linux), `%APPDATA%\foco` (Windows) o
`~/Library/Application Support/foco` (macOS). Desinstalar no lo borra.
