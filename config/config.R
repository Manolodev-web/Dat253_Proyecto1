# config/config.R -- parametros globales del proyecto
SEMILLA <- 2024
ANIO_ENCUESTA <- 2024
DIR <- list(raw="data/raw", interim="data/interim", clean="data/clean", meta="data/metadatos",
            img="images", inf="informes", bit="bitacora")
F_RAW <- file.path(DIR$raw, "persona.csv")
F_BIT <- file.path(DIR$bit, "bitacora_limpieza.csv")
