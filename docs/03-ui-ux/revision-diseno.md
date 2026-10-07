---
lang: es-CO
título: Foco - Revisión de diseño sobre prototipos renderizados
versión: 1.0.0
---

# Foco - Revisión de diseño sobre prototipos renderizados

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Revisión con las cinco lentes sobre 17 capturas, hallazgos y correcciones |

## Método

Cada pantalla se prototipó en QML (lenguaje declarativo de interfaces de Qt) con datos
simulados y se renderizó sin ventana a PNG con `tools/prototipo/Render.qml`, en Drácula y
Alucard, a 400 x 640 y a la ventana mínima de 340 x 520, también con la letra del sistema al
doble. Las capturas están en `galeria/`. Para regenerarlas:

```bash
QT_QPA_PLATFORM=offscreen QT_QUICK_CONTROLS_STYLE=Basic \
  qml6 -I qml tools/prototipo/Render.qml -- "$PWD/docs/03-ui-ux/galeria"
```

## Resumen

Calificación final: **Bien**, sin hallazgos críticos abiertos. La tesis se sostiene: la cifra
manda, el anillo doble dice a la vez cuánto falta y en qué punto del ciclo se está, y el tinte
de fase cambia "la habitación" sin depender solo del color. Lo que hará reconocible a Foco es el
anillo rosa, verde o cian con los cuatro segmentos del ciclo.

## Hallazgos y correcciones

| Severidad | Hallazgo | Corrección | Captura |
| --- | --- | --- | --- |
| Crítico | Con letra al doble y ventana mínima, pestañas cortadas, menú fuera de pantalla y cifra desbordada (pautas HIG `accessibility.md`: ampliar el texto al 200 %) | Pestañas pasan a solo icono con descripción emergente y nombre accesible; nombres cortos de fase; cifra ajustada al anillo en ancho y alto | 13 |
| Crítico | La etiqueta del botón principal salía negra sobre morado en Alucard: una propiedad QML llamada `onAccent` se leía como manejador de señal | Renombrada a `accentLabel`; crema sobre `#644AC9` = 6,02:1 | 07, 15 |
| Alto | Barras de días pasados al 55 % daban 2,77:1, por debajo del 3:1 para gráficos | Opacidad al 70 %: 3,64:1 en Drácula y 4,10:1 en Alucard; hoy además en negrita | 06, 09 |
| Medio | La racha en verde chocaba con el verde del descanso (`color.md`: un color, un significado) | Racha en color de texto | 06 |
| Medio | El subtítulo repetía la fase ya visible en el selector | Subtítulo con la posición en el ciclo ("2 de 4"; en descanso, "2 de 4 hechos") | 01, 03 |
| Medio | Texto de la fila activa descentrado por el relleno del componente | Relleno vertical en cero | 05 |
| Medio | Interruptores salidos de la tarjeta de ajustes | Ancho implícito del interruptor | 14 |
| Bajo | La pista del anillo tiene 1,56:1 | Se acepta: es decorativa; el progreso lo cargan el arco (5,97:1) y la cifra | 01 |

## Lo que funciona y se conserva

- La etiqueta oscura sobre los rellenos de color: nunca blanco sobre morado (2,26:1).
- Texto secundario `#B6BCD8`, nunca `#6272A4` (3,03:1).
- Estadísticas escritas como frases y no como mosaicos de números grandes, un patrón de
  plantilla que la lente de oficio pide evitar.
- Ajustes en una sola página agrupada, sin botón Guardar: cada cambio aplica al instante.

## Pendiente para la verificación en la aplicación real

Orden de tabulación y nombres en el árbol de accesibilidad con la sesión KWin aislada; letra
real de cada sistema (SF Pro, Segoe UI Variable, Noto Sans); notificaciones y bandeja nativas.
