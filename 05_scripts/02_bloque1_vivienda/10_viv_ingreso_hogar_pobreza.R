# ==============================================================================
# Script: 10_viv_ingreso_hogar_pobreza.R
# Bloque: 01 - Vivienda y Pobreza
# Descripcion: Consistencia matematica de ingresos de hogar (yhog, yhogpc),
#              lineas de pobreza (z, zext) y clasificacion FGT (p0, pext0).
# Entrada: 03_data/02_interim/persona_09.rds
# Salida:  03_data/02_interim/persona_10.rds
#          06_images/10_viv_ingreso_pobreza.png
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

message(">>> [INICIO] Ejecutando 10_viv_ingreso_hogar_pobreza.R...")

# 2. Cargar estado anterior
ruta_interim_09 <- file.path("03_data", "02_interim", "persona_09.rds")
if (!file.exists(ruta_interim_09)) {
  stop("ERROR: No se encuentra persona_09.rds. Ejecuta primero 09_viv_totper_tipohogar.R")
}

df <- readRDS(ruta_interim_09)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Saneamiento preventivo de tipos atomicos (Elimina clases <labelled> conflictivas)
df <- df %>%
  mutate(
    yhog   = as.numeric(yhog),
    totper = as.numeric(totper),
    yhogpc = as.numeric(yhogpc),
    z      = as.numeric(z),
    zext   = as.numeric(zext),
    p0     = as.integer(p0),
    pext0  = as.integer(pext0)
  )

# 4. Auditoria contable: yhogpc vs (yhog / totper)
df <- df %>%
  mutate(
    yhogpc_estimado = if_else(totper > 0 & !is.na(yhog), yhog / totper, NA_real_),
    diff_yhogpc     = abs(yhogpc - yhogpc_estimado)
  )

discrepancias_yhogpc <- sum(!is.na(df$diff_yhogpc) & df$diff_yhogpc > 0.05)
message(paste0(">>> Discrepancias encontradas entre yhogpc y (yhog / totper): ", discrepancias_yhogpc))

# Sincronizacion de yhogpc con el tamanio corregido del hogar
df <- df %>%
  mutate(
    yhogpc = if_else(!is.na(yhogpc_estimado), round(yhogpc_estimado, 2), yhogpc)
  ) %>%
  select(-yhogpc_estimado, -diff_yhogpc)

# 5. Consistencia de lineas de pobreza y clasificacion p0 / pext0
# Regla 1: zext <= z (La canasta extrema no puede superar a la canasta moderada)
violaciones_lineas <- sum(!is.na(df$z) & !is.na(df$zext) & df$zext > df$z)
message(paste0(">>> Inconsistencias en lineas zext > z: ", violaciones_lineas))
stopifnot(violaciones_lineas == 0)

# Regla 2: Si pext0 == 1 -> p0 DEBE ser 1 (Inclusion de conjuntos de pobreza)
inconsistencias_pobreza <- sum(df$pext0 == 1 & df$p0 == 0, na.rm = TRUE)
message(paste0(">>> Inconsistencias de pobreza extrema sin pobreza moderada: ", inconsistencias_pobreza))

# Sincronizacion formal de p0 ante consistencia
df <- df %>%
  mutate(
    p0 = if_else(pext0 == 1L, 1L, p0)
  )

# Resumen de distribucion de pobreza saneada
tabla_p0    <- table(df$p0, useNA = "ifany")
tabla_pext0 <- table(df$pext0, useNA = "ifany")
message(">>> Distribucion final Pobreza Moderada (p0):")
print(tabla_p0)
message(">>> Distribucion final Pobreza Extrema (pext0):")
print(tabla_pext0)

# Reasignar etiquetas descriptivas limpias
Hmisc::label(df$yhogpc) <- "Ingreso per capita del hogar mensual en Bs (yhog / totper)"
Hmisc::label(df$p0)     <- "Condicion de pobreza moderada (1: Pobre, 0: No pobre)"
Hmisc::label(df$pext0)  <- "Condicion de pobreza extrema (1: Indigente, 0: No indigente)"

# 6. Generacion de visualizacion: Distribucion de Ingreso per capita segun Pobreza
p_pobreza <- df %>%
  filter(!is.na(p0), yhogpc > 0, yhogpc <= quantile(yhogpc, 0.99, na.rm = TRUE)) %>%
  mutate(
    categoria_pobreza = case_when(
      pext0 == 1 ~ "Pobre Extremo",
      p0 == 1    ~ "Pobre Moderado",
      TRUE       ~ "No Pobre"
    )
  ) %>%
  ggplot(aes(x = factor(categoria_pobreza, levels = c("No Pobre", "Pobre Moderado", "Pobre Extremo")), 
             y = yhogpc, fill = categoria_pobreza)) +
  geom_boxplot(outlier.alpha = 0.2, alpha = 0.85) +
  scale_fill_manual(values = c("No Pobre" = "#2b5c8f", 
                               "Pobre Moderado" = "#e0a96d", 
                               "Pobre Extremo" = "#c84b31")) +
  labs(
    title = "Distribucion de Ingreso Per Capita por Condicion de Pobreza",
    subtitle = "Encuesta de Hogares 2024 - Validacion de consistencia yhogpc vs lineas z y zext",
    x = "Condicion de Pobreza del Hogar",
    y = "Ingreso Mensual Per Capita (Bs)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_pobreza, "10_viv_ingreso_pobreza", ancho = 8.5, alto = 5)

# 7. Persistencia interim persona_10.rds
guardar_interim(df, "persona_10")

# 8. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 10,
  atributo = "yhogpc, z, zext, p0, pext0",
  tipo_problema = "Consistencia Matematica y Reglas FGT",
  metodologia_fase = "Fase 5: Validacion de Consistencia Logica",
  accion_realizada = "Sincronizacion de yhogpc = yhog / totper, validacion de zext <= z y regla de inclusion pext0 subset of p0",
  criterio_justificacion = "Garantizar coherencia contable entre el ingreso del hogar y las lineas de corte oficial del INE",
  filas_afectadas = discrepancias_yhogpc,
  impacto_dataset = paste0(n_filas, " filas x ", ncol(df), " columnas (Ingreso per capita y pobreza consistentes)"),
  codigo_script = "05_scripts/02_bloque1_vivienda/10_viv_ingreso_hogar_pobreza.R"
)

message(">>> [FIN] Script 10_viv_ingreso_hogar_pobreza.R completado exitosamente.\n")