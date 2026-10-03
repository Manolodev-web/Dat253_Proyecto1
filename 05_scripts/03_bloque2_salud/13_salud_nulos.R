# ==============================================================================
# Script: 13_salud_nulos.R
# Bloque: 02 - Salud
# Descripcion: Tratamiento de NAs en cobertura de salud (cobersalud) y modulo
#              de dificultades permanentes (discapacidad) con flags de linaje.
# Entrada: 03_data/02_interim/persona_12.rds
# Salida:  03_data/02_interim/persona_13.rds
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

message(">>> [INICIO] Ejecutando 13_salud_nulos.R...")

# 2. Cargar estado anterior
ruta_interim_12 <- file.path("03_data", "02_interim", "persona_12.rds")
if (!file.exists(ruta_interim_12)) {
  stop("ERROR: No se encuentra persona_12.rds. Ejecuta primero 12_salud_diagnostico.R")
}

df <- readRDS(ruta_interim_12)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos en variables existentes
df$cobersalud <- as.integer(df$cobersalud)
if ("s02a_01a" %in% names(df)) df$s02a_01a <- as.integer(df$s02a_01a)
if ("s02a_01b" %in% names(df)) df$s02a_01b <- as.integer(df$s02a_01b)

# 4. Tratamiento y bandera de linaje para cobersalud
# Inicializar bandera: 0 = original, 1 = imputado/recodificado
df$cobersalud_imputado <- 0L

nas_cobersalud_prev <- sum(is.na(df$cobersalud))

# Si cobersalud es NA, recuperamos el seguro a partir del codigo en s02a_01a
# Codigos INE: 1 = SUS, 2 = Caja de Salud, 3 = Seguro Privado, 4 = Otro, 5 = Ninguno
if (nas_cobersalud_prev > 0) {
  idx_na <- which(is.na(df$cobersalud))
  df$cobersalud_imputado[idx_na] <- 1L
  
  if ("s02a_01a" %in% names(df)) {
    seguro_recuperado <- ifelse(!is.na(df$s02a_01a[idx_na]) & df$s02a_01a[idx_na] %in% 1:5,
                                df$s02a_01a[idx_na], 5L)
    df$cobersalud[idx_na] <- as.integer(seguro_recuperado)
  } else {
    df$cobersalud[idx_na] <- 5L  # 5 = Sin seguro / Ninguno
  }
}

imputados_cobersalud <- sum(df$cobersalud_imputado == 1L)
message(paste0(">>> NAs en cobersalud resueltos con reglas de boleta/linaje: ", imputados_cobersalud))

# 5. Tratamiento de NAs en modulo de discapacidad permanente (s02a_04a a s02a_04f)
# Codigos INE: 1 = No tiene dificultad, 2 = Poca dificultad, 3 = Mucha dificultad, 4 = No puede
vars_discapacidad <- intersect(c("s02a_04a", "s02a_04b", "s02a_04c", 
                                 "s02a_04d", "s02a_04e", "s02a_04f"), names(df))

for (v in vars_discapacidad) {
  df[[v]] <- as.integer(df[[v]])
  nas_v <- sum(is.na(df[[v]]))
  if (nas_v > 0) {
    df[[v]][is.na(df[[v]])] <- 1L  # Criterio: Sin dificultad
  }
}
message(paste0(">>> Columnas de discapacidad regularizadas (", length(vars_discapacidad), " verificadas)."))

# Reasignar etiquetas descriptivas limpias
Hmisc::label(df$cobersalud)          <- "Cobertura de seguro de salud (1: SUS, 2: Caja, 3: Privado, 4: Otro, 5: Ninguno)"
Hmisc::label(df$cobersalud_imputado) <- "Bandera de linaje: 1 si cobersalud fue imputado, 0 valor original"

# 6. Guardar checkpoint persona_13.rds
guardar_interim(df, "persona_13")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 13,
  atributo = "cobersalud, s02a_04a-f, cobersalud_imputado",
  tipo_problema = "Tratamiento de NAs y Linaje",
  metodologia_fase = "Fase 4: Tratamiento de Valores Faltantes (Salud)",
  accion_realizada = paste0("Resolucion de ", imputados_cobersalud, 
                            " NAs en cobersalud mediante s02a_01a y regularizacion de discapacidad"),
  criterio_justificacion = "Homogeneizacion de cobertura medica basada en boleta censal y preservacion de trazabilidad analitica",
  filas_afectadas = imputados_cobersalud,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (+1 flag cobersalud_imputado)"),
  codigo_script = "05_scripts/03_bloque2_salud/13_salud_nulos.R"
)

message(">>> [FIN] Script 13_salud_nulos.R completado exitosamente.\n")