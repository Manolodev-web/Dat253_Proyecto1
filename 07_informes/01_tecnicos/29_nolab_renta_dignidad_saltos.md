---
id_script: "29"
nombre_archivo: "29_nolab_renta_dignidad_saltos.R"
bloque: "05_consolidacion"
fase_metodologica: "Fase 4: Tratamiento de NAs No Laborales y Saltos Censales"
entrada: "03_data/02_interim/persona_28.rds"
salida: "03_data/02_interim/persona_29.rds"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 29: Consistencia de Saltos en Renta Dignidad y Ceros Analíticos

## 1. Contexto y Defectos Abordados
Se atendieron dos situaciones en la Sección 5:
1. Registros anómalos de cobro de pensión de vejez en personas menores a la edad legal mínima.
2. Presencia de valores `NA` no clasificados en la variable agregada de ingreso no laboral individual (`ynolab`).

## 2. Justificación Metodológica y Regla de Negocio
1. **Restricción Normativa Estricta de Renta Dignidad:** En el Estado Plurinacional de Bolivia, el derecho al cobro de la Renta Universal de Vejez se adquiere estrictamente a partir del día de cumplimiento de los **60 años de edad**. Cualquier cobro asentado en individuos de $0$ a $59$ años representa un error de digitación o asignación errónea de boleta que debe regularizarse forzosamente a $0$ Bs.
2. **Cero Analítico en No Perceptores:** Quienes no reciben pensiones, rentas de capital ni transferencias familiares no son casos de información faltante: su ingreso no laboral observable es exactamente **0 Bs**.
3. **Bandera de Linaje:** Se inicializó la bandera binaria `ynolab_imputado = 0/1` para transparentar los registros modificados.

## 3. Algoritmo y Procedimiento en R
1. Creación de la bandera `ynolab_imputado` inicializada en `0L`.
2. Anulación algorítmica de montos de Renta Dignidad en individuos con `edad < 60`.
3. Detección indexada de celdas con `is.na(ynolab)` y activación del flag: `ynolab_imputado[idx] <- 1L`.
4. Asignación determinística: `df$ynolab[idx] <- 0`.
5. Verificación de no negatividad: `df$ynolab[df$ynolab < 0] <- 0`.
6. Asignación de metadatos semánticos con `Hmisc::label()`.
7. Persistencia en `persona_29.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Registros de menores con cobro anómalo regularizados: Casos aislados corregidos a 0 Bs.
* Ceros analíticos asignados en `ynolab`: 100% de la columna libre de NAs.
* Bandera de linaje: `ynolab_imputado` creada y documentada.
* Checkpoint generado: `03_data/02_interim/persona_29.rds`.
* Registro en bitácora: Paso 29 registrado formalmente.