# ==============================================================================
# Script: 27_emp_validacion.R
# Bloque: 04 - Empleo e Ingresos Laborales
# Descripcion: Bateria de validacion estricta (Fail-Fast) del Bloque 4 (Empleo).
# Entrada: 03_data/02_interim/persona_26.rds
# Salida:  03_data/02_interim/persona_27.rds (Cierre Bloque 4)
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
})

message(">>> Ejecutando 27_emp_validacion.R...")

# 2. Cargar estado anterior
ruta_interim_26 <- file.path("03_data", "02_interim", "persona_26.rds")
if (!file.exists(ruta_interim_26)) {
  stop("ERROR: No se encuentra persona_26.rds. Ejecuta primero 26_emp_ingreso_horario_sinteticas.R")
}

df <- readRDS(ruta_interim_26)
n_filas <- nrow(df)
n_cols  <- ncol(df)

message(">>> Ejecutando bateria de aserciones de consistencia en Empleo e Ingresos...")

# Asercion 1: Completitud total en ylab (0 NAs)
stopifnot(all(!is.na(df$ylab)))
message(">>> [PASO 1/6] Asercion completitud en ylab (0 NAs): APROBADA")

# Asercion 2: Completitud total en tothrs (0 NAs)
stopifnot(all(!is.na(df$tothrs)))
message(">>> [PASO 2/6] Asercion completitud en tothrs (0 NAs): APROBADA")

# Asercion 3: No negatividad en ingresos, horas e ingreso horario
stopifnot(all(df$ylab >= 0))
stopifnot(all(df$tothrs >= 0))
stopifnot(all(df$ingreso_horario >= 0))
message(">>> [PASO 3/6] Asercion no negatividad estricta (ylab, tothrs, ingreso_horario >= 0): APROBADA")

# Asercion 4: Inactivos y desocupados tienen 0 Bs y 0 horas
inconsistencias_inactivos <- sum(df$condact != 1L & (df$ylab != 0 | df$tothrs != 0))
stopifnot(inconsistencias_inactivos == 0)
message(">>> [PASO 4/6] Asercion poblacion no ocupada con ingreso y jornada igual a cero: APROBADA")

# Asercion 5: Cota fisiologica de jornada laboral (<= 112 hrs)
violaciones_jornada <- sum(df$tothrs > 112)
stopifnot(violaciones_jornada == 0)
message(">>> [PASO 5/6] Asercion cota fisiologica semanal (tothrs <= 112): APROBADA")

# Asercion 6: Consistencia de flags de imputacion (0 o 1)
stopifnot(all(df$ylab_imputado %in% c(0L, 1L)))
stopifnot(all(df$tothrs_imputado %in% c(0L, 1L)))
message(">>> [PASO 6/6] Asercion banderas de linaje (*_imputado en {0, 1}): APROBADA")

# 3. Guardar checkpoint definitivo de cierre del Bloque 4
guardar_interim(df, "persona_27")

# 4. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 27,
  atributo = "BLOQUE 4 (Empleo e Ingresos)",
  tipo_problema = "Validacion Estricta de Cierre",
  metodologia_fase = "Fase 5: Evaluacion y Cierre de Bloque",
  accion_realizada = "Bateria de 6 aserciones duras (completitud de ylab/tothrs, no negatividad, consistencia inactivos y cotas) aprobada al 100%",
  criterio_justificacion = "Metodologia Fail-Fast: certificar la consistencia del mercado de trabajo antes de consolidar los ingresos no laborales y el ingreso agregado final",
  filas_afectadas = 0,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Bloque 4 certificado sin defectos)"),
  codigo_script = "05_scripts/05_bloque4_empleo/27_emp_validacion.R"
)

message(">>> Script 27_emp_validacion.R completado exitosamente.")
message(">>> ¡BLOQUE 4 (EMPLEO E INGRESOS) FINALIZADO!\n")