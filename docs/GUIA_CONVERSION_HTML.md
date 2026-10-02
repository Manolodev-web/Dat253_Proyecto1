# Guía para convertir los informes a HTML (para pegar a otra IA)

**Entrada:** `informes/NN_*.md`, `informes/resumenes/resumen_bloque_N.md`, `informes/indice.json` y `images/*.png`.
**Salida:** un sitio estático HTML + CSS (sin frameworks), una página por bloque y una por informe.

Reglas:
1. Cada `.md` empieza con un bloque YAML (`id`, `titulo`, `bloque`, `fase`, `filas_afectadas`, `na_antes`, `na_despues`, `imagenes`). Úsalo para el encabezado y para tarjetas de métricas (NA antes → después).
2. Todos los informes tienen las mismas 9 secciones `##`, en el mismo orden. Muéstralas como pestañas o secciones plegables; **Resumen** y **Puntos para exponer** siempre visibles.
3. Las imágenes usan ruta relativa `../images/archivo.png`. Cópialas junto al HTML y ajusta la ruta; conserva el texto alternativo.
4. Las tablas son Markdown estándar: conviértelas a `<table>` con scroll horizontal en pantallas pequeñas.
5. `indice.json` lista todos los informes: úsalo para el menú y los botones anterior/siguiente.
6. Los números usan formato español (punto de miles, coma decimal). No los reformatees.
7. No inventes datos: todo valor debe salir de los `.md`.

Navegación sugerida: Bloque 0 Global → 1 Vivienda → 2 Salud → 3 Educación → 4 Empleo e ingresos → 5 Cierre. Para la exposición, usa los `resumen_bloque_N.md`.
