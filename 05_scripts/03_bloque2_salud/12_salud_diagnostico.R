# ==============================================================================
# Script: 12_salud_diagnostico.R
# Bloque: 02 - Salud
# Descripcion: Diagnostico de cobertura de salud, gastos medicos de bolsillo,
#              discapacidad y filtro de fecundidad (mujeres 13-50 anios).
# Entrada: 03_data/02_interim/persona_11.rds
# Salida:  03_data/02_interim/persona_12.rds
#          06_images/12_salud_cobertura.png
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

message(">>> [INICIO] Ejecutando 12_salud_diagnostico.R...")

# 2. Cargar estado anterior (Cierre Bloque 1)
ruta_interim_11 <- file.path("03_data", "02_interim", "persona_11.rds")
if (!file.exists(ruta_interim_11)) {
  stop("ERROR: No se encuentra persona_11.rds. Ejecuta primero 11_viv_validacion.R")
}

df <- readRDS(ruta_interim_11)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos en variables de salud
df <- df %>%
  mutate(
    cobersalud = as.integer(cobersalud),
    s02a_01a   = as.integer(s02a_01a),
    s02a_03a   = as.numeric(s02a_03a),
    s02a_03b   = as.numeric(s02a_03b),
    s02a_03c   = as.numeric(s02a_03c),
    s02a_03d   = as.numeric(s02a_03d),
    s02a_03e   = as.numeric(s02a_03e)
  )

# 4. Diagnostico de Cobertura de Salud (cobersalud)
tabla_cobertura <- table(df$cobersalud, useNA = "ifany")
nas_cobertura   <- sum(is.na(df$cobersalud))
message(">>> Distribucion de cobertura de salud original (cobersalud):")
print(tabla_cobertura)
message(paste0(">>> Total NAs en cobersalud: ", nas_cobertura))

# 5. Diagnostico de Gastos de Bolsillo en Salud (s02a_03a - s02a_03e)
vars_gastos <- c("s02a_03a", "s02a_03b", "s02a_03c", "s02a_03d", "s02a_03e")
resumen_gastos <- data.frame(
  rubro = c("Consulta Externa", "Aparatos", "Internacion", "Examenes/Ambulancia", "Medicinas"),
  nas = sapply(df[vars_gastos], function(x) sum(is.na(x))),
  pct_na = sapply(df[vars_gastos], function(x) round((sum(is.na(x)) / n_filas) * 100, 2)),
  gasto_max = sapply(df[vars_gastos], function(x) max(x, na.rm = TRUE)),
  gasto_mediana = sapply(df[vars_gastos], function(x) median(x[x > 0], na.rm = TRUE))
)
message(">>> Resumen de gastos medicos reportados:")
print(resumen_gastos)

# 6. Auditoria de poblacion de fecundidad (mujeres de 13 a 50 anios)
mujeres_fertil <- sum(df$sexo == 2 & df$edad >= 13 & df$edad <= 50, na.rm = TRUE)
respuestas_embarazo_fuera_rango <- sum(!is.na(df$s02b_06) & !(df$sexo == 2 & df$edad >= 13 & df$edad <= 50))
message(paste0(">>> Universo de mujeres en edad fertil (13 a 50 anios): ", mujeres_fertil))
message(paste0(">>> Anomalías detectadas (respuestas de embarazo fuera del universo): ", respuestas_embarazo_fuera_rango))

# 7. Generacion de visualizacion: Distribucion de Cobertura de Salud
df_plot_cober <- df %>%
  mutate(
    etiqueta_cober = case_when(
      cobersalud == 1 ~ "SUS",
      cobersalud == 2 ~ "Caja de Salud",
      cobersalud == 3 ~ "Seguro Privado",
      cobersalud == 4 ~ "Otro Seguro",
      cobersalud == 5 ~ "Sin Seguro / Ninguno",
      TRUE            ~ "No Declarado / NA"
    )
  ) %>%
  count(etiqueta_cober)

p_cober <- ggplot(df_plot_cober, aes(x = reorder(etiqueta_cober, -n), y = n, fill = etiqueta_cober)) +
  geom_bar(stat = "identity", color = "black", alpha = 0.85) +
  geom_text(aes(label = format(n, big.mark = ",")), vjust = -0.4, size = 4, fontface = "bold") +
  scale_fill_brewer(palette = "Blues") +
  labs(
    title = "Distribucion de la Cobertura de Seguro de Salud",
    subtitle = paste0("Encuesta de Hogares 2024 - N = ", format(n_filas, big.mark = ","), " individuos"),
    x = "Tipo de Seguro de Salud",
    y = "Cantidad de Personas"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 15, hjust = 1, face = "bold"),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_cober, "12_salud_cobertura", ancho = 8.5, alto = 5)

# 8. Persistencia interim persona_12.rds
guardar_interim(df, "persona_12")

# 9. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 12,
  atributo = "cobersalud, s02a_03*, s02b_06",
  tipo_problema = "Diagnostico de Salud y Fecundidad",
  metodologia_fase = "Fase 1: Auditoria y Perfilado (Salud)",
  accion_realizada = paste0("Diagnostico de cobertura medica, cuantificacion de NAs en cobersalud (", 
                            nas_cobertura, ") y auditoria de ", mujeres_fertil, " mujeres en edad fertil"),
  criterio_justificacion = "Identificar omisiones reales en afiliacion a seguros y validar universo biologico de fecundidad",
  filas_afectadas = nas_cobertura,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Diagnostico de salud completado)"),
  codigo_script = "05_scripts/03_bloque2_salud/12_salud_diagnostico.R"
)

message(">>> [FIN] Script 12_salud_diagnostico.R completado exitosamente.\n")