# ==============================================================================
# 05_scripts/00_setup/00_instalar_dependencias.R
# Instalación centralizada de paquetes para el proyecto DAT-255
# ==============================================================================

message(">>> Verificando e instalando paquetes necesarios...")

paquetes <- c(
  "here", "tidyverse", "readxl", "writexl", 
  "visdat", "VIM", "mice", "arules", "arulesViz", "Hmisc"
)

for (pkg in paquetes) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste0("Instalando: ", pkg, "..."))
    install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org")
  } else {
    message(paste0("Ya instalado: ", pkg))
  }
}

message(">>> ¡Todas las dependencias están listas!")
