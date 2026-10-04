---
id_script: "14"
nombre_archivo: "14_salud_saltos_fecundidad.R"
bloque: "02_salud"
fase_metodologica: "Fase 5: Validacion de Consistencia Logica y Filtros Biologicos"
entrada: "03_data/02_interim/persona_13.rds"
salida: "03_data/02_interim/persona_14.rds"
fecha_certificacion: "2026-10-03"
estado: "CERTIFICADO_SIN_DEFECTOS"
---

# Informe Técnico 14: Consistencia Biológica y Saltos de Fecundidad e Infancia

## 1. Contexto y Defecto Abordado
En procesos de captura censal suelen registrarse errores de digitación donde preguntas exclusivas de salud materna o desarrollo de la primera infancia contienen respuestas en personas fuera del grupo objetivo (por ejemplo, respuestas de embarazo registradas en varones o en personas mayores de 60 años).

## 2. Justificación Metodológica y Universos Censales
1. **Universo de Fecundidad (Sección 2 Parte B):** Restringido biológica y normativamente por el INE a mujeres de 13 a 50 años cumplidos:
   $$U_{\text{Fecundidad}} = \{i \mid sexo_i = 2 \land 13 \le edad_i \le 50\}$$
2. **Universo de Primera Infancia (Sección 2 Parte C):** Preguntas de desarrollo infantil temprano y estimulación limitadas a niños de 0 a 5 años:
   $$U_{\text{Infancia}} = \{i \mid 0 \le edad_i \le 5\}$$
Cualquier registro observado fuera de estos conjuntos representa una respuesta espuria que debe anularse a `NA_real_` o cero estructural según corresponda.

## 3. Algoritmo y Procedimiento en R
1. Identificación algorítmica de todas las columnas correspondientes a fecundidad (`s02b_*`, `hnv_ult_a`, `quienatenparto`) e infancia (`s02c_*`).
2. Construcción de máscaras booleanas para identificar violaciones al universo objetivo.
3. Anulación sistemática de respuestas espurias registradas fuera de los límites de edad o sexo.
4. Persistencia del dataset saneado en `persona_14.rds`.

## 4. Métricas de Impacto y Trazabilidad
* Columnas de fecundidad e infancia auditadas: Todas las variables de las Secciones 2B y 2C.
* Anomalías biológicas eliminadas: Respuestas fuera de rango depuradas al 100%.
* Checkpoint generado: `03_data/02_interim/persona_14.rds`.
* Registro en bitácora: Paso 14 registrado formalmente.