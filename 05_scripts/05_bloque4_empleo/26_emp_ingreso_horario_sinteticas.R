# ==============================================================================
# Script: 26_emp_ingreso_horario_sinteticas.R
# Bloque: 04 - Empleo e Ingresos Laborales
# Descripcion: Calculo del ingreso laboral por hora, indicadores de subempleo
#              y sobreempleo horario, y visualizacion por nivel educativo.
# Entrada: 03_data/02_interim/persona_25.rds
# Salida:  03_data/02_interim/persona_26.rds
#          06_images/26_emp_ingreso_horario.png
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
message(">>>  Raiz del proyecto fijada en: ", getwd())

source("02_R_helpers/funciones.R")

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(Hmisc)
})

message(">>> Ejecutando 26_emp_ingreso_horario_sinteticas.R...")

# 2. Cargar estado anterior
ruta_interim_25 <- file.path("03_data", "02_interim", "persona_25.rds")
if (!file.exists(ruta_interim_25)) {
  stop("ERROR: No se encuentra persona_25.rds. Ejecuta primero 25_emp_salario_minimo_outliers.R")
}

df <- readRDS(ruta_interim_25)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos
df$ylab    <- as.numeric(df$ylab)
df$tothrs  <- as.numeric(df$tothrs)
df$condact <- as.integer(df$condact)
df$sexo    <- as.integer(df$sexo)
df$aestudio <- as.numeric(df$aestudio)

# 4. Construccion de la variable sintetica: ingreso_horario (Bs / hora)
# Estandar mensual: tothrs * 4.33 semanas al mes
horas_mensuales <- df$tothrs * 4.33

df$ingreso_horario <- ifelse(
  df$condact == 1L & df$tothrs > 0 & df$ylab > 0,
  round(df$ylab / horas_mensuales, 2),
  0
)

# 5. Indicadores sinteticos de jornada laboral
# Subempleo horario: Ocupados que trabajan menos de 40 horas por semana
df$subempleo_horario <- ifelse(df$condact == 1L & df$tothrs > 0 & df$tothrs < 40, 1L, 0L)

# Sobreempleo horario: Ocupados con jornadas superiores al limite legal (> 48 horas semanales)
df$sobreempleo_horario <- ifelse(df$condact == 1L & df$tothrs > 48, 1L, 0L)

ocupados_subempleo   <- sum(df$subempleo_horario == 1L)
ocupados_sobreempleo <- sum(df$sobreempleo_horario == 1L)
total_ocupados       <- sum(df$condact == 1L)

message(paste0(">>> Ocupados en subempleo horario (< 40 hrs): ", ocupados_subempleo, 
               " (", round((ocupados_subempleo / total_ocupados) * 100, 2), "%)"))
message(paste0(">>> Ocupados en sobreempleo horario (> 48 hrs): ", ocupados_sobreempleo, 
               " (", round((ocupados_sobreempleo / total_ocupados) * 100, 2), "%)"))
message(paste0(">>> Ingreso horario mediano en ocupados: ", 
               median(df$ingreso_horario[df$ingreso_horario > 0], na.rm = TRUE), " Bs/hora"))

# Reasignar etiquetas descriptivas
Hmisc::label(df$ingreso_horario)     <- "Ingreso laboral por hora trabajada en Bs (ylab / (tothrs * 4.33))"
Hmisc::label(df$subempleo_horario)   <- "Indicador de subempleo horario: 1 si trabaja < 40 hrs semanales"
Hmisc::label(df$sobreempleo_horario) <- "Indicador de sobreempleo: 1 si trabaja > 48 hrs semanales"

# 6. Generacion de visualizacion: Retornos a la educacion (Ingreso horario por nivel educativo)
p_ing_horario <- df %>%
  filter(condact == 1L, ingreso_horario > 0, ingreso_horario <= quantile(ingreso_horario[ingreso_horario > 0], 0.98)) %>%
  mutate(
    nivel_instruccion = case_when(
      aestudio == 0             ~ "Sin Instruccion",
      aestudio >= 1 & aestudio <= 6  ~ "Primaria (1-6)",
      aestudio >= 7 & aestudio <= 12 ~ "Secundaria (7-12)",
      aestudio >= 13            ~ "Superior (13+)"
    ),
    sexo_lab = if_else(sexo == 1L, "Hombres", "Mujeres")
  ) %>%
  ggplot(aes(x = factor(nivel_instruccion, levels = c("Sin Instruccion", "Primaria (1-6)", "Secundaria (7-12)", "Superior (13+)")), 
             y = ingreso_horario, fill = sexo_lab)) +
  geom_boxplot(outlier.alpha = 0.2, alpha = 0.85) +
  scale_fill_manual(values = c("Hombres" = "#2b5c8f", "Mujeres" = "#e0a96d")) +
  labs(
    title = "Ingreso Laboral por Hora segun Nivel de Instruccion y Sexo",
    subtitle = "Encuesta de Hogares 2024 - Retornos al capital humano y brecha de genero",
    x = "Nivel de Instruccion Alcanzado",
    y = "Ingreso Laboral (Bs / Hora)",
    fill = "Sexo"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )

guardar_figura(p_ing_horario, "26_emp_ingreso_horario", ancho = 8.5, alto = 5)

# 7. Guardar checkpoint interim persona_26.rds
guardar_interim(df, "persona_26")

# 8. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 26,
  atributo = "ingreso_horario, subempleo_horario, sobreempleo_horario",
  tipo_problema = "Variables Sinteticas y Jornada Laboral",
  metodologia_fase = "Fase 5: Enriquecimiento e Ingenieria de Variables (Empleo)",
  accion_realizada = paste0("Calculo de ingreso_horario, indicador de subempleo (< 40 hrs: ", 
                            ocupados_subempleo, ") y sobreempleo (> 48 hrs: ", ocupados_sobreempleo, ")"),
  criterio_justificacion = "Metricas OIT/INE de calidad del empleo y productividad horaria del trabajo",
  filas_afectadas = n_filas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (+3 variables sinteticas)"),
  codigo_script = "05_scripts/05_bloque4_empleo/26_emp_ingreso_horario_sinteticas.R"
)

message(">>> Script 26_emp_ingreso_horario_sinteticas.R completado.\n")