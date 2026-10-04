# ==============================================================================
# Script: 28_nolab_diagnostico.R
# Bloque: 05 - Ingresos No Laborales y Consolidacion Final
# Descripcion: Diagnostico de la Seccion 5 (ynolab, transferencias, pensiones
#              y Renta Dignidad para adultos mayores de 60 anos).
# Entrada: 03_data/02_interim/persona_27.rds
# Salida:  03_data/02_interim/persona_28.rds
#          06_images/28_nolab_diagnostico.png
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
})

message(">>> Ejecutando 28_nolab_diagnostico.R...")

# 2. Cargar estado anterior (Cierre Bloque 4)
ruta_interim_27 <- file.path("03_data", "02_interim", "persona_27.rds")
if (!file.exists(ruta_interim_27)) {
  stop("ERROR: No se encuentra persona_27.rds. Ejecuta primero 27_emp_validacion.R")
}

df <- readRDS(ruta_interim_27)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos
df$ynolab <- as.numeric(df$ynolab)
df$edad   <- as.integer(df$edad)

# 4. Auditoria de ynolab (Ingresos no laborales individuales)
nas_ynolab       <- sum(is.na(df$ynolab))
ceros_ynolab     <- sum(df$ynolab == 0, na.rm = TRUE)
positivos_ynolab <- sum(df$ynolab > 0, na.rm = TRUE)

message(paste0(">>> Total de personas con ynolab positivo (> 0 Bs): ", positivos_ynolab, 
               " (", round((positivos_ynolab / n_filas) * 100, 2), "% de la muestra)"))
message(paste0(">>> Personas con ynolab igual a 0 Bs: ", ceros_ynolab))
message(paste0(">>> Registros con ynolab en NA: ", nas_ynolab))

# 5. Auditoria del modulo de Renta Dignidad (Poblacion >= 60 anios)
# En el cuestionario INE EH2024: s05a_01e / s05a_01e0 registra el cobro de Renta Dignidad
adultos_mayores <- sum(df$edad >= 60, na.rm = TRUE)
col_renta_dignidad <- intersect(c("s05a_01e", "s05a_01e0", "s05a_01a"), names(df))[1]

message(paste0(">>> Total de adultos mayores en edad normativa (edad >= 60 anios): ", adultos_mayores))

if (!is.na(col_renta_dignidad)) {
  df[[col_renta_dignidad]] <- as.numeric(df[[col_renta_dignidad]])
  cobro_renta_60mas <- sum(df$edad >= 60 & !is.na(df[[col_renta_dignidad]]) & df[[col_renta_dignidad]] > 0)
  cobro_renta_menor <- sum(df$edad < 60 & !is.na(df[[col_renta_dignidad]]) & df[[col_renta_dignidad]] > 0)
  
  message(paste0(">>> Adultos mayores (>= 60) que cobran Renta Dignidad: ", cobro_renta_60mas, 
                 " (", round((cobro_renta_60mas / adultos_mayores) * 100, 2), "%)"))
  message(paste0(">>> Anomalias detectadas (menores de 60 con cobro de Renta Dignidad): ", cobro_renta_menor))
}

# 6. Generacion de visualizacion: Distribucion de Ingresos No Laborales por Tramo de Edad
p_nolab <- df %>%
  filter(!is.na(ynolab), ynolab > 0, ynolab <= quantile(ynolab[ynolab > 0], 0.98, na.rm = TRUE)) %>%
  mutate(
    grupo_edad = case_when(
      edad < 18               ~ "00-17 anios (Menores)",
      edad >= 18 & edad <= 59 ~ "18-59 anios (Adultos en edad laboral)",
      edad >= 60              ~ "60+ anios (Adultos Mayores)"
    )
  ) %>%
  ggplot(aes(x = factor(grupo_edad, levels = c("00-17 anios (Menores)", 
                                               "18-59 anios (Adultos en edad laboral)", 
                                               "60+ anios (Adultos Mayores)")), 
             y = ynolab, fill = grupo_edad)) +
  geom_boxplot(outlier.alpha = 0.2, alpha = 0.85) +
  scale_fill_brewer(palette = "Blues") +
  labs(
    title = "Distribucion de Ingresos No Laborales por Grupo Etario",
    subtitle = "Encuesta de Hogares 2024 - Impacto de la Renta Dignidad y transferencias corrientes",
    x = "Grupo Etario",
    y = "Ingreso No Laboral Mensual (Bs)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_nolab, "28_nolab_diagnostico", ancho = 8.5, alto = 5)

# 7. Guardar checkpoint interim persona_28.rds
guardar_interim(df, "persona_28")

# 8. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 28,
  atributo = "ynolab, s05a_*, edad",
  tipo_problema = "Diagnostico de Ingresos No Laborales",
  metodologia_fase = "Fase 1: Auditoria y Perfilado (No Laboral)",
  accion_realizada = paste0("Diagnostico de ynolab (", positivos_ynolab, " positivos) y cobertura de Renta Dignidad en ", 
                            adultos_mayores, " adultos mayores"),
  criterio_justificacion = "Evaluar transferencias y pensiones de vejez previo a la consolidacion del ingreso total individual",
  filas_afectadas = nas_ynolab,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Diagnostico no laboral completado)"),
  codigo_script = "05_scripts/06_bloque5_consolidacion/28_nolab_diagnostico.R"
)

message(">>> Script 28_nolab_diagnostico.R completado.\n")