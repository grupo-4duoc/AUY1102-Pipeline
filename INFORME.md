# Evaluación Parcial 2 - Ciclo de Vida del Software I (AUY1102)

**Integrantes:** Abraham Ravelo y Simón Lagos  
**Grupo:** Grupo 4 - Duoc UC  
**Repositorio:** [https://github.com/grupo-4duoc/AUY1102-Pipeline](https://github.com/grupo-4duoc/AUY1102-Pipeline)  

---

## 1. Conceptos Clave de Calidad de Software (Indicador IE3.1.1)

A continuación explicamos los conceptos solicitados en la rúbrica y cómo aportan a la calidad del software:

* **Pruebas Unitarias:** Son pruebas que revisan que una función, método o clase pequeña funcione bien de forma aislada, sin depender de bases de datos o servicios externos. Ayudan a encontrar errores de lógica rápido mientras uno programa.
* **Calidad de Código Estático:** Es revisar el código sin ejecutarlo (usando linters como ESLint o herramientas como SonarCloud). Sirve para detectar malas prácticas, código duplicado y posibles fallas antes de compilar.
* **Calidad de Código Dinámico:** Es evaluar el software mientras se está ejecutando (por ejemplo corriendo las pruebas con Jest). Permite ver el comportamiento real, si se caen funciones o si hay problemas de rendimiento en tiempo de ejecución.
* **Análisis de Seguridad y Vulnerabilidades:** Es buscar fallas de seguridad en el código propio (como inyecciones SQL o XSS) o en las librerías que usamos (dependencias vulnerables). Sirve para que nadie pueda hackear o botar el sistema.
* **Pruebas Integradas:** Prueban cómo interactúan dos o más partes del sistema entre sí (por ejemplo, que la API se conecte bien con la base de datos). Aseguran que las partes que funcionan solas también funcionen juntas.
* **Pruebas de Estrés:** Consisten en exigir al sistema al máximo con mucho tráfico o datos para ver en qué punto falla y cómo se recupera.
* **Pruebas de Regresión:** Son las pruebas que se vuelven a correr después de hacer un cambio o arreglo para confirmar que lo nuevo no rompió nada de lo que ya funcionaba.

---

## 2. Herramientas de Aseguramiento de Calidad (Indicador IE3.2.1)

| Herramienta | Para qué sirve | En qué etapa del ciclo de vida se usa | Beneficio principal |
|---|---|---|---|
| **Jest** | Framework para ejecutar pruebas unitarias y medir cobertura. | Desarrollo (mientras se programa y antes de subir cambios). | Detecta fallas de lógica al instante antes de pasar a producción. |
| **SonarCloud** | Plataforma para análisis estático continuo de calidad y seguridad. | Integración Continua (CI al hacer Pull Request). | Muestra la deuda técnica, code smells y si el código pasa el Quality Gate. |
| **Snyk** | Escáner de seguridad para dependencias y código fuente. | Desarrollo y CI/CD. | Avisa si usamos librerías viejas con vulnerabilidades y da recomendaciones para arreglarlas. |
| **npm audit** | Comando nativo de Node.js para revisar vulnerabilidades de paquetes. | Instalación y empaquetado de dependencias. | Rápido y directo en terminal para parchar paquetes con `npm audit fix`. |
| **GitHub Advanced Security** | Herramientas de seguridad dentro de GitHub (Secret Scanning y Dependabot). | Repositorio y control de versiones. | Bloquea y avisa si alguien sube accidentalmente contraseñas o tokens al repositorio. |

---

## 3. Desarrollo de la Evaluación

### Parte 1: Pruebas Unitarias y Cobertura (Trabajado por Abraham)

1. **Creación de rama de trabajo:** Se creó la rama `feature/pruebas-unitarias`.
2. **Script de Cobertura:** Creamos el script en `scripts/reporte-pruebas.js` y lo dejamos enlazado en `package.json` con el comando:
   ```bash
   npm run test:report
   ```
   Al ejecutarlo, corre Jest con cobertura y muestra por consola qué pruebas pasaron, el porcentaje de cada archivo y qué líneas quedaron sin pruebas.
3. **Arreglo del bug en `DateValueObject`:**
   Al revisar `src/value-object/primitives/date-value-object.ts`, encontramos que en la línea 13 tenía un error:
   ```typescript
   // Tenía !Number.isNaN, lo que hacía que fallara con fechas válidas:
   if (Number.isNaN(new Date(date).getTime())) {
     this.throwErrorForInvalidDate(date);
   }
   ```
   Se corrigió y se crearon las pruebas unitarias en `test/value-object/primitives/DateValueObject/dateValueObject.test.ts`. Con esto, la cobertura de ese archivo subió de 6% a 100%.

---

### Parte 2: Análisis de Seguridad y Monitoreo (Trabajado por Simón)

1. **Creación de rama de trabajo:** Se creó la rama `feature/seguridad-snyk`.
2. **Conexión con Snyk (app.snyk.io):**
   * Se conectó el repositorio en la consola de Snyk.
   * El escáner detectó vulnerabilidades en dependencias (`package.json`) y en el `Dockerfile`.
3. **Conexión con SonarCloud (sonarcloud.io):**
   * Se dejó configurado el archivo `sonar-project.properties` y el workflow de GitHub Actions.
4. **Remediación de Vulnerabilidad:**
   * La vulnerabilidad más crítica detectada fue una clave real (Personal Access Token de GitHub) expuesta en texto plano en `credentials.yml`.
   * Se retiró el token quemado del archivo para evitar filtraciones y se protegió la subida de claves en `.gitignore`.
5. **npm audit:**
   * Se corrió `npm audit` en la terminal encontrando vulnerabilidades en paquetes antiguos (como `chokidar`). Se actualizó a una versión segura.

---

### Parte 3: Trabajo en Equipo y Pull Requests

* **Flujo colaborativo:**
  1. Abraham trabajó en `feature/pruebas-unitarias` y abrió su Pull Request hacia `master`.
  2. Simón revisó el Pull Request de Abraham, comprobó que las pruebas pasaban y lo aprobó con un comentario.
  3. Simón trabajó en `feature/seguridad-snyk` y abrió su Pull Request hacia `master`.
  4. Abraham revisó el Pull Request de Simón, validó las correcciones de seguridad y lo aprobó con un comentario.
