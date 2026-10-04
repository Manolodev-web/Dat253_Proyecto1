---
id_script: "10"
nombre_archivo: "10_viv_ingreso_hogar_pobreza.R"
bloque: "01_vivienda"
fase_metodologica: "Fase 5: Validacion de Consistencia Logica y Reglas FGT"
entrada: "03_data/02_interim/persona_09.rds"
salida: "03_data/02_interim/persona_10.rds"
evidencia_grafica: "06_images/10_viv_ingreso_pobreza.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 10: Sincronización Contable de Ingreso Per Cápita y Axiomas FGT

## 1. Contexto y Diagnóstico Forense
La corrección del tamaño del hogar (`totper`) en el paso anterior dejó a la variable `yhogpc` (ingreso per cápita del hogar) desfasada en relación a la ecuación contable. Asimismo, las variables oficiales de pobreza monetaria (`p0` pobreza moderada y `pext0` pobreza extrema) requerían verificación contra las líneas de corte del INE (`z` y `zext`).

## 2. Justificación Teórica: Ecuaciones Contables y Axiomas FGT
1. **Identidad Contable Per Cápita:**
   $$yhogpc = \frac{yhog}{totper}$$
2. **Jerarquía Axiomática de Pobreza (Foster-Greer-Thorbecke, 1984):** La canasta de indigencia o pobreza extrema ($zext$) es un subconjunto biológico de la canasta básica total o pobreza moderada ($z$), por lo que estrictamente:
   $$zext \le z$$
   Consecuentemente, el conjunto de personas en indigencia es un subconjunto estricto de los pobres moderados:
   $$pext0 = 1 \implies p0 = 1$$

## 3. Algoritmo y Procedimiento en R
1. Despojo preventivo de clases `<labelled>` convirtiendo las variables monetarias a vectores `<double>` primitivos para blindar el código contra errores de coerción en `dplyr`.
2. Recálculo sincronizado de `yhogpc` como cociente entre `yhog` y el `totper` reconstruido.
3. Evaluación de consistencia de umbrales: comprobación de que ninguna fila registre $zext > z$.
4. Imposición de la regla de inclusión: todo individuo con $pext0 == 1$ se fuerza a $p0 = 1$.
5. Construcción de la figura `10_viv_ingreso_pobreza.png` mostrando la distribución de `yhogpc` por categoría de pobreza.
6. Guardado en `persona_10.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Discrepancias corregidas en `yhogpc`: Universal en hogares pluripersonales.
* Violaciones en líneas $zext > z$: 0 violaciones detectadas.
* Inconsistencias de pobreza extrema sin pobreza moderada: 0 remanentes.
* Gráfico generado: `06_images/10_viv_ingreso_pobreza.png`.
* Registro en bitácora: Paso 10 registrado formalmente.