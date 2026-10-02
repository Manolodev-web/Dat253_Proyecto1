# 05 · Reglas de salto (Fase 4): deduce el "universo" de cada variable
# Para cada variable busca la condicion mas pequena (hasta 3 compuertas) que cubra TODAS sus respuestas.
# Las filas fuera del universo son NA estructurales; las de dentro sin respuesta son NA reales.
source("R/funciones.R"); iniciar_script("05_reglas_de_salto")
df <- leer_interim(4); N <- nrow(df); edad <- df$edad; vars <- names(df); na0 <- na_total(df)
na_n <- colSums(is.na(df))
nu <- vapply(df, function(x) n_distinct(x, na.rm = TRUE), integer(1)); es_num <- vapply(df, is.numeric, logical(1))
excl <- c("s01a_02", "s01a_05", "nro", "area", "depto", "estrato", "factor", "edad", "s01a_03")
g_disc <- setdiff(vars[es_num & nu >= 2 & nu <= 25], excl)      # preguntas filtro (pocas categorias)
g_cont <- setdiff(vars[es_num & nu > 25], excl)                  # montos/cantidades: se usa "monto > 0"
cod <- list(); lvl <- list(); naflag <- list()
for (g in g_disc) { f <- factor(df[[g]], exclude = NULL); cod[[g]] <- as.integer(f); lvl[[g]] <- ifelse(is.na(levels(f)), "NA", levels(f)); naflag[[g]] <- is.na(df[[g]]) }
for (g in g_cont) { nm <- paste0(g, ">0"); x <- df[[g]]; cod[[nm]] <- ifelse(is.na(x), 1L, ifelse(x <= 0, 2L, 3L)); lvl[[nm]] <- c("NA", "<=0", ">0"); naflag[[nm]] <- is.na(x) }
gates <- names(cod); nlev <- vapply(cod, max, integer(1))
MINRED <- max(50, ceiling(0.005 * N))   # una reduccion menor a esto no se considera estructural
TOL <- 0.02                             # una categoria con < 2% de respuestas queda fuera del universo

buscar <- function(v) {
  obs <- !is.na(df[[v]]); U <- rep(TRUE, N); cadena <- character()
  for (nivel in 1:3) {
    idx_u <- which(U); idx_o <- which(U & obs); mejor <- NULL; mejor_tam <- length(idx_u) - MINRED + 1
    r <- range(edad[idx_o]); Ue <- U & edad >= r[1] & edad <= r[2]; te <- sum(Ue)
    if (te < mejor_tam) { mejor <- list(U = Ue, txt = sprintf("edad en [%d,%d]", r[1], r[2])); mejor_tam <- te }
    for (g in gates) {
      if (g == v || g == paste0(v, ">0")) next
      cg <- cod[[g]]; k <- nlev[[g]]; tu <- tabulate(cg[idx_u], nbins = k); to <- tabulate(cg[idx_o], nbins = k)
      S <- to > 0 & (to / pmax(tu, 1)) >= TOL
      if (!any(S)) next
      tg <- sum(tu[S])
      if (tg < mejor_tam) {
        ng <- naflag[[g]]; if (sum(!obs & ng) / max(1, sum(!obs | ng)) >= 0.98) next   # misma huella de NA: no es una regla
        lv <- lvl[[g]][S]
        txt <- sprintf("%s en {%s}", g, if (length(lv) > 8) paste(length(lv), "valores") else paste(lv, collapse = ","))
        mejor <- list(U = U & S[cg], txt = txt); mejor_tam <- tg }
    }
    if (is.null(mejor)) break
    U <- mejor$U; cadena <- c(cadena, mejor$txt)
  }
  list(U = U, cadena = cadena)
}
estructural <- matrix(FALSE, N, length(vars), dimnames = list(NULL, vars)); filas <- vector("list", length(vars))
for (i in seq_along(vars)) { v <- vars[i]; obs <- !is.na(df[[v]])
  if (na_n[[v]] == 0) { U <- rep(TRUE, N); cad <- character() } else { b <- buscar(v); U <- b$U; cad <- b$cadena }
  estructural[, v] <- !U & !obs
  filas[[i]] <- tibble(variable = v, bloque = bloque_de(v), n_na = na_n[[v]], n_respondidos = sum(obs), n_universo = sum(U),
    na_estructural = sum(!U & !obs), na_real = sum(U & !obs), n_excepciones = sum(!U & obs), regla = if (length(cad)) paste(cad, collapse = " Y ") else "todos", niveles = length(cad))
  if (i %% 60 == 0) cat("   ", i, "de", length(vars), "\n") }
