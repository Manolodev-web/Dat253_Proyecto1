# Resumen Ejecutivo - Bloque 1: Vivienda, Hogar y Pobreza

## 1. Puntos Clave del Bloque
1. **Detección del Aplanamiento en `totper`:** En la base original, la variable `totper` figuraba colapsada en `1.0` en 39,477 filas y con 20 `NA`, anulando el tamaño real de los hogares.
2. **Reconstrucción mediante Agregación por Folio:** Se recalculó `totper` mediante el conteo exacto de registros por cada `folio`, restaurando la distribución real de miembros (rango de 1 a 19 personas por hogar, promedio de 3.11 miembros).
3. **Consistencia de Tipología de Hogar:** Se validó que los hogares clasificados como unipersonales (`tipohogar == 1`) coincidan estrictamente con `totper == 1`.
4. **Sincronización de Ingreso Per Cápita (`yhogpc`):** Se recalculó el ingreso per cápita del hogar dividiendo el ingreso total (`yhog`) entre el tamaño corregido (`totper`), eliminando distorsiones contables.
5. **Certificación de Reglas FGT de Pobreza:** Se validó que las líneas de indigencia no superen a las de pobreza ($zext \le z$) y se aseguró la coherencia teórica de que todo pobre extremo pertenezca al conjunto de pobres moderados ($pext0 = 1 \implies p0 = 1$).

---

## 2. Métricas de Transformación (Antes vs. Después)

| Indicador Metodológico | Estado Inicial (persona_07) | Estado Final (persona_11) | Criterio de Calidad |
| :--- | :---: | :---: | :--- |
| **Distribución de `totper`** | Aplanado en 1.0 (99.9%) | [1 - 19] miembros reales | Conteo exacto por llave `folio` |
| **NAs en `totper`** | 20 registros | 0 registros | Reconstrucción completa |
| **Consistencia `yhogpc = yhog / totper`** | Discrepante en hogares > 1 | Consistencia exacta (100%) | Sincronización contable |
| **Inconsistencias $pext0 \subseteq p0$** | Posibles casos dispersos | 0 violaciones | Jerarquía axiomática FGT |
| **Aserciones `stopifnot`** | No evaluadas | 5 reglas aprobadas | Principio Fail-Fast (ZDM) |

---

## 3. Evidencias Gráficas Generadas
* **`06_images/08_viv_diagnostico_totper.png`**: Comparación entre el aplanamiento original y la distribución real del tamaño de los hogares bolivianos.
* **`06_images/10_viv_ingreso_pobreza.png`**: Distribución del ingreso per cápita mensual según condición de pobreza moderada y extrema.

---

## 4. Trazabilidad de Auditoría
Todas las intervenciones quedaron documentadas con marca de tiempo, filas modificadas y justificación teórica en:
`04_bitacora/bitacora_limpieza.csv` (Pasos 8, 9, 10 y 11 registrados).