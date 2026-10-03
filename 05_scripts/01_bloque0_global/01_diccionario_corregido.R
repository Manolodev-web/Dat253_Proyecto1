# ==============================================================================
# Script: 01_diccionario_corregido.R
# Bloque: 00 - Global
# Descripcion: Reconciliacion formal de variables sociodemograficas (Seccion 1)
#              con auto-ubicacion de ruta y exportacion de diccionario_corregido.csv
#              (Texto estandarizado en ASCII sin tildes ni enies).
# Entrada: 03_data/02_interim/persona_00.rds
# Salida:  03_data/04_metadatos/diccionario_corregido.csv
#          03_data/02_interim/persona_01.rds
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

# 2. Cargar helpers
source("02_R_helpers/funciones.R")

message(">>> [INICIO] Ejecutando 01_diccionario_corregido.R...")

# 3. Cargar el estado anterior (persona_00.rds)
ruta_interim_00 <- file.path("03_data", "02_interim", "persona_00.rds")
if (!file.exists(ruta_interim_00)) {
  stop("ERROR: No se encuentra persona_00.rds. Ejecuta primero 00_auditoria_inicial.R")
}

df <- readRDS(ruta_interim_00)
n_filas_orig <- nrow(df)
n_cols_orig  <- ncol(df)

# 4. Derivacion de variables explicitas segun catalogo oficial INE 2024
# s01a_02 = Sexo (1 = Hombre, 2 = Mujer)
# s01a_03 = Edad cumplida (0 a 98 anios)
# s01a_05 = Parentesco con jefe/a (1 = Jefe, 2 = Conyuge, etc.)
df <- df %>%
  mutate(
    sexo = as.integer(s01a_02),
    edad = as.integer(s01a_03),
    parentesco = as.integer(s01a_05)
  )

message(">>> Variables explicitas creadas: sexo, edad, parentesco.")
message(paste0(">>> Total hombres (sexo=1): ", sum(df$sexo == 1, na.rm = TRUE)))
message(paste0(">>> Total mujeres (sexo=2): ", sum(df$sexo == 2, na.rm = TRUE)))
message(paste0(">>> Rango de edad verificado: [", min(df$edad, na.rm = TRUE), " - ", max(df$edad, na.rm = TRUE), "] anios"))
message(paste0(">>> Jefes/as de hogar verificados (parentesco=1): ", sum(df$parentesco == 1, na.rm = TRUE)))

# 5. Construccion de diccionario_corregido.csv en ASCII limpio
cols_actuales <- names(df)

clasificar_bloque <- function(col) {
  if (col %in% c("folio", "area", "depto", "estrato", "upm", "factor", "totper", "tipohogar", 
                 "yhog", "yhogpc", "z", "zext", "p0", "p1", "p2", "pext0", "pext1", "pext2")) {
    return("Vivienda / Hogar")
  } else if (startsWith(col, "s01") || col %in% c("nro", "sexo", "edad", "parentesco")) {
    return("Demografia (Seccion 1)")
  } else if (startsWith(col, "s02") || col %in% c("cobersalud", "hnv_ult_a", "quienatenparto")) {
    return("Salud (Seccion 2)")
  } else if (startsWith(col, "s03") || col %in% c("niv_ed", "niv_ed_g", "cmasi", "educ_prev", "aestudio")) {
    return("Educacion (Seccion 3)")
  } else if (startsWith(col, "s04") || col %in% c("cob_op", "caeb_op", "caeb_os", "pet", "pea", "pei", 
                                                  "condact", "phrs", "shrs", "tothrs", "yprilab", "yseclab", "ylab")) {
    return("Empleo (Seccion 4)")
  } else if (startsWith(col, "s05") || col %in% c("ynolab", "yper")) {
    return("Ingresos No Laborales (Seccion 5)")
  } else {
    return("Otras Variables Derivadas")
  }
}

