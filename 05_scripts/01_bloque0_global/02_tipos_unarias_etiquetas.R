# ==============================================================================
# Script: 02_tipos_unarias_etiquetas.R
# Bloque: 00 - Global
# Descripcion: Coercion de tipos primitivos, identificacion de variables unarias
#              y asignacion de etiquetas de metadatos (Hmisc) en ASCII limpio.
# Entrada: 03_data/02_interim/persona_01.rds
# Salida:  03_data/02_interim/persona_02.rds
#          06_images/02_tipos_datos.png
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

message(">>> [INICIO] Ejecutando 02_tipos_unarias_etiquetas.R...")

# 2. Cargar estado anterior
ruta_interim_01 <- file.path("03_data", "02_interim", "persona_01.rds")
if (!file.exists(ruta_interim_01)) {
  stop("ERROR: No se encuentra persona_01.rds. Ejecuta primero 01_diccionario_corregido.R")
}

df <- readRDS(ruta_interim_01)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Coercion de tipos primitivos
df <- df %>%
  mutate(
    folio   = as.character(folio),
    upm     = as.character(upm),
    estrato = as.character(estrato),
    depto   = as.integer(depto),
    area    = as.integer(area),
    nro     = as.integer(nro)
  )

message(">>> Coercion de tipos de identificadores completada (folio, upm, estrato -> character).")

# 4. Auditoria de variables unarias o cuasi-unarias (varianza cero)
valores_unicos <- sapply(df, function(x) length(unique(na.omit(x))))
unarias <- names(valores_unicos[valores_unicos <= 1])

message(">>> Variables unarias o cuasi-unarias detectadas (<= 1 valor no nulo):")
for (u in unarias) {
  val_obs <- unique(na.omit(df[[u]]))
  na_cnt  <- sum(is.na(df[[u]]))
  message(paste0("    - ", u, ": valor='", paste(val_obs, collapse=","), "' | NAs=", na_cnt))
}

# 5. Asignacion de etiquetas de metadatos (Hmisc) en ASCII limpio
Hmisc::label(df$folio)       <- "Identificador unico de la vivienda o hogar"
Hmisc::label(df$nro)         <- "Numero de orden de la persona en el hogar"
Hmisc::label(df$depto)       <- "Departamento de residencia (1 a 9)"
Hmisc::label(df$area)        <- "Area geografica (1: Urbana, 2: Rural)"
Hmisc::label(df$sexo)        <- "Sexo estandarizado (1: Hombre, 2: Mujer)"
Hmisc::label(df$edad)        <- "Edad estandarizada en anios cumplidos (0 a 98)"
Hmisc::label(df$parentesco)  <- "Parentesco estandarizado con el jefe/a del hogar (1 a 14)"
Hmisc::label(df$totper)      <- "Total de personas en el hogar (pendiente de recalculo)"
Hmisc::label(df$cobersalud)  <- "Cobertura de seguro de salud (1: SUS, 2: Caja, 3: Privado, 4: Ninguno)"
Hmisc::label(df$aestudio)    <- "Anios de estudio aprobados acumulados"
Hmisc::label(df$condact)     <- "Condicion de actividad laboral (1: Ocupado, 2: Desocupado, 3: Inactivo)"
Hmisc::label(df$tothrs)      <- "Total de horas trabajadas por semana"
Hmisc::label(df$ylab)        <- "Ingreso laboral individual mensual en Bolivianos"
Hmisc::label(df$yhogpc)      <- "Ingreso per capita del hogar en Bolivianos"
Hmisc::label(df$p0)          <- "Indicador de pobreza moderada (1: Pobre, 0: No pobre)"
Hmisc::label(df$pext0)       <- "Indicador de pobreza extrema (1: Indigente, 0: No indigente)"

# 6. Grafica de tipos de datos en el dataset (Extraccion atomica para evitar error en count)
tipos_vector <- sapply(df, function(x) class(x)[1])

df_tipos <- data.frame(
  variable = names(df),
  tipo = as.character(tipos_vector),
  stringsAsFactors = FALSE
) %>%
  count(tipo, name = "cantidad")

p_tipos <- ggplot(df_tipos, aes(x = reorder(tipo, -cantidad), y = cantidad, fill = tipo)) +
  geom_bar(stat = "identity", color = "black", alpha = 0.85) +
  geom_text(aes(label = cantidad), vjust = -0.4, size = 4.5, fontface = "bold") +
  labs(
    title = "Distribucion de Tipos de Datos en el Dataset",
    subtitle = paste0("Total: ", n_cols, " columnas | Evaluacion de tipos primitivos R"),
    x = "Tipo de Dato en R",
    y = "Cantidad de Columnas"
  ) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

guardar_figura(p_tipos, "02_tipos_datos", ancho = 8, alto = 5)

# 7. Persistencia interim
guardar_interim(df, "persona_02")

# 8. Registro en Bitacora
log_bitacora(
  id_paso = 2,
  atributo = "folio, upm, estrato, depto, area, nro, etiquetas Hmisc",
  tipo_problema = "Tipos Primitivos y Metadatos",
  metodologia_fase = "Fase 2: Normalizacion de Formatos",
  accion_realizada = "Coercion de IDs a character, codigos a integer, auditoria de 3 unarias y etiquetado formal Hmisc sin acentos",
  criterio_justificacion = "Evitar operaciones aritmeticas sobre llaves/estratos y documentar metadatos semanticos estandarizados",
  filas_afectadas = n_filas,
  impacto_dataset = paste0(n_filas, " filas x ", n_cols, " columnas (Tipos saneados)"),
  codigo_script = "05_scripts/01_bloque0_global/02_tipos_unarias_etiquetas.R"
)

message(">>> [FIN] Script 02_tipos_unarias_etiquetas.R completado exitosamente.\n")