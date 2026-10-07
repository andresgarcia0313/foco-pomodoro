---
lang: es-CO
título: Foco - Especificación de experiencia e interfaz
versión: 1.0.0
---

# Foco - Especificación de experiencia e interfaz

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-07 | Andrés García | Versión inicial: brief, trabajos, arquitectura de información, flujos, maquetas y criterios |

Método: modo de creación de la guía de diseño basada en las HIG (Human Interface Guidelines,
pautas de interfaz humana de Apple), ampliada para Qt, los tres escritorios y la paleta Dracula.
Sistema visual en `sistema-de-diseno.md`; textos en `textos.md`; revisión en `revision-diseno.md`.

## 1. Brief

Una persona que trabaja frente al computador quiere sostener bloques de concentración sin pensar
en el reloj. Foco le muestra una sola cosa importante, **cuánto falta y en qué fase está**, y se
aparta del camino: vive en la bandeja, avisa sin interrumpir y guarda el avance sin pedir nada.
Foco **no** es un gestor de proyectos: las tareas existen solo para dar nombre al enfoque.

**Tesis de diseño:** "La habitación cambia de color". El anillo y un tinte suave del fondo pasan
de rosa (enfoque) a verde (descanso) o cian (descanso largo): el estado se lee desde lejos,
siempre acompañado de texto y de la forma del anillo, nunca solo con color.

## 2. Trabajos y frecuencia

| Trabajo | Frecuencia | Ubicación |
| --- | --- | --- |
| Iniciar o pausar | Cada pocos minutos | Botón principal, Espacio, bandeja |
| Saber cuánto falta | Constante | Cifra central, descripción de la bandeja, modo mini |
| Nombrar en qué trabajo | Varias veces al día | Tarea activa bajo los controles |
| Saltar o reiniciar una fase | Varias veces al día | Botones secundarios, atajos, bandeja |
| Revisar el avance | Diario | Sección Estadísticas |
| Ajustar duraciones | Rara vez | Ajustes (menú de la app) |

## 3. Arquitectura de información (máximo dos niveles)

```text
Foco
├── Temporizador  (Ctrl+1)  ← sección inicial
├── Tareas        (Ctrl+2)
├── Estadísticas  (Ctrl+3)
├── Menú (☰ en Windows y KDE; barra de menús nativa en macOS)
│   ├── Ajustes…          (StandardKey.Preferences)
│   ├── Modo mini         (Ctrl+Shift+M)
│   ├── Siempre encima
│   ├── Exportar historial…
│   ├── Atajos de teclado
│   ├── Acerca de Foco
│   └── Salir             (Ctrl+Q)
├── Ventana de Ajustes (una sola página con grupos)
├── Ventana mini
└── Bandeja del sistema (estado + menú)
```

## 4. Flujos clave (clics para el trabajo más frecuente: uno o ninguno)

1. **Primer uso:** abre en Temporizador con 25:00 y el botón Iniciar enfocado. Sin asistente
   ni permisos al arrancar. El permiso de notificaciones (macOS) se pide al terminar el primer
   enfoque, en contexto.
2. **Concentrarse:** Espacio o clic en Iniciar. Al llegar a 0: notificación "Enfoque terminado",
   sonido si está activo, el enfoque suma a la tarea activa y la fase pasa a Descanso, en espera o
   automática según Ajustes.
3. **Trabajar con la ventana cerrada:** cerrar la ventana la oculta en la bandeja; la primera vez
   un aviso único lo explica. Desde la bandeja: Iniciar o Pausar, Saltar, Mostrar Foco, Salir.
4. **Nombrar el trabajo:** en Temporizador, clic en "Elegir tarea" abre un menú con las tareas
   pendientes y "Nueva tarea…"; en Tareas, la estrella marca la activa.
5. **Equivocarse:** borrar una tarea muestra "Tarea eliminada · Deshacer" durante 6 s y Ctrl+Z
   la recupera. Reiniciar una fase en curso no pide confirmación: solo devuelve el reloj.

## 5. Maquetas (ventana por defecto 400 x 640; mínima 340 x 520)

