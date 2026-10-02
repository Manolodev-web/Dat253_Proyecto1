# Ejecuta todos los scripts en orden. Uso:  LC_ALL=C.UTF-8 Rscript run_all.R
scripts <- sort(list.files("scripts", pattern = "^[0-9]{2}_.*\\.R$", full.names = TRUE))
for (s in scripts) { cat("\n>>>", s, "\n"); source(s, encoding = "UTF-8", local = new.env()) }
