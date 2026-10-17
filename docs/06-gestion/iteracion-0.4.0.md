---
lang: es-CO
título: Foco - Iteración 0.4.0
versión: 1.0.0
---

# Foco - Iteración 0.4.0

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 0.1.0 | 2026-10-16 | Andrés García | Alcance y estimado registrados antes de construir |
| 1.0.0 | 2026-10-16 | Andrés García | Tiempos reales, error de estimación, diseño, pruebas, puesta en marcha y lecciones |

## 1. Inicio: alcance

Pedido del usuario a las 19:23 (hora de Colombia):

- Al empezar un descanso, una pantalla completa que pregunte en qué tarea se trabajó de verdad:
  la propuesta al comienzo u otra, que se puede registrar ahí mismo.
- La pantalla muestra la cuenta regresiva del descanso configurado y se puede cerrar con un
  botón.
- Al terminar el descanso pregunta con qué tarea se sigue y con eso deja pasar.
- Revisar cómo lo resolvieron otras aplicaciones de pomodoro y aplicar las pautas de diseño de
  Apple sin romper la arquitectura.
- Al final, borrar la carpeta `target` tras comprobar que todo funciona.
- Fuera del producto: skills de desarrollo solo para este proyecto y una skill global con el
  proceso de desarrollo completo.

## 2. Planeación: estimado frente a real

Estimado registrado a las 19:25, antes del primer cambio de código, como trabajo más esperas
medidas (lección de las iteraciones 0.2.0 y 0.3.0). No hubo integración continua: la versión no
se publica sin autorización. Horas reales tomadas del registro de la sesión.

| Fase | Estimado (min) | Real (min) | Desviación |
| --- | --- | --- | --- |
| Inicio, investigación y planeación | 15 | 2,5 | -83 % |
| Requisitos y diseño | 10 | 0,6 | -94 % |
| Construcción | 40 | 11,7 | -71 % |
| Skills del proyecto y skill global | 35 | 3,8 | -89 % |
| Integración y pruebas | 30 | 7,9 | -74 % |
| Entrega y cierre | 15 | 6,0 | -60 % |
| Total | 145 | 32,5 | -78 % |

Error de estimación: se repitió el de la iteración 0.2.0, estimar al ritmo de una persona. Tres
investigaciones (otras aplicaciones, skills existentes y skills para el proyecto) y la
compilación limpia de 12 minutos corrieron en paralelo con la construcción, así que la espera
más larga no sumó tiempo. El diseño no tuvo fase propia: se hizo dentro de la construcción, sobre
la galería del prototipo. Para la próxima: estimar por camino crítico y no sumar el trabajo que
corre en paralelo.

Riesgos: la pantalla completa encima de todo en KDE Wayland (Qt no puede subir su ventana sola),
varios monitores, y que la pantalla aparezca mientras se escribe y capture el teclado.

## 3. Diseño

Referentes revisados: Stretchly, BreakTimer, Safe Eyes, Pomatez, LookAway, Time Out, Session,
Flow, Focus To-Do, Pomofocus y Super Productivity, cuyo registro de tarea al terminar el foco se
tomó como modelo. Decisiones (DA-14 a DA-16 en `docs/02-diseno/arquitectura.md`):

- Al completar un enfoque se acredita a la tarea activa como siempre; la pantalla solo corrige
  ese crédito, así que cerrarla nunca deja el enfoque sin registrar.
- Una ventana por monitor; preguntas solo en el de la ventana principal y cuenta regresiva en los
  demás. En KDE Wayland un guion de KWin coloca cada ventana en su salida y la deja encima.
- Ninguna tecla responde: es la queja más repetida en otras aplicaciones (lo que se escribía al
  aparecer la pantalla terminaba eligiendo una opción). Esc y el botón Cerrar sí cierran.
- Entrada con fundido, tarea propuesta preseleccionada y nombrada en la pregunta, y el tiempo
  restante como protagonista durante el descanso (pautas de Apple sobre modales y temporizadores).
- Fuera de alcance: detener la pantalla ante videollamadas o micrófono en uso y esperar una pausa
  en el tecleo; quedan como mejora siguiente.

## 4. Integración y pruebas

| Verificación | Resultado |
| --- | --- |
| Núcleo: 35 pruebas, 6 nuevas de crédito corregible | Todas en verde |
| `cargo fmt`, `clippy -D warnings` del núcleo y de la app | Sin avisos |
| Galería del prototipo en Qt 6.10 y en Qt 6.4 (Debian 12) | 24 de 24 escenas sin errores |
| Arranque sin pantalla de la aplicación | Sin errores de QML; guarda `foco.json` |
| Prueba real en dos monitores con Plasma 6.6 Wayland | Ambos cubiertos, descanso corriendo, pregunta en el monitor de la ventana |
| Uso real por Andrés durante la prueba | Registró "tarea x", el crédito y el historial pasaron a ella, cerró, la pantalla volvió al terminar el descanso y el enfoque arrancó con la tarea elegida |

Fallos que solo mostró la prueba real, ya corregidos:

1. El segundo monitor quedaba sin cubrir: dos guiones de KWin cargados a la vez con el mismo
   nombre; ahora cada uno lleva un número propio.
2. El descanso no arrancaba: la señal de fin de fase llegaba antes de actualizar el estado.
3. "Empezar enfoque" no hacía nada: cerrar las ventanas antes de emitir la señal destruía a quien
   la emitía; ahora se emite primero y se cierra en el siguiente ciclo.

No probado: Windows y macOS (no se publicó versión) y la prevención de robo de foco de KWin en
nivel "Medio" o mayor.

## 5. Entrega: puesta en marcha

Versión 0.4.0 en el repositorio local, sin publicar en GitHub. La carpeta `target` se borra al
final tras verificar.

## 6. Lecciones aprendidas

- La prueba en el escritorio real encontró los tres fallos que ni las pruebas unitarias ni la
  galería podían mostrar: los de ventanas, señales y gestor de ventanas se prueban en vivo.
- En QML, emitir la señal antes de cambiar el estado que destruye al emisor.
- Estimar por camino crítico cuando hay trabajo en paralelo.
