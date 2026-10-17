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

## 3. Diseño

Decisión DA-17 en `docs/02-diseno/arquitectura.md`, con el criterio en RF-18:

- KDE (Wayland y X11): el guion de KWin que ya coloca cada ventana la fija también a todos los
  escritorios y actividades.
- macOS: cada ventana de descanso se une a todos los espacios, incluidos los de aplicaciones a
  pantalla completa (`all_spaces.cpp`, por el entorno de ejecución de Objective-C).
- Windows y GNOME no dejan fijar una ventana a todos los escritorios con una interfaz estable:
  cuando ninguna ventana de descanso tiene el foco durante 400 ms, se ocultan y se vuelven a
  mostrar, y una ventana que se muestra abre en el escritorio en uso.

## 4. Integración y pruebas

| Verificación | Resultado |
| --- | --- |
| `cargo clippy --all-targets -D warnings` y 35 pruebas del núcleo | Sin avisos; todas en verde |
| `qmllint` de `BreakScreens.qml` y `BreakWindow.qml` | Sin avisos |
| `all_spaces.cpp` revisado con clang como macOS (cabeceras de Objective-C simuladas) | Sin errores de sintaxis |
| KDE Wayland, dos monitores: propiedades de las ventanas según KWin | Ambas con `onAllDesktops = true` y `activities = []` (todas las actividades), a pantalla completa y encima |
| Modo Windows y GNOME simulado en KDE (`XDG_CURRENT_DESKTOP=GNOME`): ventanas movidas al escritorio 1 y sin foco | A los 400 ms se crearon de nuevo en el escritorio en uso (6), a pantalla completa, y una recuperó el foco: sin bucle |
| Puesta en marcha con el enfoque de Andrés corriendo | Guardado 1212 s, reanudado en 1211 s y corriendo |

Hallazgo no resuelto: sin el guion de KWin, las dos ventanas quedan a pantalla completa en el
mismo monitor (el activo). En GNOME con varios monitores puede pasar lo mismo; Qt no indicó a
KWin la salida de cada ventana. Queda para la siguiente iteración.

No probado: macOS y Windows reales (sin equipo ni versión publicada), GNOME real y el cambio de
escritorio a mano (se simuló con KWin para no mover el escritorio en uso).

## 5. Entrega: puesta en marcha

Versión 0.4.1 instalada en `~/.local/bin/foco`, sin publicar en GitHub. El proceso se reinició
con el enfoque en curso conservado.

## 6. Lecciones aprendidas

- Una ventana movida de escritorio por guion de KWin sigue activa; para simular un cambio de
  escritorio hay que quitarle el foco.
- Probar la variante de otra plataforma en el escritorio propio cambiando `XDG_CURRENT_DESKTOP`
  mostró el fallo de monitores que la 0.4.0 tenía oculto fuera de KDE.
- Estimar la compilación con caché: `sccache` sobrevive al borrado de `target`.
