---
id_script: "22"
nombre_archivo: "22_emp_diagnostico.R"
bloque: "04_empleo"
fase_metodologica: "Fase 1: Auditoria y Perfilado Forense (Mercado Laboral)"
entrada: "03_data/02_interim/persona_21.rds"
salida: "03_data/02_interim/persona_22.rds"
evidencia_grafica: "06_images/22_emp_diagnostico.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 22: Diagnóstico del Mercado Laboral y Tasas Macroeconómicas

## 1. Contexto y Diagnóstico Forense
La Sección 4 de la boleta censal recoge la actividad económica, jornada de trabajo e ingresos laborales. Este script ejecutó un diagnóstico integral sobre los universos de empleo según las normas de la Organización Internacional del Trabajo (OIT) y el catálogo metodológico del INE 2024.

## 2. Justificación Teórica y Fórmulas Macroeconómicas
1. **Población en Edad de Trabajar (PET):** Normada en Bolivia para personas de 14 años o más ($edad \ge 14$).
2. **Población Económicamente Activa (PEA):** Compuesta por ocupados ($condact = 1$) y desocupados abiertos ($condact = 2$).
3. **Población Económicamente Inactiva (PEI):** Estudiantes, personas dedicadas a quehaceres del hogar, jubilados o rentistas ($condact = 3$).
4. **Tasas Oficiales del Mercado de Trabajo:**
   * Tasa Global de Participación (TGP):
     $$TGP = \frac{PEA}{PET} \times 100$$
   * Tasa de Desempleo Abierto (TD):
     $$TD = \frac{\text{Desocupados}}{PEA} \times 100$$
5. **Auditoría de No Respuesta:** Cuantificación de los 52 casos con `tothrs == NA` y los 2,751 trabajadores ocupados con ingresos laborales no declarados (`ylab == NA`).

## 3. Algoritmo y Procedimiento en R
1. Coerción atómica de variables laborales a tipos nativos `<integer>` y `<double>`.
2. Sincronización explícita de `pet` ($edad \ge 14$).
3. Tabulación y cálculo en consola de los agregados macroeconómicos (PET, PEA, PEI, TGP, TD).
4. Generación de la figura `22_emp_diagnostico.png` resumiendo la composición de la fuerza laboral.
5. Persistencia en `persona_22.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Población en Edad de Trabajar (PET): 29,985 personas.
* Ocupados con no respuesta en `ylab` a imputar: 2,751 individuos.
* Ocupados con horas no declaradas: 52 individuos.
* Gráfico generado: `06_images/22_emp_diagnostico.png`.
* Checkpoint generado: `03_data/02_interim/persona_22.rds`.
* Registro en bitácora: Paso 22 registrado formalmente.