reglas <- bind_rows(filas) %>% mutate(pct_na_explicado = ifelse(n_na == 0, NA, round(100 * na_estructural / n_na, 1)))
write_csv(reglas, file.path(DIR$meta, "reglas_saltos.csv")); saveRDS(estructural, file.path(DIR$interim, "mascara_estructural.rds"))
con_na <- reglas %>% filter(n_na > 0)
fig <- guardar_figura(ggplot(con_na, aes(pct_na_explicado)) + geom_histogram(bins = 20, fill = "#2b6cb0", colour = "white") + theme_minimal(base_size = 13) +
  labs(title = "Qué parte de los NA de cada variable explican las reglas de salto", x = "% de NA explicado como estructural", y = "Variables"), "na_explicado_por_reglas")
ej <- reglas %>% filter(variable %in% c("ylab", "phrs", "niv_ed", "s01a_06", "cobersalud", "hnv_ult_a", "yhog", "totper")) %>% select(variable, n_na, regla, na_estructural, na_real)
log_bitacora("todas las variables con NA", "Valor nulo por salto lógico", "Fase 4", "Deducción empírica del universo de cada variable (hasta 3 compuertas)",
  "El universo mínimo que contiene todas las respuestas define quién debía contestar; grupos < 50 filas no se consideran estructurales", sum(reglas$na_estructural),
  sprintf("%d variables con NA analizadas", nrow(con_na)), "buscar <- function(v) {...}  # ver scripts/05_reglas_de_salto.R")
escribir_informe("Reglas de salto de la boleta (universo por variable)", "Bloque 0 · Global", "Fase 4 · Valores faltantes", c("ylab", "phrs", "niv_ed", "s01a_06", "cobersalud", "hnv_ult_a"), 0, na0, na0, fig, list(
  Resumen = sprintf("Se dedujeron reglas de salto para **%d variables** con NA. Resultado: `data/metadatos/reglas_saltos.csv` y la máscara de NA estructurales.", nrow(con_na)),
  Contexto = "No todos los NA son datos perdidos: la boleta solo hace ciertas preguntas a ciertas personas. Distinguirlos evita imputar valores sin sentido (por ejemplo, ingresos de un niño).",
  `Diagnóstico` = c("Ejemplos de reglas halladas:", "", tabla_md(ej)),
  `Decisión y justificación` = "Para cada variable se busca la condición más pequeña (edad, o una pregunta previa de la boleta) que cubra **todas** sus respuestas. Se descartan compuertas con la misma huella de NA (no son reglas, son copias) y grupos menores a 50 filas. Es una **estimación**: si un salto oculto no se detecta, el NA real queda sobrestimado.",
  Procedimiento = "Búsqueda voraz de hasta 3 compuertas por variable con `tabulate()` sobre variables discretas (≤ 25 valores) y rango de edad.",
  Resultados = img_md(fig, "Porcentaje de NA explicado por reglas de salto"),
  `Validación` = "Caso de control: `ylab` se contrasta contra la categoría ocupacional en el script 06.",
  `Puntos para exponer` = c("- Las reglas se **descubren de los datos**, no se suponen.", "- Esto cambia el objetivo: de 'eliminar NA' a 'separar NA estructurales de reales'."),
  `Archivos generados` = "- `data/metadatos/reglas_saltos.csv`\n- `data/interim/mascara_estructural.rds`\n- `data/interim/persona_05.rds`"))
guardar_interim(df, 5); cerrar_script()
