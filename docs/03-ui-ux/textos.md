---
lang: es-CO
título: Foco - Textos de la interfaz y atajos
versión: 1.0.0
---

# Foco - Textos de la interfaz y atajos

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Inventario de textos en español de Colombia y mapa de atajos |

Reglas: mayúscula solo al inicio (norma de la RAE, Real Academia Española); verbos en infinitivo
para acciones y sustantivos para secciones; tuteo constante; plurales con dos textos
traducibles (singular y plural, función `Phases.count`), nunca "pomodoro(s)". Todo texto pasa por `qsTr()`.

## 1. Textos

| Contexto | Texto | Límite |
| --- | --- | --- |
| Secciones | Temporizador · Tareas · Estadísticas | 14 caracteres |
| Fases | Enfoque · Descanso · Descanso largo | 16 |
| Botón principal | Iniciar · Pausar · Reanudar | 10 |
| Botones secundarios | Reiniciar fase · Saltar fase | Descripción emergente |
| Ciclo | %1 de %2 | - |
| Pausa | En pausa | - |
| Tarea activa vacía | Elegir tarea | - |
| Campo de tareas | Añadir tarea… | - |
| Estimación | Pomodoros estimados (descripción del selector) | - |
| Tareas vacías | Aún no hay tareas. Escribe la primera y pulsa Intro. | - |
| Completadas | Completadas (%1) | - |
| Deshacer | Tarea eliminada · Deshacer | - |
| Estadísticas hoy | Hoy: %1 enfoque / %1 enfoques · duración | - |
| Racha | Racha: %1 día seguido / %1 días seguidos | - |
| Semana | Esta semana: %1 enfoque / %1 enfoques · duración | - |
| Estadísticas vacías | Completa tu primer enfoque para ver tu semana. | - |
| Exportar | Exportar historial… | - |
| Bandeja oculta (una vez) | Foco sigue en la bandeja. Para cerrarlo del todo, usa Salir. | - |

## 2. Notificaciones (breves, sin el nombre de la app, con acción útil)

| Evento | Título | Cuerpo | Acción |
| --- | --- | --- | --- |
| Fin de enfoque | Enfoque terminado | Llevas %1 de %2. Toca descansar %3 min. | Iniciar descanso |
| Fin de descanso | Descanso terminado | Listo para otro enfoque de %1 min. | Iniciar enfoque |
| Fin de descanso largo | Ciclo completo | Buen trabajo. Empieza un ciclo nuevo cuando quieras. | Iniciar enfoque |

## 3. Ajustes (una página con grupos)

| Grupo | Opciones (valor por defecto) |
| --- | --- |
| Temporizador | Enfoque 25 min · Descanso 5 min · Descanso largo 15 min · Descanso largo cada 4 enfoques |
| Automatización | Iniciar descansos automáticamente (no) · Iniciar enfoques automáticamente (no) |
| Avisos | Notificaciones (sí) · Sonido al terminar (sí) · Volumen (60 %) |
| Ventana | Mantener en la bandeja al cerrar (sí) · Siempre encima (no) |
| Apariencia | Drácula (predeterminada) · Alucard · Según el sistema |
| Idioma | Según el sistema · Español · English |
| Movimiento | Reducir movimiento (sigue al sistema cuando se puede leer) |

## 4. Atajos (Ctrl se lee Cmd en macOS)

| Acción | Atajo | Contexto |
| --- | --- | --- |
| Iniciar o pausar | Espacio | Fuera de campos de texto |
| Reiniciar fase | Ctrl+R | Global en la ventana |
| Saltar fase | Ctrl+Shift+S | Global en la ventana |
| Ir a sección 1, 2, 3 | Ctrl+1, Ctrl+2, Ctrl+3 | Global |
| Nueva tarea | Ctrl+N | Lleva a Tareas y enfoca el campo |
| Deshacer | Ctrl+Z | Tras eliminar una tarea |
| Ajustes | Ctrl+, (Ctrl+Shift+, en KDE) | `StandardKey.Preferences` |
| Modo mini | Ctrl+Shift+M | Ctrl+M es minimizar en macOS |
| Cerrar ventana a la bandeja | Ctrl+W | - |
| Salir | Ctrl+Q | - |
