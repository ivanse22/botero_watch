# Botero Watch Prototype Runbook

## Goal

Run the interactive watchOS mockup in Xcode and validate end-to-end completion of Flow 01 and Flow 02.

## Setup in Xcode

- Open Xcode and create a new project: `watchOS > App`.
- Add local package dependency pointing to `BoteroMuseum`.
- Link products `BoteroCore` and `BoteroWatchUI` to the Watch App target.
- Add `XcodeIntegration/BoteroMuseumWatchApp.swift` to the Watch App target (replace default app file).
- In the Watch App target Info settings, include location usage description if required by your template.

## Run

- Select an Apple Watch Simulator device.
- Build and Run.
- The app opens with two tabs:
  - `Rutas` (Flow 01)
  - `Numero` (Flow 02)

## Demo Script

### Flow 01 (Route)

- Tap `Rutas`.
- Select input mode (manual list or voice simulation).
- Pick an artwork and wait for route calculation.
- In guidance screen:
  - Use `Desvio` button to force deviation branch.
  - Use `Llegada` button to force arrival branch.
- Continue to `Listo para consultar`.

### Flow 02 (Wall Number)

- Go to `Numero` tab.
- Enter valid number (example: `01`) and tap `OK` to see artwork sheet.
- Try invalid number (example: `99`) to validate retry flow.

## Notes

- `GPS` mode is available in Flow 01, but if indoor calibration is not configured the app falls back to simulation.
- Route graph and catalog are loaded from package resources:
  - `Sources/BoteroCore/Resources/museum_route_graph.json`
  - `Sources/BoteroCore/Resources/museum_catalog.json`
