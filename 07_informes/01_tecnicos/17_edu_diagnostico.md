---
id_script: "17"
nombre_archivo: "17_edu_diagnostico.R"
bloque: "03_educacion"
fase_metodologica: "Fase 1: Auditoria y Perfilado Forense (Educacion)"
entrada: "03_data/02_interim/persona_16.rds"
salida: "03_data/02_interim/persona_17.rds"
evidencia_grafica: "06_images/17_edu_diagnostico.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 17: Diagnóstico del Módulo Educativo y Años de Estudio

## 1. Contexto y Diagnóstico Forense
La Sección 3 de la Encuesta de Hogares 2024 releva la acumulación de capital humano individual: condición de alfabetismo (`s03a_01`), asistencia escolar actual (`s03a_02`), nivel educativo máximo alcanzado (`niv_ed`, `niv_ed_g`) y los años de estudio aprobados acumulados (`aestudio`). Este script auditó la estructura poblacional de escolaridad formal y evaluó la consistencia en el grupo objetivo normativo.

## 2. Justificación Metodológica y Universos Censales
1. **Universo de Escolaridad Formal:** El INE delimita el módulo educativo a la población de 4 años o más ($edad \ge 4$). Los menores de 4 años ($N = 2,407$) ya fueron regularizados en el Script 07 con el cero analítico correspondiente ($aestudio = 0$).
2. **Evaluación de Omisiones:** En la población en edad escolar ($\ge 4$ años), se identificó un remanente de 18 casos de no respuesta genuina (`NA_Real`) en `aestudio` que requieren tratamiento algorítmico específico.
3. **Auditoría de Inconsistencias Biológicas:** Se evaluó si existían registros preliminares con años aprobados superiores a los que su edad cronológica permite acumular.

## 3. Algoritmo y Procedimiento en R
1. Coerción atómica preventiva de tipos en variables educativas (`aestudio` como `<double>`, variables de boleta como `<integer>`).
2. Cuantificación de subpoblaciones: menores de 4 años ($N = 2,407$) y población de 4 años o más ($N = 36,929$).
3. Tabulación de frecuencias cruzadas en nivel educativo agrupado (`niv_ed_g`).
4. Generación de la visualización diagnóstica `17_edu_diagnostico.png`, mostrando los diagramas de caja de años de estudio aprobados a través de cinco cohortes etarias.
5. Guardado en `persona_17.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Población evaluada en edad de instrucción ($\ge 4$ años): 36,929 individuos.
* NAs reales cuantificados en `aestudio`: 18 observaciones.
* Gráfico generado: `06_images/17_edu_diagnostico.png`.
* Checkpoint generado: `03_data/02_interim/persona_17.rds`.
* Registro en bitácora: Paso 17 registrado formalmente.