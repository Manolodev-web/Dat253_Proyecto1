# ==============================================================================
# Script: 19_edu_consistencia_biologica.R
# Bloque: 03 - Educacion
# Descripcion: Validacion y acotamiento de la restriccion biologica censal
#              (aestudio <= edad - 4) y consistencia con nivel educativo.
# Entrada: 03_data/02_interim/persona_18.rds
# Salida:  03_data/02_interim/persona_19.rds
#          06_images/19_edu_consistencia_edad.png
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
  library(ggplot2)
  library(Hmisc)
})

message(">>> [INICIO] Ejecutando 19_edu_consistencia_biologica.R...")

# 2. Cargar estado anterior
ruta_interim_18 <- file.path("03_data", "02_interim", "persona_18.rds")
if (!file.exists(ruta_interim_18)) {
  stop("ERROR: No se encuentra persona_18.rds. Ejecuta primero 18_edu_nulos_alfabetismo.R")
}

df <- readRDS(ruta_interim_18)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Auditoria y ajuste de la restriccion biologica censal: aestudio <= pmax(0, edad - 4)
limite_max_aestudio <- pmax(0, df$edad - 4)
inconsistencias_biologicas <- sum(df$aestudio > limite_max_aestudio, na.rm = TRUE)

message(paste0(">>> Casos con aestudio superior a la cota biologica (edad - 4): ", inconsistencias_biologicas))

if (inconsistencias_biologicas > 0) {
  idx_inconsistentes <- which(df$aestudio > limite_max_aestudio)
  df$aestudio[idx_inconsistentes] <- limite_max_aestudio[idx_inconsistentes]
  message(">>> [CORRECCION APLICADA] Casos ajustados al maximo factible segun su edad.")
}

# 4. Validacion de no negatividad y cota superior absoluta
stopifnot(all(df$aestudio >= 0))
stopifnot(all(df$aestudio <= pmax(0, df$edad - 4)))
message(">>> [VALIDACION OK] La cota biologica aestudio <= (edad - 4) se cumple al 100%.")

# 5. Generacion de visualizacion: Dispersion edad vs aestudio y cota biologica
# Submuestra aleatoria para visualizacion limpia sin sobretrazado
set.seed(42)
df_sample <- df %>%
  filter(edad >= 4) %>%
  sample_n(min(5000, n()))

p_biologico <- ggplot(df_sample, aes(x = edad, y = aestudio)) +
  geom_point(alpha = 0.25, color = "#2b5c8f", size = 1.2) +
  geom_abline(intercept = -4, slope = 1, linetype = "dashed", color = "#c84b31", linewidth = 1) +
  annotate("text", x = 30, y = 30, label = "Limite Biologico: Aestudio = Edad - 4", 
           color = "#c84b31", fontface = "bold", angle = 35) +
  labs(
    title = "Consistencia Biologica: Anios de Estudio vs Edad Cronologica",
    subtitle = "Encuesta de Hogares 2024 - Verificacion de cota superior (ningun punto sobre la linea roja)",
    x = "Edad Cumplida (Anios)",
    y = "Anios de Estudio Aprobados (aestudio)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_biologico, "19_edu_consistencia_edad", ancho = 8.5, alto = 5)

# 6. Guardar checkpoint interim persona_19.rds
guardar_interim(df, "persona_19")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 19,
  atributo = "aestudio, edad",
  tipo_problema = "Restriccion Biologica y Limites Censales",
  metodologia_fase = "Fase 5: Validacion de Consistencia Logica (Educacion)",
  accion_realizada = paste0("Verificacion de cota aestudio <= edad - 4; ajuste de ", 
                            inconsistencias_biologicas, " casos sobredeclarados"),
  criterio_justificacion = "Definicion censal: un individuo no puede tener mas anos aprobados de estudio que anos vividos a partir de los 4 anos de edad",
  filas_afectadas = inconsistencias_biologicas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (Consistencia biologica garantizada al 100%)"),
  codigo_script = "05_scripts/04_bloque3_educacion/19_edu_consistencia_biologica.R"
)

message(">>> [FIN] Script 19_edu_consistencia_biologica.R completado exitosamente.\n")