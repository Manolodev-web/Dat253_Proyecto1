# ==============================================================================
# Script: 21_edu_validacion.R
# Bloque: 03 - Educacion
# Descripcion: Bateria de validacion estricta (Fail-Fast) del Bloque 3 (Educacion).
# Entrada: 03_data/02_interim/persona_20.rds
# Salida:  03_data/02_interim/persona_21.rds (Cierre Bloque 3)
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
message(">>>Raiz del proyecto fijada en: ", getwd())

source("02_R_helpers/funciones.R")

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

message(">>>Ejecutando 21_edu_validacion.R...")

# 2. Cargar estado anterior
ruta_interim_20 <- file.path("03_data", "02_interim", "persona_20.rds")
if (!file.exists(ruta_interim_20)) {
  stop("ERROR: No se encuentra persona_20.rds. Ejecuta primero 20_edu_tics_sinteticas.R")
}

df <- readRDS(ruta_interim_20)
n_filas <- nrow(df)
n_cols  <- ncol(df)

message(">>> Ejecutando bateria de aserciones de consistencia en Educacion...")

# Asercion 1: Completitud absoluta en aestudio (0 NAs)
stopifnot(all(!is.na(df$aestudio)))
message(">>> [PASO 1/5] Asercion aestudio sin valores faltantes (0 NAs): APROBADA")

# Asercion 2: Cota biologica censal aestudio <= max(0, edad - 4)
violaciones_biologicas <- sum(df$aestudio > pmax(0, df$edad - 4))
stopifnot(violaciones_biologicas == 0)
message(">>> [PASO 2/5] Asercion cota biologica aestudio <= (edad - 4): APROBADA")

# Asercion 3: Menores de 4 anios tienen exactamente 0 anios de estudio
menores_no_cero <- sum(df$edad < 4 & df$aestudio != 0)
stopifnot(menores_no_cero == 0)
message(">>> [PASO 3/5] Asercion menores de 4 anios con aestudio == 0: APROBADA")

# Asercion 4: No negatividad en escolaridad
stopifnot(all(df$aestudio >= 0))
message(">>> [PASO 4/5] Asercion no negatividad en aestudio: APROBADA")

# Asercion 5: Clima educativo del hogar completo y no negativo
stopifnot(all(!is.na(df$clima_educativo_hogar)))
stopifnot(all(df$clima_educativo_hogar >= 0))
message(">>> [PASO 5/5] Asercion consistencia de clima_educativo_hogar: APROBADA")

# 3. Guardar checkpoint definitivo de cierre del Bloque 3
guardar_interim(df, "persona_21")

# 4. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 21,
  atributo = "BLOQUE 3 (Educacion)",
  tipo_problema = "Validacion Estricta de Cierre",
  metodologia_fase = "Fase 5: Evaluacion y Cierre de Bloque",
  accion_realizada = "Bateria de 5 aserciones duras (aestudio completo, cota biologica, menores con 0, no negatividad y clima educativo) aprobada al 100%",
  criterio_justificacion = "Metodologia Fail-Fast: certificar que el capital humano individual y del hogar este completamente saneado previo al bloque de empleo e ingresos",
  filas_afectadas = 0,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Bloque 3 certificado sin defectos)"),
  codigo_script = "05_scripts/04_bloque3_educacion/21_edu_validacion.R"
)

message(">>>Script 21_edu_validacion.R completado exitosamente.")
message(">>> ¡BLOQUE 3 (EDUCACION) FINALIZADO!\n")