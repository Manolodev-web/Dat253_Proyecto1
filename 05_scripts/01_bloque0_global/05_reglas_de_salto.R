# ==============================================================================
# Script: 05_reglas_de_salto.R
# Bloque: 00 - Global
# Descripcion: Formalizacion de reglas de salto (skip patterns) segun catalogo
#              oficial INE EH 2024 y generacion de reglas_saltos.csv.
# Entrada: 03_data/02_interim/persona_04.rds
# Salida:  03_data/04_metadatos/reglas_saltos.csv
#          03_data/02_interim/persona_05.rds
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
})

message(">>>Ejecutando 05_reglas_de_salto.R...")

# 2. Cargar estado anterior
ruta_interim_04 <- file.path("03_data", "02_interim", "persona_04.rds")
if (!file.exists(ruta_interim_04)) {
  stop("ERROR: No se encuentra persona_04.rds. Ejecuta primero 04_duplicados_integridad.R")
}

df <- readRDS(ruta_interim_04)
n_filas <- nrow(df)
n_cols  <- ncol(df)

# 3. Calculo dinamico de los universos poblacionales segun reglas censales INE
n_total_poblacion      <- nrow(df)
n_fecundidad_mujeres   <- sum(df$sexo == 2 & df$edad >= 13 & df$edad <= 50, na.rm = TRUE)
n_infantil_temprano    <- sum(df$edad >= 0 & df$edad <= 5, na.rm = TRUE)
n_bono_juana_ninos     <- sum(df$edad >= 0 & df$edad <= 2, na.rm = TRUE)
n_educacion_escolar    <- sum(df$edad >= 4, na.rm = TRUE)
n_educacion_tic        <- sum(df$edad >= 5, na.rm = TRUE)
n_empleo_pet           <- sum(df$pet == 1, na.rm = TRUE)
n_empleo_ocupados      <- sum(df$condact == 1, na.rm = TRUE)
n_renta_dignidad       <- sum(df$edad >= 60, na.rm = TRUE)

message(paste0(">>> Poblacion total observada: ", n_total_poblacion))
message(paste0(">>> Universo Fecundidad (Mujeres 13 a 50 anios): ", n_fecundidad_mujeres))
message(paste0(">>> Universo Educacion (Personas >= 4 anios): ", n_educacion_escolar))
message(paste0(">>> Universo Empleo PET (Personas >= 14 anios): ", n_empleo_pet))
message(paste0(">>> Universo Poblacion Ocupada (condact == 1): ", n_empleo_ocupados))
message(paste0(">>> Universo Renta Dignidad (Adultos Mayores >= 60 anios): ", n_renta_dignidad))

# 4. Construccion de la matriz de metadatos de reglas de salto
reglas_saltos <- data.frame(
  id_regla = 1:9,
  seccion_encuesta = c(
    "Seccion 1: Demografia General",
    "Seccion 2 Parte B: Fecundidad",
    "Seccion 2 Parte C: Desarrollo Infantil",
    "Seccion 2 Parte D: Bono Juana Azurduy",
    "Seccion 3 Parte A: Educacion",
    "Seccion 3 Parte C: Tecnologias TIC",
    "Seccion 4 Parte A: Empleo (PET)",
    "Seccion 4 Partes B-F: Ocupados e Ingresos Laborales",
    "Seccion 5 Parte A: Renta Dignidad"
  ),
  prefijo_variables = c(
    "s01a_, s01b_",
    "s02b_",
    "s02c_",
    "s02d_",
    "s03a_, s03b_",
    "s03c_",
    "s04a_",
    "s04b_, s04c_, s04d_, s04e_, s04f_, tothrs, ylab",
    "s05a_01e, s05a_01e0, s05a_01f"
  ),
  filtro_logico_r = c(
    "TRUE (Aplica a toda la poblacion)",
    "sexo == 2 & edad >= 13 & edad <= 50",
    "edad >= 0 & edad <= 5",
    "edad >= 0 & edad <= 2",
    "edad >= 4",
    "edad >= 5",
    "pet == 1 (edad >= 14 anios)",
    "condact == 1 (Poblacion ocupada con trabajo)",
    "edad >= 60"
  ),
  poblacion_objetivo = c(
    "Todos los miembros del hogar",
    "Mujeres en edad fertil entre 13 y 50 anios",
    "Ninios y ninias de 0 a 5 anios",
    "Ninios y ninias menores de 2 anios",
    "Poblacion de 4 anios o mas",
    "Poblacion de 5 anios o mas",
    "Poblacion en Edad de Trabajar (PET 14 anios o mas)",
    "Poblacion ocupada que genero horas o ingresos",
    "Adultos mayores habilitados para pension universal no contributiva"
  ),
  universo_esperado_n = c(
    n_total_poblacion,
    n_fecundidad_mujeres,
    n_infantil_temprano,
    n_bono_juana_ninos,
    n_educacion_escolar,
    n_educacion_tic,
    n_empleo_pet,
    n_empleo_ocupados,
    n_renta_dignidad
  ),
  inaplicables_esperados_n = c(
    0,
    n_total_poblacion - n_fecundidad_mujeres,
    n_total_poblacion - n_infantil_temprano,
    n_total_poblacion - n_bono_juana_ninos,
    n_total_poblacion - n_educacion_escolar,
    n_total_poblacion - n_educacion_tic,
    n_total_poblacion - n_empleo_pet,
    n_total_poblacion - n_empleo_ocupados,
    n_total_poblacion - n_renta_dignidad
  ),
  clasificacion_na = c(
    "Sin saltos estructurales",
    "NA Estructural si hombre o fuera de 13 a 50 anios",
    "NA Estructural si edad > 5 anios",
    "NA Estructural si edad > 2 anios",
    "NA Estructural si edad < 4 anios",
    "NA Estructural si edad < 5 anios",
    "NA Estructural si menor de 14 anios (pet == 0)",
    "NA Estructural si desocupado o inactivo (condact != 1)",
    "NA Estructural si menor de 60 anios"
  ),
  stringsAsFactors = FALSE
)

# 5. Exportar el catalogo de reglas a CSV
ruta_reglas <- file.path("03_data", "04_metadatos", "reglas_saltos.csv")
readr::write_csv(reglas_saltos, ruta_reglas)
message(paste0(">>> Catalogo oficial de saltos exportado a: ", ruta_reglas))

# 6. Guardar checkpoint interim persona_05.rds
guardar_interim(df, "persona_05")

# 7. Registro en bitacora oficial
log_bitacora(
  id_paso = 5,
  atributo = "reglas_saltos (9 modulos)",
  tipo_problema = "Metadatos de Saltos / Skip Patterns",
  metodologia_fase = "Fase 4: Diagnostico de Datos Faltantes",
  accion_realizada = "Formalizacion de 9 reglas de salto censal segun catalogo INE EH2024 y exportacion de reglas_saltos.csv",
  criterio_justificacion = "Diferenciar NAs estructurales legitimos de verdaderas omisiones de respuesta previas a imputacion",
  filas_afectadas = n_filas,
  impacto_dataset = paste0("Generado reglas_saltos.csv (9 reglas maestras para ", n_filas, " registros)"),
  codigo_script = "05_scripts/01_bloque0_global/05_reglas_de_salto.R"
)

message(">>>Script 05_reglas_de_salto.R completado.\n")