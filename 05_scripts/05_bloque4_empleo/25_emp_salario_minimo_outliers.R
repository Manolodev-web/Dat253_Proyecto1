# ==============================================================================
# Script: 25_emp_salario_minimo_outliers.R
# Bloque: 04 - Empleo e Ingresos Laborales
# Descripcion: Auditoria respecto al Salario Minimo Nacional (2,500 Bs),
#              evaluacion de precariedad laboral y analisis de valores extremos.
# Entrada: 03_data/02_interim/persona_24.rds
# Salida:  03_data/02_interim/persona_25.rds
#          06_images/25_emp_distribucion_ingresos.png
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

message(">>> [INICIO] Ejecutando 25_emp_salario_minimo_outliers.R...")

# 2. Cargar estado anterior
ruta_interim_24 <- file.path("03_data", "02_interim", "persona_24.rds")
if (!file.exists(ruta_interim_24)) {
  stop("ERROR: No se encuentra persona_24.rds. Ejecuta primero 24_emp_imputacion_mice.R")
}

df <- readRDS(ruta_interim_24)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Auditoria respecto al Salario Minimo Nacional (SMN 2024 = 2,500 Bs)
smn_vigente <- 2500

# Trabajadores a tiempo completo (>= 40 hrs) por debajo del SMN
df$debajo_smn <- ifelse(df$condact == 1L & df$tothrs >= 40 & df$ylab < smn_vigente, 1L, 0L)

ocupados_fulltime <- sum(df$condact == 1L & df$tothrs >= 40)
ocupados_bajo_smn <- sum(df$debajo_smn == 1L)
pct_bajo_smn <- round((ocupados_bajo_smn / ocupados_fulltime) * 100, 2)

message(paste0(">>> Ocupados a tiempo completo (>= 40 hrs): ", ocupados_fulltime))
message(paste0(">>> Trabajadores de tiempo completo por debajo del SMN (< 2,500 Bs): ", 
               ocupados_bajo_smn, " (", pct_bajo_smn, "%)"))

# 4. Auditoria de valores extremos en ylab
q99_5 <- quantile(df$ylab[df$condact == 1L & df$ylab > 0], 0.995)
outliers_ylab <- sum(df$condact == 1L & df$ylab > q99_5)

message(paste0(">>> Percentil 99.5 de ingresos laborales: ", round(q99_5, 2), " Bs"))
message(paste0(">>> Trabajadores con ingresos superiores al P99.5: ", outliers_ylab))

# Reasignar etiquetas limpias
Hmisc::label(df$debajo_smn) <- "Indicador de precariedad: 1 si trabaja >= 40 hrs y gana < 2,500 Bs (SMN)"

# 5. Generacion de visualizacion: Distribucion de Ingresos y Salario Minimo
p_smn <- df %>%
  filter(condact == 1L, ylab > 0, ylab <= 15000) %>%
  ggplot(aes(x = ylab)) +
  geom_histogram(binwidth = 250, fill = "#2b5c8f", color = "black", alpha = 0.85) +
  geom_vline(xintercept = smn_vigente, linetype = "dashed", color = "#c84b31", linewidth = 1.1) +
  annotate("text", x = smn_vigente + 200, y = 1400, 
           label = paste0("SMN: ", format(smn_vigente, big.mark = ","), " Bs"), 
           color = "#c84b31", fontface = "bold", hjust = 0) +
  labs(
    title = "Distribucion de Ingresos Laborales y Salario Minimo Nacional",
    subtitle = paste0("Encuesta de Hogares 2024 - ", pct_bajo_smn, 
                      "% de trabajadores a tiempo completo perciben menos del salario legal"),
    x = "Ingreso Laboral Liquido Mensual (Bs)",
    y = "Cantidad de Trabajadores"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_smn, "25_emp_distribucion_ingresos", ancho = 8.5, alto = 5)

# 6. Guardar checkpoint interim persona_25.rds
guardar_interim(df, "persona_25")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 25,
  atributo = "ylab, debajo_smn",
  tipo_problema = "Auditoria de Salario Minimo y Outliers",
  metodologia_fase = "Fase 5: Validacion de Consistencia Logica y Precariedad",
  accion_realizada = paste0("Evaluacion contra SMN (2,500 Bs); creacion de bandera debajo_smn (", 
                            ocupados_bajo_smn, " personas en precariedad salarial)"),
  criterio_justificacion = "Identificar informalidad salarial y verificar que los percentiles superiores mantengan coherencia economica",
  filas_afectadas = n_filas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (+1 indicador debajo_smn)"),
  codigo_script = "05_scripts/05_bloque4_empleo/25_emp_salario_minimo_outliers.R"
)

message(">>> [FIN] Script 25_emp_salario_minimo_outliers.R completado exitosamente.\n")