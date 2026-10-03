# ==============================================================================
# Archivo: 01_config/packages.R
# Descripcion: Verificacion e instalacion automatica de dependencias para DAT-253.
# ==============================================================================

paquetes_requeridos <- c(
  "readr",
  "dplyr",
  "tidyr",
  "ggplot2",
  "Hmisc",
  "mice"
)

paquetes_faltantes <- paquetes_requeridos[!(paquetes_requeridos %in% installed.packages()[, "Package"])]

if (length(paquetes_faltantes) > 0) {
  message(">>> Instalando paquetes faltantes: ", paste(paquetes_faltantes, collapse = ", "))
  install.packages(paquetes_faltantes, dependencies = TRUE)
} else {
  message(">>> [OK] Todos los paquetes requeridos estan instalados.")
}