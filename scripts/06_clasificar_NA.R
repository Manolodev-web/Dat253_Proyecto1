# 06 · Clasificar NA: estructural vs real, y estrategia sugerida (Fase 4)
source("R/funciones.R"); iniciar_script("06_clasificar_NA")
df <- leer_interim(5); N <- nrow(df); na0 <- na_total(df)
reglas <- read_csv(file.path(DIR$meta, "reglas_saltos.csv"), show_col_types = FALSE)
et <- read_csv(file.path(DIR$meta, "etiquetas_variables.csv"), show_col_types = FALSE) %>% select(variable, tipo_estadistico)
cl <- reglas %>% left_join(et, by = "variable") %>% mutate(pct_real_en_universo = ifelse(n_universo > 0, round(100 * na_real / n_universo, 1), 0),
  estrategia_sugerida = case_when(na_real == 0 ~ "ninguna (sin NA reales)",
    pct_real_en_universo > 40 ~ "revisar: posible salto no detectado o MNAR",
    tipo_estadistico == "texto libre" ~ "dejar como 'NO REPORTA'",
    tipo_estadistico %in% c("binario", "categorico/ordinal") ~ if_else(pct_real_en_universo <= 5, "imputar moda / hot-deck", "imputar con mice (polyreg/logreg)"),
    TRUE ~ if_else(pct_real_en_universo <= 5, "imputar mediana / regresión", "imputar con mice (PMM)")))
write_csv(cl, file.path(DIR$meta, "na_clasificados.csv"))
bl <- cl %>% group_by(bloque) %>% summarise(na_total = sum(n_na), na_estructural = sum(na_estructural), na_real = sum(na_real), .groups = "drop") %>%
  mutate(pct_estructural = round(100 * na_estructural / na_total, 1)) %>% arrange(desc(na_total))
tot <- bl %>% summarise(na_total = sum(na_total), na_estructural = sum(na_estructural), na_real = sum(na_real))
top_real <- cl %>% filter(na_real > 0) %>% arrange(desc(na_real)) %>% slice_head(n = 12) %>% select(variable, bloque, na_real, pct_real_en_universo, estrategia_sugerida)
oc <- df %>% filter(condact == 1); caso <- oc %>% group_by(s04b_12) %>% summarise(ocupados = n(), sin_ylab = sum(is.na(ylab)), pct_sin_ylab = round(100 * mean(is.na(ylab)), 1), .groups = "drop")
ylab_r <- cl %>% filter(variable == "ylab")
larg <- bind_rows(bl %>% transmute(bloque, tipo = "estructural", n = na_estructural), bl %>% transmute(bloque, tipo = "real", n = na_real))
fig <- guardar_figura(ggplot(larg, aes(reorder(bloque, n), n, fill = tipo)) + geom_col() + coord_flip() + scale_y_continuous(labels = fmt) +
  scale_fill_manual(values = c(estructural = "#a0aec0", real = "#e53e3e")) + theme_minimal(base_size = 13) +
  labs(title = "NA por bloque: estructurales vs reales", x = NULL, y = "Celdas con NA", fill = NULL), "na_estructural_vs_real")
log_bitacora("todas las variables con NA", "Valor nulo", "Fase 4", "Clasificación de NA en estructural / real y estrategia sugerida por variable",
  "Solo los NA reales se imputan (Fase 4); los estructurales no representan información perdida", tot$na_real,
  sprintf("%s NA totales: %s estructurales, %s reales", fmt(tot$na_total), fmt(tot$na_estructural), fmt(tot$na_real)), "cl <- reglas %>% mutate(estrategia_sugerida = case_when(...))")
escribir_informe("Clasificación de NA: estructurales vs reales", "Bloque 0 · Global", "Fase 4 · Valores faltantes", c("ylab", top_real$variable[1:5]), 0, na0, na0, fig, list(
  Resumen = sprintf("De **%s NA**, **%s (%.1f%%) son estructurales** (la pregunta no aplicaba) y **%s son NA reales** candidatos a imputación.", fmt(tot$na_total), fmt(tot$na_estructural), 100 * tot$na_estructural / tot$na_total, fmt(tot$na_real)),
  Contexto = "Con las reglas del script 05 cada NA se asigna a una de dos clases. A cada variable con NA real se le sugiere una técnica del curso (moda, hot-deck, regresión, `mice`).",
  `Diagnóstico` = c(tabla_md(bl), "", "Variables con más NA reales:", "", tabla_md(top_real)),
  `Decisión y justificación` = "Imputar solo NA reales. Las variables con más de 40% de NA real dentro de su universo se marcan 'revisar', porque suelen indicar un salto no detectado o un patrón MNAR.",
  Procedimiento = "Cruce de `reglas_saltos.csv` con el tipo estadístico (`etiquetas_variables.csv`) y reglas de decisión por % de NA real.",
  Resultados = c(img_md(fig, "NA estructurales y reales por bloque"), "", "**Caso de control `ylab`** (ocupados por categoría ocupacional `s04b_12`):", "", tabla_md(caso),
    "", sprintf("Regla hallada para `ylab`: `%s`.", ylab_r$regla), "Las categorías con casi 100% sin ingreso son coherentes con trabajo no remunerado (por confirmar en la boleta), por lo que gran parte de los NA de `ylab` entre ocupados son estructurales."),
  `Validación` = "Cada variable cumple n_na = na_estructural + na_real (se comprueba en el script 07).",
  `Puntos para exponer` = c("- La gran mayoría de NA no es información perdida.", "- Corrección sobre el diagnóstico inicial: no todos los ocupados sin `ylab` son faltantes reales; muchos son trabajadores sin remuneración."),
  `Archivos generados` = "- `data/metadatos/na_clasificados.csv`\n- `data/interim/persona_06.rds`"))
stopifnot(all(cl$n_na == cl$na_estructural + cl$na_real))
guardar_interim(df, 6); cerrar_script()
