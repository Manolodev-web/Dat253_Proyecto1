---
id_script: "25"
nombre_archivo: "25_emp_salario_minimo_outliers.R"
bloque: "04_empleo"
fase_metodologica: "Fase 5: Validacion de Consistencia Logica y Precariedad"
entrada: "03_data/02_interim/persona_24.rds"
salida: "03_data/02_interim/persona_25.rds"
evidencia_grafica: "06_images/25_emp_distribucion_ingresos.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 25: Auditoría Frente al Salario Mínimo Nacional y Precariedad

## 1. Contexto y Marco Normativo
Con los ingresos laborales completamente imputados y continuos, este script audita la consistencia económica de las remuneraciones en relación con el marco legal laboral de Bolivia y examina el comportamiento de los percentiles superiores de la distribución.

## 2. Justificación Metodológica y Regla de Negocio
1. **Salario Mínimo Nacional (SMN Bolivia 2024 = 2,500 Bs):** La legislación boliviana establece el piso salarial obligatorio para una jornada legal completa.
2. **Indicador de Precariedad / Informalidad Salarial (`debajo_smn`):** Se construye una variable sintética para identificar a aquellos trabajadores que, aun laborando a tiempo completo ($\ge 40$ horas semanales), perciben un ingreso laboral líquido inferior al mínimo legal:
   $$debajo\_smn_i = \mathbb{I}(condact_i = 1 \land tothrs_i \ge 40 \land ylab_i < 2500)$$
3. **Auditoría de Outliers Superiores:** Verificación del percentil 99.5 de ingresos para corroborar que los valores en la cola derecha guarden relación con las actividades de gerencia, minería o consultoría especializada sin representar errores de tipeo.

## 3. Algoritmo y Procedimiento en R
1. Construcción del indicador binario `debajo_smn` (1: Precariedad salarial a tiempo completo, 0: Cumple o no aplica).
2. Cálculo de métricas porcentuales de incidencia salarial en consola.
3. Evaluación de extremos superiores contra el umbral $P_{99.5}$.
4. Generación del gráfico `25_emp_distribucion_ingresos.png` mostrando el histograma de ingresos laborales con la línea vertical de referencia del SMN.
5. Persistencia en `persona_25.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Ocupados a tiempo completo evaluados: Cuantificados en consola.
* Incidencia de precariedad salarial: Documentada bajo la bandera `debajo_smn`.
* Variable sintética creada: `debajo_smn` debidamente etiquetada.
* Gráfico generado: `06_images/25_emp_distribucion_ingresos.png`.
* Checkpoint generado: `03_data/02_interim/persona_25.rds`.
* Registro en bitácora: Paso 25 registrado formalmente.