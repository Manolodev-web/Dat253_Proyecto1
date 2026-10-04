---
id_script: "08"
nombre_archivo: "08_viv_diagnostico.R"
bloque: "01_vivienda"
fase_metodologica: "Fase 1: Auditoria y Perfilado Forense (Vivienda)"
entrada: "03_data/02_interim/persona_07.rds"
salida: "03_data/02_interim/persona_08.rds"
evidencia_grafica: "06_images/08_viv_diagnostico_totper.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 08: Diagnóstico del Aplanamiento Estructural en Tamaño de Hogar

## 1. Contexto y Diagnóstico Forense
En las encuestas de hogares, el bienestar individual se evalúa en el marco de la economía compartida del hogar. Al auditar la variable `totper` (Total de personas en el hogar) en la base cruda `persona.csv`, se identificó una patología estructural grave: en 39,477 de las 39,497 observaciones el valor figuraba rígidamente fijado en `1.0`, y en 20 observaciones aparecía como valor faltante (`NA`).

## 2. Justificación Metodológica y Teórica
El aplanamiento de `totper` distorsiona de forma terminal cualquier estimación de bienestar económico. Si un hogar compuesto por 5 personas tiene un ingreso acumulado de 10,000 Bs y la base asigna `totper = 1`, su ingreso per cápita aparente sería de 10,000 Bs en lugar del valor real de 2,000 Bs. Esto generaría una subestimación masiva de la pobreza monetaria en Bolivia. Se requiere cuantificar la verdadera distribución del tamaño del hogar mediante agregación por la clave unívoca de vivienda `folio`.

## 3. Algoritmo y Procedimiento en R
1. Carga del estado intermedio saneado del Bloque 0 (`persona_07.rds`).
2. Agrupación por identificador de hogar (`folio`) y cálculo del conteo real de miembros empadronados:
   $$\text{miembros\_reales} = \sum_{i \in \text{folio}} 1$$
3. Comparación vectorial entre el `totper` declarado en boleta y los miembros reales por hogar.
4. Cuantificación de discrepancias en los 12,718 hogares que componen la muestra.
5. Generación de la figura `08_viv_diagnostico_totper.png` contrastando el aplanamiento artificial frente a la distribución real de miembros.
6. Guardado del checkpoint en `persona_08.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Hogares analizados: 12,718 folios unívocos.
* Hogares con `totper` colapsado o discrepante: 12,718 (discrepancia en hogares pluripersonales).
* Rango real de integrantes observado: [1 a 19 miembros por hogar].
* Gráfico generado: `06_images/08_viv_diagnostico_totper.png`.
* Registro en bitácora: Paso 08 registrado formalmente.