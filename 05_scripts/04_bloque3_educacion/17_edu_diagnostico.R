# ==============================================================================
# Script: 17_edu_diagnostico.R
# Bloque: 03 - Educacion
# Descripcion: Diagnostico de la Seccion 3 (alfabetismo, asistencia escolar,
#              nivel educativo y anos de estudio acumulados).
# Entrada: 03_data/02_interim/persona_16.rds
# Salida:  03_data/02_interim/persona_17.rds
#          06_images/17_edu_diagnostico.png
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

message(">>> [INICIO] Ejecutando 17_edu_diagnostico.R...")

# 2. Cargar estado anterior (Cierre Bloque 2)
ruta_interim_16 <- file.path("03_data", "02_interim", "persona_16.rds")
if (!file.exists(ruta_interim_16)) {
  stop("ERROR: No se encuentra persona_16.rds. Ejecuta primero 16_salud_validacion.R")
}

df <- readRDS(ruta_interim_16)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos en variables educativas presentes
vars_edu_posibles <- c("aestudio", "niv_ed", "niv_ed_g", "s03a_01", "s03a_02")
vars_edu_presentes <- intersect(vars_edu_posibles, names(df))

for (v in vars_edu_presentes) {
  if (v == "aestudio") {
    df[[v]] <- as.numeric(df[[v]])
  } else {
    df[[v]] <- as.integer(df[[v]])
  }
}

# 4. Auditoria del universo poblacional
pob_menor_4  <- sum(df$edad < 4, na.rm = TRUE)
pob_mayor_4  <- sum(df$edad >= 4, na.rm = TRUE)
nas_aestudio <- sum(is.na(df$aestudio))

message(paste0(">>> Poblacion menor de 4 anios (saltos censales): ", pob_menor_4))
message(paste0(">>> Poblacion de 4 anios o mas (universo educacion): ", pob_mayor_4))
message(paste0(">>> NAs remanentes en aestudio: ", nas_aestudio))

# 5. Auditoria de anomalias biologicas preliminares
# Regla biologica: aestudio no puede exceder (edad - 4)
anomalias_biologicas <- sum(!is.na(df$aestudio) & df$aestudio > (df$edad - 4) & df$edad >= 4, na.rm = TRUE)
message(paste0(">>> Casos potenciales con aestudio > (edad - 4): ", anomalias_biologicas))

# 6. Distribucion de anos de estudio y nivel educativo
if ("niv_ed_g" %in% names(df)) {
  message(">>> Frecuencias por Nivel Educativo Agrupado (niv_ed_g):")
  print(table(df$niv_ed_g, useNA = "ifany"))
}

summary_aestudio <- summary(df$aestudio[df$edad >= 4])
message(">>> Resumen de anios de estudio en poblacion >= 4 anios:")
print(summary_aestudio)

# 7. Generacion de visualizacion diagnostica: Distribucion de aestudio
p_edu <- df %>%
  filter(edad >= 4, !is.na(aestudio)) %>%
  mutate(
    tramo_edad = case_when(
      edad >= 4  & edad <= 11 ~ "04-11 anios (Primaria)",
      edad >= 12 & edad <= 17 ~ "12-17 anios (Secundaria)",
      edad >= 18 & edad <= 29 ~ "18-29 anios (Superior/Joven)",
      edad >= 30 & edad <= 59 ~ "30-59 anios (Adulto)",
      edad >= 60              ~ "60+ anios (Adulto Mayor)"
    )
  ) %>%
  ggplot(aes(x = factor(tramo_edad, levels = c("04-11 anios (Primaria)", 
                                               "12-17 anios (Secundaria)", 
                                               "18-29 anios (Superior/Joven)", 
                                               "30-59 anios (Adulto)", 
                                               "60+ anios (Adulto Mayor)")), 
             y = aestudio, fill = tramo_edad)) +
  geom_boxplot(outlier.alpha = 0.2, alpha = 0.85) +
  scale_fill_brewer(palette = "Blues") +
  labs(
    title = "Distribucion de Anios de Estudio Aprobados por Grupo Etario",
    subtitle = paste0("Encuesta de Hogares 2024 - Universo: personas >= 4 anios (N = ", 
                      format(pob_mayor_4, big.mark = ","), ")"),
    x = "Grupo Etario",
    y = "Anios de Estudio Aprobados (aestudio)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 15, hjust = 1, face = "bold"),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_edu, "17_edu_diagnostico", ancho = 8.5, alto = 5)

# 8. Guardar checkpoint interim persona_17.rds
guardar_interim(df, "persona_17")

# 9. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 17,
  atributo = "aestudio, niv_ed, niv_ed_g, s03a_01, s03a_02",
  tipo_problema = "Diagnostico de Educacion y Escolaridad",
  metodologia_fase = "Fase 1: Auditoria y Perfilado (Educacion)",
  accion_realizada = paste0("Diagnostico del modulo educativo; evaluacion de ", pob_mayor_4, 
                            " personas en universo >= 4 anios y deteccion de ", nas_aestudio, " NAs en aestudio"),
  criterio_justificacion = "Verificar la cobertura de escolaridad formal y preparar la validacion de consistencia biologica",
  filas_afectadas = nas_aestudio,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Diagnostico de educacion completado)"),
  codigo_script = "05_scripts/04_bloque3_educacion/17_edu_diagnostico.R"
)

message(">>> [FIN] Script 17_edu_diagnostico.R completado exitosamente.\n")