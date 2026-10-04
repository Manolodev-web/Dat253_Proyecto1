---
id_script: "03"
nombre_archivo: "03_normalizacion_texto.R"
bloque: "00_global"
fase_metodologica: "Fase 2: Limpieza y Normalizacion Lexica"
entrada: "03_data/02_interim/persona_02.rds"
salida: "03_data/02_interim/persona_03.rds"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 03: Normalización Léxica y Estandarización ASCII

## 1. Contexto y Defecto Detectado
Las preguntas abiertas de la boleta censal (especificación de seguros, causas de no asistencia escolar, ocupaciones abiertas) presentaban inconsistencias de captura manual: mezclas de mayúsculas y minúsculas, espacios redundantes en los extremos y caracteres con tildes o eñes que fallan al migrar entre sistemas operativos (Linux/Windows/macOS).

## 2. Justificación Metodológica
Para garantizar un estándar de ingeniería de datos interoperable y evitar fallas en pipelines de visualización o exportación a bases de datos relacionales, todo texto abierto debe normalizarse a mayúsculas puras, sin espacios en blanco superfluos y transliterado a ASCII estándar.

## 3. Algoritmo y Procedimiento en R
1. Identificación automática de todas las columnas de texto (`character`) en el dataset (14 atributos).
2. Aplicación secuencial por columna:
   * `toupper()`: Homogeneización a mayúsculas.
   * `trimws()`: Eliminación de espacios iniciales y finales.
   * Transliteración mediante expresiones regulares: sustitución de `Á`, `É`, `Í`, `Ó`, `Ú` por `A`, `E`, `I`, `O`, `U` y `Ñ` por `N`.
3. Persistencia en `persona_03.rds`.

## 4. Métricas de Impacto
* Columnas de texto saneadas: 14 atributos abiertos.
* Registros normalizados: 39,497 observaciones.
* Registro en bitácora: Paso 03 registrado.