---
id_script: "07"
nombre_archivo: "07_recodificar_NA_estructurales.R"
bloque: "00_global"
fase_metodologica: "Fase 4: Tratamiento de NAs Estructurales y Banderas de Linaje"
entrada: "03_data/02_interim/persona_06.rds"
salida: "03_data/02_interim/persona_07.rds"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 07: Ceros Analíticos y Banderas de Linaje

## 1. Contexto y Marco Teórico
Para personas que no trabajan (estudiantes de 15 años, jubilados, amas de casa) o niños de 2 años, sus ingresos laborales y años de escolaridad formal no son incógnitas estocásticas: son ceros biológicos y económicos exactos.

## 2. Justificación Metodológica
* Niños menores de 4 años poseen exactamente $0$ años de estudio aprobados.
* Personas no ocupadas ($condact \neq 1$) o menores de 14 años generan exactamente $0$ Bs de ingreso laboral y trabajan $0$ horas semanales.
* Inicialización obligatoria de banderas binarias de linaje (`*_imputado = 0`) para garantizar la trazabilidad cuando se apliquen imputaciones algorítmicas posteriores.

## 3. Algoritmo y Procedimiento en R
1. Creación de variables indicadoras: `aestudio_imputado = 0L`, `tothrs_imputado = 0L`, `ylab_imputado = 0L`.
2. Coerción atómica a decimales para evitar conflictos con clases `<labelled>`.
3. Asignación de ceros analíticos en celdas clasificadas como `NA_Estructural`:
   * 2,407 ceros asignados en `aestudio` a menores de 4 años (quedando solo 18 NAs reales).
   * 24,890 ceros asignados en `tothrs` a no ocupados (quedando solo 52 NAs reales).
   * 22,213 ceros asignados en `ylab` a no ocupados (quedando 2,751 NAs reales en ocupados listos para MICE).
4. Persistencia en `persona_07.rds`.

## 4. Métricas de Impacto
* Cierre formal del Bloque 0: Base saneada al 100% en su estructura básica.
* Dimensiones resultantes: 39,497 filas x 285 columnas (+3 flags de linaje).
* Checkpoint maestro: `03_data/02_interim/persona_07.rds`.
* Registro en bitácora: Paso 07 registrado.