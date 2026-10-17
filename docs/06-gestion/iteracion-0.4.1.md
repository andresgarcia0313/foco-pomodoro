---
lang: es-CO
título: Foco - Iteración 0.4.1
versión: 1.0.0
---

# Foco - Iteración 0.4.1

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-17 | Andrés García | Alcance, estimado frente a real, diseño, pruebas y lecciones |
| 1.1.0 | 2026-10-17 | Andrés García | Segunda ronda: fallo de monitores resuelto, prueba real en Windows (ASUS) y paquetes de macOS |

## 1. Inicio: alcance

Pedido del usuario (12:28, hora de Colombia): la pantalla completa del descanso solo aparece en
el escritorio virtual donde está la ventana de Foco; debe bloquear la pantalla en todos los
escritorios virtuales, en KDE, GNOME, macOS y Windows.

Fuera de alcance: bloquear el sistema operativo (la pantalla sigue cerrándose con el botón o Esc).

Riesgos para quien ya lo usa: que la pantalla parpadee al cambiar de escritorio o al pasar el foco
entre monitores.

## 2. Planeación: estimado frente a real

Estimado registrado a las 12:30, ya con el código escrito (desviación del proceso: el estimado
debía ir antes del primer cambio).

| Proceso | Estimado (min) | Real (min) | Desviación |
| --- | --- | --- | --- |
| Inicio, diseño y construcción | 10 | 2 | -80 % |
| Compilación limpia (`target` se había borrado) | 12 | 1 | -92 % |
| Integración y pruebas | 10 | 4 | -60 % |
| Entrega y cierre | 8 | 2 | -75 % |
| Total | 40 | 9 | -78 % |

Error de estimación: la compilación limpia tardó 53 s y no 12 min porque `sccache` conservaba los
objetos aunque `target` se había borrado; el estimado tomó el tiempo de una compilación sin caché.

### Segunda ronda (13:10 a 14:58)

Pedido: resolver el fallo de monitores fuera de KDE, validar en el ASUS (Windows 11) y compilar
para macOS. No se registró estimado antes de empezar: se repitió la desviación de proceso de la
primera ronda. Real: 108 min, de los que unos 40 fueron esperas de compilación en GitHub (cuatro
rondas de unos 8 min) y unos 30 la investigación de un bloqueo que resultó del método de prueba.

## 3. Diseño

Decisión DA-17 en `docs/02-diseno/arquitectura.md`, con el criterio en RF-18:

- KDE (Wayland y X11): el guion de KWin que ya coloca cada ventana la fija también a todos los
  escritorios y actividades.
- macOS: cada ventana de descanso se une a todos los espacios, incluidos los de aplicaciones a
  pantalla completa (`all_spaces.cpp`, por el entorno de ejecución de Objective-C).
- Windows y GNOME no dejan fijar una ventana a todos los escritorios con una interfaz estable:
  cuando ninguna ventana de descanso tiene el foco durante 400 ms, se ocultan y se vuelven a
  mostrar, y una ventana que se muestra abre en el escritorio en uso (GNOME).
- Windows (segunda ronda): `IVirtualDesktopManager` dice cada segundo si la pantalla quedó en
  otro escritorio; entonces su ventana nativa se destruye y se crea de nuevo, porque Windows
  recuerda el escritorio de una ventana aunque se oculte.
- Monitores (segunda ronda): Qt elige el monitor de una ventana por su posición y todas nacían en
  0,0; cada ventana se coloca en su monitor antes de pedir pantalla completa. La ventana de las
  preguntas se muestra de última para quedarse con el foco.

## 4. Integración y pruebas

| Verificación | Resultado |
| --- | --- |
| `cargo clippy --all-targets -D warnings` y 35 pruebas del núcleo | Sin avisos; todas en verde |
| `qmllint` de `BreakScreens.qml` y `BreakWindow.qml` | Sin avisos |
| `all_spaces.cpp` revisado con clang como macOS (cabeceras de Objective-C simuladas) | Sin errores de sintaxis |
| KDE Wayland, dos monitores: propiedades de las ventanas según KWin | Ambas con `onAllDesktops = true` y `activities = []` (todas las actividades), a pantalla completa y encima |
| Modo Windows y GNOME simulado en KDE (`XDG_CURRENT_DESKTOP=GNOME`): ventanas movidas al escritorio 1 y sin foco | A los 400 ms se crearon de nuevo en el escritorio en uso (6), a pantalla completa, y una recuperó el foco: sin bucle |
| Puesta en marcha con el enfoque de Andrés corriendo | Guardado 1212 s, reanudado en 1211 s y corriendo |

Segunda ronda:

| Verificación | Resultado |
| --- | --- |
| KWin anidado con dos monitores virtuales, modo GNOME | Cada ventana en su monitor; tras un cambio real al escritorio 2, ambas se crean ahí, cada una en su monitor, con la de preguntas activa |
| KWin anidado, modo KDE | Fijas a todos los escritorios, cada una en su monitor, sin recrearse |
| GitHub Actions, 13 trabajos (paquetes deb, Windows, macOS arm64 y x86_64) | Todos en verde; la prueba de arranque de macOS carga el QML sin errores |
| ASUS, Windows 11, instalador 0.4.1 | Instala con código 0 |
| ASUS, flujo completo | Pregunta, cambio de tarea a "tarea x", cuenta regresiva, escritorio 2 y regreso al 1 cubiertos, Esc cierra, reaparece al terminar el descanso y "Empezar enfoque" arranca con "tarea x" (crédito 1 a 2, historial con "tarea x") |
| Puesta en marcha en el Lenovo | Guardado 479 s, reanudado en 478 s y corriendo |

Fallos encontrados en la segunda ronda y resueltos: el enlace de `user32` en Windows; la pantalla
no volvía al escritorio de origen en Windows (ocultar y mostrar no la mueve).

Hallazgo del método de prueba, no del producto: Foco lanzado como hijo de una tarea programada
con consola sin ventana se bloquea en la sesión del escritorio (también la 0.3.0); lanzado por
`explorer.exe`, como lo abre una persona, funciona.

No probado: macOS real (sin equipo; solo la prueba de arranque sin pantalla de GitHub) y GNOME
real (se probó el mismo camino con KWin anidado).

## 5. Entrega: puesta en marcha

Versión 0.4.1 instalada en `~/.local/bin/foco` y en el ASUS. Paquetes en `dist/0.4.1/` (dos
`.dmg` de macOS, instalador y zip de Windows). El código está en la rama `prueba-0.4.1` de
GitHub, sin etiqueta ni versión publicada.

## 6. Lecciones aprendidas

- Una ventana movida de escritorio por guion de KWin sigue activa; para simular un cambio de
  escritorio hay que quitarle el foco.
- Probar la variante de otra plataforma en el escritorio propio cambiando `XDG_CURRENT_DESKTOP`
  mostró el fallo de monitores que la 0.4.0 tenía oculto fuera de KDE.
- Estimar la compilación con caché: `sccache` sobrevive al borrado de `target`.
- En Windows una ventana conserva su escritorio virtual aunque se oculte; solo una ventana
  nativa nueva abre en el escritorio en uso.
- Probar en Windows desde SSH: lanzar la app a través de `explorer.exe`; como hija de una tarea
  programada con consola sin ventana se bloquea y confunde el diagnóstico.
- Con un solo monitor disponible, `kwin_wayland --virtual --output-count 2` dentro de
  `dbus-run-session` prueba varios monitores sin tocar el escritorio en uso.
