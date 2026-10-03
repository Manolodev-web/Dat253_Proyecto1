# Resumen Ejecutivo - Bloque 2: Salud y Fecundidad

## 1. Puntos Clave del Bloque
1. **Auditoría de Afiliación Médica (`cobersalud`):** Se identificaron y resolvieron los registros sin seguro declarado mediante cruce con las preguntas directas de afiliación (`s02a_01a`), creando la bandera de trazabilidad `cobersalud_imputado = 0/1`.
2. **Consistencia Biológica de Fecundidad (Sección 2 Parte B):** Se aplicó el filtro estricto de cuestionario censal: las variables de embarazo y controles prenatales quedaron restringidas al universo de mujeres biológicas de 13 a 50 años, anulando cualquier valor espurio fuera de este rango.
3. **Regularización del Módulo de Discapacidad:** Se verificaron las 6 dimensiones de dificultad permanente (`s02a_04a` a `s02a_04f`), eliminando inconsistencias y asegurando su dominio ordinal de 1 a 4.
4. **Agregación de Gastos de Bolsillo:** Se procesaron los 5 rubros de gasto médico en consulta externa, medicamentos, prótesis, exámenes e internación (`s02a_03a` a `s02a_03e`), asignando ceros lógicos a personas sin consulta y consolidando la variable sintética `gasto_salud_total`.
5. **Certificación Fail-Fast:** Cuatro pruebas de aserción dura (`stopifnot`) validaron la completitud de cobertura, no negatividad de gastos y exclusión biológica sin excepciones.

---

## 2. Métricas de Transformación (Antes vs. Después)

| Indicador Metodológico | Estado Inicial (persona_11) | Estado Final (persona_16) | Criterio de Calidad |
| :--- | :---: | :---: | :--- |
| **NAs en `cobersalud`** | Nulos presentes | 0 NAs (100% clasificado) | Reconciliación con boleta de seguro |
| **Bandera de Linaje Cobertura** | Inexistente | `cobersalud_imputado` (0/1) | Trazabilidad del dato imputado |
| **Respuestas espurias en fecundidad** | Respuestas fuera de rango | 0 casos anómalos | Filtro biológico: mujeres [13 - 50] |
| **NAs en Gastos Médicos** | NAs mixtos | Ceros analíticos (0 Bs) | Ausencia de atención médica = 0 gasto |
| **Variable `gasto_salud_total`** | Inexistente | Creada e integrada | Suma contable de 5 rubros de salud |
| **Aserciones `stopifnot`** | No evaluadas | 4 reglas aprobadas | Principio Fail-Fast (ZDM) |

---

## 3. Evidencias Gráficas Generadas
* **`06_images/12_salud_cobertura.png`**: Distribución poblacional por tipo de seguro médico (SUS, Caja de Salud, Privado, Sin cobertura).
* **`06_images/15_salud_gastos_bolsillo.png`**: Histograma de la distribución del gasto de bolsillo en salud individual para quienes incurrieron en costos médicos.

---

## 4. Trazabilidad de Auditoría
Todas las intervenciones quedaron asentadas con marca de tiempo, volumen de filas modificadas y justificación teórica en:
`04_bitacora/bitacora_limpieza.csv` (Pasos 12, 13, 14, 15 y 16 completados).