---
id_script: "00"
nombre_archivo: "00_perfilado_inicial.R"
bloque: "00_global"
fase_metodologica: "Fase 1: Auditoria y Perfilado Forense"
entrada: "03_data/01_raw/persona.csv"
salida: "03_data/02_interim/persona_00.rds"
evidencia_grafica: "06_images/00_distribucion_nulos.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 00: Perfilado Inicial y Diagnóstico de Nulos

## 1. Contexto y Diagnóstico Forense
La Encuesta de Hogares 2024 de Bolivia fue suministrada en un archivo CSV plano denominado `persona.csv`. El objetivo de este primer paso fue auditar la integridad dimensional, tipos de variables crudas y cuantificar el volumen exacto de datos faltantes antes de aplicar cualquier transformación destructiva.

## 2. Hallazgos Principales
* **Dimensiones brutas:** 39,497 filas (individuos) por 275 columnas (atributos).
* **Volumen de NAs:** 6,261,409 valores nulos sobre un universo matricial de 10,861,675 celdas (57.65% de ausencia de datos).
* **Distribución de NAs:** Se determinó que la ausencia de datos no es homogénea ni responde a un mecanismo puramente aleatorio (MCAR), sino a un patrón censal bimodal:
  * Columnas sociodemográficas y de identificación: 0% a 5% de nulos.
  * Módulos temáticos específicos (fecundidad, empleo, TICs): más del 50% de nulos debido a saltos de boleta (*skip patterns*).

## 3. Algoritmo y Procedimiento en R
1. Lectura robusta mediante `readr::read_csv()` forzando `guess_max = 50000` para prevenir truncamiento erróneo de tipos mixtos.
2. Cálculo de métricas vectorizadas de completitud por columna.
3. Categorización de atributos en tramos porcentuales de completitud (`0-10%`, `10-30%`, `30-50%`, `50-70%`, `70-100%`).
4. Generación del gráfico de barras de diagnóstico `00_distribucion_nulos.png`.
5. Persistencia binaria del estado original sin modificaciones en `persona_00.rds`.

## 4. Métricas de Impacto
* Filas procesadas: 39,497
* Columnas analizadas: 275
* Checkpoint generado: `03_data/02_interim/persona_00.rds`
* Registro en bitácora: Paso 00 registrado con éxito.