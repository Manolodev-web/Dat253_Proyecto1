# ==============================================================================
# Script: 31_exportar_dataset_final.R
# Bloque: 05 - Ingresos No Laborales y Consolidacion Final
# Descripcion: Exportacion del dataset maestro final en formatos duales (.rds,
#              .csv abierto y .csv codificado numerico) y catalogo de metadatos.
# Entrada: 03_data/02_interim/persona_30.rds
# Salida:  03_data/03_processed/persona_limpio.rds
#          03_data/03_processed/persona_limpio.csv
#          03_data/03_processed/persona_limpio_codificado.csv
#          03_data/04_metadatos/diccionario_final.csv
# ==============================================================================

# 1. AUTO-UBICACION INTELIGENTE DE LA RAIZ
ruta_script <- tryCatch({
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    dirname(rstudioapi::getActiveDocumentContext()$path)
  } else { getwd() }
}, error = function(e) getwd())

dir_raiz <- normalizePath(ruta_script, winslash = "/", mustWork = FALSE)
while (!dir.exists(file.path(dir_raiz, "03_data")) && dirname(dir_raiz) != dir_raiz) {
  dir_raiz <- dirname(dir_raiz)
}
setwd(dir_raiz)
message(">>> [OK] Raiz del proyecto fijada en: ", getwd())

source("02_R_helpers/funciones.R")

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(Hmisc)
})

message(">>> [INICIO] Ejecutando 31_exportar_dataset_final.R...")

# 2. Cargar estado anterior
ruta_interim_30 <- file.path("03_data", "02_interim", "persona_30.rds")
if (!file.exists(ruta_interim_30)) {
  stop("ERROR: No se encuentra persona_30.rds. Ejecuta primero 30_ingreso_total_consolidacion.R")
}

df <- readRDS(ruta_interim_30)
n_filas <- nrow(df)
n_cols  <- ncol(df)

dir_salida_datos <- file.path("03_data", "03_processed")
if (!dir.exists(dir_salida_datos)) dir.create(dir_salida_datos, recursive = TRUE)

# 3. Exportacion 1: Dataset binario optimizado (.rds)
ruta_rds_final <- file.path(dir_salida_datos, "persona_limpio.rds")
saveRDS(df, ruta_rds_final)
message(paste0(">>> [1/3] Dataset RDS binario guardado en: ", ruta_rds_final))

# 4. Exportacion 2: Dataset plano abierto (.csv)
ruta_csv_final <- file.path(dir_salida_datos, "persona_limpio.csv")
readr::write_csv(df, ruta_csv_final)
message(paste0(">>> [2/3] Dataset CSV estandar guardado en: ", ruta_csv_final))

# 5. Exportacion 3: Dataset codificado numerico para econometria (.csv)
df_codificado <- df
for (col in names(df_codificado)) {
  if (is.factor(df_codificado[[col]])) {
    df_codificado[[col]] <- as.integer(df_codificado[[col]])
  }
}
ruta_csv_cod <- file.path(dir_salida_datos, "persona_limpio_codificado.csv")
readr::write_csv(df_codificado, ruta_csv_cod)
message(paste0(">>> [3/3] Dataset CSV codificado numerico guardado en: ", ruta_csv_cod))

# 6. Generacion automatica del diccionario de metadatos final
diccionario_final <- data.frame(
  columna_id = 1:n_cols,
  nombre_atributo = names(df),
  tipo_dato_r = sapply(df, function(x) class(x)[1]),
  etiqueta_semantica = sapply(df, function(x) {
    lbl <- attr(x, "label")
    if (is.null(lbl) || length(lbl) == 0) return("Sin etiqueta")
    return(as.character(lbl))
  }),
  total_valores_na = sapply(df, function(x) sum(is.na(x))),
  valores_distintos = sapply(df, function(x) length(unique(x))),
  stringsAsFactors = FALSE
)

ruta_dicc_final <- file.path("03_data", "04_metadatos", "diccionario_final.csv")
readr::write_csv(diccionario_final, ruta_dicc_final)
message(paste0(">>> [OK] Diccionario final de datos guardado en: ", ruta_dicc_final))

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 31,
  atributo = "DATASET_MAESTRO_FINAL",
  tipo_problema = "Exportacion Definitiva y Metadatos",
  metodologia_fase = "Fase 5: Evaluacion y Despliegue de Datos",
  accion_realizada = paste0("Generacion de persona_limpio.rds, persona_limpio.csv y persona_limpio_codificado.csv (", 
                            n_filas, "x", n_cols, ") con diccionario_final.csv"),
  criterio_justificacion = "Proveer version nativa RDS con etiquetas, version tabular estandar y version codificada numerica para modelos econometricos",
  filas_afectadas = n_filas,
  impacto_dataset = paste0("Exportados 3 formatos maestros y 1 catalogo formal de ", n_cols, " columnas"),
  codigo_script = "05_scripts/06_bloque5_consolidacion/31_exportar_dataset_final.R"
)

message(">>> [FIN] Script 31_exportar_dataset_final.R completado exitosamente.\n")