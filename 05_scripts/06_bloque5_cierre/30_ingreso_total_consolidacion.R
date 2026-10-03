# ==============================================================================
# Script: 30_ingreso_total_consolidacion.R
# Bloque: 05 - Ingresos No Laborales y Consolidacion Final
# Descripcion: Reconstruccion contable de ingresos (yper = ylab + ynolab),
#              agregacion de yhog por folio, yhogpc y recalibracion de pobreza.
# Entrada: 03_data/02_interim/persona_29.rds
# Salida:  03_data/02_interim/persona_30.rds
#          06_images/30_ingreso_pobreza_final.png
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

message(">>> [INICIO] Ejecutando 30_ingreso_total_consolidacion.R...")

# 2. Cargar estado anterior
ruta_interim_29 <- file.path("03_data", "02_interim", "persona_29.rds")
if (!file.exists(ruta_interim_29)) {
  stop("ERROR: No se encuentra persona_29.rds. Ejecuta primero 29_nolab_renta_dignidad_saltos.R")
}

df <- readRDS(ruta_interim_29)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos
df$ylab   <- as.numeric(df$ylab)
df$ynolab <- as.numeric(df$ynolab)
df$totper <- as.numeric(df$totper)
df$z      <- as.numeric(df$z)
df$zext   <- as.numeric(df$zext)

# 4. Reconstruccion contable individual: yper = ylab + ynolab
df$yper <- round(df$ylab + df$ynolab, 2)
stopifnot(all(df$yper >= 0))
message(paste0(">>> Ingreso individual total (yper) reconstruido: Promedio = ", 
               round(mean(df$yper), 2), " Bs"))

# 5. Agregacion contable a nivel de hogar por folio: yhog
df_yhog_recalc <- df %>%
  group_by(folio) %>%
  summarise(
    yhog_recalculado = round(sum(yper, na.rm = TRUE), 2),
    .groups = "drop"
  )

if ("yhog_recalculado" %in% names(df)) df <- df %>% select(-yhog_recalculado)

df <- df %>%
  left_join(df_yhog_recalc, by = "folio") %>%
  mutate(yhog = yhog_recalculado) %>%
  select(-yhog_recalculado)

# 6. Sincronizacion contable de ingreso per capita: yhogpc = yhog / totper
df$yhogpc <- round(df$yhog / df$totper, 2)
stopifnot(all(df$yhogpc >= 0))

message(paste0(">>> Ingreso de hogar (yhog) y per capita (yhogpc) sincronizados al 100%."))
message(paste0(">>> Ingreso per capita medio nacional: ", round(mean(df$yhogpc), 2), " Bs"))

# 7. Recalibracion de condiciones de pobreza FGT
# Pobreza extrema (pext0 = 1 si yhogpc < zext)
# Pobreza moderada (p0 = 1 si yhogpc < z)
df$pext0 <- ifelse(!is.na(df$zext) & df$yhogpc < df$zext, 1L, 0L)
df$p0    <- ifelse(!is.na(df$z) & df$yhogpc < df$z, 1L, 0L)

# Forzar regla de inclusion axiomatica: todo pobre extremo es pobre moderado
df$p0[df$pext0 == 1L] <- 1L

tasa_pobreza_mod <- round(mean(df$p0) * 100, 2)
tasa_pobreza_ext <- round(mean(df$pext0) * 100, 2)

message(paste0(">>> Tasa consolidada de Pobreza Moderada (p0): ", tasa_pobreza_mod, "%"))
message(paste0(">>> Tasa consolidada de Pobreza Extrema (pext0): ", tasa_pobreza_ext, "%"))

# Reasignar etiquetas limpias
Hmisc::label(df$yper)   <- "Ingreso individual total mensual en Bs (ylab + ynolab)"
Hmisc::label(df$yhog)   <- "Ingreso total del hogar mensual en Bs (suma de yper por folio)"
Hmisc::label(df$yhogpc) <- "Ingreso per capita del hogar mensual en Bs (yhog / totper)"
Hmisc::label(df$p0)     <- "Condicion de pobreza moderada consolidada (1: Pobre, 0: No pobre)"
Hmisc::label(df$pext0)  <- "Condicion de pobreza extrema consolidada (1: Indigente, 0: No indigente)"

# 8. Generacion de visualizacion: Ingreso per capita y lineas de pobreza
p_pobreza_final <- df %>%
  filter(yhogpc > 0, yhogpc <= 6000) %>%
  ggplot(aes(x = yhogpc)) +
  geom_density(fill = "#2b5c8f", alpha = 0.4, color = "#2b5c8f", linewidth = 1) +
  geom_vline(aes(xintercept = median(z, na.rm = TRUE)), color = "#e0a96d", linewidth = 1.1, linetype = "dashed") +
  geom_vline(aes(xintercept = median(zext, na.rm = TRUE)), color = "#c84b31", linewidth = 1.1, linetype = "dashed") +
  annotate("text", x = median(df$z, na.rm = TRUE) + 80, y = 0.0006, 
           label = "Linea Pobreza Moderada (z)", color = "#e0a96d", fontface = "bold", hjust = 0) +
  annotate("text", x = median(df$zext, na.rm = TRUE) - 80, y = 0.0008, 
           label = "Linea Extrema (zext)", color = "#c84b31", fontface = "bold", hjust = 1) +
  labs(
    title = "Distribucion Consolidada del Ingreso Per Capita y Umbrales de Pobreza",
    subtitle = paste0("Encuesta de Hogares 2024 - Pobreza Moderada: ", tasa_pobreza_mod, 
                      "% | Pobreza Extrema: ", tasa_pobreza_ext, "%"),
    x = "Ingreso Mensual Per Capita (yhogpc en Bs)",
    y = "Densidad Empirica"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_pobreza_final, "30_ingreso_pobreza_final", ancho = 8.5, alto = 5)

# 9. Guardar checkpoint interim persona_30.rds
guardar_interim(df, "persona_30")

# 10. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 30,
  atributo = "yper, yhog, yhogpc, p0, pext0",
  tipo_problema = "Consolidacion Contable y Pobreza FGT",
  metodologia_fase = "Fase 5: Validacion de Consistencia Logica y Agregacion Final",
  accion_realizada = paste0("Reconstruccion contable completa: yper=ylab+ynolab, agregacion yhog por folio, ", 
                            "yhogpc=yhog/totper y recalibracion de tasas FGT (p0=", tasa_pobreza_mod, "%, pext0=", tasa_pobreza_ext, "%)"),
  criterio_justificacion = "Cerrar el circuito contable de bienestar asegurando consistencia matematica exacta entre microdatos individuales y macrovariables de hogar",
  filas_afectadas = n_filas,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (Circuito contable de ingresos completado)"),
  codigo_script = "05_scripts/06_bloque5_consolidacion/30_ingreso_total_consolidacion.R"
)

message(">>> [FIN] Script 30_ingreso_total_consolidacion.R completado exitosamente.\n")