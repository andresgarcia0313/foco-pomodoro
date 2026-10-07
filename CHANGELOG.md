---
lang: es-CO
---

# Registro de cambios

Formato basado en "Keep a Changelog"; versiones con SemVer (versionado semántico).

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 0.1.0 | 2026-10-07 | Andrés García | Primera versión del registro |

## [Sin publicar]

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
