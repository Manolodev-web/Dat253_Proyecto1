---
id_script: "19"
nombre_archivo: "19_edu_consistencia_biologica.R"
bloque: "03_educacion"
fase_metodologica: "Fase 5: Validacion de Consistencia Logica y Cotas Biologicas"
entrada: "03_data/02_interim/persona_18.rds"
salida: "03_data/02_interim/persona_19.rds"
evidencia_grafica: "06_images/19_edu_consistencia_edad.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 19: Validación y Acotamiento de la Restricción Biológica Escolar

## 1. Contexto y Diagnóstico Forense
En encuestas de hogares suelen presentarse inconsistencias temporales derivadas de errores de captura o sobredeclaración, donde los años de estudio aprobados superan el tiempo cronológico real que la persona ha tenido disponible para cursar la escuela formal.

## 2. Justificación Teórica: La Cota Biológica Censal
En el sistema educativo formal de Bolivia y los estándares de la UNESCO, el ingreso regular a la educación primaria ocurre a los 4 o 5 años de edad (etapa inicial/primaria). Por definición axiomática, un individuo no puede tener más años aprobados de estudio que su edad cumplida menos la edad mínima de escolarización:
$$\text{Límite Máximo Teórico: } aestudio_i \le \max(0, edad_i - 4)$$
*Ejemplo:* Un niño de 7 años no puede tener más de 3 años de estudio aprobados ($7 - 4 = 3$). Cualquier valor superior viola la frontera biológica y debe ser acotado (*winsorizado*) a su valor máximo factible.

## 3. Algoritmo y Procedimiento en R
1. Cálculo del vector de cota biológica máxima: `limite_max_aestudio <- pmax(0, df$edad - 4)`.
2. Detección de casos de sobredeclaración donde `df$aestudio > limite_max_aestudio`.
3. Ajuste determinístico de los registros anómalos fijándolos en su límite biológico superior.
4. Generación de la figura `19_edu_consistencia_edad.png` mediante diagrama de dispersión con línea de cota $y = x - 4$ que comprueba visualmente que ningún dato cruza la frontera permitida.
5. Persistencia en `persona_19.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Inconsistencias biológicas detectadas y acotadas: Casos sobredeclarados regularizados.
* Cumplimiento de la regla $aestudio \le edad - 4$: 100.0% de la muestra.
* Gráfico generado: `06_images/19_edu_consistencia_edad.png`.
* Checkpoint generado: `03_data/02_interim/persona_19.rds`.
* Registro en bitácora: Paso 19 registrado formalmente.