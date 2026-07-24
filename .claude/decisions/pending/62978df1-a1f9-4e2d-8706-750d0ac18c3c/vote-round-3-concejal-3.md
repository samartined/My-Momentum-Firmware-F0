---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-3
angulo: MNT
ronda: 3
timestamp: 2026-05-23T19:35:00Z
---

# Validación cruzada del concejal 3 — ronda 3

## Evaluación de condiciones de los otros concejales

### Condición C1-N1 (auditoría a 3m con métrica de disjunción: co-asignación ROB+COR con >70% razones solapantes; si >30% de casos → retirar)
- Decisión: accepted-with-note
- Razón: Aditivamente útil desde MNT (instrumenta la cláusula de retirada con criterio objetivo), pero el predicado "razones textualmente solapantes >70%" requiere comparación semántica entre veredictos en prosa y, sin herramienta automatizada, el architect a 3 meses recaerá en juicio subjetivo — la nota es que la implementación del comparador debe quedar especificada (diff de tokens, embedding, o checklist de subtemas) en la misma entrada de historial, no diferida.

### Condición C1-N2 (guard de auto-veto: justificación de una línea en dossier cuando master co-invoca ROB+COR, hasta auditoría a 3m)
- Decisión: accepted
- Razón: Trazabilidad ligera y proporcionada; produce exactamente los datapoints que la auditoría empírica necesita, sin sobrecargar el flujo del master. Refuerza la propiedad de catálogo cerrado disjunto.

### Condición C2-N1 (umbral de retirada como query reproducible sobre `decisions.jsonl`, con campo `eligible_for_cor` marcado en clasificación)
- Decisión: accepted
- Razón: Convierte la cláusula de retirada en un mecanismo operacional verificable, no en prosa interpretable. Esto es exactamente lo que mi condición nueva 1 de ronda 2 demandaba (owner + sink + métrica); C2-N1 cubre el sink con precisión técnica.

### Condición C2-N2 (definición operacional de "elegible para COR" documentada en `council-angles.md` junto a la entrada)
- Decisión: accepted
- Razón: Sin esta definición, el divisor del cociente "<10%" es indeterminado y la cláusula colapsa. Además, mantiene la trazabilidad longitudinal del catálogo (la definición vive junto al ángulo, no en código disperso).

### Condición C2-N3 (revisión obligatoria a 3m con calendario activo, no opcional)
- Decisión: accepted
- Razón: Las cláusulas de retirada que dependen de iniciativa proactiva sistemáticamente no se ejecutan — esto es deuda de mantenimiento conocida. El calendario activo (cron, recordatorio en `phases.md`) es el mecanismo correcto para garantizar que la cláusula se materialice. Complementa mi propia condición nueva 1 de ronda 2 (architect como owner) con el disparador temporal.

## Voto final de ronda 3
SÍ (todas las condiciones aceptadas; C1-N1 con nota técnica de implementación, no veto)
