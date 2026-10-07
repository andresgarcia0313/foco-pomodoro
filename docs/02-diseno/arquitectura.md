---
lang: es-CO
título: Foco - Diseño de arquitectura
versión: 1.0.0
---

# Foco - Diseño de arquitectura

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Vista de componentes, máquina de estados, datos, decisiones y trazabilidad |

## 1. Vista general

```text
┌──────────────────────── Proceso de Foco ────────────────────────┐
│  QML (qml/Foco)            Puente CXX-Qt (crates/foco-app)       │
│  ┌──────────────┐  props   ┌────────────────┐   ┌─────────────┐ │
│  │ MainWindow   │◄────────►│ PomodoroTimer  │──►│ foco-core   │ │
│  │ AppShell     │ señales  │ TaskStore      │   │  timer      │ │
│  │ SettingsPage │          │ StatsStore     │   │  tasks      │ │
│  │ MiniView     │          │ AppSettings    │   │  stats      │ │
│  │ Bandeja      │          └───────┬────────┘   │  storage    │ │
│  └──────────────┘                  │            │  export     │ │
│                                    ▼            └─────────────┘ │
│                     Notificador (notify-rust) · Archivo foco.json │
└──────────────────────────────────────────────────────────────────┘
```

- **foco-core** (Rust puro, sin Qt): reglas del método, cálculos y persistencia. Se prueba en
  milisegundos en las tres plataformas.
- **foco-app**: objetos Qt delgados creados con CXX-Qt (puente Rust y Qt de KDAB) que exponen
  propiedades, métodos invocables y señales a QML (lenguaje declarativo de interfaces de Qt), y
  el arranque de la aplicación.
- **qml/Foco**: interfaz completa, solo presentación. Cada vista recibe sus objetos por
  propiedad (`timer`, `tasks`, `stats`, `settings`), lo que permite renderizarla con objetos
  simulados (`tools/prototipo`) y con los reales sin cambiar una línea.

## 2. Máquina de estados del temporizador

```text
           toggle                 toggle
   Idle ───────────► Running ◄───────────► Paused
    ▲                   │ tick: tiempo = 0
    │ reset / select    ▼
    └──────────── advance(next) ── auto-inicio? ──► Running
```

Siguiente fase: tras un enfoque completado, descanso largo si `ciclo >= cada N`, si no corto;
tras cualquier descanso, enfoque. Salir del descanso largo, completo o saltado, reinicia el ciclo.
Saltar nunca cuenta el enfoque. El tiempo restante se calcula como `total - (acumulado + (ahora -
inicio))` con `Instant`, un reloj monotónico: un pulso tardío o el equipo suspendido no producen
deriva (RNF-02).

## 3. Datos

Un solo archivo `foco.json` en la carpeta de configuración del usuario
(`~/.config/foco` en Linux, `%APPDATA%\foco` en Windows, `~/Library/Application Support/foco`
en macOS):

| Clave | Contenido |
| --- | --- |
| `version` | Versión del esquema (1) |
| `settings` | Duraciones, automatismos, avisos, ventana, apariencia, idioma |
| `tasks` | Lista, siguiente identificador y tarea activa |
| `history` | Enfoques completados: fecha y hora local de fin, minutos y título de la tarea |
| `session` | Fase en curso al cerrar: fase, segundos restantes, ciclo (RF-13) |

Escritura atómica (archivo temporal y renombrado). Un archivo dañado se renombra a
`foco.corrupt-<fecha>.json` y la aplicación arranca con valores por defecto (RNF-08). Campos
desconocidos se ignoran y los ausentes toman su valor por defecto, lo que permite evolucionar el
esquema sin migraciones.

## 4. Decisiones de arquitectura

| Id | Decisión | Alternativas descartadas y motivo |
| --- | --- | --- |
| DA-01 | Rust con CXX-Qt 0.10 y QML | Slint o egui: no son Qt, y Qt es requisito; qmetaobject-rs: sin mantenimiento activo |
| DA-02 | Núcleo sin Qt en un crate aparte | Lógica dentro de los QObject: impediría probar sin interfaz gráfica |
| DA-03 | Reloj inyectado (`Instant` como parámetro) | Contar pulsos de un temporizador: deriva medible en 25 minutos |
| DA-04 | Estilo `Basic` de Qt Quick Controls con tokens propios | Estilos nativos: ignoran la paleta y avisan en tiempo de ejecución |
| DA-05 | JSON con serde en vez de SQLite | Volumen pequeño (decenas de registros al día); SQLite agrega una dependencia nativa por plataforma |
| DA-06 | Notificaciones con notify-rust | Mensajes de la bandeja de Qt: en Linux no siguen el estándar de notificaciones del escritorio |
| DA-07 | Código compatible con Qt 6.10; versiones publicadas con Qt 6.12.0 | Solo 6.12: rompería la compilación con los paquetes de Kubuntu 26.04 |
| DA-08 | Plurales con dos textos traducibles | `%n` de `qsTr`: muestra "(s)" sin archivo de traducción del idioma fuente |
| DA-09 | Apariencia Drácula por defecto con opción Sistema o Alucard | Solo seguir al sistema (pauta de Apple): perdería la identidad pedida; queda documentado |

## 5. Trazabilidad

| Requisito | Dónde se cumple | Prueba |
| --- | --- | --- |
| RF-01, RF-02 | `foco-core/src/timer*` | `tests/timer_cycle.rs` |
| RF-03 | `PhaseRing.qml`, `ClockFace.qml` | Galería 01 a 04 |
| RF-04, RF-05 | `foco-app` notificador, `SoundEffect` | Prueba manual en las tres plataformas |
| RF-06 | Bandeja en `foco-app` | Prueba manual y CI de compilación |
| RF-07 | `foco-core/src/tasks*`, `TasksView.qml` | `tests/tasks_list.rs`, galería 05 |
| RF-08 | `foco-core/src/stats.rs`, `StatsView.qml` | `tests/stats_history.rs`, galería 06 |
| RF-09, RNF-08 | `foco-core/src/storage.rs` | `tests/storage_export.rs` |
| RF-10, RF-11 | `SettingsPage.qml`, `WindowShortcuts.qml` | Galería 14, criterios de `especificacion-ui-ux.md` |
| RF-12 | `MiniView.qml` | Galería 16 y 17 |
| RF-13 | `foco-core/src/timer/snapshot.rs` | `tests/storage_export.rs` |
| RF-14 | `foco-core/src/export.rs` | `tests/storage_export.rs` |
| RNF-04 | Tokens con contraste medido | `revision-diseno.md` |
