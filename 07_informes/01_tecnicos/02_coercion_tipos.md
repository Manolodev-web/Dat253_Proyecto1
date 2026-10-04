---
id_script: "02"
nombre_archivo: "02_coercion_tipos.R"
bloque: "00_global"
fase_metodologica: "Fase 2: Estandarizacion Estructural y Coercion de Tipos"
entrada: "03_data/02_interim/persona_01.rds"
salida: "03_data/02_interim/persona_02.rds"
evidencia_grafica: "06_images/02_tipos_datos.png"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 02: Coerción Estricta de Tipos Primitivos

## 1. Contexto y Defecto Detectado
R detecta por defecto columnas de códigos e identificadores censales (`folio`, `upm`, `estrato`) como números enteros o decimales. Si se mantienen como numéricos, los entornos estadísticos permiten operaciones matemáticas aberrantes (como promediar folios) y corren el riesgo de perder ceros a la izquierda o generar imprecisiones de coma flotante.

## 2. Justificación Metodológica
Los identificadores espaciales y claves jerárquicas son variables cualitativas nominales que deben residir en memoria como vectores de caracteres (`character`). Asimismo, las variables binarias y de boleta deben tiparse como enteros (`integer`) y las variables monetarias o temporales como decimales de doble precisión (`double`).

## 3. Algoritmo y Procedimiento en R
1. Coerción de llaves primarias y códigos geográficos a tipo carácter:
   * `folio`, `upm`, `estrato`, `zona`.
2. Asignación de etiquetas descriptivas semánticas mediante `Hmisc::label()` bajo formato ASCII plano.
3. Auditoría de varianza cero para detectar atributos constantes no informativos.
4. Generación del gráfico `02_tipos_datos.png` resumiendo la composición final de tipos.
5. Guardado en `persona_02.rds`.

## 4. Métricas de Impacto
* Filas afectadas: 39,497 registros.
* Claves forzadas a carácter: 4 variables esenciales.
* Gráfico generado: `06_images/02_tipos_datos.png`.
* Registro en bitácora: Paso 02 registrado.