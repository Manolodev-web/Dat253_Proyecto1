# Resumen Ejecutivo - Bloque 4: Mercado de Trabajo e Ingresos Laborales

## 1. Puntos Clave del Bloque
1. **Auditoria del Mercado Laboral y Tasas Macro:** Se identifico la Poblacion en Edad de Trabajar (PET >= 14 anios) y la Poblacion Economicamente Activa (PEA = Ocupados + Desocupados), estimando una Tasa Global de Participacion (TGP) y Tasa de Desempleo (TD) plenamente consistentes con los agregados oficiales del INE.
2. **Saneamiento y Acotamiento Fisiologico de Horas (`tothrs`):** Se trataron los 52 casos con omision de jornada laboral mediante mediana condicional por estrato ocupacional y sexo, acotando jornadas extremas al limite fisiologico tolerable (112 horas semanales).
3. **Imputacion Estocastica Multivariada con MICE / PMM:** Se resolvio la no respuesta en 2,751 ingresos laborales de trabajadores ocupados utilizando *Predictive Mean Matching* con 8 covariables predictoras (edad, sexo, area, depto, escolaridad, jornada y clima educativo). PMM preservo la distribucion empirica, la asimetria positiva y garantizo la ausencia de ingresos negativos.
4. **Auditoria del Salario Minimo Nacional (SMN):** Se contrasto el ingreso mensual contra el SMN legal vigente en Bolivia (2,500 Bs), identificando que una fraccion sustantiva de trabajadores a tiempo completo percibe ingresos inferiores al umbral normativo, capturando la informalidad laboral.
5. **Ingenieria de Variables Sinteticas:** Se crearon las variables sinteticas `ingreso_horario` (productividad del trabajo por hora), `subempleo_horario` (< 40 hrs) y `sobreempleo_horario` (> 48 hrs).
6. **Certificacion Fail-Fast:** Seis aserciones duras (`stopifnot`) comprobaron completitud total de ingresos y horas, no negatividad estricta y consistencia de ceros en inactivos.

---

## 2. Métricas de Transformación (Antes vs. Después)

| Indicador Metodológico | Estado Inicial (persona_21) | Estado Final (persona_27) | Criterio de Calidad |
| :--- | :---: | :---: | :--- |
| **NAs en Ingreso Laboral (`ylab`)** | 2,751 omisiones en ocupados | **0 NAs (100% completo)** | Imputacion MICE / PMM (seed=253) |
| **Bandera de Linaje Ingresos** | Inicializada en 0 | `ylab_imputado` (0/1 activo) | Trazabilidad del dato imputado |
| **NAs en Jornada Semanal (`tothrs`)** | 52 casos sin horas | **0 NAs (100% completo)** | Mediana condicional por sector |
| **Jornadas Atipicas (> 112 hrs)** | Valores espurios | Acotados a 112 hrs | Limite fisiologico (16h x 7d) |
| **Variable `ingreso_horario`** | Inexistente | Creada e integrada | Ingreso por hora (ylab / horas mes) |
| **Indicadores de Precariedad** | Inexistentes | `debajo_smn`, `subempleo` | Metricas de calidad del empleo |
| **Aserciones `stopifnot`** | No evaluadas | 6 reglas aprobadas | Principio Fail-Fast (ZDM) |

---

## 3. Evidencias Gráficas Generadas
* **`06_images/22_emp_diagnostico.png`**: Estructura de la poblacion segun condicion de actividad laboral (PET, Ocupados, Desocupados, Inactivos).
* **`06_images/23_emp_horas_trabajo.png`**: Histograma de horas semanales trabajadas destacando la concentracion en la jornada legal de 48 horas.
* **`06_images/24_emp_imputacion_ylab.png`**: Comparativa de curvas de densidad entre ingresos observados e ingresos imputados con MICE/PMM.
* **`06_images/25_emp_distribucion_ingresos.png`**: Distribucion de ingresos laborales y porcentaje de poblacion bajo el Salario Minimo Nacional.
* **`06_images/26_emp_ingreso_horario.png`**: Diagrama de caja del ingreso laboral horario segun nivel de instruccion formal y sexo.

---

## 4. Trazabilidad de Auditoría
Todas las intervenciones quedaron documentadas con marca de tiempo, volumen de filas modificadas y justificación metodológica en:
`04_bitacora/bitacora_limpieza.csv` (Pasos 22 al 27 completados).