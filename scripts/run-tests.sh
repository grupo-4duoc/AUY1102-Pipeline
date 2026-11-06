#!/usr/bin/env bash
# =============================================================================
# run-tests.sh
# Ejecuta las pruebas unitarias con Jest y muestra:
#   1. El porcentaje de cobertura (global y por archivo)
#   2. Las pruebas que fallan (con su mensaje de error)
#   3. Las partes del código que NO están cubiertas por pruebas
#
# Uso:  npm run test:coverage      (o)      bash scripts/run-tests.sh
# Salida: código 0 si todas las pruebas pasan, 1 si alguna falla.
# =============================================================================

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

COVERAGE_DIR="coverage"
RESULTS_FILE="$COVERAGE_DIR/test-results.json"
SUMMARY_FILE="$COVERAGE_DIR/coverage-summary.json"
FINAL_FILE="$COVERAGE_DIR/coverage-final.json"

# Colores (solo si la terminal los soporta)
if [ -t 1 ]; then
  BOLD="\033[1m"; CYAN="\033[36m"; RESET="\033[0m"
else
  BOLD=""; CYAN=""; RESET=""
fi

title() { printf "\n${BOLD}${CYAN}==================== %s ====================${RESET}\n" "$1"; }

rm -rf "$COVERAGE_DIR"
mkdir -p "$COVERAGE_DIR"

# -----------------------------------------------------------------------------
# 1) Ejecutar Jest con cobertura
#    json-summary -> % global y por archivo, usado en el resumen final
#    json         -> detalle por línea/función/rama, usado para "código no cubierto"
#    lcov         -> coverage/lcov.info, lo consume SonarCloud
# -----------------------------------------------------------------------------
title "1. EJECUTANDO PRUEBAS UNITARIAS + COBERTURA"

npx jest \
  --coverage \
  --coverageReporters=json-summary \
  --coverageReporters=json \
  --coverageReporters=lcov \
  --json --outputFile="$RESULTS_FILE"
JEST_EXIT=$?

if [ ! -f "$RESULTS_FILE" ]; then
  echo "ERROR: Jest no generó $RESULTS_FILE (¿error de configuración?)."
  exit 1
fi

# -----------------------------------------------------------------------------
# 2) y 3) Resumen legible usando Node (ya está instalado porque usamos npm)
# -----------------------------------------------------------------------------
RESULTS_FILE="$RESULTS_FILE" SUMMARY_FILE="$SUMMARY_FILE" FINAL_FILE="$FINAL_FILE" \
ROOT_DIR="$ROOT_DIR" node <<'NODE'
const fs = require('fs');
const path = require('path');

const results = JSON.parse(fs.readFileSync(process.env.RESULTS_FILE, 'utf8'));
const summary = fs.existsSync(process.env.SUMMARY_FILE)
  ? JSON.parse(fs.readFileSync(process.env.SUMMARY_FILE, 'utf8')) : null;
const final = fs.existsSync(process.env.FINAL_FILE)
  ? JSON.parse(fs.readFileSync(process.env.FINAL_FILE, 'utf8')) : {};
const rel = (p) => path.relative(process.env.ROOT_DIR, p).split(path.sep).join('/');
const title = (t) => console.log(`\n==================== ${t} ====================`);

// ---------- Pruebas que fallan ----------
title('2. PRUEBAS QUE FALLAN');
console.log(`Suites : ${results.numPassedTestSuites} OK / ${results.numFailedTestSuites} con fallos / ${results.numTotalTestSuites} total`);
console.log(`Pruebas: ${results.numPassedTests} OK / ${results.numFailedTests} fallidas / ${results.numTotalTests} total`);

let failures = 0;
for (const suite of results.testResults) {
  const failed = suite.assertionResults.filter((a) => a.status === 'failed');
  // Suite que ni siquiera compila / carga
  if (suite.status === 'failed' && failed.length === 0) {
    failures++;
    console.log(`\n✖ ${rel(suite.name)} (la suite no se pudo ejecutar)`);
    console.log('   ' + (suite.message || '').split('\n').slice(0, 8).join('\n   '));
  }
  for (const a of failed) {
    failures++;
    console.log(`\n✖ ${rel(suite.name)}`);
    console.log(`   Prueba : ${a.fullName}`);
    const msg = (a.failureMessages || []).join('\n').replace(/\u001b\[[0-9;]*m/g, '');
    console.log('   Error  : ' + msg.split('\n').filter(Boolean).slice(0, 6).join('\n            '));
  }
}
if (failures === 0) console.log('\n✔ Todas las pruebas pasaron.');

// ---------- Código no cubierto ----------
title('3. CÓDIGO NO CUBIERTO POR PRUEBAS');

const ranges = (nums) => {
  const out = [];
  nums.sort((a, b) => a - b).forEach((n) => {
    const last = out[out.length - 1];
    if (last && n === last[1] + 1) last[1] = n; else out.push([n, n]);
  });
  return out.map(([a, b]) => (a === b ? `${a}` : `${a}-${b}`)).join(', ');
};

let uncoveredFiles = 0;
for (const file of Object.keys(final).sort()) {
  const f = final[file];
  const lines = new Set();
  for (const [id, hits] of Object.entries(f.s)) if (hits === 0) lines.add(f.statementMap[id].start.line);
  const fns = Object.entries(f.f).filter(([, h]) => h === 0)
    .map(([id]) => `${f.fnMap[id].name || '(anónima)'} (línea ${f.fnMap[id].loc.start.line})`);
  let branches = 0;
  for (const hits of Object.values(f.b)) branches += hits.filter((h) => h === 0).length;

  if (lines.size === 0 && fns.length === 0 && branches === 0) continue;
  uncoveredFiles++;
  console.log(`\n• ${rel(file)}`);
  if (lines.size) console.log(`    Líneas sin cubrir   : ${ranges([...lines])}`);
  if (fns.length) console.log(`    Funciones sin probar: ${fns.join(', ')}`);
  if (branches) console.log(`    Ramas (if/else) sin cubrir: ${branches}`);
}
if (uncoveredFiles === 0) console.log('\n✔ Todo el código analizado está cubierto.');

// ---------- Resumen ----------
title('RESUMEN DE COBERTURA');
if (summary) {
  const pct = (v) => `${v.pct}%`.padStart(8);
  console.log(`  ${'Archivo'.padEnd(50)}${'% Sent.'.padStart(8)}${'% Ramas'.padStart(8)}${'% Func.'.padStart(8)}${'% Lín.'.padStart(8)}`);
  console.log('  ' + '-'.repeat(82));
  for (const file of Object.keys(summary).filter((k) => k !== 'total').sort()) {
    const s = summary[file];
    console.log(`  ${rel(file).padEnd(50)}${pct(s.statements)}${pct(s.branches)}${pct(s.functions)}${pct(s.lines)}`);
  }
  console.log('  ' + '-'.repeat(82));
  console.log('  TOTAL');
  const t = summary.total;
  const row = (k, n) => console.log(`  ${n.padEnd(12)}: ${String(t[k].pct).padStart(6)} %  (${t[k].covered}/${t[k].total})`);
  row('statements', 'Sentencias');
  row('branches', 'Ramas');
  row('functions', 'Funciones');
  row('lines', 'Líneas');
}
console.log('\n  Reporte HTML : coverage/lcov-report/index.html');
console.log('  Reporte LCOV : coverage/lcov.info (para SonarCloud)');
console.log(`  Resultado    : ${results.success ? 'ÉXITO ✔' : 'CON FALLOS ✖'}`);
NODE

exit $JEST_EXIT
