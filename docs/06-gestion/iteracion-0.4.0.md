---
lang: es-CO
título: Foco - Iteración 0.4.0
versión: 0.1.0
---

# Foco - Iteración 0.4.0

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 0.1.0 | 2026-10-16 | Andrés García | Alcance y estimado registrados antes de construir |

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

Estimado registrado a las 19:30, antes de construir, como trabajo más esperas medidas (lección de
las iteraciones 0.2.0 y 0.3.0). No hay ejecuciones de integración continua: no se publica
versión sin autorización.

| Fase | Estimado (min) | Real (min) | Desviación |
| --- | --- | --- | --- |
| Inicio, investigación y planeación | 15 | | |
| Requisitos y diseño | 10 | | |
| Construcción | 40 | | |
| Integración y pruebas (3 compilaciones de 2 min, galería, Qt 6.4, prueba real) | 30 | | |
| Skills del proyecto y skill global | 35 | | |
| Entrega y cierre | 15 | | |
| Total | 145 | | |

Riesgos: la pantalla completa encima de todo en KDE Wayland (Qt no puede subir su ventana sola),
varios monitores, y que la pantalla aparezca mientras se escribe y capture el teclado.
