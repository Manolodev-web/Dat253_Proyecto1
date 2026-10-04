---
id_script: "12"
nombre_archivo: "12_salud_diagnostico.R"
bloque: "02_salud"
fase_metodologica: "Fase 1: Auditoria y Perfilado Forense (Salud)"
entrada: "03_data/02_interim/persona_11.rds"
salida: "03_data/02_interim/persona_12.rds"
evidencia_grafica: "06_images/12_salud_cobertura.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 12: Diagnóstico de Cobertura Médica, Gastos y Fecundidad

## 1. Contexto y Diagnóstico Forense
La Sección 2 de la boleta de la Encuesta de Hogares 2024 releva las dimensiones de acceso a salud, seguro médico, gastos de bolsillo, discapacidades permanentes y fecundidad. Este script ejecutó un perfilado forense sobre:
1. Valores faltantes en el tipo de seguro de salud (`cobersalud`).
2. Comportamiento distribucional de los gastos de bolsillo en consulta, medicinas e internación.
3. Cumplimiento de universos biológicos censales en las preguntas de salud sexual y reproductiva.

## 2. Justificación Metodológica y Normativa
En Bolivia coexisten el Sistema Único de Salud (SUS, Ley 1152), los Entes Gestores de la Seguridad Social a Corto Plazo (Cajas de Salud) y los seguros privados. Las preguntas de fecundidad (embarazo, partos, controles prenatales) tienen un universo poblacional normativo internacional y nacional estricto: mujeres en edad fértil (13 a 50 años). Cualquier respuesta fuera de este dominio es un artefacto de captura que debe ser cuantificado.

## 3. Algoritmo y Procedimiento en R
1. Coerción atómica preventiva de las variables de salud para evitar discrepancias de atributos.
2. Tabulación cruzada de `cobersalud` e identificación de NAs.
3. Perfilado de las 5 variables de gastos de bolsillo (`s02a_03a` a `s02a_03e`).
4. Identificación del universo fértil ($N = 10,741$ mujeres de 13 a 50 años) y cuantificación de respuestas anómalas registradas en hombres o personas fuera de rango.
5. Construcción de la figura `12_salud_cobertura.png` reflejando la distribución de seguros de salud.
6. Guardado en `persona_12.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Universo evaluado: 39,497 personas.
* Mujeres en edad fértil catalogadas: 10,741 individuos.
* NAs detectados en cobertura de salud: Cuantificados para tratamiento en el paso 13.
* Gráfico generado: `06_images/12_salud_cobertura.png`.
* Registro en bitácora: Paso 12 registrado formalmente.