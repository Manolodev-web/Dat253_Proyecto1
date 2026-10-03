# ==============================================================================
# Script: 11_viv_validacion.R
# Bloque: 01 - Vivienda y Pobreza
# Descripcion: Validacion estricta con aserciones duras (Fail-Fast) del Bloque 1.
# Entrada: 03_data/02_interim/persona_10.rds
# Salida:  03_data/02_interim/persona_11.rds (Cierre Bloque 1)
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

message(">>> [INICIO] Ejecutando 11_viv_validacion.R...")

# 2. Cargar estado anterior
ruta_interim_10 <- file.path("03_data", "02_interim", "persona_10.rds")
if (!file.exists(ruta_interim_10)) {
  stop("ERROR: No se encuentra persona_10.rds. Ejecuta primero 10_viv_ingreso_hogar_pobreza.R")
}

df <- readRDS(ruta_interim_10)
n_filas <- nrow(df)
n_cols  <- ncol(df)

message(">>> Ejecutando bateria de aserciones de consistencia...")

# Asercion 1: No existen NAs ni valores <= 0 en totper
stopifnot(all(!is.na(df$totper)))
stopifnot(all(df$totper > 0))
message(">>> [PASO 1/5] Asercion totper > 0: APROBADA")

# Asercion 2: Consistencia en hogares unipersonales
unipersonales_invalidos <- sum(df$tipohogar == 1 & df$totper != 1, na.rm = TRUE)
stopifnot(unipersonales_invalidos == 0)
message(">>> [PASO 2/5] Asercion tipohogar unipersonal == 1 persona: APROBADA")

# Asercion 3: Exactamente un jefe por folio
jefes_por_folio <- df %>%
  group_by(folio) %>%
  summarise(total_jefes = sum(parentesco == 1, na.rm = TRUE), .groups = "drop")
stopifnot(all(jefes_por_folio$total_jefes == 1))
message(">>> [PASO 3/5] Asercion un solo jefe por hogar: APROBADA")

# Asercion 4: Consistencia de pobreza extrema vs moderada (pext0 == 1 -> p0 == 1)
inconsistencia_pobreza <- sum(df$pext0 == 1 & df$p0 != 1, na.rm = TRUE)
stopifnot(inconsistencia_pobreza == 0)
message(">>> [PASO 4/5] Asercion pext0 contenido en p0: APROBADA")

# Asercion 5: Relacion de lineas de pobreza zext <= z
inconsistencia_lineas <- sum(df$zext > df$z, na.rm = TRUE)
stopifnot(inconsistencia_lineas == 0)
message(">>> [PASO 5/5] Asercion linea zext <= z: APROBADA")

# 3. Guardar checkpoint de cierre del Bloque 1
guardar_interim(df, "persona_11")

# 4. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 11,
  atributo = "BLOQUE 1 (Vivienda y Pobreza)",
  tipo_problema = "Validacion Estricta de Cierre",
  metodologia_fase = "Fase 5: Evaluacion y Cierre de Bloque",
  accion_realizada = "Bateria de 5 aserciones logicas (totper, tipohogar, jefatura unica, lineas z y pobreza FGT) aprobadas al 100%",
  criterio_justificacion = "Metodologia Fail-Fast: impedir que inconsistencias de hogar se propaguen a los bloques individuales de salud, educacion y empleo",
  filas_afectadas = 0,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Bloque 1 certificado sin defectos)"),
  codigo_script = "05_scripts/02_bloque1_vivienda/11_viv_validacion.R"
)

message(">>> [FIN] Script 11_viv_validacion.R completado exitosamente.")
message(">>> ¡BLOQUE 1 (VIVIENDA Y POBREZA) FINALIZADO AL 100%!\n")