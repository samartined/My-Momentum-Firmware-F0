---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-1
angulo: ORT
ronda: 2
timestamp: 2026-05-23T18:45:00Z
---

# Voto del concejal 1 sobre síntesis — ronda 2

## Voto
SÍ-CON-CONDICIONES-NUEVAS

## Razones (máximo 3, breves)

1. **Las tres condiciones operativas de mi ronda 1 quedan incorporadas según el resumen del master.** La reformulación simultánea de ROB para excluir correctitud funcional, el campo "no aplicable cuando" en la entrada de COR, y la entrada congelada en el historial del catálogo — los tres mecanismos que pedí para que la separación ROB/COR sea operacionalmente disjunta y no solo semánticamente — están en la síntesis. La frontera deja de ser un matiz frágil y se vuelve verificable por inspección del catálogo.

2. **La pregunta clave operacional propuesta para COR ("contraejemplo concreto" vs "garantía estructural" de ROB) cierra el solape en runtime.** Mis ejemplos de ronda 1 (deserialización SubGHz, NFC, `flipper_migrate_files`) ya no son ambiguos: ROB pregunta "¿qué invariante queda verificable?" mientras COR pregunta "¿puedo construir un input que rompa este resultado?". Esto produce críticas no-redundantes, que era el test definitivo de ortogonalidad que mi razón 2 de ronda 1 demandaba.

3. **El rail de aplicabilidad disjunto restringido a operaciones bit-a-bit / byte-a-byte comparables acota correctamente el alcance de COR.** Mi riesgo de "doble asignación encubierta" queda mitigado: las decisiones puramente arquitectónicas o de lifecycle caen en ROB, y solo las transformaciones input→output con criterio de éxito en el contenido del output caen en COR. La regla 2-de-3 SÍ recupera su mecánica anti-sesgo porque los dos ángulos ya no votan sobre la misma sub-cuestión.

## Condiciones nuevas (solo si SÍ-CON-CONDICIONES-NUEVAS)

- **Condición ORT-N1 (auditoría a 3 meses con métrica explícita de disjunción).** La cláusula de retirada empírica a 3 meses (atendiendo al voto minoritario) debe incluir un criterio operacional medible *desde ortogonalidad*: revisar el log `decisions.jsonl` y contar cuántas convocatorias asignaron ROB y COR al mismo trío y cuántos veredictos resultantes fueron textualmente solapantes (>70% de razones compartidas). Si la tasa de co-asignación con solape supera el 30%, la separación se considera fallida desde ORT y se retira COR — independientemente de los criterios de utilidad funcional que justifiquen su mantenimiento desde otros ángulos. Esta condición no contradice la cláusula de retirada propuesta; la operacionaliza desde mi ángulo.

- **Condición ORT-N2 (guard de auto-veto al routing del master).** Hasta la primera auditoría a 3 meses, el master debe registrar en el dossier de cada L3 que invoque tanto ROB como COR una justificación de una línea explicando por qué la decisión requiere las dos lentes y no es expresable como una sola. Si en 3 meses no se acumula ningún dossier con justificación creíble de co-invocación, esto es evidencia adicional de no-ortogonalidad que la auditoría debe ponderar. Es trazabilidad ligera, no carga operacional pesada.
