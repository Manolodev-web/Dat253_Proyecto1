---
id_script: "09"
nombre_archivo: "09_viv_totper_tipohogar.R"
bloque: "01_vivienda"
fase_metodologica: "Fase 2: Normalizacion y Reconstruccion Estructural"
entrada: "03_data/02_interim/persona_08.rds"
salida: "03_data/02_interim/persona_09.rds"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 09: Reconstrucción de `totper` y Consistencia de Tipología de Hogar

## 1. Contexto y Defecto Abordado
Tras evidenciarse en el paso 08 el aplanamiento masivo de `totper` en la base original, este script ejecuta la reconstrucción algorítmica definitiva del tamaño del hogar y audita la coherencia lógica con la variable `tipohogar` (tipología familiar del INE: unipersonal, nuclear, extendido, compuesto).

## 2. Justificación Metodológica y Regla de Negocio
1. **Regla de Conteo Fidedigno:** El número oficial de miembros de un hogar censal es igual a la cantidad exacta de cuestionarios individuales consolidados bajo el mismo `folio`.
2. **Axioma de Hogar Unipersonal:** Todo hogar clasificado tipológicamente como unipersonal (`tipohogar == 1`) debe poseer de forma obligatoria y estricta exactamente un miembro (`totper == 1`).

## 3. Algoritmo y Procedimiento en R
1. Carga de `persona_08.rds`.
2. Extracción de conteos de frecuencia por `folio` y generación del vector `totper_recalculado`.
3. Reemplazo del atributo defectuoso en el dataset principal mediante una unión izquierda (`left_join`) por `folio`.
4. Tipificación forzada a entero atómico (`as.integer(totper)`).
5. Comprobación cruzada contra `tipohogar`: evaluación de discrepancias en hogares unipersonales.
6. Asignación de metadatos mediante `Hmisc::label()` en formato ASCII limpio.
7. Guardado en `persona_09.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Registros con `totper` corregido: 39,497 filas (reconstrucción universal).
* Nuevo promedio poblacional de miembros por hogar: 3.11 personas.
* Inconsistencias en hogares unipersonales: 0 violaciones detectadas.
* Checkpoint generado: `03_data/02_interim/persona_09.rds`.
* Registro en bitácora: Paso 09 registrado formalmente.