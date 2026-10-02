# R/funciones.R -- utilidades comunes. Cada script empieza con: source("R/funciones.R")
suppressWarnings(try(Sys.setlocale("LC_CTYPE", "C.UTF-8"), silent = TRUE))
suppressPackageStartupMessages({library(readr); library(dplyr); library(ggplot2); library(stringr); library(stringi); library(tibble)})
source("config/config.R")
for (d in unlist(DIR)) dir.create(d, recursive = TRUE, showWarnings = FALSE)

# ---- Bloques tematicos --------------------------------------------------
VIV_VARS <- c("folio","area","depto","nro","upm","estrato","factor","totper","tipohogar",
              "yhog","yhogpc","z","zext","p0","p1","p2","pext0","pext1","pext2")
bloque_de <- function(v) {
  case_when(
    v %in% VIV_VARS ~ "Vivienda",
    v %in% c("sexo","edad","parentesco") | str_starts(v, "s01") ~ "Sociodemografico",
    str_starts(v, "s02") | v %in% c("cobersalud","hnv_ult_a","quienatenparto") ~ "Salud",
    str_starts(v, "s03") | v %in% c("niv_ed","niv_ed_g","cmasi","educ_prev","aestudio") ~ "Educacion",
    str_starts(v, "s05") | v %in% c("ynolab","yper") ~ "Ingresos",
    TRUE ~ "Empleo")
}

# ---- Utilidades -----------------------------------------------------------
na_total <- function(df) sum(is.na(df))
fmt <- function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)
guardar_interim <- function(df, n) { saveRDS(df, sprintf("%s/persona_%02d.rds", DIR$interim, n)); invisible(df) }
leer_interim <- function(n) readRDS(sprintf("%s/persona_%02d.rds", DIR$interim, n))

# ---- Figuras e informes -----------------------------------------------------
guardar_figura <- function(p, nombre, w = 9, h = 5.5) {
  f <- file.path(DIR$img, sprintf("%s_%s.png", substr(SCRIPT_ID, 1, 2), nombre))
  ggsave(f, p, width = w, height = h, dpi = 110, bg = "white"); f
}
img_md <- function(f, alt) sprintf("![%s](../%s)", alt, f)
tabla_md <- function(df) {
  if (nrow(df) == 0) return("_(sin filas)_")
  df <- as.data.frame(lapply(df, function(x) if (is.numeric(x)) fmt(x) else as.character(x)), stringsAsFactors = FALSE)
  enc <- paste0("| ", paste(names(df), collapse = " | "), " |")
  sep <- paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|")
  filas <- apply(df, 1, function(r) paste0("| ", paste(gsub("\\|", "/", r), collapse = " | "), " |"))
  paste(c(enc, sep, filas), collapse = "\n")
}
SECCIONES <- c("Resumen","Contexto","Diagnóstico","Decisión y justificación","Procedimiento",
               "Resultados","Validación","Puntos para exponer","Archivos generados")
escribir_informe <- function(titulo, bloque, fase, variables, filas_afectadas, na_antes, na_despues, imagenes, secciones) {
  vv <- if (length(variables) > 12) c(variables[1:12], "...") else variables
  yml <- c("---", paste0("id: ", substr(SCRIPT_ID, 1, 2)), paste0("titulo: \"", titulo, "\""),
           paste0("bloque: \"", bloque, "\""), paste0("fase: \"", fase, "\""),
           paste0("script: scripts/", SCRIPT_ID, ".R"), paste0("variables: [", paste(vv, collapse = ", "), "]"),
           paste0("filas_afectadas: ", filas_afectadas), paste0("na_antes: ", na_antes),
           paste0("na_despues: ", na_despues), "imagenes:", paste0("  - ", imagenes), "---", "")
  secciones[["Archivos generados"]] <- paste(c(paste0("- `scripts/", SCRIPT_ID, ".R`"),
      paste0("- `", imagenes, "`"), secciones[["Archivos generados"]]), collapse = "\n")
  cuerpo <- unlist(lapply(SECCIONES, function(s) c(paste0("## ", s), "",
      if (is.null(secciones[[s]])) "—" else paste(secciones[[s]], collapse = "\n"), "")))
  writeLines(enc2utf8(c(yml, paste0("# ", substr(SCRIPT_ID, 1, 2), " · ", titulo), "", cuerpo)),
             file.path(DIR$inf, paste0(SCRIPT_ID, ".md")), useBytes = TRUE)
}

# ---- Bitacora (12 columnas del marco teorico) -------------------------------
iniciar_script <- function(id) { assign("SCRIPT_ID", id, envir = .GlobalEnv); assign("BIT_BUFFER", tibble(), envir = .GlobalEnv); cat("==", id, "==\n") }
log_bitacora <- function(atributo, tipo_problema, fase, accion, criterio, filas_afectadas, impacto, codigo, dataset = "persona.csv") {
  fila <- tibble(id_paso = NA_character_, fecha_hora = format(Sys.time(), "%Y-%m-%dT%H:%M:%S"),
    responsable = Sys.info()[["user"]], dataset = dataset, atributo = atributo, tipo_problema = tipo_problema,
    metodologia_fase = fase, accion_realizada = accion, criterio_justificacion = criterio,
    filas_afectadas = as.character(filas_afectadas), impacto_dataset = impacto,
    codigo_script = paste0(SCRIPT_ID, ".R: ", codigo))
  assign("BIT_BUFFER", bind_rows(BIT_BUFFER, fila), envir = .GlobalEnv)
}
cerrar_script <- function() {
  prev <- if (file.exists(F_BIT)) read_csv(F_BIT, col_types = cols(.default = "c"), show_col_types = FALSE) else tibble()
  if (nrow(prev) > 0) prev <- prev[!startsWith(prev$codigo_script, paste0(SCRIPT_ID, ".R:")), ]
  todo <- bind_rows(prev, BIT_BUFFER) %>% arrange(substr(codigo_script, 1, 2)) %>% mutate(id_paso = as.character(row_number()))
  write_csv(todo, F_BIT); cat("   bitacora:", nrow(BIT_BUFFER), "filas nuevas\n")
}
