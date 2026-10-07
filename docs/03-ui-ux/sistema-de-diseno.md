---
lang: es-CO
título: Foco - Sistema de diseño
versión: 1.0.0
---

# Foco - Sistema de diseño

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Tokens de color con contraste medido, tipografía, espaciado, movimiento y componentes |

La fuente de verdad en código es `qml/Foco/Theme.qml`; este documento la explica. Los
contrastes se midieron con la fórmula de las pautas WCAG 2.x (Web Content Accessibility
Guidelines, pautas de accesibilidad para contenido web).

## 1. Color por rol

| Rol | Drácula (oscuro) | Alucard (claro) | Contraste sobre la base |
| --- | --- | --- | --- |
| `base` (lienzo) | `#282A36` | `#FFFBEB` | - |
| `raised` (tarjetas, menús) | `#343746` | `#EFEDDC` | - |
| `hover` | `#424450` | `#ECE9DF` | - |
| `selected`, pista del anillo | `#44475A` | `#DEDCCF` | Decorativa (1,56 y 1,33) |
| `text` | `#F8F8F2` | `#1F1F1F` | 13,36 y 15,89 |
| `textMuted` | `#B6BCD8` | `#5C5848` | 7,58 y 6,05 sobre tarjeta |
| `border` | `#6272A4` | `#6C664B` | 3,03 y 5,56 (no texto) |
| `accent` (acción principal, foco) | `#BD93F9` | `#644AC9` | 5,90 y 6,02 |
| `accentLabel` (etiqueta sobre relleno) | `#282A36` | `#FFFBEB` | 5,90 y 6,02 |
| `focusPhase` | `#FF79C6` | `#A3144D` | 5,97 y 7,33 |
| `shortBreak` | `#50FA7B` | `#14710A` | 10,38 y 5,96 |
| `longBreak` | `#8BE9FD` | `#036A96` | 10,29 y 5,78 |
| `danger` | `#FF5555` | `#CB3A2A` | 4,53 y 4,85 (solo sobre la base) |

Reglas: el texto secundario nunca usa `#6272A4` (3,03:1 no alcanza AA). Sobre rellenos de color la
etiqueta es oscura en Drácula; el blanco sobre morado da 2,26:1 y se descarta. El tinte de fase
del fondo es el color de la fase al 7 % de opacidad: perceptible, sin vibrar.

## 2. Tipografía

Letra del sistema (SF Pro, Segoe UI Variable, Noto Sans) para todo; la personalidad la pone la
cifra. Tamaños relativos a `B = Qt.application.font.pointSize`, para respetar el ajuste del
sistema.

| Estilo | Tamaño | Peso | Uso |
| --- | --- | --- | --- |
| `display` | 5,2 B | Medio, cifras tabulares | Cifra del temporizador |
| `displayMini` | 2,4 B | Medio, cifras tabulares | Modo mini |
| `title` | 1,35 B | Seminegrita | Títulos de sección |
| `body` | 1,0 B | Normal | Texto general, tareas |
| `label` | 0,92 B | Medio | Botones, navegación |
| `caption` | 0,85 B, mínimo 9 pt | Normal | Metadatos, ejes del gráfico |

## 3. Espaciado, forma y elevación

- Escala de 4 px: 4, 8, 12, 16, 24, 32, 48.
- Radios: 6 px en controles, 10 px en tarjetas, píldora en el botón principal.
- Áreas de clic de 32 x 32 px como mínimo (piso común entre Apple, Fluent y KDE).
- Elevación por luminosidad, sin sombras: base, `raised`, `hover`, `selected`.
- Anillo: diámetro 240 px (se escala con la ventana, mínimo 180), arco 10 px con extremos
  redondeados, anillo del ciclo 3 px con cuatro segmentos separados 6°.

## 4. Movimiento

| Token | Duración | Uso |
| --- | --- | --- |
| `fast` | 120 ms | Hover y presión |
| `normal` | 200 ms | Cambio de sección, aparición del aviso de deshacer |
| `slow` | 320 ms | Cambio de color de fase (único momento orquestado) |

`reduceMotion` pone todo en 0. Nada se anima en Iniciar o Pausar, que son frecuentes.

## 5. Componentes

| Componente | Estados | Teclado y accesibilidad |
| --- | --- | --- |
| `PrimaryButton` (píldora, `accent`) | normal, hover, presionado, foco, inactivo | Espacio o Intro; nombre = texto visible |
| `IconButton` (32 x 32) | normal, hover (`hover`), presionado (`selected`), foco | Nombre accesible obligatorio y descripción emergente con atajo |
| `NavTab` (icono + texto) | normal, seleccionado (texto `text` + barra `accent` de 2 px), hover, foco | Ctrl+1 a Ctrl+3; rol `PageTab` |
| `PhaseRing` | en marcha, en pausa (arco en `textMuted`), terminado | Rol `ProgressBar`; nombre "Enfoque, quedan 24 minutos" |
| `TaskRow` | pendiente, activa (estrella `accent`), completada (texto `textMuted` tachado), hover | Flechas para moverse; Espacio completa; Supr elimina; Intro activa |
| `Toast` de deshacer | visible 6 s, pausado al pasar el puntero | Ctrl+Z; rol `Alert` |
| `WeekChart` | barras de enfoque en `focusPhase`; hoy al 100 %, otros días al 55 % | Cada barra con nombre "Martes, 4 enfoques" |
| Anillo de foco | 2 px `accent` a 2 px del control | En todos los controles con `visualFocus` |

## 6. Iconografía

Lucide (licencia ISC), trazo de 2 px a 20 px, coloreado con el rol del texto vecino. Icono de la
app: el anillo rosa sobre `#282A36` con un cáliz verde de tres hojas encima, guiño al tomate que
da nombre a la técnica, sin caer en la caricatura.
