---
id_script: "18"
nombre_archivo: "18_edu_nulos_alfabetismo.R"
bloque: "03_educacion"
fase_metodologica: "Fase 4: Tratamiento de Valores Faltantes en Escolaridad"
entrada: "03_data/02_interim/persona_17.rds"
salida: "03_data/02_interim/persona_18.rds"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 18: Tratamiento de Omisiones en Escolaridad y Bandera de Linaje

## 1. Contexto y Defecto Abordado
Tras clasificar los saltos censales de infantes en el Bloque 0, persistían exactamente 18 registros con valores nulos no informativos (`NA_Real`) en la variable continua `aestudio` pertenecientes a personas de 4 años o más.

## 2. Justificación Metodológica y Regla de Imputación Condicional
Para resolver estas omisiones sin recurrir a imputaciones arbitrarias desvinculadas de la realidad del individuo, se implementó una estrategia en dos etapas:
1. **Regla Lógica por Alfabetismo:** Si la persona declara no saber leer ni escribir (`s03a_01 == 2`) o su nivel de instrucción registrado es "Ninguno" (`niv_ed_g == 0`), se le atribuye con certeza contable $aestudio = 0$.
2. **Imputación por Mediana Etaria:** Para los casos restantes sin alfabetismo específico, se imputa la mediana de años de estudio aprobados de su cohorte generacional inmediata ($[edad - 2, edad + 2]$ años), preservando el promedio educativo de su estrato etario.
3. **Trazabilidad de Linaje:** Todo registro imputado activa obligatoriamente la bandera `aestudio_imputado = 1L`.

## 3. Algoritmo y Procedimiento en R
1. Identificación indexada de las 18 filas con `is.na(aestudio)`.
2. Activación del flag de linaje en los índices identificados: `aestudio_imputado[idx] <- 1L`.
3. Bucle condicional aplicando la regla de alfabetismo o la mediana móvil de años aprobados por edad vecina.
4. Verificación de completitud: confirmación de que la columna alcanza 0 NAs residuales.
5. Reasignación de metadatos semánticos con `Hmisc::label()`.
6. Persistencia en `persona_18.rds`.

## 4. Métricas de Impacto y Trazabilidad
* NAs en `aestudio` resueltos: 18 registros tratados y certificados.
* Estado final de completitud en `aestudio`: 100.0% (0 NAs en las 39,497 filas).
* Bandera de linaje: `aestudio_imputado` documentada con 18 casos activos.
* Checkpoint generado: `03_data/02_interim/persona_18.rds`.
* Registro en bitácora: Paso 18 registrado formalmente.