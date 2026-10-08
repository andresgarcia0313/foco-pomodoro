---
lang: es-CO
título: Foco - Especificación de requisitos
versión: 1.1.0
---

# Foco - Especificación de requisitos

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Versión inicial: visión, actores, requisitos, casos de uso y riesgos |
| 1.1.0 | 2026-10-08 | Andrés García | RF-13 ampliado a caídas y congelamientos; nuevos RF-16 y RF-17; RNF-08 con recuperación automática |

## 1. Visión

Foco es una aplicación de escritorio para aplicar la técnica Pomodoro: bloques de enfoque de
25 minutos separados por descansos cortos y, cada cuatro bloques, un descanso largo. Funciona en
Kubuntu, Windows 11 y macOS con una sola base de código: núcleo en Rust e interfaz en Qt 6.

**Trabajo principal:** que la persona empiece a concentrarse en un segundo y sepa, de un vistazo,
en qué fase está y cuánto falta. **Lo que no hace:** no es un gestor de proyectos, no sincroniza
con la nube y no pide cuenta.

## 2. Actores

| Actor | Descripción |
| --- | --- |
| Persona usuaria | Trabaja en el computador en bloques de concentración y quiere medir su avance |
| Sistema operativo | Entrega notificaciones, bandeja del sistema, apariencia clara u oscura y atajos |

## 3. Requisitos funcionales (prioridad MoSCoW: debe, debería, podría, no hará)

| Id | Requisito | Prioridad |
| --- | --- | --- |
| RF-01 | Ciclo de tres fases: enfoque (25 min), descanso corto (5 min) y descanso largo (15 min) cada 4 enfoques; todas las duraciones configurables | Debe |
| RF-02 | Iniciar, pausar, reanudar, reiniciar la fase y saltar a la siguiente | Debe |
| RF-03 | Tiempo restante como elemento principal, anillo de progreso y marcador del ciclo (por ejemplo, 2 de 4) | Debe |
| RF-04 | Notificación nativa del sistema al terminar cada fase, sin robar el foco | Debe |
| RF-05 | Sonido opcional al terminar la fase, con volumen ajustable y silencio total | Debe |
| RF-06 | Icono en la bandeja del sistema con estado, tiempo en la descripción emergente y menú con iniciar o pausar, saltar, mostrar ventana y salir | Debe |
| RF-07 | Tareas: crear, completar, eliminar con opción de deshacer, estimar pomodoros y marcar una tarea activa; cada enfoque completado suma a la tarea activa | Debe |
| RF-08 | Estadísticas: enfoques y minutos de hoy, racha de días consecutivos y barras de los últimos 7 días | Debe |
| RF-09 | Persistencia local de ajustes, tareas e historial; funciona sin red | Debe |
| RF-10 | Ajustes: duraciones, intervalo del descanso largo, inicio automático de descansos y de enfoques, sonido, notificaciones, siempre encima, apariencia (Sistema, Drácula, Alucard) e idioma | Debe |
| RF-11 | Atajos de teclado para todas las acciones frecuentes | Debe |
| RF-12 | Modo mini: ventana compacta con tiempo y botón principal, opcionalmente siempre encima | Debería |
| RF-13 | Al reabrir, tras cierre, caída o congelamiento, la fase sigue con el mismo tiempo restante y en el mismo estado (corriendo o en pausa), con el mismo modo de ventana y tamaño | Debe |
| RF-14 | Exportar el historial a CSV (valores separados por comas) | Podría |
| RF-15 | Cuentas, sincronización en la nube, versión móvil | No hará |
| RF-16 | Añadir o quitar un minuto a la fase en curso, con botón (mantener pulsado repite) y con las teclas + y - | Debe |
| RF-17 | Registro local de uso (conteo diario de cada función) que guía las mejoras de la interfaz; nunca sale del equipo ni pasa de 10 MB | Debe |

## 4. Requisitos no funcionales

| Id | Atributo | Criterio medible |
| --- | --- | --- |
| RNF-01 | Portabilidad | Compila y ejecuta en Kubuntu 26.04 (Wayland y X11), Windows 11 y macOS 13 o superior con Qt 6.10 |
| RNF-02 | Precisión | Deriva del temporizador menor de 1 s en 25 min; el tiempo se calcula con reloj monotónico, no contando pulsos |
| RNF-03 | Rendimiento | Arranque en frío menor de 1,5 s; memoria residente menor de 150 MB; CPU en reposo cercana a 0 % |
| RNF-04 | Accesibilidad | Contraste de texto 4,5:1 o más (nivel AA de las pautas WCAG, Web Content Accessibility Guidelines); todo operable con teclado; nombres accesibles en controles con solo icono |
| RNF-05 | Internacionalización | Todo texto visible pasa por el sistema de traducción de Qt; español (es-CO) por defecto e inglés |
| RNF-06 | Privacidad | Sin conexiones de red; datos solo en la carpeta de configuración del usuario |
| RNF-07 | Mantenibilidad | Núcleo en Rust sin dependencia de Qt, con cobertura de pruebas del 90 % o más; archivos de código de 100 líneas o menos |
| RNF-08 | Robustez | Un archivo de datos dañado no impide arrancar: se respalda y se crea uno nuevo. Una caída o un cuelgue de más de 45 s reinician la interfaz sola; se pierden como máximo 15 s de avance |

## 5. Casos de uso principales

**CU-01 Concentrarse en una tarea.** La persona escribe o elige una tarea, pulsa Iniciar (o la
barra espaciadora). Al terminar los 25 minutos recibe una notificación, el enfoque suma a la tarea
y comienza el descanso (automático si así lo configuró).

**CU-02 Interrupción.** Durante el enfoque pulsa Pausar; al volver, Reanudar. Si abandona el
bloque, Reiniciar lo devuelve a 25:00 sin contarlo.

**CU-03 Trabajar con la ventana oculta.** Cierra la ventana; Foco sigue en la bandeja. Desde el
menú de la bandeja pausa, salta o vuelve a mostrar la ventana.

**CU-04 Revisar el avance.** Abre Estadísticas y ve los enfoques de hoy, la racha y la semana.

**CU-05 Ajustar el método.** Cambia duraciones y automatismos en Ajustes; aplica desde la
siguiente fase sin reiniciar la aplicación.

## 6. Restricciones

- Núcleo en Rust estable (1.93 o superior) e interfaz en Qt 6.10 con QML (lenguaje declarativo
  de interfaces de Qt) mediante CXX-Qt, el puente Rust y Qt de KDAB.
- Paleta Dracula (oscura) y Alucard (clara, variante oficial) como identidad visual.
- Licencias compatibles con distribución libre: Qt bajo LGPL (Lesser General Public License).

## 7. Riesgos

| Riesgo | Impacto | Mitigación |
| --- | --- | --- |
| API de CXX-Qt cambia entre versiones | Medio | Fijar versión 0.10 y aislar el puente en un módulo delgado |
| Bandeja del sistema distinta por plataforma | Medio | Qt.labs.platform con respaldo de Qt Widgets; pruebas en las tres plataformas por integración continua |
| Notificaciones con permisos en macOS | Bajo | Crate notify-rust y mensaje en la interfaz si se niegan |
| Firma de código en macOS y Windows | Medio | Fuera del alcance 1.0; documentado en despliegue |
