# ==============================================================================
# Script: 07_recodificar_NA_estructurales.R
# Bloque: 00 - Global
# Descripcion: Saneamiento de NAs estructurales (ceros logicos en escolaridad,
#              horas e ingresos de inactivos) y creacion de flags *_imputado (0/1).
# Entrada: 03_data/02_interim/persona_06.rds
# Salida:  03_data/02_interim/persona_07.rds (Cierre Bloque 0)
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

message(">>>Ejecutando 07_recodificar_NA_estructurales.R...")

# 2. Cargar estado anterior
ruta_interim_06 <- file.path("03_data", "02_interim", "persona_06.rds")
if (!file.exists(ruta_interim_06)) {
  stop("ERROR: No se encuentra persona_06.rds. Ejecuta primero 06_clasificar_NA.R")
}

df <- readRDS(ruta_interim_06)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Creacion de flags indicadores de linaje (0 = original / no imputado, 1 = imputado)
df <- df %>%
  mutate(
    aestudio_imputado = 0L,
    tothrs_imputado   = 0L,
    ylab_imputado     = 0L
  )

# 4. Recodificacion controlada de saltos estructurales a ceros analiticos
# Se usa as.numeric() para evitar conflicto de tipos entre <double> y <labelled>
n_aestudio_ceros <- sum(df$tipo_na_aestudio == "NA_Estructural", na.rm = TRUE)
n_tothrs_ceros   <- sum(df$tipo_na_tothrs == "NA_Estructural", na.rm = TRUE)
n_ylab_ceros     <- sum(df$tipo_na_ylab == "NA_Estructural", na.rm = TRUE)

df <- df %>%
  mutate(
    aestudio = if_else(tipo_na_aestudio == "NA_Estructural", 0, as.numeric(aestudio)),
    tothrs   = if_else(tipo_na_tothrs == "NA_Estructural", 0, as.numeric(tothrs)),
    ylab     = if_else(tipo_na_ylab == "NA_Estructural", 0, as.numeric(ylab))
  )

# Restaurar etiquetas semanticas Hmisc en formato ASCII limpio
Hmisc::label(df$aestudio)          <- "Anios de estudio aprobados acumulados (ceros en menores de 4)"
Hmisc::label(df$tothrs)            <- "Total de horas trabajadas por semana (ceros en no ocupados)"
Hmisc::label(df$ylab)              <- "Ingreso laboral mensual en Bs (ceros en no ocupados)"
Hmisc::label(df$aestudio_imputado) <- "Bandera de linaje: 1 si fue imputado, 0 valor original/salto"
Hmisc::label(df$tothrs_imputado)   <- "Bandera de linaje: 1 si fue imputado, 0 valor original/salto"
Hmisc::label(df$ylab_imputado)     <- "Bandera de linaje: 1 si fue imputado, 0 valor original/salto"

message(paste0(">>> Ceros logicos asignados en aestudio (menores de 4 anios): ", n_aestudio_ceros))
message(paste0(">>> Ceros logicos asignados en tothrs (poblacion no ocupada): ", n_tothrs_ceros))
message(paste0(">>> Ceros logicos asignados en ylab (poblacion no ocupada): ", n_ylab_ceros))

# 5. Verificacion de consistencia
message(paste0(">>> NAs remanentes reales en aestudio (a tratar en Bloque 3): ", sum(is.na(df$aestudio))))
message(paste0(">>> NAs remanentes reales en tothrs (a tratar en Bloque 4): ", sum(is.na(df$tothrs))))
message(paste0(">>> NAs remanentes reales en ylab (a imputar con MICE en Bloque 4): ", sum(is.na(df$ylab))))

# 6. Persistencia del estado final del Bloque 0
guardar_interim(df, "persona_07")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 7,
  atributo = "aestudio, tothrs, ylab, *_imputado",
  tipo_problema = "Tratamiento de NAs Estructurales",
  metodologia_fase = "Fase 4: Tratamiento de Valores Faltantes",
  accion_realizada = "Asignacion de ceros logicos en saltos estructurales de escolaridad, horas e ingresos; creacion de flags *_imputado (0/1)",
  criterio_justificacion = "Definicion teorica: inactivos laborales generan 0 Bs y 0 horas; infantes menores de 4 anios tienen 0 anios cursados",
  filas_afectadas = n_ylab_ceros,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (Cierre Bloque 0 listo para bloques tematicos)"),
  codigo_script = "05_scripts/01_bloque0_global/07_recodificar_NA_estructurales.R"
)

message(">>>Script 07_recodificar_NA_estructurales.R completado.")
message(">>> ¡BLOQUE 0 (GLOBAL) FINALIZADO!\n")