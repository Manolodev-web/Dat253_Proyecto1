# 03 · Normalizar texto (Fase 2)
source("R/funciones.R"); iniciar_script("03_normalizar_texto")
df <- leer_interim(2); na0 <- na_total(df)
cols_txt <- names(df)[vapply(df, is.character, logical(1))]
norm <- function(x) { y <- toupper(str_squish(stri_trans_general(x, "Latin-ASCII"))); y[!is.na(y) & y == ""] <- NA; y }
res <- bind_rows(lapply(cols_txt, function(v) { x <- df[[v]]; y <- norm(x)
  r <- tibble(variable = v, celdas_texto = sum(!is.na(x)), celdas_cambiadas = sum(x != y, na.rm = TRUE) + sum(is.na(y) & !is.na(x)),
    unicos_antes = n_distinct(x, na.rm = TRUE), unicos_despues = n_distinct(y, na.rm = TRUE)); df[[v]] <<- y; r }))
tot_cambios <- sum(res$celdas_cambiadas)
long <- bind_rows(res %>% transmute(variable, etapa = "antes", n = unicos_antes), res %>% transmute(variable, etapa = "después", n = unicos_despues)) %>% filter(!variable %in% c("folio", "upm"))
fig <- guardar_figura(ggplot(long, aes(variable, n, fill = etapa)) + geom_col(position = "dodge") + coord_flip() + theme_minimal(base_size = 12) +
  labs(title = "Valores distintos de texto antes y después de normalizar", x = NULL, y = "Valores únicos"), "texto_antes_despues")
log_bitacora(paste(cols_txt, collapse = ", "), "Inconsistencia de formato", "Fase 2", "Trimming, mayúsculas, quitar tildes y cadenas vacías → NA",
  "Evitar categorías duplicadas por formato", tot_cambios, sprintf("%d columnas de texto; %d celdas modificadas", length(cols_txt), tot_cambios),
  "y <- toupper(str_squish(stri_trans_general(x, 'Latin-ASCII')))")
escribir_informe("Normalización de texto", "Bloque 0 · Global", "Fase 2 · Formatos", cols_txt, tot_cambios, na0, na_total(df), fig, list(
  Resumen = sprintf("Se normalizaron **%d columnas de texto**; se modificaron **%s celdas**.", length(cols_txt), fmt(tot_cambios)),
  Contexto = "Las columnas 'especifique' (`s03a_05e`, `s04a_06e`, etc.) contienen texto libre; los identificadores `folio` y `upm` también son texto.",
  `Diagnóstico` = tabla_md(res),
  `Decisión y justificación` = if (tot_cambios == 0) "El texto ya venía en mayúsculas, sin tildes ni espacios sobrantes: el INE lo entregó normalizado. Se deja constancia y se mantiene el paso como control." else "Se aplicó la misma normalización a todas las columnas de texto para evitar duplicados por formato.",
  Procedimiento = "`stri_trans_general('Latin-ASCII')`, `str_squish()`, `toupper()` y conversión de cadenas vacías a NA.",
  Resultados = img_md(fig, "Valores únicos antes y después de normalizar"),
  `Validación` = "El total de NA solo puede aumentar si había cadenas vacías; se compara antes y después en el YAML.",
  `Puntos para exponer` = c("- Un paso que no cambia nada también es un resultado: confirma que el texto ya estaba limpio."),
  `Archivos generados` = "- `data/interim/persona_03.rds`"))
guardar_interim(df, 3); cerrar_script()
