# ==============================================================================
# Script: 16_salud_validacion.R
# Bloque: 02 - Salud
# Descripcion: Bateria de validacion estricta (Fail-Fast) del Bloque 2 (Salud).
# Entrada: 03_data/02_interim/persona_15.rds
# Salida:  03_data/02_interim/persona_16.rds (Cierre Bloque 2)
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

message(">>>Ejecutando 16_salud_validacion.R...")

# 2. Cargar estado anterior
ruta_interim_15 <- file.path("03_data", "02_interim", "persona_15.rds")
if (!file.exists(ruta_interim_15)) {
  stop("ERROR: No se encuentra persona_15.rds. Ejecuta primero 15_salud_gastos_bolsillo.R")
}

df <- readRDS(ruta_interim_15)
n_filas <- nrow(df)
n_cols  <- ncol(df)

message(">>> Ejecutando bateria de aserciones de consistencia en Salud...")

# Asercion 1: cobersalud completo y en rango valido (1 a 5)
stopifnot(all(!is.na(df$cobersalud)))
stopifnot(all(df$cobersalud %in% 1:5))
message(">>> [PASO 1/4] Asercion cobersalud (completitud y dominio 1-5): APROBADA")

# Asercion 2: Fecundidad restringida estrictamente a mujeres de 13 a 50 anios
fuera_universo_fecundidad <- which(!(df$sexo == 2 & df$edad >= 13 & df$edad <= 50))
if ("s02b_06" %in% names(df)) {
  anomalias_fecundidad <- sum(!is.na(df$s02b_06[fuera_universo_fecundidad]))
  stopifnot(anomalias_fecundidad == 0)
}
message(">>> [PASO 2/4] Asercion consistencia biologica de fecundidad: APROBADA")

# Asercion 3: Discapacidad sin NAs y en dominio valido (1 a 4)
vars_discapacidad <- intersect(c("s02a_04a", "s02a_04b", "s02a_04c", 
                                 "s02a_04d", "s02a_04e", "s02a_04f"), names(df))
for (v in vars_discapacidad) {
  stopifnot(all(!is.na(df[[v]])))
  stopifnot(all(df[[v]] %in% 1:4))
}
message(">>> [PASO 3/4] Asercion dificultad permanente (sin NAs, dominio 1-4): APROBADA")

# Asercion 4: gasto_salud_total sin NAs y no negativo
stopifnot(all(!is.na(df$gasto_salud_total)))
stopifnot(all(df$gasto_salud_total >= 0))
message(">>> [PASO 4/4] Asercion no negatividad en gasto_salud_total: APROBADA")

# 3. Persistencia de cierre del Bloque 2
guardar_interim(df, "persona_16")

# 4. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 16,
  atributo = "BLOQUE 2 (Salud)",
  tipo_problema = "Validacion Estricta de Cierre",
  metodologia_fase = "Fase 5: Evaluacion y Cierre de Bloque",
  accion_realizada = "Bateria de 4 aserciones duras (cobersalud, saltos biologicos, discapacidad y gasto total) aprobada al 100%",
  criterio_justificacion = "Metodologia Fail-Fast: asegurar integridad de salud antes de avanzar a los modulos de educacion y empleo",
  filas_afectadas = 0,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Bloque 2 certificado sin defectos)"),
  codigo_script = "05_scripts/03_bloque2_salud/16_salud_validacion.R"
)

message(">>>Script 16_salud_validacion.R completado exitosamente.")
message(">>> ¡BLOQUE 2 (SALUD) FINALIZADO!\n")