# ==============================================================================
# Script: 22_emp_diagnostico.R
# Bloque: 04 - Empleo e Ingresos Laborales
# Descripcion: Diagnostico del mercado laboral (PET, PEA, PEI, condact),
#              calculo de tasas macro y cuantificacion de no respuesta en ingresos.
# Entrada: 03_data/02_interim/persona_21.rds
# Salida:  03_data/02_interim/persona_22.rds
#          06_images/22_emp_diagnostico.png
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

message(">>>Ejecutando 22_emp_diagnostico.R...")

# 2. Cargar estado anterior (Cierre Bloque 3)
ruta_interim_21 <- file.path("03_data", "02_interim", "persona_21.rds")
if (!file.exists(ruta_interim_21)) {
  stop("ERROR: No se encuentra persona_21.rds. Ejecuta primero 21_edu_validacion.R")
}

df <- readRDS(ruta_interim_21)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos en variables laborales
df$edad    <- as.integer(df$edad)
df$pet     <- as.integer(df$pet)
df$condact <- as.integer(df$condact)
df$tothrs  <- as.numeric(df$tothrs)
df$ylab    <- as.numeric(df$ylab)

# Sincronizar PET con catalogo oficial INE (edad >= 14 anios)
df$pet <- ifelse(df$edad >= 14, 1L, 0L)

# 4. Auditoria de universos laborales
total_pet        <- sum(df$pet == 1L, na.rm = TRUE)
total_ocupados   <- sum(df$condact == 1L, na.rm = TRUE)
total_desocup    <- sum(df$condact == 2L, na.rm = TRUE)
total_inactivos  <- sum(df$condact == 3L, na.rm = TRUE)
total_pea        <- total_ocupados + total_desocup

tgp <- round((total_pea / total_pet) * 100, 2)
td  <- round((total_desocup / total_pea) * 100, 2)

message(paste0(">>> Poblacion en Edad de Trabajar (PET >= 14 anios): ", total_pet, 
               " (", round((total_pet / n_filas) * 100, 2), "% de la muestra)"))
message(paste0(">>> Poblacion Economicamente Activa (PEA): ", total_pea))
message(paste0("    - Ocupados: ", total_ocupados))
message(paste0("    - Desocupados: ", total_desocup))
message(paste0(">>> Inactivos (PEI): ", total_inactivos))
message(paste0(">>> Tasa Global de Participacion (TGP): ", tgp, "%"))
message(paste0(">>> Tasa de Desempleo Abierto (TD): ", td, "%"))

# 5. Auditoria de omisiones en horas e ingresos
nas_tothrs_ocupados <- sum(df$condact == 1L & is.na(df$tothrs))
nas_ylab_ocupados   <- sum(df$condact == 1L & is.na(df$ylab))

message(paste0(">>> Ocupados con NAs en tothrs (horas semanales): ", nas_tothrs_ocupados))
message(paste0(">>> Ocupados con NAs en ylab (ingreso laboral a imputar): ", nas_ylab_ocupados, 
               " (", round((nas_ylab_ocupados / total_ocupados) * 100, 2), "% de los ocupados)"))

# 6. Generacion de visualizacion diagnostica: Composicion del Mercado Laboral
df_plot_emp <- df %>%
  mutate(
    estado_laboral = case_when(
      pet == 0L       ~ "Menor de 14 anios (No PET)",
      condact == 1L   ~ "Ocupado",
      condact == 2L   ~ "Desocupado",
      condact == 3L   ~ "Inactivo",
      TRUE            ~ "No Determinado"
    )
  ) %>%
  count(estado_laboral)

p_emp <- ggplot(df_plot_emp, aes(x = reorder(estado_laboral, -n), y = n, fill = estado_laboral)) +
  geom_bar(stat = "identity", color = "black", alpha = 0.85) +
  geom_text(aes(label = format(n, big.mark = ",")), vjust = -0.4, size = 4, fontface = "bold") +
  scale_fill_brewer(palette = "Blues") +
  labs(
    title = "Estructura de la Poblacion segun Condicion de Actividad",
    subtitle = paste0("Encuesta de Hogares 2024 - PET: ", format(total_pet, big.mark = ","), 
                      " | PEA: ", format(total_pea, big.mark = ","), " | TGP: ", tgp, "% | TD: ", td, "%"),
    x = "Condicion Laboral",
    y = "Cantidad de Personas"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 15, hjust = 1, face = "bold"),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_emp, "22_emp_diagnostico", ancho = 8.5, alto = 5)

# 7. Guardar checkpoint interim persona_22.rds
guardar_interim(df, "persona_22")

# 8. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 22,
  atributo = "pet, condact, tothrs, ylab",
  tipo_problema = "Diagnostico de Empleo y Tasas Macro",
  metodologia_fase = "Fase 1: Auditoria y Perfilado (Empleo)",
  accion_realizada = paste0("Perfilado de PET (", total_pet, "), PEA (", total_pea, 
                            ") y deteccion de ", nas_ylab_ocupados, " NAs en ylab de ocupados"),
  criterio_justificacion = "Establecer la linea base de empleo y cuantificar el volumen exacto de ingresos a imputar con MICE",
  filas_afectadas = nas_ylab_ocupados,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Diagnostico laboral completado)"),
  codigo_script = "05_scripts/05_bloque4_empleo/22_emp_diagnostico.R"
)

message(">>> Script 22_emp_diagnostico.R completado.\n")