#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';

const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const DEFAULT_WEB_ROOT = path.resolve(ROOT, '..', 'botero-app-reference');

const args = process.argv.slice(2);
const webRootFlagIndex = args.indexOf('--web-root');
const webRoot = webRootFlagIndex >= 0 && args[webRootFlagIndex + 1]
  ? path.resolve(args[webRootFlagIndex + 1])
  : DEFAULT_WEB_ROOT;

const appPath = path.join(webRoot, 'src', 'App.jsx');
const outDir = path.join(ROOT, 'Sources', 'BoteroCore', 'Resources');

function extractLiteral(source, declarationPrefix) {
  const idx = source.indexOf(declarationPrefix);
  if (idx < 0) throw new Error(`No se encontro: ${declarationPrefix}`);

  let start = -1;
  for (let i = idx + declarationPrefix.length; i < source.length; i++) {
    const ch = source[i];
    if (ch === '[' || ch === '{') {
      start = i;
      break;
    }
    if (!/\s|=/.test(ch)) break;
  }
  if (start < 0) throw new Error(`No se encontro literal para ${declarationPrefix}`);

  const open = source[start];
  const close = open === '[' ? ']' : '}';
  let depth = 0;
  let inString = false;
  let stringQ = '';
  let escaped = false;

  for (let i = start; i < source.length; i++) {
    const ch = source[i];
    const prev = source[i - 1];

    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (ch === '\\') {
        escaped = true;
      } else if (ch === stringQ) {
        inString = false;
      }
      continue;
    }

    if (ch === '"' || ch === "'" || ch === '`') {
      inString = true;
      stringQ = ch;
      continue;
    }

    if (ch === '/' && source[i + 1] === '/') {
      while (i < source.length && source[i] !== '\n') i++;
      continue;
    }
    if (ch === '/' && source[i + 1] === '*') {
      i += 2;
      while (i < source.length && !(source[i] === '*' && source[i + 1] === '/')) i++;
      i++;
      continue;
    }

    if (ch === open) depth++;
    if (ch === close) {
      depth--;
      if (depth === 0) {
        return source.slice(start, i + 1);
      }
    }
  }

  throw new Error(`Literal sin cierre para ${declarationPrefix}`);
}

function evalLiteral(literal) {
  return vm.runInNewContext(`(${literal})`, {}, { timeout: 1000 });
}

function compactArtwork(a, coord) {
  return {
    id: String(a.id),
    wallNumber: String(a.id).padStart(2, '0'),
    titulo: a.titulo,
    año: a.año,
    tecnica: a.tecnica,
    sala: a.sala,
    piso: Number(a.piso),
    desc: a.desc,
    iaRespuesta: a.iaRespuesta,
    coordenadasSala: coord ? { x: Number(coord.x), y: Number(coord.y) } : null,
  };
}

function main() {
  if (!fs.existsSync(appPath)) {
    throw new Error(`No existe App.jsx en: ${appPath}`);
  }
  fs.mkdirSync(outDir, { recursive: true });

  const source = fs.readFileSync(appPath, 'utf8');

  const obrasLiteral = extractLiteral(source, 'const OBRAS');
  const pins1Literal = extractLiteral(source, 'const PINS_P1');
  const pins2Literal = extractLiteral(source, 'const PINS_P2');

  const obras = evalLiteral(obrasLiteral);
  const pins1 = evalLiteral(pins1Literal);
  const pins2 = evalLiteral(pins2Literal);
  const pins = [...pins1, ...pins2];

  const coordById = new Map(pins.map((p) => [String(p.id), p]));

  const artworks = obras.map((a) => compactArtwork(a, coordById.get(String(a.id))));

  const edges = [
    { from: '01', to: '02' },
    { from: '02', to: '07' },
    { from: '03', to: '04' },
    { from: '03', to: '07' },
    { from: '04', to: '07' },
    { from: '04', to: '08' },
    { from: '05', to: '06' },
    { from: '05', to: '08' },
    { from: '06', to: '08' },
    { from: '07', to: '08' },
    { from: '07', to: '09' },
    { from: '09', to: '10' },
    { from: '10', to: '11' },
    { from: '11', to: '12' },
    { from: '12', to: '13' },
    { from: '13', to: '14' },
    { from: '14', to: '15' },
    { from: '15', to: '16' },
  ];

  const routeGraph = {
    map: {
      width: 340,
      height: 280,
      metersPerUnit: 0.11,
      defaultStartNodeId: '07',
    },
    nodes: pins.map((p) => ({
      id: String(p.id),
      artworkId: String(p.id),
      x: Number(p.x),
      y: Number(p.y),
    })),
    edges,
  };

  const unified = {
    version: 1,
    generatedAt: new Date().toISOString(),
    source: {
      webRoot,
      appPath,
    },
    obras: artworks,
    routeGraph,
  };

  const catalog = {
    version: unified.version,
    obras: artworks.map(({ coordenadasSala, ...rest }) => rest),
  };

  fs.writeFileSync(path.join(outDir, 'museum_unified_data.json'), JSON.stringify(unified, null, 2) + '\n');
  fs.writeFileSync(path.join(outDir, 'museum_catalog.json'), JSON.stringify(catalog, null, 2) + '\n');
  fs.writeFileSync(path.join(outDir, 'museum_route_graph.json'), JSON.stringify(routeGraph, null, 2) + '\n');

  console.log(`[sync_from_web] OK`);
  console.log(`- Source: ${appPath}`);
  console.log(`- Artworks: ${artworks.length}`);
  console.log(`- Nodes: ${routeGraph.nodes.length}`);
  console.log(`- Outputs:`);
  console.log(`  - ${path.join(outDir, 'museum_unified_data.json')}`);
  console.log(`  - ${path.join(outDir, 'museum_catalog.json')}`);
  console.log(`  - ${path.join(outDir, 'museum_route_graph.json')}`);
}

try {
  main();
} catch (err) {
  console.error('[sync_from_web] ERROR:', err.message);
  process.exit(1);
}
