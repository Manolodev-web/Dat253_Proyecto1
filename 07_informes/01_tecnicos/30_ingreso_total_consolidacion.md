---
id_script: "30"
nombre_archivo: "30_ingreso_total_consolidacion.R"
bloque: "05_consolidacion"
fase_metodologica: "Fase 5: Validacion de Consistencia Logica y Agregacion Contable"
entrada: "03_data/02_interim/persona_29.rds"
salida: "03_data/02_interim/persona_30.rds"
evidencia_grafica: "06_images/30_ingreso_pobreza_final.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 30: Reconciliación Contable de Ingresos y Recalibración de Pobreza

## 1. Contexto y Objetivos Analíticos
Con los ingresos laborales (`ylab`) e ingresos no laborales (`ynolab`) completamente saneados, imputados y continuos, este script ejecuta el cierre del circuito contable de bienestar individual y de hogar, garantizando la consistencia exacta en tres niveles de agregación y recalculando las tasas oficiales de pobreza FGT.

## 2. Fundamentación Teórica y Ecuaciones Contables
1. **Identidad Contable Individual:**
   $$yper_i = ylab_i + ynolab_i$$
2. **Agregación Contable del Hogar (por folio):**
   $$yhog_h = \sum_{j \in h} yper_j$$
3. **Identidad Per Cápita Sincronizada:**
   $$yhogpc_h = \frac{yhog_h}{totper_h}$$
4. **Recalibración de Pobreza FGT (Foster-Greer-Thorbecke, 1984):**
   * Pobreza Extrema / Indigencia:
     $$pext0_i = \mathbb{I}(yhogpc_i < zext_i)$$
   * Pobreza Moderada:
     $$p0_i = \mathbb{I}(yhogpc_i < z_i)$$
   * Axioma de Inclusión de Conjuntos:
     $$pext0_i = 1 \implies p0_i = 1$$

## 3. Algoritmo y Procedimiento en R
1. Coerción de variables monetarias y líneas de pobreza a `<double>`.
2. Cálculo lineal exacto de `yper = round(ylab + ynolab, 2)`.
3. Agrupación por `folio`, cálculo del total acumulado de ingresos por hogar y sincronización de `yhog`.
4. Recálculo del ingreso per cápita: `yhogpc = round(yhog / totper, 2)`.
5. Evaluación vectorial de las condiciones de pobreza contra los umbrales oficiales `z` y `zext`.
6. Forzado axiomático: imposición estricta de que todo pobre extremo pertenezca al conjunto de pobres moderados.
7. Generación de la figura `30_ingreso_pobreza_final.png` contrastando la función de densidad empírica de `yhogpc` contra las líneas oficiales de pobreza.
8. Guardado en `persona_30.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Tasa de Pobreza Moderada ($p0$) consolidada: Calculada e informada en consola.
* Tasa de Pobreza Extrema ($pext0$) consolidada: Calculada e informada en consola.
* Inconsistencias contables residuales: 0 discrepancias ($yper$, $yhog$, $yhogpc$ exactos).
* Gráfico generado: `06_images/30_ingreso_pobreza_final.png`.
* Checkpoint generado: `03_data/02_interim/persona_30.rds`.
* Registro en bitácora: Paso 30 registrado formalmente.