```text
Temporizador                            Tareas
┌────────────────────────────────────┐  ┌────────────────────────────────────┐
│ ◷ Temporizador  ☑ Tareas  ▥ Estad. ☰│  │ ◷ Temporizador  ☑ Tareas  ▥ Estad. ☰│
│                                    │  │ ┌────────────────────────────┐ ┌─┐ │
│   Enfoque · Descanso · Desc. largo │  │ │ Añadir tarea…              │ │+│ │
│           ╭──────────────╮         │  │ └────────────────────────────┘ └─┘ │
│        ╭─╯   ▪ ▪ ▫ ▫      ╰─╮      │  │ ★ ○ Escribir informe      2/4 ◷   │
│       │                     │      │  │ ☆ ○ Revisar correos       0/1 ◷   │
│       │       24:13         │      │  │ ☆ ● Preparar clase        3/3 ◷   │
│       │   Enfoque · 2 de 4  │      │  │                                    │
│        ╰─╮                ╭─╯      │  │  Completadas (1)  ▾                │
│           ╰──────────────╯         │  │                                    │
│     [↺]    [ ▶  Iniciar ]    [⏭]   │  │                                    │
│                                    │  │ ┌ Tarea eliminada · Deshacer ┐    │
│   ★ Escribir informe · 2 de 4  ▾   │  │ └────────────────────────────┘    │
└────────────────────────────────────┘  └────────────────────────────────────┘

Estadísticas                            Modo mini (240 x 120)
┌────────────────────────────────────┐  ┌──────────────────────┐
│ ◷ Temporizador  ☑ Tareas  ▥ Estad. ☰│  │ ● 24:13   [ ▶ ]  [⤢] │
│ Hoy: 6 enfoques · 2 h 30 min       │  │   Enfoque · 2 de 4   │
│ Racha: 4 días seguidos             │  └──────────────────────┘
│                                    │
│  ▆      ▃   ▇   ▅                  │  Bandeja (menú)
│  ▆  ▂   ▃   ▇   ▅   ▁   █          │  ┌──────────────────────┐
│  L  M   M   J   V   S   D          │  │ 24:13 · Enfoque      │
│                                    │  │ Pausar               │
│ Esta semana: 21 enfoques · 8 h 45 m│  │ Saltar fase          │
│ Exportar historial…                │  │ Reiniciar fase       │
└────────────────────────────────────┘  │ Mostrar Foco         │
                                        │ Modo mini            │
                                        │ Salir                │
                                        └──────────────────────┘
```

El anillo doble es la firma: el arco grueso interior es el progreso de la fase; los cuatro
segmentos del anillo exterior fino son el ciclo de enfoques hasta el descanso largo.

## 6. Estados

| Pantalla | Vacío | Error | Otros |
| --- | --- | --- | --- |
| Temporizador | Sin tarea activa: "Elegir tarea" en texto secundario | No aplica | Pausado: cifra en texto secundario y "En pausa"; el anillo deja de avanzar |
| Tareas | "Aún no hay tareas. Escribe la primera y pulsa Intro." | Título vacío: el botón + queda inactivo | Completadas plegadas por defecto |
| Estadísticas | "Completa tu primer enfoque para ver tu semana." con barras en cero | Historial dañado: aviso en línea y respaldo creado | Racha 0 no se muestra |
| Notificaciones | No aplica | Permiso negado (macOS): aviso en Ajustes con botón "Abrir ajustes del sistema" | No roban el foco |

## 7. Criterios de aceptación

1. Espacio inicia o pausa desde cualquier control salvo un campo de texto.
2. La cifra no se desplaza al cambiar los dígitos (cifras tabulares).
3. Todo control con solo icono tiene nombre accesible y descripción emergente.
4. Con el doble del tamaño de letra del sistema la ventana mínima no recorta texto.
5. La fase se identifica sin color: texto "Enfoque", "Descanso" o "Descanso largo" siempre visible.
6. Cerrar la ventana no detiene el temporizador; Salir sí, y guarda el estado.
7. Con "Reducir movimiento" activo no hay animaciones, salvo el avance del anillo cada segundo.
8. Los atajos de `textos.md` funcionan en las tres plataformas con Cmd en macOS.
