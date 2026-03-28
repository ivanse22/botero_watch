# Data Pipeline (web -> watchOS resources)

## Goal

Generate a single source JSON schema and derived watchOS resources from the web project data (`botero-app-reference/src/App.jsx`).

## Command

From `BoteroMuseum/` run:

```bash
node scripts/sync_from_web.mjs
```

Optional custom source root:

```bash
node scripts/sync_from_web.mjs --web-root /absolute/path/to/web/repo
```

## Inputs

- `src/App.jsx` from web repo:
  - `const OBRAS = [...]`
  - `const PINS_P1 = [...]`
  - `const PINS_P2 = [...]`

## Outputs

Generated in `Sources/BoteroCore/Resources/`:

- `museum_unified_data.json` (single schema with artworks + wallNumber + sala coordinates + route nodes/edges)
- `museum_catalog.json` (derived catalog used by app)
- `museum_route_graph.json` (derived route graph used by SYS01)

## Notes

- Route edges are maintained in pipeline script (`scripts/sync_from_web.mjs`) to keep route behavior deterministic.
- Coordinates and artworks are refreshed from web source on each run.
