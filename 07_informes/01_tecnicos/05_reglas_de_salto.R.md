---
id_script: "05"
nombre_archivo: "05_reglas_de_salto.R"
bloque: "00_global"
fase_metodologica: "Fase 4: Formalizacion de Metadatos de Saltos (Skip Patterns)"
entrada: "03_data/02_interim/persona_04.rds"
salida: "03_data/02_interim/persona_05.rds, 03_data/04_metadatos/reglas_saltos.csv"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 05: Formalización de Reglas de Salto Censal

## 1. Contexto y Marco Normativo
En la Encuesta de Hogares del INE, el cuestionario está estructurado mediante compuertas lógicas de exclusión biológica y normativa. Por diseño metodológico, grandes secciones de la encuesta no deben ser respondidas por la totalidad de los empadronados.

## 2. Justificación Metodológica
Para evitar el grave sesgo de imputar valores artificiales a individuos a quienes nunca se les debió formular la pregunta, es obligatorio modelar contractualmente los universos poblacionales de cada módulo y exportar un catálogo normativo auditable.

## 3. Algoritmo y Procedimiento en R
1. Cálculo dinámico de los 9 universos censales sobre los 39,497 registros:
   * Universo Fecundidad: Mujeres de 13 a 50 años ($N = 10,741$).
   * Universo Infancia: Niños de 0 a 5 años ($N = 3,674$).
   * Universo Educación: Población de 4 años o más ($N = 36,929$).
   * Universo TICs: Población de 5 años o más ($N = 36,252$).
   * Universo Mercado de Trabajo (PET): Personas de 14 años o más ($N = 29,985$).
   * Universo Ocupados: Ocupados con horas o ingresos ($condact = 1$).
   * Universo Adultos Mayores: Personas de 60 años o más ($N = 4,821$).
2. Construcción y exportación de `03_data/04_metadatos/reglas_saltos.csv` detallando regla, población objetivo, fórmula en R e inaplicables esperados.
3. Persistencia en `persona_05.rds`.

## 4. Métricas de Impacto
* Reglas formales catalogadas: 9 compuertas censales maestras.
* Archivo generado: `03_data/04_metadatos/reglas_saltos.csv`.
* Registro en bitácora: Paso 05 registrado.