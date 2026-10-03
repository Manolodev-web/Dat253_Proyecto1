# Resumen Ejecutivo - Bloque 0: Global y Auditoría Estructural

## 1. Puntos Clave del Bloque
1. **Auditoría Forense Dimensional:** Se verificó la base cruda con 39,497 registros y 275 atributos originales. Se identificaron 6,261,409 valores nulos (57.65%), demostrando que la ausencia responde fundamentalmente a saltos lógicos de la boleta censal (*skip patterns*).
2. **Reconciliación de Metadatos (Sección 1):** Se corrigió la discrepancia documental de variables sociodemográficas derivando de forma explícita `sexo` (`s01a_02`), `edad` (`s01a_03`) y `parentesco` (`s01a_05`), respaldado por el catálogo oficial DDI del INE (`diccionario_completo.pdf`). Se exportó el archivo auditable `diccionario_corregido.csv`.
3. **Estandarización de Tipos y Normalización ASCII:** Se convirtieron los identificadores a tipo carácter, se auditaron las 3 variables con varianza cero (`totper`, `s02a_01e`, `s05c_09e`) y se transliteraron 14 columnas de texto abierto a mayúsculas puras sin caracteres especiales ni tildes (`anio`, `nino`).
4. **Integridad Referencial y Jefatura Única:** Se validaron 0 duplicados en la base y 0 duplicados en la llave primaria `(folio, nro)`. Se comprobó que los 12,718 hogares poseen estricta y unívocamente un solo jefe o jefa de hogar con numeración correlativa.
5. **Taxonomía de Datos Faltantes y Banderas de Linaje:** Se construyó `reglas_saltos.csv` mapeando los 9 universos poblacionales. Se clasificaron los NAs en estructurales vs. reales y se asignaron ceros lógicos en horas, ingresos y escolaridad a quienes no correspondía aplicar la pregunta, inicializando las columnas indicadoras `*_imputado = 0`.

---

## 2. Métricas de Transformación (Antes vs. Después)

| Indicador Metodológico | Estado Inicial (persona_00) | Estado Final (persona_07) | Criterio de Ingeniería |
| :--- | :---: | :---: | :--- |
| **Total Columnas** | 275 | 285 | +3 demográficas, +4 flags tipo_na, +3 flags imputado |
| **Identificadores (folio, upm)** | Numérico / Mixto | Cadena (`character`) | Previene cálculos aritméticos espurios |
| **NAs en Ingreso Laboral (`ylab`)** | 24,964 | 2,751 | Inactivos y menores recodificados a 0 Bs |
| **NAs en Horas Trabajadas (`tothrs`)** | 24,942 | 52 | Inactivos y menores recodificados a 0 horas |
| **NAs en Escolaridad (`aestudio`)** | 2,425 | 18 | Menores de 4 años recodificados a 0 años |
| **Diccionarios Formalizados** | Inexistente | 2 archivos CSV | `diccionario_corregido.csv` y `reglas_saltos.csv` |

---

## 3. Evidencias Gráficas Generadas
* **`06_images/00_distribucion_nulos.png`**: Diagnóstico de completitud por tramos de ausencia en las 275 variables iniciales.
* **`06_images/02_tipos_datos.png`**: Distribución de tipos primitivos tras la coerción estructural.
* **`06_images/06_clasificacion_na.png`**: Demostración empírica de cómo los NAs estructurales superan ampliamente a las omisiones reales.

---

## 4. Trazabilidad de Auditoría
Todas las intervenciones quedaron asentadas con marca de tiempo, volumen de filas afectadas y justificación teórica en:
`04_bitacora/bitacora_limpieza.csv` (Pasos del 0 al 7 completados).