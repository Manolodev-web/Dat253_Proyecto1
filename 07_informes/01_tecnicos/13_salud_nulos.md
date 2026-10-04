---
id_script: "13"
nombre_archivo: "13_salud_nulos.R"
bloque: "02_salud"
fase_metodologica: "Fase 4: Tratamiento de Valores Faltantes y Banderas de Linaje"
entrada: "03_data/02_interim/persona_12.rds"
salida: "03_data/02_interim/persona_13.rds"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 13: Tratamiento de Nulos en Cobertura de Salud y Discapacidad

## 1. Contexto y Defecto Abordado
Se identificó la presencia de valores nulos no clasificados en la variable resumen `cobersalud` (afiliación a seguro de salud), así como celdas vacías en el módulo de dificultades permanentes (visión, audición, motricidad, cognición, autocuidado y comunicación: `s02a_04a` a `s02a_04f`).

## 2. Justificación Metodológica y Regla de Reconciliación Censal
1. **Reconciliación con Boleta:** La pregunta específica de seguro médico es `s02a_01a` (donde se anota el código del seguro principal: 1=SUS, 2=Caja, 3=Privado, 4=Otro, 5=Ninguno). Si `cobersalud` es `NA`, el dato puede recuperarse fidedignamente leyendo el código numérico asentado en `s02a_01a`. Si toda la boleta está vacía, corresponde atribuir lógicamente `5 = Sin seguro / Ninguno`.
2. **Bandera de Linaje:** Para cumplir el estándar de reproducibilidad y auditoría científica, todo registro modificado debe ser señalado con la bandera `cobersalud_imputado = 1L`.
3. **Módulo de Discapacidad:** Las preguntas aplican a la totalidad de la población; los NAs aislados corresponden a la categoría modal de referencia `1 = No tiene dificultad`.

## 3. Algoritmo y Procedimiento en R
1. Creación de la bandera `cobersalud_imputado` inicializada en `0L`.
2. Aplicación de `intersect()` para verificar columnas presentes sin riesgo de errores por nombres inexistentes en boleta.
3. Recuperación del código de seguro desde `s02a_01a` hacia `cobersalud` para registros en `NA` y activación del flag en `1L`.
4. Regularización de las columnas `s02a_04a` a `s02a_04f` fijando `NA -> 1L`.
5. Guardado en `persona_13.rds`.

## 4. Métricas de Impacto y Trazabilidad
* NAs en `cobersalud` resueltos: 100% de la columna clasificada.
* Bandera de linaje creada: `cobersalud_imputado` (0/1).
* Módulo de dificultades permanentes regularizado en dominio válido `1:4`.
* Checkpoint generado: `03_data/02_interim/persona_13.rds`.
* Registro en bitácora: Paso 13 registrado formalmente.