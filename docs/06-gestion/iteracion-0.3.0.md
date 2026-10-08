---
lang: es-CO
título: Foco - Iteración 0.3.0
versión: 1.0.0
---

# Foco - Iteración 0.3.0

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-08 | Andrés García | Alcance, tiempos reales, error de planeación, pruebas, puesta en marcha y lecciones |

## 1. Inicio: alcance

Pedido del usuario a las 10:58 (hora de Colombia), ampliado a las 11:11:

- Commits según buenas prácticas.
- Proyecto de código abierto en GitHub.
- Paquete `.deb` para las distintas versiones de Debian, con lanzador en los menús de los
  escritorios de Linux.
- Compatibilidad con Windows probada en el equipo ASUS.
- Compilado y listo para macOS (pedido de las 11:11).

Decisiones tomadas al inicio, tras revisar el equipo ASUS (sin Rust ni Qt, 17,5 GB libres) y el Qt
de cada distribución (Debian 12 y Ubuntu 24.04 con 6.4, Debian 13 con 6.8, Ubuntu 26.04 con 6.10):

- Compilar en GitHub Actions y no en el equipo de desarrollo ni en el ASUS: un `.deb` por
  distribución, compilado con su propio Qt, más Windows y macOS en máquinas de GitHub.
- En el ASUS solo instalar y probar el instalador resultante.
- Publicar una versión solo si compilan y arrancan todos los paquetes.

## 2. Planeación: estimado frente a real

No se registró un estimado antes de empezar. Fue un error de proceso: la lección de la iteración
0.2.0 pedía estimar cada fase como trabajo más esperas medidas, y no se aplicó. Por eso solo hay
tiempo real, tomado del registro de la sesión.

| Fase | Inicio | Fin | Real (min) |
| --- | --- | --- | --- |
| Inicio, planeación, requisitos y diseño | 10:58 | 11:06 | 7,7 |
| Construcción | 11:06 | 11:13 | 6,9 |
| Integración y pruebas | 11:13 | 11:55 | 42,4 |
| Entrega y cierre | 11:55 | 11:57 | 1,5 |
| Total | 10:58 | 11:57 | 58,5 |

Error de planeación: se supuso que una sola ejecución del flujo de publicación bastaría. Hicieron
falta cuatro, de 7 a 12 minutos cada una, porque cada plataforma reveló un fallo que solo aparece
al compilar o al arrancar en ella. Integración y pruebas tomó el 72 % del tiempo.

## 3. Construcción

- `scripts/empaquetar-deb.sh`: el `.deb` con dependencias calculadas por `dpkg-shlibdeps`,
  lanzador freedesktop, iconos SVG y PNG y metadatos AppStream.
- `scripts/probar-deb.sh`: instala el paquete con apt en un sistema limpio y arranca Foco sin
  pantalla.
- `packaging/windows/foco.iss`: instalador con menú Inicio y desinstalador.
- `packaging/macos/Info.plist` e icono: `Foco.app` dentro de un `.dmg`.
- `.github/workflows/release.yml`: compila, prueba y publica.

## 4. Integración y pruebas

| Ronda | Fallo encontrado | Corrección |
| --- | --- | --- |
| 1 | Windows: aqtinstall no encuentra Qt 6.12.0 | Qt 6.10.3 en Windows |
| 2 | Windows: no enlaza Qt Gui; Qt 6.4: módulo `Foco` y `Settings` no encontrados | Qt Gui explícito; ruta `qrc:/qt/qml` y `Qt.labs.settings` |
| 3 | Qt 6.4: `preferredRendererType` y `font.features` son de Qt 6.6 | `SmoothShape` y `Digits` los activan solo si existen |
| 4 | Prueba sin pantalla sin complemento `offscreen`; acción de Qt fijada por commit | Complemento tomado del Qt de compilación; acción por etiqueta |

| Verificación | Resultado |
| --- | --- |
| Flujo de publicación v0.3.0 | 13 de 13 trabajos correctos |
| `.deb` en Debian 12 y 13, Ubuntu 24.04 y 26.04 | Instalación con apt, lanzador, icono y arranque sin errores de QML |
| Interfaz en Qt 6.4 | 17 de 17 pantallas del prototipo cargan sin errores |
| ASUS con Windows 11 | Instalación, menú Inicio, arranque, temporizador y recuperación tras una caída provocada |
| macOS arm64 e Intel | Arranque sin pantalla en máquinas de GitHub; sin prueba en un Mac real |

## 5. Entrega: puesta en marcha

Versión publicada: <https://github.com/andresgarcia0313/foco-pomodoro/releases/tag/v0.3.0>.
Queda instalada en el ASUS. En el equipo de desarrollo sigue la 0.2.0 abierta, para no cortar el
enfoque en curso.

## 6. Lecciones aprendidas

- Estimar antes de empezar, aunque sea en una línea; sin estimado no hay error que medir.
- Contar como espera cada ronda de integración continua (unos 10 minutos) y suponer al menos dos
  rondas por plataforma nueva.
- Probar primero la versión de Qt más antigua que se quiere soportar: ahí aparecieron cuatro de
  los ocho fallos.
