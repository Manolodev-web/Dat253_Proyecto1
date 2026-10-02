# 01 · Reconciliar diccionario vs datos (Fase 1)
source("R/funciones.R"); iniciar_script("01_diccionario_corregido")
df <- leer_interim(0); na0 <- na_total(df)
vals <- function(x) paste(sort(unique(x[!is.na(x)])), collapse = ",")
dif <- df$s01a_03 - (ANIO_ENCUESTA - df$s01a_04c); pct_coh <- round(100 * mean(dif %in% c(0, -1)), 2)
pct_na_ec <- round(100 * mean(is.na(df$s01a_06[df$s01a_03 >= 12])), 1)
corr <- tribble(~variable, ~descripcion_diccionario, ~descripcion_real, ~evidencia, ~estado,
  "s01a_02", "Parentesco con jefe/a", "Sexo", paste0("Valores observados: ", vals(df$s01a_02), " (2 categorías)"), "corregida",
  "s01a_03", "Sexo", "Edad en años", sprintf("Rango %d-%d; coincide con 2024 - año de nacimiento (±1) en %.2f%% de filas", min(df$s01a_03), max(df$s01a_03), pct_coh), "corregida",
  "s01a_05", "Edad calculada", "Parentesco con jefe/a del hogar", paste0("Valores observados: ", vals(df$s01a_05)), "corregida",
  "totper", "Total de personas del hogar", "Columna constante (=1); inutilizable", paste0("Valores: ", vals(df$totper), "; NA: ", sum(is.na(df$totper))), "inconsistente",
  "condact", "1=Ocupado, 2=Desocupado, 3=Inactivo", "Códigos 1-5 (significado de 4 y 5 por confirmar)", paste0("Valores observados: ", vals(df$condact)), "inconsistente",
  "tipohogar", "4 categorías", "Más categorías que el diccionario", paste0("Valores observados: ", vals(df$tipohogar)), "inconsistente",
  "s01a_06", "Estado civil", "Por verificar (muchos NA entre mayores de 12)", sprintf("%.1f%% NA entre personas de 12+ años; códigos hasta %d", pct_na_ec, max(df$s01a_06, na.rm = TRUE)), "por_verificar",
  "s01a_05a", "Edad (meses)", "Por verificar", paste0("Valores observados: ", vals(df$s01a_05a)), "por_verificar")
write_csv(corr, file.path(DIR$meta, "diccionario_corregido.csv"))
df <- df %>% mutate(sexo = s01a_02, edad = s01a_03, parentesco = s01a_05)
fig <- guardar_figura(ggplot(tibble(a = ANIO_ENCUESTA - df$s01a_04c, b = df$s01a_03), aes(a, b)) + geom_count(alpha = 0.4, colour = "#2b6cb0") +
  theme_minimal(base_size = 13) + labs(title = "s01a_03 es la edad: coincide con 2024 − año de nacimiento", x = "2024 − año de nacimiento (s01a_04c)", y = "s01a_03", size = "n"), "edad_vs_nacimiento")
log_bitacora("s01a_02, s01a_03, s01a_05", "Inconsistencia con diccionario", "Fase 1", "Se documenta la descripción real y se crean alias sexo, edad, parentesco",
  sprintf("s01a_03 coincide con 2024−año de nacimiento en %.2f%% de filas; s01a_02 solo tiene códigos 1-2", pct_coh), nrow(df), "275 → 278 columnas",
  "df <- df %>% mutate(sexo = s01a_02, edad = s01a_03, parentesco = s01a_05)")
log_bitacora("totper, condact, tipohogar", "Inconsistencia con diccionario", "Fase 1", "Se marcan como inconsistentes en diccionario_corregido.csv",
  "Códigos observados distintos a los documentados", 0, "Sin cambio de datos", "corr <- tribble(...)")
escribir_informe("Reconciliación del diccionario con los datos", "Bloque 0 · Global", "Fase 1 · Perfilado", c("s01a_02","s01a_03","s01a_05","totper","condact","tipohogar","s01a_06"), 0, na0, na0, fig, list(
  Resumen = "El diccionario entregado **no coincide** con varias columnas. Se verificó con los datos y se creó `diccionario_corregido.csv`; además se añadieron los alias `sexo`, `edad` y `parentesco`.",
  Contexto = "Un diccionario desalineado lleva a limpiar mal (por ejemplo, tratar la edad como sexo). Por eso este es el primer paso.",
  `Diagnóstico` = tabla_md(corr),
  `Decisión y justificación` = "Se conservan las columnas originales y se agregan alias con el significado verificado. Las dudas (`s01a_06`, `s01a_05a`) quedan 'por verificar' contra la boleta oficial.",
  Procedimiento = "Se contrastó cada variable con sus valores observados y con la fecha de nacimiento (`2024 − s01a_04c`).",
  Resultados = img_md(fig, "Edad reportada frente a 2024 menos año de nacimiento"),
  `Validación` = sprintf("La edad calculada coincide con `s01a_03` (±1) en el %.2f%% de las filas.", pct_coh),
  `Puntos para exponer` = c("- El diccionario tenía tres variables demográficas desplazadas.", "- Se documentó cada corrección con evidencia reproducible."),
  `Archivos generados` = "- `data/metadatos/diccionario_corregido.csv`\n- `data/interim/persona_01.rds`"))
guardar_interim(df, 1); cerrar_script()
