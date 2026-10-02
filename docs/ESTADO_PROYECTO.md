# Estado del proyecto (para retomar en otra conversación)

**Objetivo:** dejar `persona.csv` (EH INE Bolivia) con la menor cantidad de NA *reales*, documentando todo (bitácora de 12 columnas, informes `.md` con plantilla fija, imágenes, scripts R numerados). Temas: Vivienda, Salud, Educación, Empleo (+ ingresos). Se publicará en GitHub y un resumen irá a una página web.

## Hecho: Bloque 0 (scripts 00–07)
Pipeline: `data/interim/persona_NN.rds`. Versión con NA + máscara: `persona_07.rds` + `mascara_estructural.rds`. Versión codificada (estructurales = `NO APLICA` / -1 / -999): `persona_07_codificado.rds`.

## Hallazgos clave
- Diccionario: `s01a_02`=sexo, `s01a_03`=edad, `s01a_05`=parentesco (aliases `sexo`, `edad`, `parentesco`). `totper` constante → recalcular desde `folio`. `condact` (códigos 1–5) y `tipohogar` (1–7) difieren del diccionario. `s01a_06` y `s01a_05a` por verificar.
- NA: 6.261.409 → 93.737 reales (98,5% estructurales). Método: reglas de salto deducidas (script 05; tolerancia 2%, mínimo 50 filas, hasta 3 compuertas).
- `ylab`: solo 148 NA reales entre ocupados (no 2.770); categorías `s04b_12` 6 y 7 casi sin ingreso (trabajo no remunerado, confirmar con la boleta).
- NA reales en Vivienda: `totper`, `yhog` (20 filas cada una).
- Pendiente de revisión manual: 43 variables (81.372 NA) con >40% NA dentro de su universo; las 6 principales: `s02a_05`, `s01a_07_2`, `s03c_17ab`, `s01a_06`, `s02b_10`, `quienatenparto`.
- Estrategias sugeridas por variable: `data/metadatos/na_clasificados.csv`.

## Pendiente
Bloque 1 Vivienda (08–11) · 2 Salud (12–16) · 3 Educación (17–21) · 4 Empleo e ingresos (22–29) · 5 Cierre (30–33), según el diseño acordado: diagnóstico → tratamiento → imputación (hot-deck, regresión, `mice`/PMM) → validación (incluye Apriori, IQR/K-means). Cada bloque: un resumen `informes/resumenes/resumen_bloque_N.md`.

## Notas técnicas
Ejecutar con `LC_ALL=C.UTF-8 Rscript run_all.R`. Cada script llama `iniciar_script()`, `log_bitacora()`, `escribir_informe()`, `guardar_figura()`, `cerrar_script()` (ver `R/funciones.R`). Requiere R con readr, dplyr, ggplot2, stringr, stringi, tibble.

## Cifras de estrategia (na_clasificados.csv)
Variables con NA real: 'revisar' 43 · mediana/regresión 38 · moda/hot-deck 11 · mice PMM 5 · mice polyreg 4. NA reales imputables ≈ 12.365 (93.737 − 81.372).
