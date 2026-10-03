# ==============================================================================
# Script: 08_viv_diagnostico.R
# Bloque: 01 - Vivienda y Pobreza
# Descripcion: Diagnostico de variables de hogar (totper, tipohogar, yhog, yhogpc,
#              z, zext, p0, pext0) y deteccion de aplanamiento en totper.
# Entrada: 03_data/02_interim/persona_07.rds
# Salida:  03_data/02_interim/persona_08.rds
#          06_images/08_viv_diagnostico_totper.png
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
  library(tidyr)
})

message(">>> [INICIO] Ejecutando 08_viv_diagnostico.R...")

# 2. Cargar estado anterior (Cierre Bloque 0)
ruta_interim_07 <- file.path("03_data", "02_interim", "persona_07.rds")
if (!file.exists(ruta_interim_07)) {
  stop("ERROR: No se encuentra persona_07.rds. Ejecuta primero 07_recodificar_NA_estructurales.R")
}

df <- readRDS(ruta_interim_07)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Auditoria del aplanamiento en totper (Total de personas)
# Conteo real de miembros por folio
df_conteo_hogar <- df %>%
  group_by(folio) %>%
  summarise(
    miembros_reales = n(),
    totper_declarado = first(totper),
    .groups = "drop"
  )

# Metricas de discrepancia
discrepancias_totper <- sum(df_conteo_hogar$miembros_reales != df_conteo_hogar$totper_declarado, na.rm = TRUE)
nas_totper           <- sum(is.na(df_conteo_hogar$totper_declarado))
total_hogares        <- nrow(df_conteo_hogar)
pct_discrepancia     <- (discrepancias_totper / total_hogares) * 100

message(paste0(">>> Total de hogares analizados (folios): ", total_hogares))
message(paste0(">>> Hogares con totper colapsado/discrepante: ", discrepancias_totper, 
               " (", round(pct_discrepancia, 2), "%)"))
message(paste0(">>> Hogares con totper en NA: ", nas_totper))
message(">>> Distribucion del conteo real de miembros por hogar:")
print(summary(df_conteo_hogar$miembros_reales))

# 4. Auditoria de variables de ingresos y pobreza a nivel hogar
vars_vivienda <- c("yhog", "yhogpc", "z", "zext", "p0", "pext0", "tipohogar")
resumen_vivienda <- data.frame(
  variable = vars_vivienda,
  nas = sapply(df[vars_vivienda], function(x) sum(is.na(x))),
  pct_na = sapply(df[vars_vivienda], function(x) round((sum(is.na(x)) / n_filas) * 100, 2)),
  min = sapply(df[vars_vivienda], function(x) if(is.numeric(x)) round(min(x, na.rm=TRUE), 2) else NA),
  max = sapply(df[vars_vivienda], function(x) if(is.numeric(x)) round(max(x, na.rm=TRUE), 2) else NA),
  stringsAsFactors = FALSE
)

message(">>> Estado de variables agregadas de hogar:")
print(resumen_vivienda)

# 5. Generacion de visualizacion comparativa: totper declarado vs miembros reales
df_plot_totper <- df_conteo_hogar %>%
  mutate(
    totper_cat = case_when(
      is.na(totper_declarado) ~ "NA",
      totper_declarado == 1 ~ "1 persona",
      TRUE ~ "2+ personas"
    ),
    reales_cat = case_when(
      miembros_reales == 1 ~ "1 persona",
      miembros_reales == 2 ~ "2 personas",
      miembros_reales == 3 ~ "3 personas",
      miembros_reales == 4 ~ "4 personas",
      miembros_reales >= 5 ~ "5+ personas"
    )
  )

p_comp_totper <- ggplot(df_plot_totper, aes(x = factor(reales_cat, levels = c("1 persona", "2 personas", "3 personas", "4 personas", "5 personas", "5+ personas")))) +
  geom_bar(fill = "#2b5c8f", color = "black", alpha = 0.85) +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.4, size = 4, fontface = "bold") +
  labs(
    title = "Distribucion Real del Tamanio del Hogar vs Aplanamiento Original",
    subtitle = paste0("Encuesta de Hogares 2024 - ", discrepancias_totper, 
                      " hogares presentaban totper aplanado a 1.0 en la base cruda"),
    x = "Tamanio Real del Hogar (Miembros observados por folio)",
    y = "Cantidad de Hogares"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_comp_totper, "08_viv_diagnostico_totper", ancho = 8.5, alto = 5)

# 6. Persistencia interim persona_08.rds
guardar_interim(df, "persona_08")

# 7. Registro en Bitacora Oficial
log_bitacora(
  id_paso = 8,
  atributo = "totper, tipohogar, yhog, yhogpc, z, zext, p0, pext0",
  tipo_problema = "Diagnostico de Aplanamiento Estructural",
  metodologia_fase = "Fase 1: Auditoria y Perfilado (Vivienda)",
  accion_realizada = paste0("Diagnostico de totper; cuantificacion de ", discrepancias_totper, 
                            " discrepancias estructurales donde totper estaba aplanado a 1.0"),
  criterio_justificacion = "El aplanamiento de totper distorsiona indicadores per capita; se requiere reconstruccion mediante agregacion de folios",
  filas_afectadas = discrepancias_totper,
  impacto_dataset = paste0("Diagnostico completado en ", total_hogares, " hogares; preparada la reconstruccion de totper"),
  codigo_script = "05_scripts/02_bloque1_vivienda/08_viv_diagnostico.R"
)

message(">>> [FIN] Script 08_viv_diagnostico.R completado exitosamente.\n")