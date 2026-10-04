# ==============================================================================
# Script: 23_emp_horas_trabajadas.R
# Bloque: 04 - Empleo e Ingresos Laborales
# Descripcion: Saneamiento de NAs en horas trabajadas (tothrs), acotamiento
#              biologico de outliers (> 112 hrs) y activacion de tothrs_imputado.
# Entrada: 03_data/02_interim/persona_22.rds
# Salida:  03_data/02_interim/persona_23.rds
#          06_images/23_emp_horas_trabajo.png
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

message(">>>Ejecutando 23_emp_horas_trabajadas.R...")

# 2. Cargar estado anterior
ruta_interim_22 <- file.path("03_data", "02_interim", "persona_22.rds")
if (!file.exists(ruta_interim_22)) {
  stop("ERROR: No se encuentra persona_22.rds. Ejecuta primero 22_emp_diagnostico.R")
}

df <- readRDS(ruta_interim_22)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos
df$tothrs          <- as.numeric(df$tothrs)
df$tothrs_imputado <- as.integer(df$tothrs_imputado)
df$condact         <- as.integer(df$condact)

# 4. Imputacion condicional de NAs en tothrs (Solo en ocupados)
nas_previos_tothrs <- sum(df$condact == 1L & is.na(df$tothrs))
message(paste0(">>> Ocupados con tothrs faltante: ", nas_previos_tothrs))

if (nas_previos_tothrs > 0) {
  idx_ocup_na_hrs <- which(df$condact == 1L & is.na(df$tothrs))
  df$tothrs_imputado[idx_ocup_na_hrs] <- 1L
  
  # Imputar por mediana de ocupados segun area y sexo
  mediana_global_hrs <- median(df$tothrs[df$condact == 1L & !is.na(df$tothrs) & df$tothrs > 0], na.rm = TRUE)
  
  for (i in idx_ocup_na_hrs) {
    area_i <- df$area[i]
    sexo_i <- df$sexo[i]
    horas_grupo <- df$tothrs[df$condact == 1L & df$area == area_i & df$sexo == sexo_i & !is.na(df$tothrs) & df$tothrs > 0]
    
    if (length(horas_grupo) > 0) {
      df$tothrs[i] <- round(median(horas_grupo), 0)
    } else {
      df$tothrs[i] <- mediana_global_hrs
    }
  }
}

# Para los inactivos/desocupados no ocupados, asegurar 0 horas
df$tothrs[is.na(df$tothrs) | df$condact != 1L] <- 0

imputados_tothrs <- sum(df$tothrs_imputado == 1L)
message(paste0(">>> Total de casos en tothrs imputados y documentados: ", imputados_tothrs))

# 5. Tratamiento de valores atipicos inverosimiles (> 112 horas semanales)
# 112 hrs = 16 horas diarias por 7 dias (limite fisiologico censal)
limite_max_horas <- 112
horas_extremas <- sum(df$tothrs > limite_max_horas)
message(paste0(">>> Registros con horas semanales > ", limite_max_horas, " hrs: ", horas_extremas))

if (horas_extremas > 0) {
  df$tothrs[df$tothrs > limite_max_horas] <- limite_max_horas
  message(">>>Valores superiores a 112 hrs acotados al limite fisiologico censal.")
}

# Reasignar etiquetas limpias
Hmisc::label(df$tothrs)          <- "Total de horas trabajadas por semana (ocupados, acotado a 112 hrs max)"
Hmisc::label(df$tothrs_imputado) <- "Bandera de linaje: 1 si tothrs fue imputado, 0 valor original"

# 6. Generacion de visualizacion: Distribucion de horas semanales en ocupados
p_horas <- df %>%
  filter(condact == 1L, tothrs > 0) %>%
  ggplot(aes(x = tothrs)) +
  geom_histogram(binwidth = 4, fill = "#2b5c8f", color = "black", alpha = 0.85) +
  geom_vline(xintercept = 48, linetype = "dashed", color = "#c84b31", linewidth = 1) +
  annotate("text", x = 50, y = 3000, label = "Jornada Legal Maxima (48 hrs)", 
           color = "#c84b31", fontface = "bold", hjust = 0) +
  labs(
    title = "Distribucion de la Jornada Laboral Semanal en Poblacion Ocupada",
    subtitle = "Encuesta de Hogares 2024 - Concentracion en jornada legal de 48 hrs y sobreempleo horario",
    x = "Horas Trabajadas por Semana (tothrs)",
    y = "Cantidad de Trabajadores Ocupados"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_horas, "23_emp_horas_trabajo", ancho = 8.5, alto = 5)

# 7. Guardar checkpoint interim persona_23.rds
guardar_interim(df, "persona_23")

# 8. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 23,
  atributo = "tothrs, tothrs_imputado",
  tipo_problema = "Tratamiento de Horas y Outliers Fisiologicos",
  metodologia_fase = "Fase 4: Tratamiento de Valores Faltantes (Empleo)",
  accion_realizada = paste0("Imputacion condicional de ", nas_previos_tothrs, 
                            " NAs en tothrs de ocupados y acotamiento a cota biologica (112 hrs)"),
  criterio_justificacion = "Evitar que la no respuesta en horas afecte la estimacion del ingreso horario y acotar jornadas inverosimiles",
  filas_afectadas = nas_previos_tothrs + horas_extremas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (tothrs saneado y sin NAs)"),
  codigo_script = "05_scripts/05_bloque4_empleo/23_emp_horas_trabajadas.R"
)

message(">>>Script 23_emp_horas_trabajadas.R completado.\n")