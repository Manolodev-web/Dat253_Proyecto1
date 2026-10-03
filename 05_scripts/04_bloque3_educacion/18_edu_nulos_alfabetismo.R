# ==============================================================================
# Script: 18_edu_nulos_alfabetismo.R
# Bloque: 03 - Educacion
# Descripcion: Tratamiento de NAs remanentes en escolaridad (aestudio) mediante
#              alfabetismo (s03a_01) e imputacion condicional por grupo etario.
# Entrada: 03_data/02_interim/persona_17.rds
# Salida:  03_data/02_interim/persona_18.rds
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

message(">>> [INICIO] Ejecutando 18_edu_nulos_alfabetismo.R...")

# 2. Cargar estado anterior
ruta_interim_17 <- file.path("03_data", "02_interim", "persona_17.rds")
if (!file.exists(ruta_interim_17)) {
  stop("ERROR: No se encuentra persona_17.rds. Ejecuta primero 17_edu_diagnostico.R")
}

df <- readRDS(ruta_interim_17)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos
df$aestudio <- as.numeric(df$aestudio)
df$edad     <- as.integer(df$edad)
if ("aestudio_imputado" %in% names(df)) df$aestudio_imputado <- as.integer(df$aestudio_imputado)
if ("s03a_01" %in% names(df)) df$s03a_01 <- as.integer(df$s03a_01)
if ("niv_ed_g" %in% names(df)) df$niv_ed_g <- as.integer(df$niv_ed_g)

# 4. Tratamiento e imputacion condicional de NAs en aestudio (Poblacion >= 4 anios)
nas_previos_aestudio <- sum(is.na(df$aestudio))
message(paste0(">>> Total de NAs en aestudio antes del tratamiento: ", nas_previos_aestudio))

if (nas_previos_aestudio > 0) {
  # Indices con omision en aestudio
  idx_nas <- which(is.na(df$aestudio))
  
  # Marcar en bandera de linaje
  df$aestudio_imputado[idx_nas] <- 1L
  
  # Imputacion logica: si no sabe leer (s03a_01 == 2) o nivel = 0 -> 0 anios
  for (i in idx_nas) {
    if ("s03a_01" %in% names(df) && !is.na(df$s03a_01[i]) && df$s03a_01[i] == 2L) {
      df$aestudio[i] <- 0
    } else if ("niv_ed_g" %in% names(df) && !is.na(df$niv_ed_g[i]) && df$niv_ed_g[i] == 0L) {
      df$aestudio[i] <- 0
    } else {
      # Mediana de anios de estudio de su grupo de edad correspondiente
      edad_i <- df$edad[i]
      vecinos <- df$aestudio[df$edad >= (edad_i - 2) & df$edad <= (edad_i + 2) & !is.na(df$aestudio)]
      if (length(vecinos) > 0) {
        df$aestudio[i] <- round(median(vecinos), 0)
      } else {
        df$aestudio[i] <- 0
      }
    }
  }
}

imputados_aestudio <- sum(df$aestudio_imputado == 1L)
message(paste0(">>> Total de registros en aestudio imputados y certificados: ", imputados_aestudio))
message(paste0(">>> NAs remanentes en aestudio: ", sum(is.na(df$aestudio))))

# Reasignar etiquetas semanticas Hmisc
Hmisc::label(df$aestudio)          <- "Anios de estudio aprobados acumulados (sin NAs)"
Hmisc::label(df$aestudio_imputado) <- "Bandera de linaje: 1 si aestudio fue imputado, 0 original/salto"

# 5. Persistencia interim persona_18.rds
guardar_interim(df, "persona_18")

# 6. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 18,
  atributo = "aestudio, aestudio_imputado, s03a_01",
  tipo_problema = "Tratamiento de NAs en Escolaridad",
  metodologia_fase = "Fase 4: Tratamiento de Valores Faltantes (Educacion)",
  accion_realizada = paste0("Resolucion de ", nas_previos_aestudio, 
                            " NAs en aestudio mediante cruce con alfabetismo y mediana etaria condicional"),
  criterio_justificacion = "Completar la dimension educativa preservando la consistencia logica y la trazabilidad de linaje",
  filas_afectadas = nas_previos_aestudio,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (aestudio 100% completo)"),
  codigo_script = "05_scripts/04_bloque3_educacion/18_edu_nulos_alfabetismo.R"
)

message(">>> [FIN] Script 18_edu_nulos_alfabetismo.R completado exitosamente.\n")