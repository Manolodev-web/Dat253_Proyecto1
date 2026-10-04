# ==============================================================================
# Script: 00_auditoria_inicial.R
# Bloque: 00 - Global
# Descripción: Perfilado inicial del dataset persona.csv con lectura exhaustiva
# ==============================================================================

# 1. Auto-ubicación de la raíz
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
message(">>> Raíz del proyecto fijada en: ", getwd())

# 2. Cargar funciones auxiliares
source("02_R_helpers/funciones.R")

# 3. Lectura de persona.csv con inspección completa (guess_max = 50000)
ruta_raw <- file.path("03_data", "01_raw", "persona.csv")

if (!file.exists(ruta_raw)) {
  stop("ERROR CRÍTICO: No se encuentra persona.csv en: ", ruta_raw)
}

message(">>> Leyendo dataset persona.csv ")
# guess_max = 50000 asegura que no se pierdan textos en columnas con muchos NAs iniciales
df_raw <- readr::read_csv(ruta_raw, guess_max = 50000, show_col_types = FALSE, progress = FALSE)

# 4. Métricas de dimensionalidad
n_filas <- nrow(df_raw)
n_cols  <- ncol(df_raw)
total_celdas <- n_filas * n_cols

message(paste0(">>> Dimensiones leídas: ", n_filas, " filas x ", n_cols, " columnas"))

# 5. Auditoría de valores faltantes (Missing Data)
na_por_col <- colSums(is.na(df_raw))
total_nas  <- sum(na_por_col)
pct_nas_global <- (total_nas / total_celdas) * 100

message(paste0(">>> Total NAs globales exactos: ", format(total_nas, big.mark = ","), 
               " (", round(pct_nas_global, 2), "%)"))

df_na_resumen <- data.frame(
  pct_na = (as.numeric(na_por_col) / n_filas) * 100
) %>%
  mutate(rango_na = case_when(
    pct_na == 0 ~ "0% (Completas)",
    pct_na > 0  & pct_na <= 20 ~ "0.1% - 20%",
    pct_na > 20 & pct_na <= 50 ~ "20.1% - 50%",
    pct_na > 50 & pct_na <= 80 ~ "50.1% - 80%",
    pct_na > 80 & pct_na <= 99 ~ "80.1% - 99%",
    pct_na > 99 ~ "> 99% (Casi vacías)"
  ))

df_na_resumen$rango_na <- factor(df_na_resumen$rango_na, levels = c(
  "0% (Completas)", "0.1% - 20%", "20.1% - 50%", 
  "50.1% - 80%", "80.1% - 99%", "> 99% (Casi vacías)"
))

# 6. Gráfica diagnóstica
p_nulos <- ggplot(df_na_resumen, aes(x = rango_na)) +
  geom_bar(fill = "#2b5c8f", color = "black", alpha = 0.85) +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.4, size = 4, fontface = "bold") +
  labs(
    title = "Distribución de Columnas según Porcentaje de Valores Faltantes (NAs)",
    subtitle = paste0("Encuesta de Hogares 2024 (INE) - Total: ", n_cols, " atributos | ", 
                      format(total_nas, big.mark = ","), " NAs (", round(pct_nas_global, 1), "%)"),
    x = "Tramo de Pérdida / Inaplicabilidad de Datos",
    y = "Cantidad de Columnas"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 20, hjust = 1, face = "bold"),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_nulos, "00_distribucion_nulos", ancho = 9, alto = 5)

# 7. Persistencia intermedia en .rds
guardar_interim(df_raw, "persona_00")

# 8. Registro en Bitácora Oficial
log_bitacora(
  id_paso = 0,
  atributo = "GLOBAL (275 columnas)",
  tipo_problema = "Auditoría Inicial / Profiling",
  metodologia_fase = "Fase 1: Auditoría y Perfilado",
  accion_realizada = "Perfilado global con guess_max=50000, cuantificación de 6,261,409 NAs exactos (57.65%), evaluación de tipos y dimensionalidad",
  criterio_justificacion = "Línea base diagnóstica previa a cualquier intervención conforme a KDD/CRISP-DM",
  filas_afectadas = 0,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Línea Base)"),
  codigo_script = "05_scripts/01_bloque0_global/00_auditoria_inicial.R"
)

message(">>> Script 00_auditoria_inicial.R completado exitosamente.\n")