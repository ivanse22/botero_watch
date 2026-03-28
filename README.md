# Botero WatchOS Mockup

Mockup funcional para Apple Watch de la experiencia de visita del Museo Botero, adaptado desde la propuesta original web.

## Objetivo del proyecto

Construir un prototipo ejecutable en watchOS que permita completar una **tarea continua de visitante** en dos etapas:

1. **Llegar a una obra** (navegación guiada con desvío y recalcular).
2. **Consultar la obra por número de pared** para ver su ficha.

> Nota: "Flow 01" y "Flow 02" son nombres técnicos de UX; para el visitante se diseñó como un solo recorrido.

## Caso de estudio (resumen)

### Problema

La experiencia web original tenía mayor espacio visual y componentes ricos; en reloj se requiere:

- Pantallas pequeñas.
- Interacciones rápidas.
- Estados muy claros.
- Estrategia honesta para indoor positioning (cuando no hay calibración completa).

### Enfoque

- Reimplementación nativa con **SwiftUI**.
- Núcleo de lógica separado en `BoteroCore`.
- UI separada en `BoteroWatchUI`.
- Datos sincronizables desde la fuente web mediante script.

### Resultado

- Prototipo interactivo para simulador/dispositivo.
- Flujos extremos completables.
- Diseño visual alineado a tokens del proyecto web (paleta, jerarquía, tono editorial).

## Qué se implementó

### 1) Lógica de experiencia

- Máquina de estados de navegación (`Flow01Engine`).
- Umbrales de decisión:
  - Desvío: `> 3m`.
  - Llegada: `< 1.5m`.
- Señales hápticas en momentos clave (inicio de ruta, desvío, recalcular, llegada).

### 2) Datos

- Catálogo de obras con `wallNumber`.
- Grafo de ruta con nodos/aristas para planificar trayectos.
- Recurso unificado para trazabilidad de datos.

Archivos clave:

- `Sources/BoteroCore/Resources/museum_catalog.json`
- `Sources/BoteroCore/Resources/museum_route_graph.json`
- `Sources/BoteroCore/Resources/museum_unified_data.json`

### 3) Pipeline web -> watch

Script para regenerar datos desde `src/App.jsx` del proyecto web fuente.

```bash
node scripts/sync_from_web.mjs
```

Documentación: `DATA_PIPELINE.md`.

### 4) UI watchOS

- Pantallas compactas orientadas a una sola acción.
- Tipografía legible y contraste alto para lectura rápida.
- Componentes consistentes (`BoteroTheme`, `boteroCard`).
- Mensajes explícitos cuando la navegación es simulada.

## Flujos de usuario

## Etapa A (Flow 01 técnico): llegar a la obra

1. Menú de rutas.
2. Selección de método (manual / voz simulada).
3. Cálculo de ruta.
4. Guía direccional.
5. Si hay desvío -> alerta + recalcular.
6. Llegada confirmada.

## Etapa B (Flow 02 técnico): consultar número de pared

1. Entrada numérica (`wallNumber`).
2. Búsqueda local.
3. Resultado:
   - Válido -> ficha de obra.
   - Inválido -> error + reintento.

## Consideraciones UX/UI aplicadas

- El visitante **no elige "flow"**, sigue un recorrido continuo.
- Copy breve y directo en cada estado.
- Errores con salida clara (reintentar, limpiar, volver).
- Colores semánticos:
  - Primario: acciones principales.
  - Verde: llegada/éxito.
  - Naranja: advertencias/fallback.
- Consistencia de estilo basada en la propuesta visual web.

## Qué está simulado y qué es real

### Real

- Navegación por estados y decisiones de flujo.
- Cálculo de ruta sobre grafo local.
- Lookup de obra por número de pared.
- Estados de desvío, recalcular, llegada, error y reintento.

### Simulado (mockup honesto)

- Parte del posicionamiento indoor (cuando GPS/calibración real no está disponible).
- Voz de entrada como modo de prueba (simulación de reconocimiento).

## Arquitectura

- `BoteroCore`:
  - Estados/eventos de Flow 01.
  - Modelos de datos.
  - Route planner (grafo + geometría).
- `BoteroWatchUI`:
  - Vistas SwiftUI de ambos recorridos.
  - ViewModels y fallback de posicionamiento.
- `XcodeIntegration`:
  - App shell para ejecutar en watchOS.

## Cómo ejecutar el mockup

1. Crear proyecto `watchOS App` en Xcode.
2. Añadir este repo como paquete local.
3. Enlazar productos:
   - `BoteroCore`
   - `BoteroWatchUI`
4. Usar `XcodeIntegration/BoteroMuseumWatchApp.swift` como entrypoint.
5. Run en simulador Apple Watch.

Guías:

- `XcodeIntegration/OPEN_AND_RUN_ES.md`
- `PROTOTYPE_RUNBOOK.md`

## Pruebas

Ejecutar:

```bash
swift test
```

Incluye pruebas para:

- Máquina de estados de Flow 01.
- Route planner.
- Resolución por número de pared.

## Estado actual

- Mockup funcional para demo y validación UX.
- Base lista para evolucionar a posicionamiento indoor más preciso.
- Pendiente para producción final: calibración indoor real + cierre de app de distribución.
