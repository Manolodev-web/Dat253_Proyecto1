---
id_script: "23"
nombre_archivo: "23_emp_horas_trabajadas.R"
bloque: "04_empleo"
fase_metodologica: "Fase 4: Tratamiento de Horas y Outliers Fisiologicos"
entrada: "03_data/02_interim/persona_22.rds"
salida: "03_data/02_interim/persona_23.rds"
evidencia_grafica: "06_images/23_emp_horas_trabajo.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 23: Saneamiento de Horas Trabajadas y Acotamiento Fisiológico

## 1. Contexto y Defectos Abordados
Se identificaron dos problemas en la variable `tothrs` (Total de horas trabajadas por semana en la ocupación principal y secundaria):
1. Presencia de 52 valores nulos en trabajadores ocupados.
2. Presencia de valores extremos e inverosímiles que exceden los límites fisiológicos humanos tolerables (por ejemplo, personas con 140 a 160 horas semanales).

## 2. Justificación Teórica y Límites Fisiológicos Censales
1. **Imputación Condicional:** La no respuesta en horas no debe dejarse vacía porque anula el cálculo posterior del salario por hora. Se imputa la mediana de horas observadas en trabajadores del mismo estrato geográfico (`area`) y género (`sexo`), preservando la estructura sectorial.
2. **Cota Fisiológica Tolerable:** Una semana tiene exactamente 168 horas cronológicas ($24 \times 7$). Asumiendo un mínimo biológico vital de 8 horas diarias de descanso, alimentación y traslado, el límite superior tolerable de trabajo hiperintensivo es de aproximadamente 16 horas diarias durante 7 días continuos:
   $$\text{Límite Fisiológico Máximo: } tothrs_i \le 112\text{ horas/semana}$$
   Cualquier reporte $> 112$ horas semanales se acota (*winsorización*) a 112 horas.
3. **Cero en Población No Ocupada:** Inactivos y desocupados tienen estrictamente $0$ horas semanales.

## 3. Algoritmo y Procedimiento en R
1. Activación de la bandera `tothrs_imputado = 1L` en los 52 ocupados con omisión.
2. Imputación mediante medianas condicionadas por estrato `area x sexo`.
3. Asignación de 0 horas a inactivos y desocupados.
4. Acotamiento algorítmico: `df$tothrs[df$tothrs > 112] <- 112`.
5. Generación del histograma `23_emp_horas_trabajo.png` destacando la jornada legal boliviana de 48 horas semanales.
6. Guardado en `persona_23.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Ocupados con horas imputadas: 52 registros (bandera `tothrs_imputado` activa).
* Valores extremos acotados a 112 horas: Casos inverosímiles regularizados.
* Completitud en `tothrs`: 100.0% (0 NAs).
* Gráfico generado: `06_images/23_emp_horas_trabajo.png`.
* Checkpoint generado: `03_data/02_interim/persona_23.rds`.
* Registro en bitácora: Paso 23 registrado formalmente.