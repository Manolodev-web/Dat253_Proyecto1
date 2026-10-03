# ==============================================================================
# 02_R_helpers/funciones.R
# Funciones estandarizadas: Auto-ubicación, Bitácora, Checkpoints y Figuras
# ==============================================================================

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
})

# 1. Función para auto-detectar y fijar la raíz del proyecto
fijar_raiz_proyecto <- function() {
  # Obtener la ruta del archivo abierto en RStudio
  ruta_base <- tryCatch({
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
      dirname(rstudioapi::getActiveDocumentContext()$path)
    } else {
      getwd()
    }
  }, error = function(e) getwd())
  
  # Subir directorios hasta encontrar la carpeta '03_data'
  dir_actual <- normalizePath(ruta_base, winslash = "/", mustWork = FALSE)
  while (!dir.exists(file.path(dir_actual, "03_data")) && dirname(dir_actual) != dir_actual) {
    dir_actual <- dirname(dir_actual)
  }
  
  if (dir.exists(file.path(dir_actual, "03_data"))) {
    setwd(dir_actual)
    message(">>> [EN RUTA] Directorio fijado en: ", dir_actual)
  } else {
    warning(">>> [ALERTA] No se detectó la carpeta '03_data'. Directorio actual: ", getwd())
  }
  return(getwd())
}

# 2. Registrar en la bitácora formal CSV (12 columnas)
log_bitacora <- function(id_paso, atributo, tipo_problema, metodologia_fase, 
                         accion_realizada, criterio_justificacion, 
                         filas_afectadas, impacto_dataset, codigo_script,
                         responsable = "Imanol Moya", dataset = "persona.csv") {
  
  ruta_bitacora <- file.path("04_bitacora", "bitacora_limpieza.csv")
  
  nueva_entrada <- data.frame(
    id_paso = as.integer(id_paso),
    fecha_hora = format(Sys.time(), "%Y-%m-%dT%H:%M:%S"),
    responsable = as.character(responsable),
    dataset = as.character(dataset),
    atributo = as.character(atributo),
    tipo_problema = as.character(tipo_problema),
    metodologia_fase = as.character(metodologia_fase),
    accion_realizada = as.character(accion_realizada),
    criterio_justificacion = as.character(criterio_justificacion),
    filas_afectadas = as.integer(filas_afectadas),
    impacto_dataset = as.character(impacto_dataset),
    codigo_script = as.character(codigo_script),
    stringsAsFactors = FALSE
  )
  
  readr::write_csv(nueva_entrada, file = ruta_bitacora, append = TRUE)
  message(paste0(">>> [LOG BITÁCORA] Paso ", id_paso, " registrado exitosamente: ", atributo))
}

# 3. Guardar estado intermedio en 03_data/02_interim/
guardar_interim <- function(df, nombre_archivo) {
  ruta <- file.path("03_data", "02_interim", paste0(nombre_archivo, ".rds"))
  saveRDS(df, file = ruta)
  message(paste0(">>> [CHECKPOINT RDS] Guardado: ", ruta, " | Dimensiones: ", nrow(df), "x", ncol(df)))
}

# 4. Guardar figuras en 06_images/
guardar_figura <- function(plot_obj, nombre_imagen, ancho = 8, alto = 5, dpi = 300) {
  ruta <- file.path("06_images", paste0(nombre_imagen, ".png"))
  ggplot2::ggsave(filename = ruta, plot = plot_obj, width = ancho, height = alto, dpi = dpi)
  message(paste0(">>> [FIGURA GUARDADA] ", ruta))
}