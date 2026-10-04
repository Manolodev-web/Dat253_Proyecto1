---
id_script: "24"
nombre_archivo: "24_emp_imputacion_mice.R"
bloque: "04_empleo"
fase_metodologica: "Fase 4: Imputacion Estocastica Multivariada (MICE / PMM)"
entrada: "03_data/02_interim/persona_23.rds"
salida: "03_data/02_interim/persona_24.rds"
evidencia_grafica: "06_images/24_emp_imputacion_ylab.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 24: Imputación Multivariada de Ingresos Laborales con MICE / PMM

## 1. Contexto y Diagnóstico Forense
En la Encuesta de Hogares 2024, un total de **2,751 trabajadores ocupados ($condact = 1$)** declararon su actividad y jornada pero omitieron su remuneración líquida (`ylab = NA`). La omisión de ingresos laborales en encuestas responde típicamente a motivos de desconfianza fiscal o desconocimiento en empleos informales (*Missing at Random - MAR*).

## 2. Justificación Teórica: Predictive Mean Matching (PMM) vs Métodos Clásicos
* **Falla de la media o regresión ordinaria:** La imputación por la media reduce artificialmente la varianza y concentra la distribución en un pico irreal. La regresión lineal paramétrica clásica asume normalidad y puede predecir valores negativos imposibles para un salario ($ylab < 0$).
* **Ventajas del método PMM de Rubin (1986):** Predictive Mean Matching calcula una predicción lineal preliminar para cada caso faltante, pero en lugar de usar ese número matemático directo, busca en la submuestra de casos observados a los donantes más cercanos (*k-nearest neighbors* basados en la métrica de distancia de predicción) y toma prestado el valor real de un donante empírico.
  * Garantiza no negatividad estricta sin transformaciones logarítmicas artificiales.
  * Preserva la asimetría positiva, colas pesadas y distribución discreta de la moneda boliviana.
  * Mantiene las correlaciones multivariadas con educación, horas y ubicación.

## 3. Algoritmo y Procedimiento en R
1. Selección de 8 covariables predictoras estructurales: `ylab`, `edad`, `sexo`, `area`, `depto`, `aestudio`, `tothrs`, `clima_educativo_hogar`.
2. Fijación de semilla reproducible: `set.seed(253)`.
3. Ejecución de `mice::mice()` con método `"pmm"`, $m = 1$ imputación y 5 iteraciones de cadenas de Markov.
4. Transferencia de los valores imputados a `df$ylab` en los 2,751 registros identificados.
5. Activación de la bandera de linaje: `ylab_imputado[idx] <- 1L`.
6. Confirmación de 0 Bs en población inactiva o desocupada.
7. Generación de la figura `24_emp_imputacion_ylab.png` comparando las densidades empíricas entre datos observados e imputados.
8. Guardado en `persona_24.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Ocupados con ingresos imputados: 2,751 trabajadores.
* Superposición distribucional: Convalidada mediante curvas de densidad idénticas.
* Completitud en `ylab`: 100.0% (0 NAs en todo el dataset).
* Bandera de linaje: `ylab_imputado` activa en los 2,751 casos.
* Gráfico generado: `06_images/24_emp_imputacion_ylab.png`.
* Checkpoint generado: `03_data/02_interim/persona_24.rds`.
* Registro en bitácora: Paso 24 registrado formalmente.