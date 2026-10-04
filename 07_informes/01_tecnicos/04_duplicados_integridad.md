---
id_script: "04"
nombre_archivo: "04_duplicados_integridad.R"
bloque: "00_global"
fase_metodologica: "Fase 3: Auditoria de Integridad y Unicidad Relacional"
entrada: "03_data/02_interim/persona_03.rds"
salida: "03_data/02_interim/persona_04.rds"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 04: Integridad Relacional y Jefatura Única de Hogar

## 1. Contexto y Diagnóstico Forense
Un dataset de microdatos jerárquicos de hogares debe cumplir dos axiomas relacionales indispensables:
1. No deben existir duplicados globales ni duplicados en la clave primaria compuesta `(folio, nro)`.
2. Todo hogar unívoco (`folio`) debe poseer exactamente un único jefe o jefa de hogar (`parentesco == 1`).

## 2. Justificación Metodológica
Si un hogar carece de jefe o tiene más de un jefe, colapsan los modelos de jefatura de hogar, economía del cuidado y tipología familiar de CEPAL. Asimismo, cualquier duplicado de clave primaria generaría uniones espurias (*cartesian joins*) en cruces posteriores.

## 3. Algoritmo y Procedimiento en R
1. Verificación de duplicados completos mediante `anyDuplicated(df)`.
2. Verificación de clave primaria `anyDuplicated(df[, c("folio", "nro")])`.
3. Agrupación por `folio` y conteo de jefes de hogar (`sum(parentesco == 1)`).
4. Ejecución de aserciones duras `stopifnot()`:
   * Total de duplicados = 0.
   * Total de hogares con anomalías en jefatura = 0 (12,718 hogares validados al 100%).
5. Guardado en `persona_04.rds`.

## 4. Métricas de Impacto
* Total hogares evaluados: 12,718 folios.
* Duplicados detectados: 0 registros.
* Hogares con unívoca jefatura: 12,718 (100.0%).
* Registro en bitácora: Paso 04 registrado.