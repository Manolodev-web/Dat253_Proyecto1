# ==============================================================================
# Script: 03_normalizar_texto.R
# Bloque: 00 - Global
# Descripcion: Estandarizacion de campos de texto abierto (trimming, mayusculas,
#              reemplazo de acentos y 'n'/'anio', conversion de vacios a NA).
# Entrada: 03_data/02_interim/persona_02.rds
# Salida:  03_data/02_interim/persona_03.rds
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
  library(stringr)
})

message(">>>Ejecutando 03_normalizar_texto.R...")

# 2. Cargar estado anterior
ruta_interim_02 <- file.path("03_data", "02_interim", "persona_02.rds")
if (!file.exists(ruta_interim_02)) {
  stop("ERROR: No se encuentra persona_02.rds. Ejecuta primero 02_tipos_unarias_etiquetas.R")
}

df <- readRDS(ruta_interim_02)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Identificar campos de texto abierto especificos
cols_texto_abierto <- c(
  "s01b_12e", "s02a_01e", "s02a_02he", "s02b_10e", 
  "s03a_05e", "s03b_11e", "s03c_17e", "s04a_06e", 
  "s04a_07e", "s05a_02ce", "s05b_06ae", "s05b_06be", 
  "s05b_06ce", "s05c_09e"
)

cols_presentes <- intersect(cols_texto_abierto, names(df))

# Funcion de limpieza y transliteracion a ASCII puro
limpiar_cadena <- function(cadena) {
  if (all(is.na(cadena))) return(cadena)
  
  txt <- as.character(cadena)
  txt <- stringr::str_trim(txt)
  txt <- stringr::str_squish(txt)
  txt <- stringr::str_to_upper(txt)
  
  # Sustitucion de tildes mediante escapes unicode para portabilidad ASCII
  txt <- chartr("\u00c1\u00c9\u00cd\u00d3\u00da\u00dc\u00e1\u00e9\u00ed\u00f3\u00fa\u00fc", 
                 "AEIOUUaeiouu", txt)
  txt <- gsub("\u00d1", "N", txt)
  txt <- gsub("\u00f1", "n", txt)
  
  # Reemplazo de palabras comunes con enie a formato anio/nino
  txt <- gsub("\\bANO\\b", "ANIO", txt)
  txt <- gsub("\\bANOS\\b", "ANIOS", txt)
  txt <- gsub("\\bNINA\\b", "NINA", txt)
  txt <- gsub("\\bNINO\\b", "NINO", txt)
  txt <- gsub("\\bNINOS\\b", "NINOS", txt)
  txt <- gsub("\\bNINAS\\b", "NINAS", txt)
  
  # Cadenas vacias a NA
  txt[txt %in% c("", " ", "NA", "NULL", "NONE")] <- NA_character_
  return(txt)
}

conteo_modificados <- 0
for (col in cols_presentes) {
  orig <- df[[col]]
  limp <- limpiar_cadena(orig)
  diffs <- sum(!is.na(orig) & (orig != limp), na.rm = TRUE)
  conteo_modificados <- conteo_modificados + diffs
  df[[col]] <- limp
}

message(paste0(">>> Columnas de texto abiertas procesadas: ", length(cols_presentes)))
message(paste0(">>> Total de celdas saneadas y normalizadas a ASCII: ", conteo_modificados))

# 4. Persistencia interim
guardar_interim(df, "persona_03")

# 5. Registro en Bitacora
log_bitacora(
  id_paso = 3,
  atributo = paste(cols_presentes, collapse = ", "),
  tipo_problema = "Formato de Texto / Codificacion",
  metodologia_fase = "Fase 2: Normalizacion de Formatos",
  accion_realizada = "Trimming, colapso de espacios, conversion a mayusculas, remocion de tildes/enie a ASCII y conversion de vacios a NA",
  criterio_justificacion = "Homogeneizacion de respuestas abiertas y prevencion de errores de parseo multiplataforma",
  filas_afectadas = conteo_modificados,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Texto normalizado en ", length(cols_presentes), " atributos)"),
  codigo_script = "05_scripts/01_bloque0_global/03_normalizar_texto.R"
)

message(">>>Script 03_normalizar_texto.R completado.\n")