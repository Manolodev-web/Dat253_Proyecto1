# ==============================================================================
# Script: 24_emp_imputacion_mice.R
# Bloque: 04 - Empleo e Ingresos Laborales
# Descripcion: Imputacion estocastica multivariada mediante Predictive Mean
#              Matching (MICE / PMM) para ingresos laborales omitidos (ylab).
# Entrada: 03_data/02_interim/persona_23.rds
# Salida:  03_data/02_interim/persona_24.rds
#          06_images/24_emp_imputacion_ylab.png
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

if (!requireNamespace("mice", quietly = TRUE)) install.packages("mice")

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(mice)
  library(Hmisc)
})

message(">>>Ejecutando 24_emp_imputacion_mice.R...")

# 2. Cargar estado anterior
ruta_interim_23 <- file.path("03_data", "02_interim", "persona_23.rds")
if (!file.exists(ruta_interim_23)) {
  stop("ERROR: No se encuentra persona_23.rds. Ejecuta primero 23_emp_horas_trabajadas.R")
}

df <- readRDS(ruta_interim_23)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos
df$ylab          <- as.numeric(df$ylab)
df$ylab_imputado <- as.integer(df$ylab_imputado)
df$condact       <- as.integer(df$condact)
df$edad          <- as.integer(df$edad)
df$sexo          <- as.integer(df$sexo)
df$area          <- as.integer(df$area)
df$depto         <- as.integer(df$depto)
df$aestudio      <- as.numeric(df$aestudio)
df$tothrs        <- as.numeric(df$tothrs)
df$clima_educativo_hogar <- as.numeric(df$clima_educativo_hogar)

# 4. Aislar el universo de ocupados que requiere imputacion
# Solo se imputa a quienes tienen condact == 1L (Poblacion Ocupada)
idx_ocupados <- which(df$condact == 1L)
idx_a_imputar <- which(df$condact == 1L & is.na(df$ylab))
n_a_imputar <- length(idx_a_imputar)

message(paste0(">>> Total de trabajadores ocupados: ", length(idx_ocupados)))
message(paste0(">>> Total de ocupados con no-respuesta en ylab a imputar: ", n_a_imputar))

if (n_a_imputar > 0) {
  # Matriz de variables predictoras para el modelo MICE
  df_mice_subset <- df[idx_ocupados, c("ylab", "edad", "sexo", "area", "depto", 
                                       "aestudio", "tothrs", "clima_educativo_hogar")]
  
  message(">>> Ejecutando algoritmo MICE con Predictive Mean Matching (PMM)...")
  set.seed(253) # Semilla academica DAT-253
  
  # Ejecucion de MICE (m = 1 imputacion, 5 iteraciones estocasticas)
  mice_model <- mice(
    df_mice_subset,
    m = 1,
    maxit = 5,
    method = "pmm",
    printFlag = FALSE
  )
  
  # Extraer datos completos imputados
  df_imputado <- complete(mice_model, 1)
  
  # Transferir valores imputados al dataset principal
  valores_imputados <- df_imputado$ylab[is.na(df_mice_subset$ylab)]
  df$ylab[idx_a_imputar] <- round(valores_imputados, 2)
  df$ylab_imputado[idx_a_imputar] <- 1L
  
  message(">>>Imputacion MICE completada exitosamente.")
}

# Inactivos y desocupados quedan en 0 Bs
df$ylab[is.na(df$ylab) | df$condact != 1L] <- 0

total_imputados_ylab <- sum(df$ylab_imputado == 1L)
message(paste0(">>> Total de registros con ylab imputado y certificados: ", total_imputados_ylab))
message(paste0(">>> NAs remanentes en ylab: ", sum(is.na(df$ylab))))

# Reasignar etiquetas limpias
Hmisc::label(df$ylab)          <- "Ingreso laboral individual liquido mensual en Bs (sin NAs, imputado MICE)"
Hmisc::label(df$ylab_imputado) <- "Bandera de linaje: 1 si ylab fue imputado con MICE/PMM, 0 original/salto"

# 5. Generacion de visualizacion: Comparativa Observados vs Imputados MICE
p_comp_ylab <- df %>%
  filter(condact == 1L, ylab > 0, ylab <= quantile(ylab[ylab > 0], 0.98)) %>%
  mutate(
    origen_dato = if_else(ylab_imputado == 1L, "Imputado (MICE / PMM)", "Observado Original")
  ) %>%
  ggplot(aes(x = ylab, fill = origen_dato)) +
  geom_density(alpha = 0.5, color = "black") +
  scale_fill_manual(values = c("Observado Original" = "#2b5c8f", 
                               "Imputado (MICE / PMM)" = "#e0a96d")) +
  labs(
    title = "Validacion Distribucional: Ingresos Observados vs Imputados MICE",
    subtitle = "Encuesta de Hogares 2024 - PMM preserva la forma funcional y la asimetria empírica",
    x = "Ingreso Laboral Mensual (Bs)",
    y = "Densidad Empirica",
    fill = "Origen del Dato"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )

guardar_figura(p_comp_ylab, "24_emp_imputacion_ylab", ancho = 8.5, alto = 5)

# 6. Guardar checkpoint interim persona_24.rds
guardar_interim(df, "persona_24")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 24,
  atributo = "ylab, ylab_imputado",
  tipo_problema = "Imputacion Estocastica Multivariada (MICE)",
  metodologia_fase = "Fase 4: Tratamiento de Valores Faltantes (Ingresos)",
  accion_realizada = paste0("Imputacion por Predictive Mean Matching (PMM) de ", n_a_imputar, 
                            " ingresos laborales en ocupados con 8 predictores y seed=253"),
  criterio_justificacion = "Metodo de donante real que preserva la distribucion empirica sin generar valores negativos ni distorsionar la varianza",
  filas_afectadas = n_a_imputar,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (ylab 100% completo y documentado)"),
  codigo_script = "05_scripts/05_bloque4_empleo/24_emp_imputacion_mice.R"
)

message(">>>Script 24_emp_imputacion_mice.R completado.\n")