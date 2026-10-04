# ==============================================================================
# Script: 32_auditoria_certificacion_global.R
# Bloque: 05 - Ingresos No Laborales y Consolidacion Final
# Descripcion: Auditoria de certificacion global (Fail-Fast) del pipeline completo.
#              Bateria de 10 aserciones maestras sobre persona_limpio.rds.
# Entrada: 03_data/03_processed/persona_limpio.rds
# Salida:  Certificacion formal en consola y cierre definitivo de bitacora.
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

message("================================================================================")
message(">>> [AUDITORIA FINAL] Iniciando Certificacion Global de persona_limpio.rds...")
message("================================================================================")

# 2. Cargar dataset maestro final
ruta_final <- file.path("03_data", "03_processed", "persona_limpio.rds")
if (!file.exists(ruta_final)) {
  stop("ERROR: No se encuentra persona_limpio.rds. Ejecuta primero 31_exportar_dataset_final.R")
}

df <- readRDS(ruta_final)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# Asercion 1: Integridad dimensional
stopifnot(n_filas == 39497)
message(">>> [ASERCION 1/10] Dimension de registros (39,497 filas exactas): APROBADA")

# Asercion 2: Unicidad de clave primaria y jefatura de hogar
duplicados_pk <- anyDuplicated(df[, c("folio", "nro")])
stopifnot(duplicados_pk == 0)
jefes_hogar <- df %>%
  group_by(folio) %>%
  summarise(n_jefes = sum(parentesco == 1, na.rm = TRUE), .groups = "drop")
stopifnot(all(jefes_hogar$n_jefes == 1))
message(">>> [ASERCION 2/10] Unicidad de clave primaria y jefatura unica por hogar: APROBADA")

# Asercion 3: Consistencia en totper (sin NAs y > 0)
stopifnot(all(!is.na(df$totper) & df$totper > 0))
message(">>> [ASERCION 3/10] Variable totper valida y no aplanada: APROBADA")

# Asercion 4: Cobertura de salud sin NAs (rango 1 a 5)
stopifnot(all(!is.na(df$cobersalud) & df$cobersalud %in% 1:5))
message(">>> [ASERCION 4/10] Cobertura de salud completa (cobersalud en [1, 5]): APROBADA")

# Asercion 5: Escolaridad completa y cota biologica respetada
stopifnot(all(!is.na(df$aestudio) & df$aestudio >= 0))
stopifnot(all(df$aestudio <= pmax(0, df$edad - 4)))
message(">>> [ASERCION 5/10] Escolaridad completa y cota biologica cumplida: APROBADA")

# Asercion 6: Empleo e ingresos laborales sin NAs y no negativos
stopifnot(all(!is.na(df$ylab) & df$ylab >= 0))
stopifnot(all(!is.na(df$tothrs) & df$tothrs >= 0 & df$tothrs <= 112))
message(">>> [ASERCION 6/10] Horas e ingresos laborales completos y dentro de limites: APROBADA")

# Asercion 7: Ecuacion contable individual exacta: yper == round(ylab + ynolab, 2)
diff_yper <- abs(df$yper - round(df$ylab + df$ynolab, 2))
stopifnot(all(diff_yper < 0.01))
message(">>> [ASERCION 7/10] Identidad contable individual (yper = ylab + ynolab): APROBADA")

# Asercion 8: Ecuacion contable de hogar exacta: yhog == sum(yper) por folio
df_check_yhog <- df %>%
  group_by(folio) %>%
  summarise(
    yhog_calc = round(sum(yper), 2),
    yhog_orig = first(yhog),
    .groups = "drop"
  )
diff_yhog <- abs(df_check_yhog$yhog_calc - df_check_yhog$yhog_orig)
stopifnot(all(diff_yhog < 0.05))
message(">>> [ASERCION 8/10] Identidad contable de hogar (yhog = suma de miembros): APROBADA")

# Asercion 9: Identidad per capita exacta: yhogpc == round(yhog / totper, 2)
diff_yhogpc <- abs(df$yhogpc - round(df$yhog / df$totper, 2))
stopifnot(all(diff_yhogpc < 0.05))
message(">>> [ASERCION 9/10] Identidad de ingreso per capita (yhogpc = yhog / totper): APROBADA")

# Asercion 10: Axioma FGT de inclusion de pobreza y consistencia de lineas
stopifnot(all(df$zext <= df$z, na.rm = TRUE))
inconsistencias_fgt <- sum(df$pext0 == 1L & df$p0 != 1L)
stopifnot(inconsistencias_fgt == 0)
message(">>> [ASERCION 10/10] Axioma FGT de inclusion (pext0 subset of p0): APROBADA")

# 3. Registro final en Bitacora Oficial
log_bitacora(
  id_paso = 32,
  atributo = "CERTIFICACION_GLOBAL_PIPELINE",
  tipo_problema = "Auditoria Global de Calidad (Zero Defect Manufacturing)",
  metodologia_fase = "Fase 5: Certificacion Final del Pipeline",
  accion_realizada = "Bateria de 10 aserciones maestras de consistencia multidimensional superada con 0 fallas",
  criterio_justificacion = "Metodologia Fail-Fast: certificar que el dataset cumple exhaustivamente con todas las reglas censales, contables y estadisticas",
  filas_afectadas = n_filas,
  impacto_dataset = paste0("Dataset maestro persona_limpio (", n_filas, "x", n_cols, ") certificado al 100%"),
  codigo_script = "05_scripts/06_bloque5_consolidacion/32_auditoria_certificacion_global.R"
)

message("================================================================================")
message(">>> [EXITO TOTAL, CON 0 DEFECTOS!")
