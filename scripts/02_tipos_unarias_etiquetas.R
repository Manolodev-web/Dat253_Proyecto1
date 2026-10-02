# 02 · Tipos, columnas unarias y etiquetas (Fases 1-2)
source("R/funciones.R"); iniciar_script("02_tipos_unarias_etiquetas")
df <- leer_interim(1); na0 <- na_total(df); mb0 <- as.numeric(object.size(df)) / 1e6
es_entero <- function(x) { v <- x[!is.na(x)]; is.numeric(x) && !is.integer(x) && length(v) > 0 && all(v == round(v)) && max(abs(v)) < 2e9 }
cols_cast <- names(df)[vapply(df, es_entero, logical(1))]
df[cols_cast] <- lapply(df[cols_cast], as.integer); mb1 <- as.numeric(object.size(df)) / 1e6
unarias <- names(df)[vapply(df, function(x) n_distinct(x, na.rm = TRUE) == 1, logical(1))]
tp <- vapply(df, function(x) { nu <- n_distinct(x, na.rm = TRUE)
  if (is.character(x)) "texto libre" else if (nu == 2) "binario" else if (nu <= 12) "categorico/ordinal" else if (is.integer(x)) "discreto" else "continuo" }, character(1))
et <- tibble(variable = names(df), bloque = bloque_de(names(df)), tipo_r = vapply(df, function(x) class(x)[1], character(1)),
  tipo_estadistico = unname(tp), n_unicos = unname(vapply(df, function(x) n_distinct(x, na.rm = TRUE), integer(1))), es_unaria = names(df) %in% unarias)
et$tipo_estadistico[et$variable %in% c("folio", "upm")] <- "identificador"
write_csv(et, file.path(DIR$meta, "etiquetas_variables.csv"))
fig <- guardar_figura(ggplot(et, aes(tipo_estadistico, fill = bloque)) + geom_bar() + coord_flip() + theme_minimal(base_size = 13) +
  labs(title = "Tipo estadístico de las variables por bloque", x = NULL, y = "Número de variables", fill = "Bloque"), "tipos_por_bloque")
log_bitacora(paste0(length(cols_cast), " columnas numéricas"), "Inconsistencia de formato", "Fase 2", "Casting de decimales con valores enteros a integer",
  "Códigos y conteos no necesitan decimales; reduce memoria", nrow(df), sprintf("%.0f MB → %.0f MB en memoria", mb0, mb1), "df[cols_cast] <- lapply(df[cols_cast], as.integer)")
log_bitacora(paste(unarias, collapse = ", "), "Columna unaria", "Fase 1", "Se marcan; no se eliminan en este paso",
  "totper se recalcula en el script 09; las de texto son campos 'especifique' con 1-2 respuestas", 0, paste(length(unarias), "columnas unarias"), "unarias <- names(df)[vapply(df, function(x) n_distinct(x, na.rm=TRUE)==1, logical(1))]")
escribir_informe("Tipos de datos, columnas unarias y etiquetas", "Bloque 0 · Global", "Fases 1-2 · Perfilado y formatos", c(cols_cast[1:5], unarias), nrow(df), na0, na_total(df), fig, list(
  Resumen = sprintf("Se convirtieron **%d columnas** de decimal a entero (memoria %.0f → %.0f MB) y se detectaron **%d columnas unarias**.", length(cols_cast), mb0, mb1, length(unarias)),
  Contexto = "`read_csv` lee como decimal cualquier columna con NA. Para códigos y conteos el tipo correcto es entero.",
  `Diagnóstico` = c(paste0("Columnas unarias: ", paste0("`", unarias, "`", collapse = ", ")), "", tabla_md(et %>% count(tipo_estadistico, name = "variables"))),
  `Decisión y justificación` = "Las unarias de tipo numérico (`totper`) no se borran todavía: se reconstruirán desde `folio`. Las de texto son respuestas 'especifique' y se conservan.",
  Procedimiento = "Se detecta si una columna decimal tiene solo valores enteros y se aplica `as.integer()`. El tipo estadístico se asigna por cardinalidad.",
  Resultados = img_md(fig, "Número de variables por tipo estadístico y bloque"),
  `Validación` = "Se verificó que el casting no alteró ningún valor (los NA siguen igual: mismo total antes y después).",
  `Puntos para exponer` = c("- Clasificar variables (binario, categórico, discreto, continuo) define luego qué método de imputación usar."),
  `Archivos generados` = "- `data/metadatos/etiquetas_variables.csv`\n- `data/interim/persona_02.rds`"))
guardar_interim(df, 2); cerrar_script()
