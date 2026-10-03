# ==============================================================================
# Script: 15_salud_gastos_bolsillo.R
# Bloque: 02 - Salud
# Descripcion: Saneamiento de gastos medicos de bolsillo (s02a_03a-e),
#              asignacion de ceros logicos, calculo de gasto_salud_total y outliers.
# Entrada: 03_data/02_interim/persona_14.rds
# Salida:  03_data/02_interim/persona_15.rds
#          06_images/15_salud_gastos_bolsillo.png
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

message(">>> [INICIO] Ejecutando 15_salud_gastos_bolsillo.R...")

# 2. Cargar estado anterior
ruta_interim_14 <- file.path("03_data", "02_interim", "persona_14.rds")
if (!file.exists(ruta_interim_14)) {
  stop("ERROR: No se encuentra persona_14.rds. Ejecuta primero 14_salud_saltos_fecundidad.R")
}

df <- readRDS(ruta_interim_14)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Identificar variables de gastos presentes
vars_gastos <- intersect(c("s02a_03a", "s02a_03b", "s02a_03c", "s02a_03d", "s02a_03e"), names(df))

# Coercion atomica a numerico y asignacion de ceros analiticos a NAs
for (v in vars_gastos) {
  df[[v]] <- as.numeric(df[[v]])
  # Los NAs en gastos corresponden a personas sin gasto en ese rubro (0 Bs)
  df[[v]][is.na(df[[v]]) | df[[v]] < 0] <- 0
}

# 4. Construccion de gasto_salud_total individual
df$gasto_salud_total <- rowSums(df[, vars_gastos, drop = FALSE])

personas_con_gasto <- sum(df$gasto_salud_total > 0)
gasto_promedio_pos <- round(mean(df$gasto_salud_total[df$gasto_salud_total > 0]), 2)
gasto_maximo       <- max(df$gasto_salud_total)

message(paste0(">>> Personas que reportaron algun gasto de salud (> 0 Bs): ", personas_con_gasto, 
               " (", round((personas_con_gasto / n_filas) * 100, 2), "%)"))
message(paste0(">>> Gasto promedio entre quienes gastaron: ", gasto_promedio_pos, " Bs"))
message(paste0(">>> Gasto maximo observado: ", gasto_maximo, " Bs"))

# Reasignar etiquetas descriptivas
Hmisc::label(df$gasto_salud_total) <- "Gasto medico de bolsillo total mensual individual en Bs"

# 5. Generacion de visualizacion: Distribucion de gastos de bolsillo positivos
p_gastos <- df %>%
  filter(gasto_salud_total > 0, gasto_salud_total <= quantile(gasto_salud_total[gasto_salud_total > 0], 0.98)) %>%
  ggplot(aes(x = gasto_salud_total)) +
  geom_histogram(bins = 40, fill = "#2b5c8f", color = "black", alpha = 0.85) +
  labs(
    title = "Distribucion del Gasto Medico de Bolsillo Individual",
    subtitle = paste0("Encuesta de Hogares 2024 - Submuestra con gasto positivo (N = ", 
                      format(personas_con_gasto, big.mark = ","), " personas)"),
    x = "Gasto Total en Salud (Bs)",
    y = "Frecuencia de Personas"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_gastos, "15_salud_gastos_bolsillo", ancho = 8.5, alto = 5)

# 6. Guardar checkpoint persona_15.rds
guardar_interim(df, "persona_15")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 15,
  atributo = "s02a_03a-e, gasto_salud_total",
  tipo_problema = "Tratamiento de Gastos y Creacion de Sinteticas",
  metodologia_fase = "Fase 4: Tratamiento de Valores Faltantes (Gastos)",
  accion_realizada = paste0("Saneamiento de ceros en 5 rubros de gasto y creacion de gasto_salud_total (", 
                            personas_con_gasto, " positivos)"),
  criterio_justificacion = "Las personas sin consulta o sin enfermedad tienen gasto de 0 Bs; la agregacion permite medir gasto catastrofico",
  filas_afectadas = n_filas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (+1 variable gasto_salud_total)"),
  codigo_script = "05_scripts/03_bloque2_salud/15_salud_gastos_bolsillo.R"
)

message(">>> [FIN] Script 15_salud_gastos_bolsillo.R completado exitosamente.\n")