diccionario_corregido <- data.frame(
  id_variable = seq_along(cols_actuales),
  nombre_columna = cols_actuales,
  tipo_dato_r = sapply(df, class),
  bloque_tematico = sapply(cols_actuales, clasificar_bloque),
  descripcion_oficial_ine = case_when(
    cols_actuales == "folio" ~ "Identificador unico de la vivienda o hogar",
    cols_actuales == "nro" ~ "Numero correlativo de orden de la persona en el hogar",
    cols_actuales == "area" ~ "Area geografica (1 = Urbana, 2 = Rural)",
    cols_actuales == "depto" ~ "Departamento (1 = Chuquisaca ... 9 = Pando)",
    cols_actuales == "s01a_02" ~ "Sexo registrado original (1 = Hombre, 2 = Mujer)",
    cols_actuales == "s01a_03" ~ "Anios cumplidos de la persona (Edad)",
    cols_actuales == "s01a_04a" ~ "Dia de nacimiento",
    cols_actuales == "s01a_04b" ~ "Mes de nacimiento",
    cols_actuales == "s01a_04c" ~ "Anio de nacimiento",
    cols_actuales == "s01a_05" ~ "Parentesco con el o la jefe/a del hogar (1 a 14)",
    cols_actuales == "s01a_10" ~ "Estado civil o conyugal actual",
    cols_actuales == "sexo" ~ "Variable estandarizada: 1 = Hombre, 2 = Mujer",
    cols_actuales == "edad" ~ "Variable estandarizada: Edad en anios cumplidos (0 a 98)",
    cols_actuales == "parentesco" ~ "Variable estandarizada: Parentesco con jefe/a (1 a 14)",
    cols_actuales == "totper" ~ "Total de personas en el hogar (requiere recalculacion en bloque vivienda)",
    cols_actuales == "pet" ~ "Poblacion en Edad de Trabajar (14 anios o mas segun catalogo INE 2024)",
    cols_actuales == "tothrs" ~ "Total de horas trabajadas por semana en todas las ocupaciones",
    cols_actuales == "ylab" ~ "Ingreso laboral individual liquido mensual (Bs/Mes)",
    cols_actuales == "cobersalud" ~ "Cobertura de seguro de salud (1 = SUS, 2 = Caja, etc.)",
    cols_actuales == "aestudio" ~ "Anios de estudio acumulados aprobados",
    TRUE ~ "Variable documentada segun catalogo oficial DDI EH 2024 INE"
  ),
  stringsAsFactors = FALSE
)

ruta_diccionario <- file.path("03_data", "04_metadatos", "diccionario_corregido.csv")
readr::write_csv(diccionario_corregido, ruta_diccionario)
message(paste0(">>> Diccionario oficial corregido exportado a: ", ruta_diccionario))

# 6. Guardar checkpoint interim persona_01.rds
guardar_interim(df, "persona_01")

# 7. Registro en bitacora
log_bitacora(
  id_paso = 1,
  atributo = "s01a_02, s01a_03, s01a_05, sexo, edad, parentesco",
  tipo_problema = "Error Estructural / Reconciliacion de Metadatos",
  metodologia_fase = "Fase 2: Normalizacion de Estructuras",
  accion_realizada = "Reconciliacion con catalogo oficial DDI INE EH2024; creacion de columnas explicitas sexo, edad, parentesco y exportacion de diccionario_corregido.csv",
  criterio_justificacion = "El diccionario preliminar Word contenia descripciones permutadas en la Seccion 1; validado con el catalogo oficial DDI del INE (V732-V737)",
  filas_afectadas = n_filas_orig,
  impacto_dataset = paste0(n_filas_orig, " filas x ", ncol(df), " columnas (+3 columnas explicitas)"),
  codigo_script = "05_scripts/01_bloque0_global/01_diccionario_corregido.R"
)

message(">>> [FIN] Script 01_diccionario_corregido.R completado exitosamente.\n")