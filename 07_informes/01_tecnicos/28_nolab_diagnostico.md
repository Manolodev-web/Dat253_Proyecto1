---
id_script: "28"
nombre_archivo: "28_nolab_diagnostico.R"
bloque: "05_consolidacion"
fase_metodologica: "Fase 1: Auditoria y Perfilado Forense (Ingresos No Laborales)"
entrada: "03_data/02_interim/persona_27.rds"
salida: "03_data/02_interim/persona_28.rds"
evidencia_grafica: "06_images/28_nolab_diagnostico.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 28: Diagnóstico de Ingresos No Laborales y Renta Dignidad

## 1. Contexto y Diagnóstico Forense
La Sección 5 de la Encuesta de Hogares 2024 investiga las fuentes de ingreso no originadas en el mercado laboral activo: transferencias corrientes del Estado (bonos y pensiones no contributivas), transferencias privadas (remesas internas y del exterior), rentas de la propiedad (alquileres, intereses) y pensiones contributivas por jubilación o invalidez. Este script auditó la magnitud de la no respuesta en `ynolab` y la focalización de la pensión no contributiva de vejez.

## 2. Justificación Teórica y Marco Previsional de Bolivia
1. **Piso de Protección Social (Renta Dignidad - Ley 3791):** Constituye el esquema previsional no contributivo universal de Bolivia para asegurar un ingreso vital mínimo a todas las personas de 60 años o más.
2. **Evaluación de Saltos Censales:** Se verificó si existían registros de cobro de Renta Dignidad asentados por error de captura en personas menores de 60 años ($edad < 60$).
3. **Distribución Etaria de `ynolab`:** En economías en desarrollo, el ingreso no laboral exhibe una concentración asimétrica en adultos mayores (vía jubilaciones y Renta Dignidad) y en hogares receptores de remesas.

## 3. Algoritmo y Procedimiento en R
1. Coerción atómica preventiva de `ynolab` a `<double>` y `edad` a `<integer>`.
2. Cuantificación de perceptores con `ynolab > 0` frente a no perceptores y celdas en `NA`.
3. Detección dinámica de la variable de cobro de Renta Dignidad (`s05a_01e` / `s05a_01e0`) mediante `intersect()`.
4. Evaluación del universo de 4,821 adultos mayores ($\ge 60$ años) y cálculo de su tasa de cobertura previsional efectiva.
5. Generación de la figura `28_nolab_diagnostico.png` mostrando la distribución de ingresos no laborales positivos en tres tramos etarios (menores, adultos y adultos mayores).
6. Guardado del checkpoint en `persona_28.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Total de adultos mayores ($\ge 60$ años) analizados: 4,821 personas.
* Tasa de percepción de Renta Dignidad en adultos mayores: Documentada en consola.
* Gráfico generado: `06_images/28_nolab_diagnostico.png`.
* Checkpoint generado: `03_data/02_interim/persona_28.rds`.
* Registro en bitácora: Paso 28 registrado formalmente.