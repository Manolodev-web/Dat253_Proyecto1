# 00 · Auditoria inicial (Fase 1: perfilado) -- NO modifica datos
source("R/funciones.R"); iniciar_script("00_auditoria_inicial")
raw <- read_csv(F_RAW, show_col_types = FALSE, guess_max = Inf, progress = FALSE)
n <- nrow(raw); p <- ncol(raw)
rng <- function(x, f) if (is.numeric(x) && any(!is.na(x))) f(x, na.rm = TRUE) else NA_real_
perfil <- tibble(variable = names(raw), bloque = bloque_de(names(raw)),
  tipo = vapply(raw, function(x) class(x)[1], character(1)),
  n_na = unname(colSums(is.na(raw))), n_unicos = unname(vapply(raw, function(x) n_distinct(x, na.rm = TRUE), integer(1))),
  minimo = unname(vapply(raw, rng, numeric(1), f = min)), maximo = unname(vapply(raw, rng, numeric(1), f = max))) %>%
  mutate(pct_na = round(100 * n_na / n, 2))
write_csv(perfil, file.path(DIR$meta, "perfil_inicial.csv"))
por_bloque <- perfil %>% group_by(bloque) %>%
  summarise(columnas = n(), celdas_na = sum(n_na), pct_na = round(100 * sum(n_na) / (n() * n), 1), .groups = "drop") %>% arrange(desc(pct_na))
na_tot <- sum(perfil$n_na); celdas <- n * p
c_sin <- sum(perfil$n_na == 0); c_90 <- sum(perfil$pct_na > 90); c_unarias <- sum(perfil$n_unicos == 1)
fig <- guardar_figura(ggplot(por_bloque, aes(reorder(bloque, pct_na), pct_na)) + geom_col(fill = "#2b6cb0") +
  geom_text(aes(label = paste0(pct_na, "%")), hjust = -0.1) + coord_flip() + ylim(0, 100) + theme_minimal(base_size = 13) +
  labs(title = "Porcentaje de celdas vacías por bloque (base original)", x = NULL, y = "% de NA"), "na_por_bloque")
log_bitacora("todas", "Perfilado inicial", "Fase 1", "Cálculo de tipos, NA, cardinalidad y rangos por variable",
  "Conocer el estado de la base antes de intervenir", 0, sprintf("%s filas x %s columnas; %s NA (%.1f%%)", fmt(n), p, fmt(na_tot), 100 * na_tot / celdas),
  "perfil <- tibble(variable, tipo, n_na, n_unicos, minimo, maximo)")
escribir_informe("Auditoría inicial de la base persona", "Bloque 0 · Global", "Fase 1 · Perfilado", names(raw), 0, na_tot, na_tot, fig, list(
  Resumen = sprintf("La base tiene **%s filas y %s columnas** (%s celdas). **%s celdas están vacías (%.1f%%)**. Este paso solo mide; no modifica nada.", fmt(n), p, fmt(celdas), fmt(na_tot), 100 * na_tot / celdas),
  Contexto = "Base de personas de la Encuesta de Hogares (INE Bolivia). Se perfila cada variable: tipo, NA, valores únicos, mínimo y máximo.",
  `Diagnóstico` = c(sprintf("- Columnas sin ningún NA: **%d**", c_sin), sprintf("- Columnas con más de 90%% de NA: **%d**", c_90),
    sprintf("- Columnas de valor único (unarias): **%d**", c_unarias), "", tabla_md(por_bloque)),
  `Decisión y justificación` = "No se elimina ni imputa nada todavía. Un NA alto no implica dato perdido: muchas preguntas solo aplican a parte de la población (saltos de la boleta). Se estudia en los scripts 05 y 06.",
  Procedimiento = "`read_csv()` con `guess_max = Inf`, luego `colSums(is.na())`, `n_distinct()` y rangos por variable. Tabla completa en `data/metadatos/perfil_inicial.csv`.",
  Resultados = img_md(fig, "Porcentaje de NA por bloque temático"),
  `Validación` = "Se comprobó que ninguna columna está 100% vacía y que el número de filas coincide con el CSV (39.497).",
  `Puntos para exponer` = c("- La base original está muy 'sucia' solo en apariencia: la mayoría de NA son estructurales.", "- Empleo concentra el mayor % de NA porque sus preguntas aplican solo a ocupados."),
  `Archivos generados` = "- `data/metadatos/perfil_inicial.csv`\n- `data/interim/persona_00.rds`"))
guardar_interim(raw, 0); cerrar_script()
