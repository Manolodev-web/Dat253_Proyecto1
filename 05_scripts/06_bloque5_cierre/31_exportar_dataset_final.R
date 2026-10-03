# ==============================================================================
# Script: 31_exportar_dataset_final.R
# Bloque: 05 - Ingresos No Laborales y Consolidacion Final
# Descripcion: Exportacion del dataset maestro final (persona_limpio.rds y .csv)
#              y generacion del diccionario de datos final tabular.
# Entrada: 03_data/02_interim/persona_30.rds
# Salida:  03_data/03_processed/persona_limpio.rds
#          03_data/03_processed/persona_limpio.csv
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

# 3. Exportar datasets definitivos a 03_data/03_processed/
if (!dir.exists("03_data/03_processed")) dir.create("03_data/03_processed", recursive = TRUE)

ruta_rds_final <- file.path("03_data", "03_processed", "persona_limpio.rds")
saveRDS(df, ruta_rds_final)
message(paste0(">>> [EXPORTACION OK] Dataset binario guardado en: ", ruta_rds_final))

ruta_csv_final <- file.path("03_data", "03_processed", "persona_limpio.csv")
readr::write_csv(df, ruta_csv_final)
message(paste0(">>> [EXPORTACION OK] Dataset CSV abierto guardado en: ", ruta_csv_final))

# 4. Generacion automatica del diccionario de datos final
nombres_cols <- names(df)
tipos_cols   <- sapply(df, function(x) class(x)[1])
nas_cols     <- sapply(df, function(x) sum(is.na(x)))
unicos_cols  <- sapply(df, function(x) length(unique(x)))

etiquetas_cols <- sapply(df, function(x) {
  lbl <- attr(x, "label")
  if (is.null(lbl) || length(lbl) == 0) return("Sin etiqueta")
  return(as.character(lbl))
})

diccionario_final <- data.frame(
  columna_id = 1:n_cols,
  nombre_atributo = nombres_cols,
  tipo_dato_r = tipos_cols,
  etiqueta_semantica = etiquetas_cols,
  total_valores_na = nas_cols,
  valores_distintos = unicos_cols,
  stringsAsFactors = FALSE
)

ruta_dicc_final <- file.path("03_data", "04_metadatos", "diccionario_final.csv")
readr::write_csv(diccionario_final, ruta_dicc_final)
message(paste0(">>> [EXPORTACION OK] Diccionario final de datos guardado en: ", ruta_dicc_final))

# 5. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 31,
  atributo = "DATASET_MAESTRO_FINAL",
  tipo_problema = "Exportacion Definitiva y Metadatos",
  metodologia_fase = "Fase 5: Evaluacion y Despliegue de Datos",
  accion_realizada = paste0("Generacion de persona_limpio.rds, persona_limpio.csv (", 
                            n_filas, "x", n_cols, ") y exportacion de diccionario_final.csv"),
  criterio_justificacion = "Preservar version binaria optimizada con metadatos para analisis en R y CSV plano para interoperabilidad web y docencia",
  filas_afectadas = n_filas,
  impacto_dataset = paste0("Exportados 2 formatos maestros y 1 catalogo formal de ", n_cols, " columnas"),
  codigo_script = "05_scripts/06_bloque5_consolidacion/31_exportar_dataset_final.R"
)

message(">>> [FIN] Script 31_exportar_dataset_final.R completado exitosamente.\n")