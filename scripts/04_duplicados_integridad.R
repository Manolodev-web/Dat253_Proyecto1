# 04 · Duplicados e integridad de llaves (Fase 3)
source("R/funciones.R"); iniciar_script("04_duplicados_integridad")
df <- leer_interim(3); na0 <- na_total(df); n0 <- nrow(df)
dup_filas <- sum(duplicated(df)); dup_llave <- sum(duplicated(df[c("folio", "nro")]))
folio_mal <- sum(!str_detect(df$folio, "^\\d{3}-\\d{6}-[A-Z]-\\d{4}$")); upm_inc <- sum(!startsWith(df$folio, df$upm))
pf <- df %>% group_by(folio) %>% summarise(n = n(), n_area = n_distinct(area), n_depto = n_distinct(depto), jefes = sum(parentesco == 1), nro_ok = all(sort(nro) == seq_len(n())), .groups = "drop")
chk <- tibble(control = c("Filas duplicadas exactas", "Duplicados de llave (folio+nro)", "Folios con formato inválido", "Filas con upm incoherente con folio",
  "Hogares (folios únicos)", "Hogares con área inconsistente", "Hogares con departamento inconsistente", "Hogares sin jefe (parentesco=1)", "Hogares con más de un jefe", "Hogares con `nro` no consecutivo"),
  resultado = c(dup_filas, dup_llave, folio_mal, upm_inc, nrow(pf), sum(pf$n_area > 1), sum(pf$n_depto > 1), sum(pf$jefes == 0), sum(pf$jefes > 1), sum(!pf$nro_ok)))
if (dup_filas > 0) df <- distinct(df); if (dup_llave > 0) df <- df[!duplicated(df[c("folio", "nro")]), ]
fig <- guardar_figura(ggplot(pf, aes(n)) + geom_bar(fill = "#2b6cb0") + theme_minimal(base_size = 13) +
  labs(title = "Personas por hogar (folio)", x = "Personas en el hogar", y = "Hogares"), "personas_por_hogar")
log_bitacora("folio, nro, upm, area, depto, parentesco", "Duplicado / integridad de llaves", "Fase 3", "Verificación de duplicados y coherencia por hogar",
  "La llave primaria es folio+nro; cada hogar debe tener un único jefe", n0 - nrow(df), sprintf("%s → %s filas", fmt(n0), fmt(nrow(df))),
  "sum(duplicated(df[c('folio','nro')]))")
escribir_informe("Duplicados e integridad de llaves", "Bloque 0 · Global", "Fase 3 · Duplicados", c("folio", "nro", "upm", "area", "depto", "parentesco"), n0 - nrow(df), na0, na_total(df), fig, list(
  Resumen = sprintf("Se eliminaron **%d filas** por duplicado. Se revisaron además la coherencia de llaves y la estructura de los **%s hogares**.", n0 - nrow(df), fmt(nrow(pf))),
  Contexto = "La llave de cada persona es `folio` + `nro`. Cada hogar debe tener un único jefe/a y compartir área y departamento.",
  `Diagnóstico` = tabla_md(chk),
  `Decisión y justificación` = "Solo se eliminaría un duplicado de llave o una fila idéntica. Las inconsistencias de estructura (hogares sin jefe o con varios) se **reportan** y se tratan en el Bloque 1.",
  Procedimiento = "`duplicated()` sobre la fila completa y sobre la llave; expresión regular para `folio`; agregación por `folio`.",
  Resultados = img_md(fig, "Distribución de personas por hogar"),
  `Validación` = "Tras el paso, `folio` + `nro` es llave única (0 duplicados).",
  `Puntos para exponer` = c("- La base no tenía duplicados; la verificación de integridad prepara el recálculo de `totper`."),
  `Archivos generados` = "- `data/interim/persona_04.rds`"))
guardar_interim(df, 4); cerrar_script()
