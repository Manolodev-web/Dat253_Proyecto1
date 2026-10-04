---
id_script: "06"
nombre_archivo: "06_clasificar_NA.R"
bloque: "00_global"
fase_metodologica: "Fase 4: Diagnostico y Taxonomia de Datos Faltantes"
entrada: "03_data/02_interim/persona_05.rds"
salida: "03_data/02_interim/persona_06.rds"
evidencia_grafica: "06_images/06_clasificacion_na.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 06: Clasificación Taxonómica de Valores Faltantes

## 1. Contexto y Diagnóstico Forense
Un valor `NA` en una base de datos tabular es ciego: no indica si la persona se negó a contestar, si el encuestador olvidó anotar o si la boleta censal ordenó saltar la pregunta.

## 2. Justificación Metodológica
Se construyó una taxonomía tripartita auditable celda por celda:
* `Observado`: Valor válido presente.
* `NA_Estructural`: Salto legítimo por no pertenecer al universo poblacional.
* `NA_Real`: Omisión o no respuesta genuina de un individuo perteneciente al universo que requiere tratamiento o imputación.

## 3. Algoritmo y Procedimiento en R
1. Creación de 4 indicadores categóricos de auditoría:
   * `tipo_na_embarazo` (Sección 2B - Fecundidad)
   * `tipo_na_aestudio` (Sección 3A - Escolaridad)
   * `tipo_na_tothrs` (Sección 4 - Horas semanales)
   * `tipo_na_ylab` (Sección 4 - Ingreso laboral)
2. Asignación lógica basada en los filtros cruzados de boleta.
3. Generación del gráfico apilado `06_clasificacion_na.png`.
4. Persistencia en `persona_06.rds`.

## 4. Métricas de Impacto
* Variables sintéticas de auditoría creadas: 4 columnas `tipo_na_*`.
* Gráfico generado: `06_images/06_clasificacion_na.png`.
* Dimensiones resultantes: 39,497 filas x 282 columnas.
* Registro en bitácora: Paso 06 registrado.