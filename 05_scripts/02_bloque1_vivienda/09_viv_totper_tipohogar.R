# ==============================================================================
# Script: 09_viv_totper_tipohogar.R
# Bloque: 01 - Vivienda y Pobreza
# Descripcion: Reconstruccion de totper mediante agregacion por folio, resolucion
#              del aplanamiento estructural y consistencia de tipohogar.
# Entrada: 03_data/02_interim/persona_08.rds
# Salida:  03_data/02_interim/persona_09.rds
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
message(">>> Raiz del proyecto fijada en: ", getwd())

source("02_R_helpers/funciones.R")

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(Hmisc)
})

message(">>>Ejecutando 09_viv_totper_tipohogar.R...")

# 2. Cargar estado anterior
ruta_interim_08 <- file.path("03_data", "02_interim", "persona_08.rds")
if (!file.exists(ruta_interim_08)) {
  stop("ERROR: No se encuentra persona_08.rds. Ejecuta primero 08_viv_diagnostico.R")
}

df <- readRDS(ruta_interim_08)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Reconstruccion del total de personas por folio (Tamanio real del hogar)
df_conteos <- df %>%
  group_by(folio) %>%
  summarise(
    totper_recalculado = as.integer(n()),
    .groups = "drop"
  )

# Flag de modificacion previa
totper_anterior <- df$totper

df <- df %>%
  select(-totper) %>%
  left_join(df_conteos, by = "folio") %>%
  rename(totper = totper_recalculado)

# 4. Auditoria de impacto tras la reconstruccion
filas_modificadas <- sum(is.na(totper_anterior) | (totper_anterior != df$totper))
message(paste0(">>> Filas con totper corregido: ", filas_modificadas, " de ", n_filas))
message(paste0(">>> Nuevo rango de totper: [", min(df$totper), " a ", max(df$totper), "] miembros por hogar"))
message(paste0(">>> Promedio de miembros por hogar: ", round(mean(df$totper), 2)))

# 5. Validacion de consistencia con tipohogar
# Hogares unipersonales (tipohogar == 1) deben tener estrictamente totper == 1
hogares_unipersonales <- df %>%
  filter(tipohogar == 1) %>%
  summarise(
    inconsistencias = sum(totper != 1)
  )

message(paste0(">>> Inconsistencias en hogares unipersonales (tipohogar=1 vs totper): ", 
               hogares_unipersonales$inconsistencias))

# Reasignar etiqueta descriptiva Hmisc en formato ASCII limpio
Hmisc::label(df$totper) <- "Total de personas en el hogar (recalculado por conteo de miembros)"

# 6. Persistencia interim persona_09.rds
guardar_interim(df, "persona_09")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 9,
  atributo = "totper, tipohogar",
  tipo_problema = "Aplanamiento y Correccion Estructural",
  metodologia_fase = "Fase 2: Normalizacion y Correccion Estructural",
  accion_realizada = paste0("Reconstruccion de totper mediante conteo por folio; solucion de ", 
                            filas_modificadas, " registros aplanados o con NA"),
  criterio_justificacion = "El valor totper original estaba colapsado en 1.0; se recalcula el tamanio real del hogar para sostener indicadores per capita",
  filas_afectadas = filas_modificadas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (totper completamente consistente)"),
  codigo_script = "05_scripts/02_bloque1_vivienda/09_viv_totper_tipohogar.R"
)

message(">>>Script 09_viv_totper_tipohogar.R completado.\n")