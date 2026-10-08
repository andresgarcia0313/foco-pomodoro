---
lang: es-CO
título: Foco - Compilación y empaquetado
versión: 1.1.0
---

# Foco - Compilación y empaquetado

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Requisitos por plataforma, compilación, variables de prueba, integración continua y empaquetado |
| 1.1.0 | 2026-10-07 | Andrés García | Perfil `fast`, técnicas para compilar más rápido y medición |

## 1. Requisitos

| Plataforma | Rust | Qt | Otros |
| --- | --- | --- | --- |
| Kubuntu 26.04 | 1.85 o superior | 6.10.2 de los paquetes (`qt6-base-dev`, `qt6-declarative-dev`, `qml6-module-qtmultimedia`, `qml6-module-qt-labs-platform`) o 6.12.0 con aqtinstall | Compilador de C++ y `pkg-config` |
| Windows 11 | 1.85 o superior, destino MSVC (el compilador de Microsoft) | 6.12.0 con el instalador en línea de Qt o aqtinstall, kit `msvc2022_64` | Visual Studio 2022 Build Tools |
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
| `app` | Compila la aplicación con Qt 6.12.0 en las tres plataformas y con Qt 6.10.3 en Linux, el piso de compatibilidad; en Linux además la arranca sin pantalla y falla si QML reporta errores |
| `docs` | `scripts/validar-docs.sh` sobre todos los documentos |

## 5. Empaquetado

| Plataforma | Herramienta | Resultado |
| --- | --- | --- |
| Linux | `linuxdeploy` con su complemento de Qt, pasando `QML_SOURCES_PATHS=qml:crates/foco-app/qml` | `Foco-x86_64.AppImage` |
| Windows | `windeployqt --release --qmldir qml --qmldir crates/foco-app/qml target\release\foco.exe` y compresión de la carpeta | `Foco-windows-x64.zip` |
| macOS | Paquete `Foco.app` con `Info.plist` y el icono, luego `macdeployqt Foco.app -qmldir=qml -qmldir=crates/foco-app/qml -dmg` | `Foco.dmg` |

Las tres herramientas copian los complementos que la interfaz importa: Qt Quick, Controls en
estilo Basic, Qt Multimedia para el sonido y Qt Labs Platform para la bandeja. La firma de
código (Authenticode en Windows, notarización en macOS) queda fuera del alcance de esta versión;
sin ella, macOS puede limitar las notificaciones de una aplicación no firmada.

## 6. Datos del usuario

`foco.json` vive en `~/.config/foco` (Linux), `%APPDATA%\foco` (Windows) o
`~/Library/Application Support/foco` (macOS). Desinstalar no lo borra.
