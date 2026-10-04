---
id_script: "15"
nombre_archivo: "15_salud_gastos_bolsillo.R"
bloque: "02_salud"
fase_metodologica: "Fase 4: Tratamiento de Gastos y Creacion de Sinteticas"
entrada: "03_data/02_interim/persona_14.rds"
salida: "03_data/02_interim/persona_15.rds"
evidencia_grafica: "06_images/15_salud_gastos_bolsillo.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 15: Saneamiento de Gastos de Bolsillo y Gasto Total en Salud

## 1. Contexto y Diagnóstico Forense
Las variables de gasto médico individual por eventos de salud en el último mes (`s02a_03a` a `s02a_03e`: consulta, aparatos/lentes, internación, exámenes/laboratorio y medicamentos) contenían valores `NA` masivos en aquellos empadronados que no sufrieron enfermedades ni asistieron a centros de salud.

## 2. Justificación Teórica y Estándar OMS/OPS
En encuestas de hogares, la no utilización de servicios de salud no constituye una pérdida estocástica de información, sino una decisión observable cuyo costo económico incurrido es de **0 Bs**. Asimismo, los estudios de gasto catastrófico en salud (estándar OMS) requieren consolidar el gasto médico total de bolsillo por individuo mediante la suma lineal de sus componentes.

## 3. Algoritmo y Procedimiento en R
1. Coerción atómica a tipo numérico de las columnas `s02a_03a` a `s02a_03e`.
2. Asignación sistemática de ceros analíticos: sustitución de `NA` por `0.0`.
3. Construcción de la variable sintética agregada:
   $$\text{gasto\_salud\_total} = \sum_{k=a}^{e} s02a\_03k$$
4. Asignación de etiquetas descriptivas con `Hmisc::label()`.
5. Generación de la figura `15_salud_gastos_bolsillo.png` mostrando el histograma de gastos en la submuestra de personas con desembolsos positivos.
6. Guardado en `persona_15.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Personas con gasto médico de bolsillo positivo: Identificadas y consolidadas.
* Variable sintética creada: `gasto_salud_total` (con 0 NAs y valores estrictamente no negativos).
* Gráfico generado: `06_images/15_salud_gastos_bolsillo.png`.
* Checkpoint generado: `03_data/02_interim/persona_15.rds`.
* Registro en bitácora: Paso 15 registrado formalmente.