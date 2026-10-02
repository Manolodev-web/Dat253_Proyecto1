# Limpieza de la base `persona` · Encuesta de Hogares (INE Bolivia)

Proyecto de limpieza documentada (R) de `persona.csv` (39.497 personas × 275 variables), organizado en 6 bloques: **0 Global · 1 Vivienda · 2 Salud · 3 Educación · 4 Empleo e ingresos · 5 Cierre**.

## Cómo ejecutar
```bash
LC_ALL=C.UTF-8 Rscript run_all.R        # paquetes: readr, dplyr, ggplot2, stringr, stringi, tibble
```
Cada script `scripts/NN_*.R` lee la salida del anterior (`data/interim/`), escribe su imagen (`images/NN_*.png`), su informe (`informes/NN_*.md`) y añade filas a `bitacora/bitacora_limpieza.csv` (12 columnas).

## Estado
Bloque 0 (scripts 00–07) completo. Ver `docs/ESTADO_PROYECTO.md` y `informes/resumenes/resumen_bloque_0.md`.

## Estructura
`config/` parámetros · `R/funciones.R` utilidades · `scripts/` · `data/{raw,interim,clean,metadatos}` · `images/` · `informes/` · `bitacora/` · `docs/`
