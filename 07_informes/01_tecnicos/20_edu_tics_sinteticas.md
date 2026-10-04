---
id_script: "20"
nombre_archivo: "20_edu_tics_sinteticas.R"
bloque: "03_educacion"
fase_metodologica: "Fase 5: Ingenieria de Variables Sinteticas y Modulo TICs"
entrada: "03_data/02_interim/persona_19.rds"
salida: "03_data/02_interim/persona_20.rds"
evidencia_grafica: "06_images/20_edu_tics.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 20: Módulo de Tecnologías TIC e Indicador de Clima Educativo

## 1. Contexto y Objetivos Analíticos
Este script atiende dos necesidades estructurales:
1. Saneamiento del módulo de Tecnologías de la Información y Comunicación (TICs - Sección 3C), restringido por el INE a personas de 5 años o más.
2. Construcción de variables sintéticas estandarizadas para el análisis econométrico y sociodemográfico: `uso_internet` y el `clima_educativo_hogar`.

## 2. Justificación Teórica y Estándares Internacionales (CEPAL)
1. **Brecha Digital (`uso_internet`):** Indicador binario (1: Utilizó internet en los últimos 3 meses, 0: No utilizó o inaplicable). Permite cuantificar la exclusión tecnológica en estratos vulnerables.
2. **Clima Educativo del Hogar (Estándar CEPAL / PNUD):** El capital cultural y educativo de una familia no se mide únicamente por la escolaridad individual, sino por el entorno formativo que rodea a sus integrantes. Se calcula como el promedio de años de estudio aprobados de los miembros adultos ($\ge 18$ años) del hogar:
   $$\text{clima\_educativo\_hogar}_h = \frac{1}{\vert{}A_h\vert{}} \sum_{j \in A_h} aestudio_j, \quad A_h = \{j \in h \mid edad_j \ge 18\}$$

## 3. Algoritmo y Procedimiento en R
1. Detección dinámica de variables TIC mediante expresiones regulares (`^s03c_`) y construcción de `uso_internet`.
2. Agrupación por identificador de vivienda `folio`, filtrado de adultos ($\ge 18$ años) y cálculo de la media de `aestudio`.
3. Unión relacional (`left_join`) de la métrica de hogar al dataset maestro.
4. Generación de la figura `20_edu_tics.png` mostrando la penetración del uso de internet por cohortes de edad.
5. Guardado en `persona_20.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Variables sintéticas agregadas: `uso_internet` y `clima_educativo_hogar`.
* Clima educativo promedio nacional: 9.87 años de estudio en adultos por hogar.
* Gráfico generado: `06_images/20_edu_tics.png`.
* Checkpoint generado: `03_data/02_interim/persona_20.rds`.
* Registro en bitácora: Paso 20 registrado formalmente.