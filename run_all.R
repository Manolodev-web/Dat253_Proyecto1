# ==============================================================================
# Pipeline Maestro: run_all.R
# Proyecto: DAT-253 - Limpieza y Auditoria de la Encuesta de Hogares 2024
# Descripcion: Ejecuta secuencialmente los 33 scripts modulares del pipeline.
# ==============================================================================

# 1. Asegurar directorio raiz
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}
message(">>> [INICIO] Ejecutando Pipeline Maestro DAT-253 desde: ", getwd())

# 2. Configurar entorno y dependencias
source("01_config/packages.R")
source("02_R_helpers/funciones.R")

# 3. Lista ordenada de scripts
scripts <- c(
  # Bloque 0: Global
  "05_scripts/01_bloque0_global/00_perfilado_inicial.R",
  "05_scripts/01_bloque0_global/01_reconciliacion_metadatos.R",
  "05_scripts/01_bloque0_global/02_coercion_tipos.R",
  "05_scripts/01_bloque0_global/03_normalizacion_texto.R",
  "05_scripts/01_bloque0_global/04_duplicados_integridad.R",
  "05_scripts/01_bloque0_global/05_reglas_de_salto.R",
  "05_scripts/01_bloque0_global/06_clasificar_NA.R",
  "05_scripts/01_bloque0_global/07_recodificar_NA_estructurales.R",
  
  # Bloque 1: Vivienda
  "05_scripts/02_bloque1_vivienda/08_viv_diagnostico.R",
  "05_scripts/02_bloque1_vivienda/09_viv_totper_tipohogar.R",
  "05_scripts/02_bloque1_vivienda/10_viv_ingreso_hogar_pobreza.R",
  "05_scripts/02_bloque1_vivienda/11_viv_validacion.R",
  
  # Bloque 2: Salud
  "05_scripts/03_bloque2_salud/12_salud_diagnostico.R",
  "05_scripts/03_bloque2_salud/13_salud_nulos.R",
  "05_scripts/03_bloque2_salud/14_salud_saltos_fecundidad.R",
  "05_scripts/03_bloque2_salud/15_salud_gastos_bolsillo.R",
  "05_scripts/03_bloque2_salud/16_salud_validacion.R",
  
  # Bloque 3: Educacion
  "05_scripts/04_bloque3_educacion/17_edu_diagnostico.R",
  "05_scripts/04_bloque3_educacion/18_edu_nulos_alfabetismo.R",
  "05_scripts/04_bloque3_educacion/19_edu_consistencia_biologica.R",
  "05_scripts/04_bloque3_educacion/20_edu_tics_sinteticas.R",
  "05_scripts/04_bloque3_educacion/21_edu_validacion.R",
  
  # Bloque 4: Empleo e Ingresos
  "05_scripts/05_bloque4_empleo/22_emp_diagnostico.R",
  "05_scripts/05_bloque4_empleo/23_emp_horas_trabajadas.R",
  "05_scripts/05_bloque4_empleo/24_emp_imputacion_mice.R",
  "05_scripts/05_bloque4_empleo/25_emp_salario_minimo_outliers.R",
  "05_scripts/05_bloque4_empleo/26_emp_ingreso_horario_sinteticas.R",
  "05_scripts/05_bloque4_empleo/27_emp_validacion.R",
  
  # Bloque 5: Consolidacion y Cierre
  "05_scripts/06_bloque5_consolidacion/28_nolab_diagnostico.R",
  "05_scripts/06_bloque5_consolidacion/29_nolab_renta_dignidad_saltos.R",
  "05_scripts/06_bloque5_consolidacion/30_ingreso_total_consolidacion.R",
  "05_scripts/06_bloque5_consolidacion/31_exportar_dataset_final.R",
  "05_scripts/06_bloque5_consolidacion/32_auditoria_certificacion_global.R"
)

# 4. Ejecucion controlada
tiempo_inicio <- Sys.time()

for (i in seq_along(scripts)) {
  s <- scripts[i]
  message(paste0("\n>>> [RUN ", i, "/", length(scripts), "] Ejecutando: ", basename(s)))
  source(s, echo = FALSE)
}

tiempo_total <- round(difftime(Sys.time(), tiempo_inicio, units = "mins"), 2)
message("\n================================================================================")
message(">>> [EXITO MAESTRO] Pipeline completo ejecutado en ", tiempo_total, " minutos.")
message("================================================================================\n")