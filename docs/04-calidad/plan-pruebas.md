---
lang: es-CO
título: Foco - Plan de pruebas
versión: 1.0.0
---

# Foco - Plan de pruebas

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Niveles de prueba, herramientas, criterios de salida y matriz de plataformas |

## 1. Niveles

| Nivel | Qué cubre | Herramienta | Dónde corre |
| --- | --- | --- | --- |
| Unitarias del núcleo | Máquina de estados, ciclo, tareas, estadísticas, persistencia, exportación | `cargo test -p foco-core` | Local y CI (integración continua) en Linux, Windows y macOS |
| Calidad estática | Formato y advertencias | `cargo fmt --check`, `cargo clippy -D warnings`, `qmllint` | Local y CI |
| Visual | Las 17 pantallas en ambos temas, ventana mínima y letra al doble | `tools/prototipo/Render.qml` y revisión con las cinco lentes | Local, antes de cada versión |
| Integración | La app real arranca, carga QML sin errores y responde a acciones | Arranque con `QT_QPA_PLATFORM=offscreen` y salida por señal; sesión KWin aislada con árbol de accesibilidad | Local y CI en Linux |
| Aceptación | Criterios de `especificacion-ui-ux.md` §7 y casos de uso | Lista de chequeo manual | Kubuntu, Windows 11 y macOS antes de publicar |
| Documental | Idioma `es-CO`, sin rayas, control de cambios | `scripts/validar-docs.sh` | Local y CI |

## 2. Casos críticos del núcleo (automatizados)

1. Arranque en enfoque, detenido, con la duración completa.
2. El tiempo restante sale del reloj monotónico y no de contar pulsos.
3. Pausar congela y reanudar continúa sin perder segundos.
4. El cuarto enfoque lleva al descanso largo; salir de él reinicia el ciclo, también si se salta.
5. Bajar "descanso largo cada N" por debajo del ciclo actual nunca deja el ciclo sin salida.
6. Saltar no cuenta el enfoque; reiniciar devuelve la duración completa.
7. Tareas: título vacío rechazado, estimación acotada de 1 a 12, deshacer devuelve posición y
   tarea activa.
8. Estadísticas: racha que termina hoy o ayer, semana de siete días con día de la semana.
9. Persistencia: ida y vuelta, archivo dañado respaldado, campos desconocidos ignorados,
   valores imposibles corregidos.
10. Sesión guardada se restaura en pausa con el mismo tiempo restante.
11. CSV (valores separados por comas) con comillas y comas escapadas según RFC 4180.

## 3. Criterios de salida de una versión

- Todas las pruebas automáticas en verde en las tres plataformas.
- `clippy` sin advertencias y ningún archivo de código de más de 100 líneas.
- Galería regenerada y revisada sin hallazgos críticos ni altos abiertos.
- Lista de aceptación completa en al menos Kubuntu y una de las otras dos plataformas.

## 4. Matriz de plataformas

| Plataforma | Qt | Compilación | Pruebas del núcleo | Arranque sin pantalla |
| --- | --- | --- | --- | --- |
| Kubuntu 26.04 (paquetes del sistema) | 6.10.2 | Local | Sí | Sí |
| Linux (CI, Ubuntu 24.04) | 6.12.0 | CI | Sí | Sí |
| Windows 11 (CI, MSVC, el compilador de Microsoft) | 6.12.0 | CI | Sí | No (requiere escritorio) |
| macOS 15 (CI, Apple Silicon) | 6.12.0 | CI | Sí | No |
