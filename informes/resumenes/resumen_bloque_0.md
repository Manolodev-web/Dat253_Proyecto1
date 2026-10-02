---
bloque: "Bloque 0 · Global"
scripts: "00-07"
na_antes: 6261409
na_despues: 93737
---
# Bloque 0 · Global — Resumen para exponer

## Cinco puntos clave
1. **Auditoría:** 39.497 filas × 275 columnas; **57,6% de las celdas vacías** (6.261.409). No hay duplicados, y los 12.718 hogares tienen un único jefe/a.
2. **El diccionario estaba desalineado:** `s01a_02` es sexo, `s01a_03` es edad y `s01a_05` es parentesco; `totper` es constante y `condact`/`tipohogar` tienen más códigos de los documentados. Se creó `diccionario_corregido.csv`.
3. **Casi todos los NA son estructurales:** tras deducir las reglas de salto de la boleta, **98,5% (6.167.672)** corresponde a preguntas que no aplicaban; quedan **93.737 NA reales**.
4. **Corrección importante:** de los 2.770 ocupados sin `ylab`, ~2.600 son trabajadores sin remuneración (estructural); solo **148** son faltantes reales a imputar.
5. **Alerta honesta:** 43 variables (81.372 de los NA reales) quedan marcadas "revisar" por posible salto no detectado; 6 concentran casi todo: `s02a_05`, `s01a_07_2`, `s03c_17ab`, `s01a_06`, `s02b_10`, `quienatenparto`. Los NA realmente imputables son unos 12 mil.

## Imágenes sugeridas
`images/01_edad_vs_nacimiento.png` · `images/06_na_estructural_vs_real.png` · `images/07_na_antes_despues.png`

## Tabla antes/después
| NA | Antes | Después |
|---|---|---|
| Celdas vacías | 6.261.409 | 93.737 |
