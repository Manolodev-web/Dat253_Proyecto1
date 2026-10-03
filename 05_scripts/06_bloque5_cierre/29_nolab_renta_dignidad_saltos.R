# ==============================================================================
# Script: 29_nolab_renta_dignidad_saltos.R
# Bloque: 05 - Ingresos No Laborales y Consolidacion Final
# Descripcion: Consistencia de saltos en Renta Dignidad (edad >= 60 anios),
#              saneamiento de NAs en ynolab a ceros analiticos y bandera de linaje.
# Entrada: 03_data/02_interim/persona_28.rds
# Salida:  03_data/02_interim/persona_29.rds
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

message(">>> [INICIO] Ejecutando 29_nolab_renta_dignidad_saltos.R...")

# 2. Cargar estado anterior
ruta_interim_28 <- file.path("03_data", "02_interim", "persona_28.rds")
if (!file.exists(ruta_interim_28)) {
  stop("ERROR: No se encuentra persona_28.rds. Ejecuta primero 28_nolab_diagnostico.R")
}

df <- readRDS(ruta_interim_28)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos
df$ynolab <- as.numeric(df$ynolab)
df$edad   <- as.integer(df$edad)

# 4. Inicializacion de bandera de linaje para ynolab
df$ynolab_imputado <- 0L

# 5. Aplicacion de restriccion legal de Renta Dignidad (edad >= 60 anios)
col_renta <- intersect(c("s05a_01e", "s05a_01e0", "s05a_01a"), names(df))[1]

if (!is.na(col_renta)) {
  df[[col_renta]] <- as.numeric(df[[col_renta]])
  anomalias_menores_renta <- sum(df$edad < 60 & !is.na(df[[col_renta]]) & df[[col_renta]] > 0)
  
  if (anomalias_menores_renta > 0) {
    idx_menores_renta <- which(df$edad < 60 & !is.na(df[[col_renta]]) & df[[col_renta]] > 0)
    df[[col_renta]][idx_menores_renta] <- 0
    message(paste0(">>> Registros de menores de 60 anios con Renta Dignidad anulados: ", anomalias_menores_renta))
  }
}

# 6. Saneamiento de NAs en ynolab (Ceros logicos en no perceptores)
nas_previos_ynolab <- sum(is.na(df$ynolab))
message(paste0(">>> NAs en ynolab antes del saneamiento: ", nas_previos_ynolab))

if (nas_previos_ynolab > 0) {
  idx_na_ynolab <- which(is.na(df$ynolab))
  df$ynolab_imputado[idx_na_ynolab] <- 1L
  df$ynolab[idx_na_ynolab] <- 0
}

# Garantizar no negatividad
df$ynolab[df$ynolab < 0] <- 0

imputados_ynolab <- sum(df$ynolab_imputado == 1L)
message(paste0(">>> Ceros analiticos asignados en ynolab: ", imputados_ynolab))
message(paste0(">>> NAs remanentes en ynolab: ", sum(is.na(df$ynolab))))

# Reasignar etiquetas limpias
Hmisc::label(df$ynolab)          <- "Ingreso no laboral mensual individual en Bs (transferencias, rentas, pensiones)"
Hmisc::label(df$ynolab_imputado) <- "Bandera de linaje: 1 si ynolab fue recodificado/imputado, 0 valor original"

# 7. Guardar checkpoint interim persona_29.rds
guardar_interim(df, "persona_29")

# 8. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 29,
  atributo = "ynolab, ynolab_imputado, Renta Dignidad",
  tipo_problema = "Saltos Censales y Tratamiento de NAs No Laborales",
  metodologia_fase = "Fase 4: Tratamiento de Valores Faltantes (No Laboral)",
  accion_realizada = paste0("Saneamiento de Renta Dignidad (edad >= 60) y asignacion de ceros analiticos a ", 
                            nas_previos_ynolab, " NAs en ynolab con flag ynolab_imputado"),
  criterio_justificacion = "Definicion contable: quienes no reportaron transferencias ni rentas perciben 0 Bs no laborales",
  filas_afectadas = nas_previos_ynolab,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (ynolab 100% completo y no negativo)"),
  codigo_script = "05_scripts/06_bloque5_consolidacion/29_nolab_renta_dignidad_saltos.R"
)

message(">>> [FIN] Script 29_nolab_renta_dignidad_saltos.R completado exitosamente.\n")