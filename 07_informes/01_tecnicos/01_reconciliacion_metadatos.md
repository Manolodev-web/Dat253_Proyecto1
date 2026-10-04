---
id_script: "01"
nombre_archivo: "01_reconciliacion_metadatos.R"
bloque: "00_global"
fase_metodologica: "Fase 2: Normalizacion y Reconciliacion de Metadatos"
entrada: "03_data/02_interim/persona_00.rds"
salida: "03_data/02_interim/persona_01.rds, 03_data/04_metadatos/diccionario_corregido.csv"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 01: Reconciliación de Metadatos Sociodemográficos

## 1. Contexto y Defecto Detectado
En los esquemas analíticos de encuestas de hogares, los atributos de `sexo`, `edad` y `parentesco` son pilares universales. Sin embargo, en el archivo `persona.csv` del INE 2024, estas variables no existían con sus nombres estándar, sino bajo códigos de boleta DDI: `s01a_02` (sexo), `s01a_03` (edad) y `s01a_05` (parentesco con el jefe de hogar).

## 2. Justificación Metodológica
Para garantizar un código reproducible y legible sin desfasar la trazabilidad censal, se estableció la reconciliación semántica documentada contra el catálogo oficial del INE (`diccionario_completo.pdf`), creando columnas explícitas conservando a la vez los códigos originales de boleta.

## 3. Algoritmo y Procedimiento en R
1. Carga de `persona_00.rds`.
2. Verificación de existencia de las columnas fuente `s01a_02`, `s01a_03`, `s01a_05`.
3. Derivación explícita mediante `mutate()`:
   * `sexo = as.integer(s01a_02)` (1: Hombre, 2: Mujer)
   * `edad = as.integer(s01a_03)` (0 a 98 años)
   * `parentesco = as.integer(s01a_05)` (1: Jefe/a, 2: Cónyuge, 3: Hijo/a, etc.)
4. Generación tabular de `03_data/04_metadatos/diccionario_corregido.csv` documentando las 278 columnas resultantes.
5. Persistencia del estado intermedio en `persona_01.rds`.

## 4. Métricas de Impacto
* Dimensiones previas: 39,497 filas x 275 columnas.
* Dimensiones posteriores: 39,497 filas x 278 columnas (+3 variables sociodemográficas explícitas).
* Registro en bitácora: Paso 01 registrado formalmente.