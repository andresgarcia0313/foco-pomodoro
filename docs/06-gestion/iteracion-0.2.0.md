---
lang: es-CO
título: Foco - Iteración 0.2.0
versión: 1.0.0
---

# Foco - Iteración 0.2.0

## Control de cambios

| Versión | Fecha | Autor | Descripción del cambio |
| --- | --- | --- | --- |
| 1.0.0 | 2026-10-08 | Andrés García | Alcance, plan, estimado frente a real, pruebas, puesta en marcha y lecciones |

## 1. Inicio: alcance

Pedido del usuario mientras usaba la aplicación:

- Si se bloquea, recuperarse sola y seguir donde iba (RNF-08, RF-13).
- Al reabrir, el mismo tiempo, fase, estado y modo de ventana (RF-13).
- Añadir o quitar un minuto (RF-16).
- Corregir "Siempre encima" y el modo mini que convivía con la ventana completa.
- Registro de uso para guiar la interfaz, con tope de 10 MB (RF-17).
- Poca memoria, poco código y la documentación mínima útil.

Causa del bloqueo que originó la iteración: la aplicación, abierta desde una terminal, quedó en
un grupo de procesos que el control de carga del equipo congela; estuvo 4 horas detenida y al
volver habría terminado la fase de golpe.

## 2. Planeación: estimado frente a real

| Fase | Estimado (min) | Real (min) | Desviación |
| --- | --- | --- | --- |
| Inicio y planeación | 15 | 2,3 | -85 % |
| Requisitos y diseño | 15 | 2,0 | -87 % |
| Construcción | 60 | 6,6 | -89 % |
| Integración y pruebas | 25 | 16,5 | -34 % |
| Entrega y cierre | 15 | 2,3 | -85 % |
| Total | 130 | 29,7 | -77 % |

Error de estimación: se estimó con ritmo de escritura humano, cuando el costo real lo marcan las
esperas de máquina. La compilación optimizada tomó 10,5 de los 16,5 minutos de pruebas y la
prueba de cuelgue exige esperar 45 s. Para la próxima: estimar cada fase como trabajo más esperas
medidas (compilación limpia de unos 10 min, incremental de unos 60 s y pruebas con temporizador).

Riesgos atendidos: perder la sesión en uso al desplegar (se leyó el estado en vivo), romper
archivos viejos (campos nuevos con valor por defecto) y gastar memoria (sonido bajo demanda).

## 3. Requisitos y diseño

Requisitos actualizados en `docs/01-analisis/requisitos.md` (RF-13, RF-16, RF-17 y RNF-08) y
decisiones DA-10 a DA-13 en `docs/02-diseno/arquitectura.md`:

- Supervisor: el mismo binario se lanza como hijo y lo reinicia si cae o deja de latir 45 s.
- Guardián: más de 10 s sin pulsos es un congelamiento y no cuenta como tiempo de la fase.
- Guardado de la fase en cada acción y cada 15 s mientras corre.
- Siempre visible en KDE Wayland mediante un guion de KWin, porque Wayland ignora la indicación
  de Qt.

## 4. Construcción y pruebas

| Verificación | Resultado |
| --- | --- |
| Pruebas del núcleo (`cargo test --workspace`) | 29 de 29 correctas, 6 nuevas |
| Clippy con avisos como errores y formato | Sin avisos |
| Reanudar una sesión corriendo de 9:00 | Sigue corriendo; 8:56 tras 4 s |
| Caída provocada (señal de aborto) | Reinicio en menos de 5 s, contado como `crash_restart` |
| Cuelgue provocado (proceso detenido) | Reinicio a los 43 s |
| Cierre del sistema o del usuario | Se respeta, sin reinicio |
| Siempre visible en Plasma 6.6 Wayland | KWin informa `keepAbove=true` en la ventana mini |
| Memoria proporcional en silencio | 87 MB la interfaz y 9 MB el supervisor; 110 MB con el sonido cargado |

## 5. Entrega: puesta en marcha

Binario optimizado instalado con `scripts/instalar-linux.sh target/fast/foco`, abierto en el
grupo de aplicaciones de escritorio. La fase en uso se trasladó a la versión nueva; la lectura en
vivo de la bandeja falló y el tiempo se reconstruyó desde el último guardado (enfoque iniciado a
las 09:33:06), con margen de unos segundos ajustable con los botones nuevos. Desde esta versión
la fase corriendo se guarda sola, así que las próximas actualizaciones no necesitan ese traslado.

## 6. Lecciones aprendidas

- Una aplicación con ventana nunca se abre desde una sesión de terminal sin pasarla al grupo de
  aplicaciones; si no, el control de carga la congela.
- `kill -SEGV` no prueba una caída en Rust: su manejador lo absorbe; usar la señal de aborto.
- Cada iteración revisa `uso.json` (carpeta de configuración de Foco) y prioriza la interfaz por
  las funciones más y menos usadas.
