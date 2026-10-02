# 07 · Recodificar NA estructurales (Fase 4) -> version "codificada" con solo NA reales
source("R/funciones.R"); iniciar_script("07_mascara_y_recodificacion")
df <- leer_interim(6); mask <- readRDS(file.path(DIR$interim, "mascara_estructural.rds")); na0 <- na_total(df)
et <- read_csv(file.path(DIR$meta, "etiquetas_variables.csv"), show_col_types = FALSE)
cod <- df; usados <- list()
for (v in names(df)) { m <- mask[, v]; if (!any(m)) next; x <- df[[v]]
  if (is.character(x)) { x[m] <- "NO APLICA"; codigo <- "NO APLICA" } else { codigo <- if (min(x, na.rm = TRUE) >= 0) -1 else -999; x[m] <- if (is.integer(x)) as.integer(codigo) else codigo }
  cod[[v]] <- x; usados[[v]] <- tibble(variable = v, codigo_no_aplica = as.character(codigo), celdas = sum(m)) }
usados <- bind_rows(usados) %>% left_join(et %>% select(variable, tipo_estadistico), by = "variable") %>%
  mutate(riesgo_estadistico = ifelse(tipo_estadistico == "continuo", "alto: excluir el código antes de promediar", "bajo"))
write_csv(usados, file.path(DIR$meta, "codigos_no_aplica.csv"))
na1 <- na_total(cod)
por_b <- tibble(bloque = bloque_de(names(df)), antes = colSums(is.na(df)), despues = colSums(is.na(cod))) %>% group_by(bloque) %>% summarise(antes = sum(antes), despues = sum(despues), .groups = "drop")
larg <- bind_rows(por_b %>% transmute(bloque, etapa = "antes", n = antes), por_b %>% transmute(bloque, etapa = "después", n = despues))
fig <- guardar_figura(ggplot(larg, aes(reorder(bloque, n), n, fill = etapa)) + geom_col(position = "dodge") + coord_flip() + scale_y_continuous(labels = fmt) +
  scale_fill_manual(values = c(antes = "#a0aec0", `después` = "#2b6cb0")) + theme_minimal(base_size = 13) +
  labs(title = "NA antes y después de recodificar los estructurales", x = NULL, y = "Celdas con NA", fill = NULL), "na_antes_despues")
log_bitacora("todas las variables con NA estructural", "Valor nulo por salto lógico", "Fase 4", "Recodificación a 'NO APLICA' (texto) o -1 / -999 (numérico) en la versión codificada",
  "El NA estructural no es información perdida; se codifica de forma explícita y se guarda la máscara", sum(mask),
  sprintf("NA: %s → %s", fmt(na0), fmt(na1)), "x[m] <- codigo  # m = mascara_estructural[, v]")
escribir_informe("Máscara de NA estructurales y recodificación", "Bloque 0 · Global", "Fase 4 · Valores faltantes", head(usados$variable, 12), sum(mask), na0, na1, fig, list(
  Resumen = sprintf("Los NA bajan de **%s a %s** (−%.1f%%). Lo que queda son los NA **reales**, que se imputarán en los Bloques 1 a 4.", fmt(na0), fmt(na1), 100 * (na0 - na1) / na0),
  Contexto = "Se mantienen dos versiones: la de análisis (con NA, más la máscara) y la codificada (cada NA estructural lleva un código explícito).",
  `Diagnóstico` = tabla_md(por_b),
  `Decisión y justificación` = "Código `NO APLICA` en texto; `-1` en numéricas sin negativos; `-999` si ya existían negativos. En variables continuas (ingresos, horas) el código debe excluirse antes de calcular promedios; se marca en `codigos_no_aplica.csv`.",
  Procedimiento = "Para cada variable, `x[mascara] <- codigo`.",
  Resultados = img_md(fig, "NA por bloque antes y después de recodificar"),
  `Validación` = sprintf("Los NA que quedan equivalen a los NA reales estimados: %s.", fmt(na1)),
  `Puntos para exponer` = c("- De la cifra inicial de NA solo queda una fracción pequeña: los NA reales.", "- La versión codificada se guarda aparte; la de análisis conserva NA + máscara."),
  `Archivos generados` = "- `data/metadatos/codigos_no_aplica.csv`\n- `data/interim/persona_07.rds` (con NA)\n- `data/interim/persona_07_codificado.rds`"))
guardar_interim(df, 7); saveRDS(cod, file.path(DIR$interim, "persona_07_codificado.rds")); cerrar_script()
