---
lang: es-CO
---

# Registro de cambios

Formato basado en "Keep a Changelog"; versiones con SemVer (versionado semántico).

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 0.1.0 | 2026-10-07 | Andrés García | Primera versión del registro |
| 0.2.0 | 2026-10-08 | Andrés García | Versión 0.2.0: reanudación exacta, recuperación automática, ajuste de minutos y registro de uso |

## [0.2.0] - 2026-10-08

### Agregado

- Botones y teclas (+ y -) para añadir o quitar un minuto a la fase en curso (RF-16).
- Supervisor de proceso: si la interfaz cae o deja de responder 45 s, se reinicia sola y
  continúa donde iba (RNF-08).
- Registro local de uso en `uso.json`, con tope de 10 MB y sin salir del equipo (RF-17).
- Puente CXX-Qt, bandeja del sistema, notificaciones nativas, CI (integración continua) en las
  tres plataformas y compilación más rápida.

### Cambiado

- Al reabrir, la fase sigue en el mismo estado (corriendo o en pausa), con el mismo tiempo, el
  mismo modo de ventana y el mismo tamaño; se guarda en cada acción y cada 15 s (RF-13).
- Qt Multimedia solo se carga si el sonido está activo: menos memoria en silencio.

### Corregido

- Un congelamiento del proceso ya no consume ni termina la fase: el hueco no se cuenta.
- "Siempre encima" funciona en KDE Plasma con Wayland.
- El clic en la bandeja con el modo mini abierto mostraba las dos ventanas a la vez.
- Cierre ordenado de QApplication para evitar un fallo de Qt Multimedia al salir.

## [0.1.0] - 2026-10-07

### Agregado

- Análisis: requisitos, casos de uso y riesgos (`docs/01-analisis`).
- Diseño de arquitectura con decisiones y trazabilidad (`docs/02-diseno`).
- Diseño UI/UX con la paleta Dracula y Alucard: especificación, sistema de diseño, textos,
  17 capturas de prototipos y revisión con hallazgos corregidos (`docs/03-ui-ux`).
- Núcleo en Rust sin Qt: temporizador con reloj monotónico, tareas con deshacer, estadísticas,
  persistencia atómica con recuperación y exportación a CSV, con 23 pruebas.
- Interfaz completa en QML: temporizador, tareas, estadísticas, ajustes, modo mini, menú,
  atajos y diálogos.
- Plan de pruebas y verificador de documentos (`scripts/validar-docs.sh`).
