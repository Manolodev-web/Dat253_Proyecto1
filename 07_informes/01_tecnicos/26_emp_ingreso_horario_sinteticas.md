---
id_script: "26"
nombre_archivo: "26_emp_ingreso_horario_sinteticas.R"
bloque: "04_empleo"
fase_metodologica: "Fase 5: Ingenieria de Variables y Calidad del Empleo"
entrada: "03_data/02_interim/persona_25.rds"
salida: "03_data/02_interim/persona_26.rds"
evidencia_grafica: "06_images/26_emp_ingreso_horario.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 26: Estimación del Ingreso Horario e Indicadores de Subempleo

## 1. Contexto y Objetivos Analíticos
El ingreso mensual bruto no permite comparar de forma homogénea la productividad laboral entre trabajadores con distintas cargas horarias (por ejemplo, quien gana 3,000 Bs trabajando 20 horas frente a quien gana lo mismo trabajando 60 horas). Este script estandariza la remuneración en términos de tarifa por hora y crea métricas de subempleo y sobreempleo.

## 2. Justificación Teórica y Estándares OIT
1. **Ingreso Laboral por Hora (`ingreso_horario`):** Considerando un mes promedio de 4.33 semanas ($52 / 12$):
   $$ingreso\_horario_i = \frac{ylab_i}{tothrs_i \times 4.33}$$
2. **Subempleo Horario (`subempleo_horario`):** Trabajadores ocupados con jornadas inferiores a la semana estándar ($tothrs < 40$ horas semanales).
3. **Sobreempleo Horario (`sobreempleo_horario`):** Trabajadores con jornadas extenuantes que superan el límite de la Ley General del Trabajo de Bolivia ($tothrs > 48$ horas semanales).
4. **Retornos a la Educación (Mincer, 1974):** La teoría del capital humano postula que el ingreso por hora debe ser monótonamente creciente según los años de instrucción formal.

## 3. Algoritmo y Procedimiento en R
1. Cálculo vectorizado de `horas_mensuales <- df$tothrs * 4.33`.
2. Estimación de `ingreso_horario` para ocupados con horas e ingresos positivos (fijando 0 en los demás).
3. Construcción de banderas categóricas `subempleo_horario` y `sobreempleo_horario`.
4. Generación de la figura `26_emp_ingreso_horario.png` mostrando el ingreso horario por nivel de instrucción alcanzado desagregado por sexo.
5. Guardado en `persona_26.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Variables sintéticas incorporadas: `ingreso_horario`, `subempleo_horario`, `sobreempleo_horario`.
* Ingreso horario mediano nacional en ocupados: Documentado en consola.
* Brecha de género y retornos al capital humano: Validados empíricamente en visualización.
* Gráfico generado: `06_images/26_emp_ingreso_horario.png`.
* Checkpoint generado: `03_data/02_interim/persona_26.rds`.
* Registro en bitácora: Paso 26 registrado formalmente.