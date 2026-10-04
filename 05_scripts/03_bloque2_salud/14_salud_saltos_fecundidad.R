# ==============================================================================
# Script: 14_salud_saltos_fecundidad.R
# Bloque: 02 - Salud
# Descripcion: Aplicacion de saltos censales y consistencia biologica en
#              fecundidad (mujeres 13-50), desarrollo infantil y bono Juana Azurduy.
# Entrada: 03_data/02_interim/persona_13.rds
# Salida:  03_data/02_interim/persona_14.rds
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
  library(Hmisc)
})

message(">>>Ejecutando 14_salud_saltos_fecundidad.R...")

# 2. Cargar estado anterior
ruta_interim_13 <- file.path("03_data", "02_interim", "persona_13.rds")
if (!file.exists(ruta_interim_13)) {
  stop("ERROR: No se encuentra persona_13.rds. Ejecuta primero 13_salud_nulos.R")
}

df <- readRDS(ruta_interim_13)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Definicion del universo de fecundidad segun catalogo oficial INE
# Mujeres biologicas (sexo == 2) entre 13 y 50 anios cumplidos
es_universo_fecundidad <- (df$sexo == 2 & df$edad >= 13 & df$edad <= 50)

vars_fecundidad <- grep("^s02b_", names(df), value = TRUE)
vars_fecundidad <- c(vars_fecundidad, intersect(c("hnv_ult_a", "quienatenparto"), names(df)))

anomalias_fecundidad <- 0
for (v in vars_fecundidad) {
  # Respuestas registradas en personas fuera del universo
  fuera_universo <- which(!es_universo_fecundidad & !is.na(df[[v]]))
  if (length(fuera_universo) > 0) {
    anomalias_fecundidad <- anomalias_fecundidad + length(fuera_universo)
    if (is.numeric(df[[v]])) {
      df[[v]][fuera_universo] <- NA_real_
    } else {
      df[[v]][fuera_universo] <- NA_character_
    }
  }
}
message(paste0(">>> Respuestas anomalas de fecundidad anuladas por saltos censales: ", anomalias_fecundidad))

# 4. Consistencia en Seccion 2 Parte C: Desarrollo Infantil (ninios 0 a 5 anios)
es_universo_infantil <- (df$edad >= 0 & df$edad <= 5)
vars_infantil <- grep("^s02c_", names(df), value = TRUE)

anomalias_infantil <- 0
for (v in vars_infantil) {
  fuera_infantil <- which(!es_universo_infantil & !is.na(df[[v]]))
  if (length(fuera_infantil) > 0) {
    anomalias_infantil <- anomalias_infantil + length(fuera_infantil)
    if (is.numeric(df[[v]])) {
      df[[v]][fuera_infantil] <- NA_real_
    } else {
      df[[v]][fuera_infantil] <- NA_character_
    }
  }
}
message(paste0(">>> Respuestas anomalas de desarrollo infantil anuladas por saltos censales: ", anomalias_infantil))

# 5. Persistencia interim persona_14.rds
guardar_interim(df, "persona_14")

# 6. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 14,
  atributo = "s02b_*, s02c_*, hnv_ult_a, quienatenparto",
  tipo_problema = "Saltos Logicos y Consistencia Biologica",
  metodologia_fase = "Fase 5: Validacion de Consistencia Logica (Fecundidad)",
  accion_realizada = paste0("Anulacion de ", anomalias_fecundidad + anomalias_infantil, 
                            " respuestas espurias fuera de universos de fecundidad (13-50) e infancia (0-5)"),
  criterio_justificacion = "Restriccion de cuestionario: hombres y personas fuera de edad fertil no deben contener respuestas de fecundidad",
  filas_afectadas = anomalias_fecundidad + anomalias_infantil,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (Saltos de salud depurados al 100%)"),
  codigo_script = "05_scripts/03_bloque2_salud/14_salud_saltos_fecundidad.R"
)

message(">>>Script 14_salud_saltos_fecundidad.R completado.\n")