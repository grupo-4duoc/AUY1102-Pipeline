const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('=== EVALUACION PARCIAL 2: PRUEBAS Y COBERTURA ===\n');
console.log('Ejecutando pruebas unitarias con Jest...\n');

try {
  // Ejecuta jest generando cobertura
  execSync('npx jest --coverage --colors=false', {
    stdio: 'inherit',
    cwd: path.resolve(__dirname, '..'),
  });
} catch (error) {
  console.log('\n[!] Hubo pruebas que fallaron durante la ejecucion.');
}

// Leer archivo de cobertura generado por Jest
const coveragePath = path.resolve(__dirname, '../coverage/coverage-final.json');

if (fs.existsSync(coveragePath)) {
  const coverage = JSON.parse(fs.readFileSync(coveragePath, 'utf8'));

  console.log('\n=============================================================================');
  console.log('                 RESUMEN DE COBERTURA Y LINEAS SIN PRUEBAS                  ');
  console.log('=============================================================================');
  console.log('Archivo'.padEnd(45) + '| Cobertura'.padEnd(15) + '| Lineas sin cobertura');
  console.log('-'.repeat(77));

  let totalStmts = 0;
  let coveredStmts = 0;
  const sinCobertura = [];

  for (const file of Object.keys(coverage)) {
    const data = coverage[file];
    const relPath = path.relative(path.resolve(__dirname, '..'), file).replace(/\\/g, '/');

    const stmts = Object.values(data.s);
    const total = stmts.length;
    const covered = stmts.filter((v) => v > 0).length;

    totalStmts += total;
    coveredStmts += covered;

    const pct = total > 0 ? ((covered / total) * 100).toFixed(1) : '100.0';

    // Obtener lineas no cubiertas
    const uncovLines = [];
    for (const key of Object.keys(data.statementMap || {})) {
      if (data.s[key] === 0) {
        const line = data.statementMap[key].start.line;
        if (!uncovLines.includes(line)) uncovLines.push(line);
      }
    }
    uncovLines.sort((a, b) => a - b);

    const lineasStr = uncovLines.length > 0 ? uncovLines.join(', ') : 'Ninguna (100%)';
    console.log(relPath.padEnd(45) + `| ${pct}%`.padEnd(15) + `| ${lineasStr}`);

    if (uncovLines.length > 0) {
      sinCobertura.push({ file: relPath, pct, lineasStr });
    }
  }

  const globalPct = totalStmts > 0 ? ((coveredStmts / totalStmts) * 100).toFixed(1) : '0';
  console.log('-'.repeat(77));
  console.log(`TOTAL PROYECTO: ${globalPct}% de cobertura global\n`);

  if (sinCobertura.length > 0) {
    console.log('Componentes que faltan por cubrir con pruebas unitarias:');
    sinCobertura.forEach((c) => {
      console.log(` - ${c.file}: falta probar las lineas ${c.lineasStr} (cobertura actual: ${c.pct}%)`);
    });
  } else {
    console.log('Todos los archivos estan cubiertos con pruebas.');
  }
} else {
  console.log('No se genero el archivo de cobertura en coverage/coverage-final.json');
}

console.log('\n=== FIN DEL REPORTE ===');
