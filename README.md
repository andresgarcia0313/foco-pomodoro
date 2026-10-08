---
lang: es-CO
---

# Foco

Temporizador Pomodoro de escritorio para Linux (Debian, Ubuntu y derivadas), Windows y macOS. Núcleo en Rust, interfaz
en Qt 6 con QML (lenguaje declarativo de interfaces de Qt) y la paleta Dracula.

![Temporizador en Drácula](docs/03-ui-ux/galeria/01-temporizador-enfoque-dracula.png)

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 0.1.0 | 2026-10-07 | Andrés García | Primera versión del documento |
| 0.2.0 | 2026-10-08 | Andrés García | Ajuste de minutos, recuperación automática y registro de uso |
| 0.3.0 | 2026-10-08 | Andrés García | Instalación con paquetes deb, instalador de Windows y aplicación de macOS |

## Qué hace

- Ciclo de enfoque, descanso y descanso largo con duraciones configurables.
- Anillo doble: progreso de la fase y ciclo de cuatro enfoques; el fondo cambia de tono por fase.
- Tareas con estimación en pomodoros, tarea activa y deshacer al eliminar.
- Estadísticas de hoy, racha y semana; exportación del historial a CSV (valores separados por
  comas).
- Notificaciones nativas, sonido opcional, bandeja del sistema, modo mini siempre encima.
- Apariencia Drácula (oscura), Alucard (clara) o según el sistema; atajos para todo.
- Añadir o quitar un minuto (botones junto al reloj o teclas + y -).
- Si se cierra, cae o se congela, vuelve con la misma fase, tiempo y modo de ventana.
- Sin cuentas ni red: los datos y el registro de uso (máximo 10 MB) viven en archivos locales.

## Instalar

Descargue el archivo de su sistema en [Versiones](https://github.com/andresgarcia0313/foco-pomodoro/releases/latest).

| Sistema | Archivo | Cómo |
| --- | --- | --- |
| Debian 13, Ubuntu 26.04 y derivadas | `foco_<versión>_debian13_amd64.deb` o `..._ubuntu26.04_amd64.deb` | `sudo apt install ./foco_*.deb` |
| Debian 12, Ubuntu 24.04, Linux Mint 22, Pop!_OS 24.04 | `..._debian12_amd64.deb` o `..._ubuntu24.04_amd64.deb` | `sudo apt install ./foco_*.deb` |
| Windows 10 y 11 de 64 bits | `Foco-<versión>-windows-x64-instalador.exe` (o el `.zip` portable) | Ejecutar; si SmartScreen avisa: Más información, Ejecutar de todas formas |
| macOS 13 o superior | `Foco-<versión>-macos-arm64.dmg` (Apple Silicon) o `-x86_64.dmg` (Intel) | Arrastrar Foco a Aplicaciones; la primera vez, clic derecho, Abrir |

En Linux queda en el menú de aplicaciones (Utilidades) de KDE Plasma, GNOME, Xfce, Cinnamon,
MATE, LXQt o Budgie; en Windows, en el menú Inicio. Desinstalar no borra sus datos.

## Estructura

| Carpeta | Contenido |
| --- | --- |
| `docs/01-analisis` | Requisitos, casos de uso y riesgos |
| `docs/02-diseno` | Arquitectura, máquina de estados, datos y decisiones |
| `docs/03-ui-ux` | Especificación, sistema de diseño, textos, galería y revisión |
| `docs/04-calidad` | Plan de pruebas |
| `docs/05-despliegue` | Compilación, empaquetado y publicación por plataforma |
| `packaging` | Lanzador de Linux, instalador de Windows y paquete de macOS |
| `crates/foco-core` | Lógica del método en Rust, sin Qt, con pruebas |
| `crates/foco-app` | Puente CXX-Qt y arranque de la aplicación |
| `qml/Foco` | Interfaz completa en QML |
| `tools/prototipo` | Renderizador de la galería con datos simulados |

## Compilar y probar

```bash
cargo test -p foco-core          # núcleo, sin Qt
cargo run -p foco-app --release  # aplicación (requiere Qt 6)
scripts/validar-docs.sh          # documentos
```

Requisitos de cada plataforma en `docs/05-despliegue/compilacion.md`.

## Licencia

GPL 3.0 o posterior. Iconos de Lucide bajo licencia ISC (`qml/Foco/icons/LICENSE-lucide.txt`).
