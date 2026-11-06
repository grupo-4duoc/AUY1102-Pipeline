# Evaluación Parcial N° 2 – AUY1102 Ciclo de Vida del Software I

**Desarrollo de Pruebas Unitarias y Análisis de Seguridad II**

| Dato | Valor |
|---|---|
| Organización GitHub | `grupo-4duoc` |
| Repositorio | https://github.com/grupo-4duoc/AUY1102-Pipeline |
| Repositorio base (docente) | https://github.com/Fundacion-Instituto-Profesional-Duoc-UC/AUY1102-Pipeline |
| Rama de trabajo | `feature/parcial2-simon` |
| Integrantes | Simón Lagos · [COMPLETAR nombre pareja] |
| Fecha | 06-11-2026 |

> Las imágenes están en la carpeta `img/` del repositorio.

---

## Índice

1. [Contexto](#1-contexto)
2. [Preparación del entorno](#2-preparación-del-entorno)
3. [Parte 1 – Pruebas unitarias y cobertura](#3-parte-1--pruebas-unitarias-y-cobertura)
4. [Parte 2 – Análisis de seguridad y código estático](#4-parte-2--análisis-de-seguridad-y-código-estático)
   - 4.1 [npm audit](#41-npm-audit)
   - 4.2 [Snyk](#42-snyk)
   - 4.3 [SonarCloud](#43-sonarcloud)
   - 4.4 [GitHub Advanced Security](#44-github-advanced-security)
   - 4.5 [Remediación](#45-remediación)
5. [Hallazgos de seguridad detectados en el código](#5-hallazgos-de-seguridad-detectados-en-el-código)
6. [Conclusiones](#6-conclusiones)

---

## 1. Contexto

La empresa *Integration Solutions* busca automatizar su ciclo de desarrollo migrando a GitHub e
incorporando revisiones de **calidad** (pruebas unitarias, cobertura y análisis estático) y de
**seguridad** (vulnerabilidades en dependencias, código inseguro y secretos expuestos).

El proyecto es una librería **TypeScript** de *Value Objects* (`StringValueObject`,
`NumberValueObject`, `DateValueObject`, `EnumValueObject`) probada con **Jest**. La carpeta
`src/quality/` contiene código inseguro intencional que sirve para validar las herramientas de análisis.

**¿Por qué importa en el ciclo de vida?** Mientras antes se detecta un error o una vulnerabilidad
(*shift-left*), más barato es corregirlo. Un bug detectado por una prueba unitaria en un Pull Request
cuesta minutos; el mismo bug en producción puede costar días y generar incidentes de seguridad.

---

## 2. Preparación del entorno

### 2.1 Herramientas

| Herramienta | Versión | Uso |
|---|---|---|
| Git | 2.54 | Control de versiones |
| Node.js | v26.13.0 (LTS) | Ejecutar el proyecto y las pruebas |
| npm | 11.20.0 | Dependencias, scripts y `npm audit` |
| Visual Studio Code | – | Editor y terminal |

Node.js no estaba instalado, así que se instaló con el gestor de paquetes de Windows:

```powershell
winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
node --version    # v26.13.0
npm --version     # 11.20.0
```

### 2.2 Repositorio (fork) y rama de trabajo

1. Se creó un **fork** del repositorio indicado por el docente
   (`Fundacion-Instituto-Profesional-Duoc-UC/AUY1102-Pipeline`) dentro de la organización `grupo-4duoc`.
2. Se clonó localmente y se creó una rama propia. Como el trabajo es en pareja, **no se trabaja sobre `master`**:

```bash
git clone https://github.com/grupo-4duoc/AUY1102-Pipeline.git
cd AUY1102-Pipeline
git checkout -b feature/parcial2-simon
npm install
```

`npm install` instaló **1599 paquetes** y advirtió **82 vulnerabilidades**, que se analizan en la sección 4.1.

---

## 3. Parte 1 – Pruebas unitarias y cobertura

### 3.1 Conceptos

- **Prueba unitaria:** verifica una unidad pequeña de código (una función o un método) de forma aislada.
- **Cobertura de código:** porcentaje del código que se ejecuta durante las pruebas. Se mide en
  *sentencias*, *líneas*, *funciones* y *ramas* (cada camino de un `if/else`).
- Una cobertura baja **no significa que el código falle**, sino que hay partes **sin verificar**, donde
  un cambio futuro podría romper algo sin que nadie lo note (**riesgo de regresión**).

### 3.2 Script creado: `scripts/run-tests.sh`

Se creó el script [`scripts/run-tests.sh`](scripts/run-tests.sh) y se conectó al comando
`npm run test:coverage` en `package.json`:

```json
"test:coverage": "bash scripts/run-tests.sh"
```

| Etapa | Qué hace |
|---|---|
| 1. Ejecutar pruebas | Ejecuta `jest --coverage` y genera reportes `json`, `json-summary` y `lcov` (`coverage/lcov.info`, que puede usar SonarCloud). |
| 2. Pruebas que fallan | Lista cada prueba fallida con su archivo y su mensaje de error. |
| 3. Código no cubierto | Por cada archivo muestra las **líneas**, **funciones** y **ramas** que ninguna prueba ejecutó. |
| 4. Resumen | Tabla de % de cobertura por archivo y total. |
| Salida | Código `0` si todo pasa y `1` si alguna prueba falla (útil para CI). |

Además se agregó `coverage` al `.gitignore`, porque los reportes son archivos generados.

### 3.3 Ejecución

```bash
npm run test:coverage
```

**Salida del script (pruebas que fallan):**

```text
==================== 2. PRUEBAS QUE FALLAN ====================
Suites : 10 OK / 0 con fallos / 10 total
Pruebas: 18 OK / 0 fallidas / 18 total

✔ Todas las pruebas pasaron.
```

**Salida del script (código no cubierto):**

```text
==================== 3. CÓDIGO NO CUBIERTO POR PRUEBAS ====================
• src/index.ts
    Líneas sin cubrir   : 8-10
• src/quality/errores-object.ts
    Líneas sin cubrir   : 2-3, 6
• src/quality/insecure-1-object.ts
    Líneas sin cubrir   : 1-3, 5, 7, 10
• src/quality/insecure-2-object.ts
    Líneas sin cubrir   : 1-2, 6-7, 11-12, 18, 22, 24, 30, 32
• src/value-object/primitives/date-value-object.ts
    Líneas sin cubrir   : 3, 7-9, 13-14, 19, 23-25, 29-30, 34-35
    Ramas (if/else) sin cubrir: 3
• src/value-object/primitives/enum-value-object.ts
    Líneas sin cubrir   : 11
    Ramas (if/else) sin cubrir: 1
```

**Salida del script (resumen de cobertura):**

```text
==================== RESUMEN DE COBERTURA ====================
  Sentencias  :  43.28 %  (29/67)
  Ramas       :     60 %  (6/10)
  Funciones   :  56.66 %  (17/30)
  Líneas      :  43.28 %  (29/67)
  Resultado    : ÉXITO ✔
```

### 3.4 Resultados

**Pruebas:** 10 suites, **18 pruebas: 18 aprobadas y 0 fallidas**.

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

**Análisis:**
- `StringValueObject` y `NumberValueObject` están **100 % cubiertos**.
- `DateValueObject` **no tiene ninguna prueba** (6,66 %), y es lo que más baja el promedio.
- En `EnumValueObject` falta probar el caso de **valor inválido** (la rama del `throw`).
- `src/quality/*.ts` es código de ejemplo inseguro, sin pruebas.
- **Mejora recomendada:** crear pruebas para `DateValueObject` y para el caso inválido de `EnumValueObject`.

> **Observación:** durante la ejecución aparece el aviso *"Cannot log after tests are done"*. Se debe a
> que `src/index.ts` ejecuta `fetchData()` al ser importado y llama a `api.example.com`. Es un problema
> de diseño que además expone credenciales (ver sección 5).

---

## 4. Parte 2 – Análisis de seguridad y código estático

### 4.1 npm audit

**Qué es:** comando nativo de npm que compara las dependencias instaladas (directas y transitivas)
con la base de datos de vulnerabilidades conocidas (GitHub Advisory Database / CVE).

**Ejecución:**

```bash
npm audit > docs/npm-audit-report.txt                  # reporte completo
npm audit --json > docs/npm-audit-report.json          # reporte completo en JSON
npm audit --omit=dev > docs/npm-audit-prod-report.txt  # solo dependencias de producción
```

Reportes: [`docs/npm-audit-report.txt`](docs/npm-audit-report.txt) ·
[`docs/npm-audit-report.json`](docs/npm-audit-report.json) ·
[`docs/npm-audit-prod-report.txt`](docs/npm-audit-prod-report.txt)

```text
82 vulnerabilities (11 low, 20 moderate, 49 high, 2 critical)

To address issues that do not require attention, run:
  npm audit fix
```

**Resultados:**

| Severidad | Todas las dependencias | Solo producción |
|---|---:|---:|
| Crítica | 2 | 0 |
| Alta | 49 | 5 |
| Moderada | 20 | 3 |
| Baja | 11 | 0 |
| **Total** | **82** | **8** |

**Vulnerabilidades más relevantes:**

| Paquete | Severidad | Tipo | Corrección |
|---|---|---|---|
| `handlebars` | Crítica | Inyección de JavaScript | `npm audit fix` |
| `tar` | Crítica | Sobrescritura de archivos (*path traversal*) | `npm audit fix` |
| `@faker-js/faker` | Alta | Ejecución arbitraria de código | Subir a v10 (cambio mayor) |
| `chokidar` → `braces`, `micromatch` | Alta | ReDoS (denegación de servicio) | Subir de versión (cambio mayor) |
| `lodash` | Alta | Inyección de código / *prototype pollution* | `npm audit fix` |

**Interpretación:** 74 de las 82 vulnerabilidades están en **herramientas de desarrollo** (eslint,
semantic-release, babel). Las **8 de producción** vienen de `chokidar@2`, que es muy antigua.
Las 2 críticas se pueden corregir con `npm audit fix` sin cambios incompatibles.

### 4.2 Snyk

**Qué es:** herramienta de seguridad que analiza las **dependencias** (SCA – *Snyk Open Source*)
y también las imágenes de contenedor (Dockerfile). Prioriza cada hallazgo y sugiere cómo corregirlo.

**Pasos realizados:**

1. Ingresar a https://app.snyk.io con la cuenta de GitHub. En **Settings → Integrations**, la
   integración **GitHub** aparece como *Configured*.
2. Ir a **Projects → Add projects**. Como el repositorio es **público**, se usó la opción
   **"monitor a public repository"**, que no requiere dar permisos extra a Snyk sobre la organización.
3. Escribir `grupo-4duoc/AUY1102-Pipeline` → **Add repo**. Snyk detecta un archivo de manifiesto
   soportado → **Import 1 repository**.
4. Snyk importa el repositorio (rama `master`) y ejecuta el escaneo automáticamente. Para volver a
   escanear después de un cambio se usa **Retest now** dentro del proyecto.

![Proyecto importado en Snyk](img/05a-snyk-proyecto-importado.jpg)

**Resultados del escaneo (estado inicial, antes de la remediación):**

| Proyecto Snyk | Críticas | Altas | Medias | Bajas |
|---|---:|---:|---:|---:|
| `Dockerfile` (imagen base) | 1 | 14 | 17 | 5 |
| `package.json` (dependencias npm) | 0 | 4 | 3 | 0 |
| **Total** | **1** | **18** | **20** | **5** |

![Resumen del proyecto package.json en Snyk](img/05b-snyk-package-json-resumen.jpg)

**Hallazgo principal en `package.json`:** `chokidar@2.0.3` arrastra 7 vulnerabilidades transitivas
(ReDoS en `decode-uri-component`, consumo excesivo de recursos y recursión no controlada en `braces`).
Snyk indica que **actualizar a `chokidar@3.0.0` corrige 6 de ellas** (cambio de versión mayor).

![Vulnerabilidades de chokidar detectadas por Snyk](img/05c-snyk-vulnerabilidades-chokidar.jpg)

### 4.3 SonarCloud

**Qué es:** plataforma de análisis **estático** de código (SAST) que detecta *bugs*, vulnerabilidades,
*security hotspots*, *code smells* y duplicación, y además puede mostrar la cobertura de pruebas.

**Configuración en el repositorio:** se creó [`sonar-project.properties`](sonar-project.properties):

```properties
sonar.organization=grupo-4duoc
sonar.projectKey=grupo-4duoc_AUY1102-Pipeline
sonar.sources=src
sonar.tests=test
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

**Pasos realizados:**

1. Ingresar a https://sonarcloud.io con **GitHub**.
2. Verificar que la aplicación **SonarQube Cloud** esté instalada en la organización de GitHub `grupo-4duoc`
   (*Organization Settings → GitHub Apps*) con acceso al repositorio `AUY1102-Pipeline`.
3. En SonarCloud, ir a **+ → Analyze new project →** organización `grupo-4duoc`.
4. Marcar el repositorio **AUY1102-Pipeline** → **Set Up**. El proyecto se crea como público y
   SonarCloud ejecuta el primer análisis automáticamente (*Automatic Analysis*).

> **Incidencia y solución:** al principio SonarCloud respondía *"The request cannot be processed"*
> al listar los repositorios. La causa era que la cuenta usada no tenía rol **Admin** en la organización
> de SonarCloud. Al ingresar con la cuenta administradora, el repositorio apareció y se pudo importar.

**Resultados del análisis (rama `master`, código original, 792 líneas de código):**

| Métrica | Resultado |
|---|---|
| Quality Gate | *Not computed*: es el primer análisis y se calcula en el siguiente |
| Security | **16 problemas abiertos – nota E** |
| Reliability | 0 problemas – nota A |
| Maintainability | 1 problema – nota A |
| Duplicaciones | 0,0 % |
| Dependency risks | 125 – nota C |
| Coverage | No configurada (el análisis automático no importa cobertura; requiere análisis por CI con el reporte `coverage/lcov.info`) |

![Resumen del análisis en SonarCloud](img/06a-sonarcloud-resumen.jpg)

**Problemas de seguridad más importantes (severidad *Blocker*):**

| Archivo | Hallazgo de SonarCloud |
|---|---|
| `.npmrc` | Token de GitHub en el código: debe revocarse, cambiarse y eliminarse |
| `credentials.yml` | Token *hard-coded* (2 hallazgos) |
| `src/quality/insecure-1-object.ts` | *Server-Side Template Injection* (SSTI) por entrada de usuario sin sanitizar |

**Otros hallazgos:**
- **Dockerfile:** copia recursiva que podría incluir datos sensibles en la imagen (alta), y la imagen `node` se ejecuta como usuario `root` (baja).
- **Workflows de GitHub Actions:** `npm install` sin `--ignore-scripts` y dependencias sin versiones bloqueadas (media).
- **`insecure-1-object.ts`:** plantilla formateada dinámicamente (media) y Express revela su versión (baja).

![Problemas de seguridad detectados por SonarCloud](img/06b-sonarcloud-issues-seguridad.jpg)

**Análisis:** SonarCloud confirmó los secretos expuestos y la vulnerabilidad SSTI que se habían
identificado en la revisión manual (sección 5). Además encontró riesgos que las herramientas de
dependencias (npm audit, Snyk y Dependabot) no ven, porque están en el **código y la configuración
propios** del proyecto: el Dockerfile y los workflows de GitHub Actions.

### 4.4 GitHub Advanced Security

**Qué es:** funciones de seguridad integradas en GitHub:
- **Dependency graph:** inventario de las dependencias del proyecto.
- **Dependabot alerts:** alertas cuando una dependencia tiene una vulnerabilidad conocida.
- **Secret scanning (Secret Protection):** detecta tokens y contraseñas subidos al repositorio.
- **Code scanning (CodeQL):** análisis estático. El repositorio ya incluye `.github/workflows/codeql.yml`.

> En repositorios **públicos** estas funciones son gratuitas.

**Estado inicial:** Dependabot alerts y Secret scanning estaban **desactivados**.

![GitHub Security antes de activar](img/07a-github-security-antes.jpg)

**Pasos realizados:**

1. Repositorio → **Settings → Advanced Security**.
2. **Dependency graph** → *On*.
3. **Dependabot alerts** → *On*.
4. **Secret Protection** → **Enable** → confirmar **Enable Secret Protection**.
5. No se activaron *Dependabot security updates* (PRs automáticos), porque la remediación se hace
   de forma manual, ni *Push protection*, para no bloquear el trabajo de la pareja.

![Secret Protection activado](img/07b-github-secret-protection-activado.jpg)

**Estado final:** Dependabot alerts y Secret scanning aparecen como **Enabled**.

![GitHub Security después de activar](img/07c-github-security-despues.jpg)

**Resultados:**

| Funcionalidad | Resultado |
|---|---|
| Dependabot alerts | **64 alertas abiertas**. Las más graves son 3 **críticas** de `handlebars` (inyección de JavaScript); le siguen altas de `flatted`, `tar` y `lodash`. |
| Secret scanning | Al activarlo: 0 alertas. [COMPLETAR resultado final] |

![Alertas de Dependabot](img/08a-dependabot-alertas.jpg)

![Secret scanning](img/08b-secret-scanning-estado-inicial.jpg)

> **¿Por qué secret scanning no marcó los secretos de inmediato?** GitHub detecta con más prioridad
> los tokens con formato válido de proveedores conocidos. Los valores de ejemplo de `src/index.ts`
> (por ejemplo `ghp_1234567890abcdef...`) no son tokens reales, y el escaneo del historial puede tardar.
> Igual, los secretos sí fueron identificados en la revisión del código (sección 5).

### 4.5 Remediación

> Se debe aplicar **al menos una** remediación detectada por SonarCloud y/o Snyk.

| Campo | Detalle |
|---|---|
| Herramienta que lo detectó | **Snyk** (*Snyk Open Source*), confirmado con `npm audit` y Dependabot |
| Problema | `chokidar@2.0.3` arrastra dependencias transitivas vulnerables: ReDoS en `decode-uri-component`, consumo descontrolado de recursos y recursión no controlada en `braces` (vía `micromatch`, `anymatch` y `readdirp`) |
| Archivo / dependencia | `package.json` → `dependencies.chokidar` (dependencia de **producción**) |
| Severidad | **Alta** (7 *issues* en Snyk, CVSS hasta 8.7) |
| Corrección aplicada | Actualización de `chokidar` de `^2.0.3` a `^3.6.0` (última versión 3.x) |
| Commit | `fix(deps): actualizar chokidar a 3.6.0` en la rama [`feature/parcial2-simon`](https://github.com/grupo-4duoc/AUY1102-Pipeline/commits/feature/parcial2-simon) |

#### Paso 1 – Análisis de impacto

Antes de actualizar se verificó si el código usa `chokidar`:

```bash
grep -r "chokidar" src test   # sin resultados
npm ls chokidar
```

```text
+-- @babel/cli@7.18.10
| `-- chokidar@3.6.0
+-- chokidar@2.0.3          <- dependencia directa vulnerable
`-- ts-node-dev@2.0.0
  `-- chokidar@3.6.0
```

**Conclusión:** `chokidar` **no se importa en ningún archivo** de `src/` ni `test/`; solo está declarado en
`package.json`. Además, la versión `3.6.0` ya estaba en el proyecto (la usan `@babel/cli` y `ts-node-dev`).
Por eso el cambio de versión mayor (2 → 3) tiene **bajo riesgo**.

#### Paso 2 – Evidencia "antes"

```bash
npm audit --omit=dev > docs/npm-audit-prod-ANTES.txt
```

```text
braces  <3.0.3                       Severity: high
  chokidar  1.3.0 - 2.1.8            (depende de anymatch y braces vulnerables)
  micromatch  <=4.0.7                (depende de braces vulnerable)
    anymatch  1.2.0 - 2.0.0
    readdirp  2.2.0 - 2.2.1
decode-uri-component  <=0.5.0        Severity: high
  source-map-resolve  >=0.5.1
yaml  1.0.0 - 1.10.2                 Severity: moderate

8 vulnerabilities (3 moderate, 5 high)
```

Reporte completo: [`docs/npm-audit-prod-ANTES.txt`](docs/npm-audit-prod-ANTES.txt)

#### Paso 3 – Corrección

```bash
npm install chokidar@^3.6.0
npm ls chokidar
```

```text
+-- @babel/cli@7.18.10
| `-- chokidar@3.6.0 deduped
+-- chokidar@3.6.0
`-- ts-node-dev@2.0.0
  `-- chokidar@3.6.0 deduped
```

- `package.json`: `"chokidar": "^2.0.3"` → `"chokidar": "^3.6.0"`.
- `package-lock.json`: se **eliminaron 134 paquetes** obsoletos que solo existían por `chokidar@2`
  (`micromatch@3`, `braces@2`, `snapdragon`, `decode-uri-component`, etc.) y **no se agregó ninguno**.
  Esto reduce la superficie de ataque del proyecto.

#### Paso 4 – Prueba de regresión

```bash
npm run test:coverage
```

```text
==================== 2. PRUEBAS QUE FALLAN ====================
Suites : 10 OK / 0 con fallos / 10 total
Pruebas: 18 OK / 0 fallidas / 18 total

✔ Todas las pruebas pasaron.
...
  Líneas      :  43.28 %  (29/67)
  Resultado    : ÉXITO ✔
```

Las **18 pruebas siguen pasando** y la cobertura no cambió: la actualización no introdujo regresiones.

#### Paso 5 – Evidencia "después"

```bash
npm audit --omit=dev > docs/npm-audit-prod-DESPUES.txt
```

```text
picomatch  <=2.3.1                   Severity: high
  fix available via `npm audit fix`
yaml  1.0.0 - 1.10.2                 Severity: moderate
  fix available via `npm audit fix`

2 vulnerabilities (1 moderate, 1 high)
```

Reporte completo: [`docs/npm-audit-prod-DESPUES.txt`](docs/npm-audit-prod-DESPUES.txt)

#### Resultado

| Severidad (producción) | Antes | Después |
|---|---:|---:|
| Alta | 5 | 1 |
| Moderada | 3 | 1 |
| **Total** | **8** | **2** |

| Vulnerabilidad | Antes | Después |
|---|---|---|
| `braces` (alta) | ❌ Presente | ✅ Corregida |
| `micromatch` (alta) | ❌ Presente | ✅ Corregida |
| `anymatch` (alta) | ❌ Presente | ✅ Corregida |
| `readdirp` (alta) | ❌ Presente | ✅ Corregida |
| `decode-uri-component` (alta) | ❌ Presente | ✅ Corregida |
| `chokidar` (moderada) | ❌ Presente | ✅ Corregida |
| `source-map-resolve` (moderada) | ❌ Presente | ✅ Corregida |
| `picomatch` (alta) | – | ⚠️ **Nueva** |
| `yaml` (moderada) | ❌ Presente | ❌ Pendiente |

**Análisis del resultado:**
- Se corrigieron **7 de las 8** vulnerabilidades de producción originales.
- **`picomatch@2.3.1` (nueva):** `chokidar@3` reemplazó a `micromatch`/`braces` por `picomatch`, y esa
  versión tiene un aviso de *ReDoS* y *method injection*. Esto demuestra por qué **siempre hay que volver
  a escanear después de una actualización**: corregir una dependencia puede introducir otra. Se corrige
  con `npm audit fix` (sin cambios incompatibles).
- **`yaml` (pendiente):** **no estaba relacionada con chokidar**. Viene de `cosmiconfig@6` y también
  se corrige con `npm audit fix`.

**Otras remediaciones posibles (no aplicadas):**
- **Secretos en `src/index.ts`:** eliminar `apiKey` y `githubToken` escritos en el código, leerlos
  desde variables de entorno (`process.env`) y quitar la llamada automática a `fetchData()`.
- **`credentials.yml`:** se elimina al final, como indicó la docente.

---

## 5. Hallazgos de seguridad detectados en el código

| # | Archivo | Hallazgo | Riesgo |
|---|---|---|---|
| 5.1 | `src/index.ts` | `apiKey` y `githubToken` escritos en el código. La API key viaja en la URL y `fetch` se ejecuta al importar el módulo. | Exposición de credenciales y efecto secundario no controlado. |
| 5.2 | `.npmrc` | Contiene un token de GitHub (`ghp_...`) en texto plano dentro del repositorio. | Cualquiera con acceso al repo podría usarlo. Debe revocarse y reemplazarse por `${NPM_TOKEN}`. |
| 5.3 | `credentials.yml` | Archivo con credenciales versionado. | Exposición de credenciales (se deja para el final, según la indicación de la docente). |
| 5.4 | `src/quality/insecure-1-object.ts` | La entrada del usuario se inserta en una plantilla **Pug** antes de compilarla. | *Server-Side Template Injection* (SSTI) → ejecución remota de código y XSS. |
| 5.5 | `src/quality/insecure-2-object.ts` | SQL armado concatenando texto, HTML sin escapar, endpoint sin token CSRF, contraseñas en el código y en los logs. | SQL Injection, XSS, CSRF y exposición de credenciales. |
| 5.6 | `src/quality/errores-object.ts` | Variables sin usar, tipo incorrecto (`string = 10`) y métodos vacíos. | Calidad y mantenibilidad (*code smells*). |
| 5.7 | `.github/workflows/pull_request.yml` | Usa Node 14 (sin soporte) y `actions/*@v2` (obsoletas). | Pipeline con componentes sin parches de seguridad. |

---

## 6. Conclusiones

- Las **pruebas unitarias** detectan errores temprano y evitan regresiones. Con un 43 % de cobertura,
  más de la mitad del código podría romperse sin que ninguna prueba lo detecte.
- **npm audit, Snyk y Dependabot** atacan el mismo problema (dependencias vulnerables) desde distintos
  puntos del ciclo de vida: en el equipo local, en una plataforma de seguridad y directamente en GitHub.
  Los tres coincidieron en hallazgos como `handlebars`, `tar`, `lodash` y `chokidar`.
- **SonarCloud y CodeQL** (análisis estático) detectan vulnerabilidades en el **código propio**, como
  SQL injection, SSTI o credenciales, antes de que lleguen a producción.
- **Secret scanning** previene uno de los incidentes más comunes: subir contraseñas o tokens al repositorio.
- Integrar estas herramientas en cada *Pull Request* convierte la calidad y la seguridad en un proceso
  **automático y continuo** (*DevSecOps*), en lugar de una revisión manual al final.

[COMPLETAR: conclusión personal de la pareja]

---

### Anexo – Archivos creados o modificados en la rama `feature/parcial2-simon`

| Archivo | Cambio |
|---|---|
| `scripts/run-tests.sh` | Nuevo: script de pruebas, cobertura, fallos y código no cubierto |
| `package.json` | `test:coverage` ahora ejecuta `bash scripts/run-tests.sh`; `chokidar` actualizado a `^3.6.0` |
| `package-lock.json` | Remediación: `chokidar@3.6.0` y eliminación de 134 paquetes obsoletos |
| `docs/npm-audit-prod-ANTES.txt` / `-DESPUES.txt` | Evidencia de la remediación (npm audit de producción) |
| `.gitignore` | Se agrega `coverage` |
| `sonar-project.properties` | Nuevo: configuración de SonarCloud |
| `docs/npm-audit-report.txt` / `.json` | Nuevo: reporte completo de npm audit |
| `docs/npm-audit-prod-report.txt` | Nuevo: reporte de npm audit solo de producción |
| `img/*.jpg` | Capturas de evidencia |
| `DOCUMENTACION.md` | Nuevo: este documento |
