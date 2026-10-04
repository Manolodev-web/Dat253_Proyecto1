# ==============================================================================
# Script: 06_clasificar_NA.R
# Bloque: 00 - Global
# Descripcion: Clasificacion analitica de datos faltantes en Observados,
#              NAs Estructurales (saltos) y NAs Reales (omisiones genuinas).
# Entrada: 03_data/02_interim/persona_05.rds
# Salida:  03_data/02_interim/persona_06.rds
#          06_images/06_clasificacion_na.png
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
  library(tidyr)
  library(ggplot2)
})

message(">>>Ejecutando 06_clasificar_NA.R...")

# 2. Cargar estado anterior
ruta_interim_05 <- file.path("03_data", "02_interim", "persona_05.rds")
if (!file.exists(ruta_interim_05)) {
  stop("ERROR: No se encuentra persona_05.rds. Ejecuta primero 05_reglas_de_salto.R")
}

df <- readRDS(ruta_interim_05)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Clasificacion taxonomica de NAs en variables representativas de cada bloque

# A. Fecundidad (s02b_06): Universo = Mujeres de 13 a 50 anios
es_universo_fecundidad <- (df$sexo == 2 & df$edad >= 13 & df$edad <= 50)
df <- df %>%
  mutate(
    tipo_na_embarazo = case_when(
      !is.na(s02b_06) ~ "Observado",
      is.na(s02b_06) & !es_universo_fecundidad ~ "NA_Estructural",
      is.na(s02b_06) & es_universo_fecundidad ~ "NA_Real"
    )
  )

# B. Educacion (aestudio): Universo = Poblacion de 4 anios o mas
es_universo_educacion <- (df$edad >= 4)
df <- df %>%
  mutate(
    tipo_na_aestudio = case_when(
      !is.na(aestudio) ~ "Observado",
      is.na(aestudio) & !es_universo_educacion ~ "NA_Estructural",
      is.na(aestudio) & es_universo_educacion ~ "NA_Real"
    )
  )

# C. Empleo y Horas (tothrs): Universo = Poblacion ocupada (condact == 1)
es_universo_ocupados <- (df$pet == 1 & !is.na(df$condact) & df$condact == 1)
df <- df %>%
  mutate(
    tipo_na_tothrs = case_when(
      !is.na(tothrs) ~ "Observado",
      is.na(tothrs) & !es_universo_ocupados ~ "NA_Estructural",
      is.na(tothrs) & es_universo_ocupados ~ "NA_Real"
    )
  )

# D. Ingreso Laboral (ylab): Universo = Poblacion ocupada
df <- df %>%
  mutate(
    tipo_na_ylab = case_when(
      !is.na(ylab) ~ "Observado",
      is.na(ylab) & !es_universo_ocupados ~ "NA_Estructural",
      is.na(ylab) & es_universo_ocupados ~ "NA_Real"
    )
  )

message(">>> Auditoria de clasificacion para tothrs (Horas semanales):")
print(table(df$tipo_na_tothrs))

message(">>> Auditoria de clasificacion para ylab (Ingreso laboral):")
print(table(df$tipo_na_ylab))

# 4. Generacion de visualizacion comparativa de NAs Estructurales vs Reales
df_plot_na <- df %>%
  select(tipo_na_embarazo, tipo_na_aestudio, tipo_na_tothrs, tipo_na_ylab) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "categoria") %>%
  mutate(
    variable = case_when(
      variable == "tipo_na_embarazo" ~ "Embarazo (s02b_06)",
      variable == "tipo_na_aestudio" ~ "Escolaridad (aestudio)",
      variable == "tipo_na_tothrs"   ~ "Horas Trabajo (tothrs)",
      variable == "tipo_na_ylab"     ~ "Ingreso Laboral (ylab)"
    )
  ) %>%
  count(variable, categoria)

p_clasif_na <- ggplot(df_plot_na, aes(x = variable, y = n, fill = categoria)) +
  geom_bar(stat = "identity", position = "stack", color = "black", alpha = 0.85) +
  geom_text(aes(label = format(n, big.mark = ",")), 
            position = position_stack(vjust = 0.5), size = 3.5, fontface = "bold") +
  scale_fill_manual(values = c("Observado" = "#2b5c8f", 
                               "NA_Estructural" = "#e0a96d", 
                               "NA_Real" = "#c84b31")) +
  labs(
    title = "Descomposicion de NAs: Estructurales (Saltos) vs Reales (Omisiones)",
    subtitle = "Encuesta de Hogares 2024 - Distincion clave previa a imputacion",
    x = "Atributo Analizado",
    y = "Total de Observaciones (N = 39,497)",
    fill = "Clasificacion del Dato"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )

guardar_figura(p_clasif_na, "06_clasificacion_na", ancho = 9, alto = 5.5)

# 5. Guardar checkpoint interim persona_06.rds
guardar_interim(df, "persona_06")

# 6. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 6,
  atributo = "tipo_na_embarazo, tipo_na_aestudio, tipo_na_tothrs, tipo_na_ylab",
  tipo_problema = "Taxonomia de Valores Faltantes",
  metodologia_fase = "Fase 4: Diagnostico de Datos Faltantes",
  accion_realizada = "Generacion de 4 columnas indicadoras de tipo_na diferenciando Observados, NAs estructurales y omisiones reales",
  criterio_justificacion = "Evitar el sesgo critico de imputar registros que legitiman un salto del cuestionario",
  filas_afectadas = n_filas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (+4 variables indicadoras de auditoria)"),
  codigo_script = "05_scripts/01_bloque0_global/06_clasificar_NA.R"
)

message(">>>Script 06_clasificar_NA.R completado.\n")