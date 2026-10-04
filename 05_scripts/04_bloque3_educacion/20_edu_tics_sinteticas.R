# ==============================================================================
# Script: 20_edu_tics_sinteticas.R
# Bloque: 03 - Educacion
# Descripcion: Consistencia del modulo TICs (edad >= 5), construccion de variables
#              sinteticas (uso_internet y clima_educativo_hogar) y visualizacion.
# Entrada: 03_data/02_interim/persona_19.rds
# Salida:  03_data/02_interim/persona_20.rds
#          06_images/20_edu_tics.png
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
  library(ggplot2)
  library(Hmisc)
})

message(">>>Ejecutando 20_edu_tics_sinteticas.R...")

# 2. Cargar estado anterior
ruta_interim_19 <- file.path("03_data", "02_interim", "persona_19.rds")
if (!file.exists(ruta_interim_19)) {
  stop("ERROR: No se encuentra persona_19.rds. Ejecuta primero 19_edu_consistencia_biologica.R")
}

df <- readRDS(ruta_interim_19)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Consistencia de modulo TIC (s03c_*)
# Identificar variable de uso de internet (generalmente s03c_14 o s03c_13)
vars_tics <- grep("^s03c_", names(df), value = TRUE)
col_internet <- intersect(c("s03c_14", "s03c_13", "s03c_16"), vars_tics)[1]

# Construir uso_internet: 1 si uso internet, 0 si no uso o es menor de 5 anios
if (!is.na(col_internet)) {
  df$uso_internet <- ifelse(!is.na(df[[col_internet]]) & df[[col_internet]] == 1 & df$edad >= 5, 1L, 0L)
} else {
  df$uso_internet <- 0L
}

usuarios_internet <- sum(df$uso_internet == 1L)
message(paste0(">>> Personas identificadas con uso de internet (edad >= 5): ", 
               usuarios_internet, " (", round((usuarios_internet / n_filas) * 100, 2), "%)"))

# 4. Construccion de la variable sintetica: clima_educativo_hogar
# Promedio de aestudio de adultos (edad >= 18) por cada folio
df_clima <- df %>%
  filter(edad >= 18) %>%
  group_by(folio) %>%
  summarise(
    clima_educativo_hogar = round(mean(aestudio, na.rm = TRUE), 2),
    .groups = "drop"
  )

# Unir al dataset general
if ("clima_educativo_hogar" %in% names(df)) df <- df %>% select(-clima_educativo_hogar)

df <- df %>%
  left_join(df_clima, by = "folio")

# Si un hogar no tiene adultos >= 18 (e.g. hogar unipersonal menor), toma el aestudio maximo del hogar
df$clima_educativo_hogar <- ifelse(is.na(df$clima_educativo_hogar), df$aestudio, df$clima_educativo_hogar)

message(paste0(">>> Clima educativo promedio nacional en hogares: ", 
               round(mean(df$clima_educativo_hogar, na.rm = TRUE), 2), " anios"))

# Reasignar etiquetas descriptivas limpias
Hmisc::label(df$uso_internet)           <- "Uso de internet en ultimos 3 meses (1: Si, 0: No/Inaplicable)"
Hmisc::label(df$clima_educativo_hogar)  <- "Promedio de anios de estudio de adultos en el hogar (CEPAL)"

# 5. Generacion de visualizacion: Tasa de uso de internet por grupo etario
p_tics <- df %>%
  filter(edad >= 5) %>%
  mutate(
    grupo_edad = case_when(
      edad >= 5  & edad <= 12 ~ "05-12 anios (Ninos)",
      edad >= 13 & edad <= 17 ~ "13-17 anios (Adolescentes)",
      edad >= 18 & edad <= 29 ~ "18-29 anios (Jovenes)",
      edad >= 30 & edad <= 59 ~ "30-59 anios (Adultos)",
      edad >= 60              ~ "60+ anios (Adultos Mayores)"
    )
  ) %>%
  group_by(grupo_edad) %>%
  summarise(
    tasa_internet = round(mean(uso_internet) * 100, 1),
    total_personas = n(),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = factor(grupo_edad, levels = c("05-12 anios (Ninos)", 
                                               "13-17 anios (Adolescentes)", 
                                               "18-29 anios (Jovenes)", 
                                               "30-59 anios (Adultos)", 
                                               "60+ anios (Adultos Mayores)")), 
             y = tasa_internet, fill = grupo_edad)) +
  geom_bar(stat = "identity", color = "black", alpha = 0.85) +
  geom_text(aes(label = paste0(tasa_internet, "%")), vjust = -0.4, size = 4.5, fontface = "bold") +
  scale_fill_brewer(palette = "Blues") +
  ylim(0, 100) +
  labs(
    title = "Brecha Digital Generacional: Tasa de Uso de Internet",
    subtitle = "Encuesta de Hogares 2024 - Porcentaje de usuarios en los ultimos 3 meses",
    x = "Grupo Etario",
    y = "Tasa de Uso de Internet (%)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_tics, "20_edu_tics", ancho = 8.5, alto = 5)

# 6. Guardar checkpoint interim persona_20.rds
guardar_interim(df, "persona_20")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 20,
  atributo = "uso_internet, clima_educativo_hogar",
  tipo_problema = "Variables Sinteticas y Modulo TICs",
  metodologia_fase = "Fase 5: Enriquecimiento e Ingenieria de Variables (Educacion)",
  accion_realizada = paste0("Consistencia de modulo TIC (edad >= 5); creacion de indicadores sinteticos uso_internet (", 
                            usuarios_internet, " usuarios) y clima_educativo_hogar"),
  criterio_justificacion = "Metrica CEPAL/INE de capital humano agregado por hogar y estandarizacion de acceso digital",
  filas_afectadas = n_filas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (+2 variables sinteticas)"),
  codigo_script = "05_scripts/04_bloque3_educacion/20_edu_tics_sinteticas.R"
)

message(">>>Script 20_edu_tics_sinteticas.R completado.\n")