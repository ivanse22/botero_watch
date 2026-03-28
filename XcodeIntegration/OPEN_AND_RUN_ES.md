# Abrir y correr en Xcode (paso a paso)

## 1) Crear proyecto Watch App

- Abrir Xcode
- `File > New > Project...`
- Elegir `watchOS > App`
- Nombre sugerido: `BoteroWatchDemo`

## 2) Conectar este paquete local

- En el proyecto nuevo: `File > Add Package Dependencies...`
- Elegir `Add Local...`
- Seleccionar carpeta: `BoteroMuseum`
- En el target de Watch App, enlazar productos:
  - `BoteroCore`
  - `BoteroWatchUI`

## 3) Usar el entrypoint listo

- En el target Watch App, reemplazar el archivo principal por:
  - `XcodeIntegration/BoteroMuseumWatchApp.swift`

## 4) Ejecutar

- Seleccionar simulador Apple Watch
- Click en **Run**

La app abre dos pestañas:

- `Rutas` (Flow 01)
- `Número` (Flow 02)

## 5) Validación rápida de demo

- Flow 01: entrar por `Rutas`, elegir obra, usar botones `Desvío` y `Llegada`.
- Flow 02: ir a `Número`, probar `01` (válido) y `99` (inválido).
