# Evaluación Parcial N° 2 – AUY1102 Ciclo de Vida del Software I

**Desarrollo de Pruebas Unitarias y Análisis de Seguridad II**

| Dato | Valor |
|---|---|
| Organización GitHub | `grupo-4duoc` |
| Repositorio | https://github.com/grupo-4duoc/AUY1102-Pipeline |
| Rama de trabajo | `feature/parcial2-simon` |
| Integrantes | Simón Lagos · [COMPLETAR nombre pareja] |
| Fecha | [COMPLETAR] |

> **Cómo usar este documento:** cada `📸 CAPTURA` indica dónde pegar un pantallazo.
> En Markdown se insertan así: `![Descripción](img/nombre-captura.png)` (guardar las imágenes en la carpeta `img/`).

---

## Índice

1. [Contexto](#1-contexto)
2. [Preparación del entorno](#2-preparación-del-entorno)
3. [Parte 1 – Pruebas unitarias y cobertura](#3-parte-1--pruebas-unitarias-y-cobertura)
4. [Parte 2 – Análisis de seguridad y código estático](#4-parte-2--análisis-de-seguridad-y-código-estático)
   - 4.1 [npm audit](#41-npm-audit)
   - 4.2 [SonarCloud](#42-sonarcloud)
   - 4.3 [Snyk](#43-snyk)
   - 4.4 [GitHub Advanced Security](#44-github-advanced-security)
   - 4.5 [Remediación](#45-remediación)
5. [Hallazgos de seguridad detectados manualmente](#5-hallazgos-de-seguridad-detectados-manualmente)
6. [Conclusiones](#6-conclusiones)

---

## 1. Contexto

La empresa *Integration Solutions* busca automatizar su ciclo de desarrollo migrando a GitHub e
incorporando revisiones de **calidad** (pruebas unitarias, cobertura, análisis estático) y de
**seguridad** (vulnerabilidades en dependencias, código inseguro y secretos expuestos).

El proyecto es una librería **TypeScript** de *Value Objects* (`StringValueObject`,
`NumberValueObject`, `DateValueObject`, `EnumValueObject`) probada con **Jest**. La carpeta
`src/quality/` contiene código inseguro intencional que sirve para validar las herramientas
de análisis.

**¿Por qué importa en el ciclo de vida?** Mientras antes se detecta un error o una vulnerabilidad
(*shift-left*), más barato es corregirlo: un bug detectado por una prueba unitaria en el PR cuesta
minutos, mientras que el mismo bug en producción puede costar días e incidentes de seguridad.

---

## 2. Preparación del entorno

### 2.1 Verificación de herramientas

```powershell
git --version     # git version 2.54.0.windows.1
node --version    # (no instalado inicialmente)
npm --version     # (no instalado inicialmente)
```

Node.js no estaba instalado, así que se instaló la versión LTS con el gestor de paquetes de Windows:

```powershell
winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
node --version    # v26.13.0
npm --version     # 11.20.0
```

📸 **CAPTURA 1:** terminal mostrando `git --version`, `node --version` y `npm --version`.

### 2.2 Fork / repositorio y rama de trabajo

1. El repositorio base indicado por el docente se replicó en la organización `grupo-4duoc`.
2. Se clonó localmente y se creó una rama propia (trabajo en pareja: **no se trabaja sobre `master`**):

```bash
git clone https://github.com/grupo-4duoc/AUY1102-Pipeline.git
cd AUY1102-Pipeline
git pull origin master
git checkout -b feature/parcial2-simon
```

📸 **CAPTURA 2:** repositorio en GitHub dentro de la organización `grupo-4duoc`.

📸 **CAPTURA 3:** `git branch` mostrando la rama `feature/parcial2-simon` activa.

### 2.3 Instalación de dependencias

```bash
npm install
```

Resultado: se instalaron **1599 paquetes** y npm advirtió **82 vulnerabilidades** (analizadas en la sección 4.1).

> **Nota Windows:** en este equipo el comando `bash` apuntaba a WSL. Para que `npm run` ejecute
> scripts `.sh` con Git Bash se configuró (solo a nivel de usuario, no afecta el repo):
> ```powershell
> npm config set script-shell "C:\Program Files\Git\bin\bash.exe" --location=user
> ```

---

## 3. Parte 1 – Pruebas unitarias y cobertura

### 3.1 Conceptos

- **Prueba unitaria:** verifica una unidad pequeña de código (una función o un método) de forma aislada.
- **Cobertura de código:** porcentaje del código que se ejecuta durante las pruebas. Se mide en:
  - *Sentencias* (statements), *Líneas*, *Funciones* y *Ramas* (cada camino de un `if/else`).
- Una cobertura baja **no significa que el código falle**, sino que hay partes **sin verificar**,
  donde un cambio futuro podría romper algo sin que nadie lo note (riesgo de regresión).

### 3.2 Script creado: `scripts/run-tests.sh`

Se creó el script [`scripts/run-tests.sh`](scripts/run-tests.sh) y se conectó al comando
`npm run test:coverage` en `package.json`:

```json
"test:coverage": "bash scripts/run-tests.sh"
```

**Qué hace el script:**

| Etapa | Descripción |
|---|---|
| 1. Ejecutar pruebas | Ejecuta `jest --coverage` generando reportes `json`, `json-summary` y `lcov`, y guarda el resultado de cada prueba en `coverage/test-results.json`. |
| 2. Pruebas que fallan | Lee el JSON de resultados y lista cada prueba fallida con su archivo y su mensaje de error. |
| 3. Código no cubierto | Por cada archivo lista las **líneas**, **funciones** y **ramas** que ninguna prueba ejecutó. |
| 4. Resumen | Tabla de % de cobertura por archivo y total. |
| Salida | Código `0` si todo pasa y `1` si alguna prueba falla (útil para CI). |

Además se agregó `coverage` al `.gitignore`, porque los reportes son generados y no deben versionarse.

### 3.3 Ejecución

```bash
npm run test:coverage
```

📸 **CAPTURA 4:** sección "2. PRUEBAS QUE FALLAN" en la terminal.

📸 **CAPTURA 5:** sección "3. CÓDIGO NO CUBIERTO POR PRUEBAS".

📸 **CAPTURA 6:** sección "RESUMEN DE COBERTURA".

📸 **CAPTURA 7 (opcional):** reporte HTML `coverage/lcov-report/index.html` abierto en el navegador.

### 3.4 Resultados

**Pruebas:** 10 suites, **18 pruebas, 18 aprobadas, 0 fallidas**.

**Cobertura por archivo:**

| Archivo | % Sentencias | % Ramas | % Funciones | % Líneas |
|---|---:|---:|---:|---:|
| src/index.ts | 62.5 | 100 | 25 | 62.5 |
| src/quality/errores-object.ts | 0 | 100 | 0 | 0 |
| src/quality/insecure-1-object.ts | 0 | 100 | 100 | 0 |
| src/quality/insecure-2-object.ts | 0 | 100 | 0 | 0 |
| src/value-object/primitives/date-value-object.ts | 6.66 | 0 | 0 | 6.66 |
| src/value-object/primitives/enum-value-object.ts | 83.33 | 0 | 100 | 83.33 |
| src/value-object/primitives/number-value-object.ts | 100 | 100 | 100 | 100 |
| src/value-object/primitives/string-value-object.ts | 100 | 100 | 100 | 100 |
| **TOTAL** | **43.28** | **60** | **56.66** | **43.28** |

**Código no cubierto (principal):**

| Archivo | Líneas sin cubrir | Motivo |
|---|---|---|
| `date-value-object.ts` | 3, 7-9, 13-14, 19, 23-25, 29-30, 34-35 | **No existe ninguna prueba** para `DateValueObject`. |
| `enum-value-object.ts` | 11 | No se prueba el caso de **valor inválido** (rama del `throw`). |
| `src/index.ts` | 8-10 | Callbacks de un `fetch` a una API externa (ver hallazgo 5.1). |
| `src/quality/*.ts` | todas | Código de ejemplo inseguro, sin pruebas. |

**Análisis:** las clases `String` y `Number` están 100% cubiertas. La cobertura total baja por
`DateValueObject` (sin pruebas) y por el código de `src/quality/`. **Mejora recomendada:** crear
`test/value-object/primitives/DateValueObject/*.test.ts` y una prueba del caso inválido de `EnumValueObject`.

> **Observación:** durante la ejecución aparece el aviso *"Cannot log after tests are done"*. Se debe
> a que `src/index.ts` ejecuta `fetchData()` al ser importado (efecto secundario) y llama a
> `api.example.com`. Es un problema de diseño que también afecta a la seguridad (ver 5.1).

---

## 4. Parte 2 – Análisis de seguridad y código estático

### 4.1 npm audit

**Qué es:** comando nativo de npm que compara las dependencias instaladas (directas y transitivas)
con la base de datos de vulnerabilidades conocidas (GitHub Advisory Database / CVE).

**Ejecución y evidencias:**

```bash
npm audit > docs/npm-audit-report.txt               # reporte completo legible
npm audit --json > docs/npm-audit-report.json       # reporte completo JSON
npm audit --omit=dev > docs/npm-audit-prod-report.txt  # solo dependencias de producción
```

Reportes: [`docs/npm-audit-report.txt`](docs/npm-audit-report.txt) ·
[`docs/npm-audit-report.json`](docs/npm-audit-report.json) ·
[`docs/npm-audit-prod-report.txt`](docs/npm-audit-prod-report.txt)

📸 **CAPTURA 8:** salida de `npm audit` (resumen final con el total de vulnerabilidades).

**Resultados:**

| Severidad | Todas las dependencias | Solo producción |
|---|---:|---:|
| Crítica | 2 | 0 |
| Alta | 49 | 5 |
| Moderada | 20 | 3 |
| Baja | 11 | 0 |
| **Total** | **82** | **8** |

**Vulnerabilidades más relevantes:**

| Paquete | Severidad | Tipo | Directa | Corrección |
|---|---|---|---|---|
| `handlebars` | Crítica | Inyección de JavaScript | No (transitiva) | `npm audit fix` |
| `tar` | Crítica | Sobrescritura de archivos (*path traversal*) | No (transitiva) | `npm audit fix` |
| `@faker-js/faker` | Alta | Ejecución arbitraria de código | Sí (dev) | Subir a v10 (*breaking*) |
| `chokidar` → `braces`, `micromatch` | Alta | ReDoS (denegación de servicio) | Sí (**producción**) | Subir a v6 (*breaking*) |
| `lodash` | Alta | Inyección de código / *prototype pollution* | No | `npm audit fix` |
| `cross-spawn`, `minimatch`, `picomatch` | Alta | ReDoS | No | `npm audit fix` |

**Interpretación:**
- 74 de 82 vulnerabilidades están en **herramientas de desarrollo** (semantic-release, eslint, babel).
  No se distribuyen con la librería, pero sí se ejecutan en los equipos de desarrollo y en CI.
- Las **8 de producción** vienen de `chokidar@2` (muy antigua). Para eliminarlas hay que migrar a
  `chokidar@6`, lo que implica un cambio mayor que hay que probar.
- Las 2 críticas se pueden corregir con `npm audit fix` sin cambios incompatibles.

### 4.2 SonarCloud

**Qué es:** plataforma de análisis **estático** de código (SAST) que detecta *bugs*, vulnerabilidades,
*security hotspots*, *code smells*, duplicación y además muestra la cobertura de pruebas.

**Configuración en el repositorio:** se creó [`sonar-project.properties`](sonar-project.properties):

```properties
sonar.organization=grupo-4duoc
sonar.projectKey=grupo-4duoc_AUY1102-Pipeline
sonar.sources=src
sonar.tests=test
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

**Pasos realizados:**

1. Ingresar a https://sonarcloud.io con **"Log in with GitHub"**.
2. **+ → Analyze new project → Import an organization** → seleccionar `grupo-4duoc` e instalar la
   aplicación de SonarCloud en GitHub (dar acceso al repositorio `AUY1102-Pipeline`).
   📸 **CAPTURA 9:** autorización de la app SonarCloud en GitHub.
3. Seleccionar el repositorio `AUY1102-Pipeline` → **Set up**.
   📸 **CAPTURA 10:** proyecto creado en SonarCloud.
4. Verificar que la **Project Key** coincida con `sonar.projectKey`
   (*Administration → Update Key* o *Information*).
5. Elegir el método de análisis:
   - **Automatic Analysis** (por defecto): no requiere configuración extra, **pero no importa cobertura**.
   - **GitHub Actions (CI)**: permite mostrar la cobertura de `coverage/lcov.info`. Requiere:
     1. *SonarCloud → My Account → Security → Generate Token*.
     2. *GitHub → Settings → Secrets and variables → Actions → New repository secret*:
        nombre **`SONAR_TOKEN`**, valor = token generado.
     3. *SonarCloud → Administration → Analysis Method →* desactivar *Automatic Analysis*.
   - Método utilizado: **[COMPLETAR: Automatic / GitHub Actions]**
   📸 **CAPTURA 11:** secreto `SONAR_TOKEN` creado en GitHub (solo se ve el nombre, no el valor).

**Resultados:** 📸 **CAPTURA 12:** *Overview* del proyecto (Quality Gate, Bugs, Vulnerabilities,
Security Hotspots, Code Smells, Coverage).

| Métrica | Valor |
|---|---|
| Quality Gate | [COMPLETAR] |
| Bugs | [COMPLETAR] |
| Vulnerabilities | [COMPLETAR] |
| Security Hotspots | [COMPLETAR] |
| Code Smells | [COMPLETAR] |
| Coverage | [COMPLETAR] |
| Duplications | [COMPLETAR] |

📸 **CAPTURA 13:** detalle de un *Security Hotspot* o vulnerabilidad (por ejemplo, credenciales en código).

### 4.3 Snyk

**Qué es:** herramienta de seguridad que analiza **dependencias** (SCA – *Snyk Open Source*) y
**código propio** (SAST – *Snyk Code*), con propuestas de corrección automática mediante PR.

**Pasos realizados:**

1. Ingresar a https://app.snyk.io con la cuenta de GitHub.
2. **Integrations → GitHub → Connect**: autorizar a Snyk para la organización `grupo-4duoc`.
   📸 **CAPTURA 14:** integración GitHub conectada en Snyk.
3. **Projects → Add project → GitHub →** seleccionar `grupo-4duoc/AUY1102-Pipeline` → **Add selected repositories**.
4. Snyk ejecuta el escaneo automáticamente (`package.json` y código fuente).
   Para volver a escanear: abrir el proyecto → **Retest now**.
5. (Opcional) Activar **Snyk Code** en *Settings → Snyk Code* para analizar el código TypeScript.

> No se requiere secreto en GitHub cuando se importa el repositorio desde la consola web.
> `SNYK_TOKEN` solo es necesario si se ejecuta Snyk desde GitHub Actions o la CLI.

**Resultados:** 📸 **CAPTURA 15:** lista de proyectos/vulnerabilidades en Snyk.

| Proyecto Snyk | Críticas | Altas | Medias | Bajas |
|---|---:|---:|---:|---:|
| package.json (Open Source) | [COMPLETAR] | [COMPLETAR] | [COMPLETAR] | [COMPLETAR] |
| Code analysis (Snyk Code) | [COMPLETAR] | [COMPLETAR] | [COMPLETAR] | [COMPLETAR] |

📸 **CAPTURA 16:** detalle de una vulnerabilidad en Snyk (descripción, ruta, *fix* sugerido).

### 4.4 GitHub Advanced Security

**Qué es:** conjunto de funciones de seguridad integradas en GitHub:
- **Dependency graph / Dependabot alerts:** alertas por dependencias vulnerables.
- **Dependabot security updates:** abre PRs automáticos con la versión corregida.
- **Secret scanning:** detecta tokens y contraseñas subidos al repositorio.
- **Push protection:** bloquea un `git push` que contenga un secreto.
- **Code scanning (CodeQL):** análisis estático. El repo ya incluye `.github/workflows/codeql.yml`.

> En repositorios **públicos** estas funciones son gratuitas. En repositorios **privados** de una
> organización se requiere licencia de GitHub Advanced Security / Secret Protection.

**Pasos realizados:**

1. Repositorio → **Settings → Code security** (*Code security and analysis*).
2. Activar: **Dependency graph**, **Dependabot alerts**, **Dependabot security updates**,
   **Secret scanning** y **Push protection**.
   📸 **CAPTURA 17:** pantalla de *Code security* con las opciones activadas.
3. Revisar resultados en la pestaña **Security**:
   - *Dependabot alerts* → 📸 **CAPTURA 18**
   - *Secret scanning alerts* → 📸 **CAPTURA 19**
   - *Code scanning alerts* (CodeQL) → 📸 **CAPTURA 20**

| Funcionalidad | Alertas encontradas |
|---|---|
| Dependabot alerts | [COMPLETAR] |
| Secret scanning | [COMPLETAR] (se esperan alertas por `.npmrc`, `src/index.ts` y `credentials.yml`; ver sección 5) |
| Code scanning (CodeQL) | [COMPLETAR] |

### 4.5 Remediación

> Se debe aplicar **al menos una** remediación detectada por SonarCloud y/o Snyk.

| Campo | Detalle |
|---|---|
| Herramienta que lo detectó | [COMPLETAR: SonarCloud / Snyk / Dependabot] |
| Problema | [COMPLETAR] |
| Archivo / dependencia | [COMPLETAR] |
| Severidad | [COMPLETAR] |
| Corrección aplicada | [COMPLETAR] |
| Commit / PR | [COMPLETAR enlace] |

📸 **CAPTURA 21:** el hallazgo **antes** de la corrección.

📸 **CAPTURA 22:** el hallazgo **resuelto** después del nuevo análisis.

**Candidatas sugeridas:**
- **Secretos en `src/index.ts`:** eliminar `apiKey` y `githubToken` *hardcodeados* y leerlos desde
  `process.env`. Quitar la llamada automática `fetchData()` al importar el módulo.
- **Dependencias críticas (`handlebars`, `tar`):** ejecutar `npm audit fix` y volver a correr las pruebas.

---

## 5. Hallazgos de seguridad detectados manualmente

Durante la revisión se identificaron estos problemas, que las herramientas anteriores deberían reportar:

| # | Archivo | Hallazgo | Riesgo |
|---|---|---|---|
| 5.1 | `src/index.ts` | `apiKey` y `githubToken` escritos en el código; la API key se envía en la URL; `fetch` se ejecuta al importar el módulo. | Exposición de credenciales; efecto secundario no controlado. |
| 5.2 | `.npmrc` | Contiene un **token personal de GitHub** (`ghp_...`) en texto plano, versionado en el repo. | Cualquiera con acceso al repo puede usar el token. **Debe revocarse** y reemplazarse por `${NPM_TOKEN}`. |
| 5.3 | `credentials.yml` | Archivo con credenciales versionado. | Exposición de credenciales (se mantiene por ahora para que lo detecte *secret scanning*). |
| 5.4 | `src/quality/insecure-1-object.ts` | La entrada del usuario se interpola dentro de una plantilla **Pug** antes de compilarla. | *Server-Side Template Injection* (SSTI) → ejecución remota de código y XSS. |
| 5.5 | `src/quality/insecure-2-object.ts` | Consulta SQL armada concatenando texto; HTML con entrada sin escapar; endpoint sin token CSRF; contraseñas en código y en logs. | SQL Injection, XSS, CSRF, exposición de credenciales. |
| 5.6 | `src/quality/errores-object.ts` | Variables no usadas, tipo incorrecto (`string = 10`), métodos vacíos. | Calidad / mantenibilidad (*code smells*). |
| 5.7 | `.github/workflows/pull_request.yml` | Usa Node 14 (sin soporte) y `actions/*@v2` (obsoletas). | Pipeline con componentes sin parches de seguridad. |

---

## 6. Conclusiones

- Las **pruebas unitarias** ayudan a detectar errores temprano y evitan regresiones. Con 43% de
  cobertura, más de la mitad del código podría romperse sin que ninguna prueba lo detecte.
- **npm audit, Snyk y Dependabot** atacan el mismo problema (dependencias vulnerables) desde distintos
  puntos del ciclo de vida: en local, en la plataforma de seguridad y directamente en GitHub.
- **SonarCloud y CodeQL** (análisis estático) detectan vulnerabilidades en el **código propio**,
  por ejemplo SQL injection, SSTI y credenciales, antes de que lleguen a producción.
- **Secret scanning y push protection** previenen uno de los incidentes más comunes: subir
  contraseñas o tokens al repositorio.
- Integrar estas herramientas en cada *pull request* convierte la calidad y la seguridad en un proceso
  **automático y continuo** (*DevSecOps*), en lugar de una revisión manual al final.

[COMPLETAR: conclusión personal de la pareja]

---

### Anexo – Archivos creados o modificados en la rama `feature/parcial2-simon`

| Archivo | Cambio |
|---|---|
| `scripts/run-tests.sh` | Nuevo: script de pruebas + cobertura + fallos + código no cubierto |
| `package.json` | `test:coverage` ahora ejecuta `bash scripts/run-tests.sh` |
| `.gitignore` | Se agrega `coverage` |
| `sonar-project.properties` | Nuevo: configuración SonarCloud |
| `docs/npm-audit-report.txt` / `.json` | Nuevo: reporte completo de npm audit |
| `docs/npm-audit-prod-report.txt` | Nuevo: reporte de npm audit solo producción |
| `DOCUMENTACION.md` | Nuevo: este documento |
