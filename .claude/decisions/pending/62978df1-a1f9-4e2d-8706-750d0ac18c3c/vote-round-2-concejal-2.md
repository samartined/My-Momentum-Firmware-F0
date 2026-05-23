---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-2
angulo: SIM
ronda: 2
timestamp: 2026-05-23T18:45:00Z
---

# Voto del concejal 2 sobre síntesis — ronda 2

## Voto
SÍ-CON-CONDICIONES-NUEVAS

## Razones (máximo 3, breves)

1. **La cláusula de retirada empírica a 3 meses convierte "permanente arriesgada" en "reversible con criterio".** Mi objeción central de ronda 1 era YAGNI: añadir COR sin datapoints. La cláusula con umbral medible (<10% de L3 elegibles) y plazo definido transforma la decisión en un experimento con condición de parada explícita. Eso es exactamente lo que SIM exige para tolerar una extensión especulativa del catálogo: si no se amortiza, vuelve a 12. Riesgo del "ratchet de catálogo" mitigado por precedente de retirada documentada.

2. **La pregunta clave operacional + rail de aplicabilidad disjunto bajan el coste cognitivo de selección.** Mi riesgo de "solape semántico ROB↔COR" se atenúa si la frontera está pre-resuelta en la documentación del ángulo (no en runtime, en cada selección del master). C(13,3)=286 sigue siendo +30% combinatoria, pero con rail disjunto el master no necesita prosa interna para resolver el caso — la decisión es lookup, no deliberación.

3. **Sigo prefiriendo Alternativa B en abstracto, pero la síntesis no es estrictamente peor que A original**, y añade un mecanismo de auto-corrección que B no tiene (B requiere ≥3 wildcards convergentes + invocación humana de `/flipper-review-wildcards` para promover). La síntesis incluye ambas direcciones del ratchet (entrar y salir), B solo cubre entrar. Eso es mejor desde SIM a largo plazo.

## Condiciones nuevas (solo si SÍ-CON-CONDICIONES-NUEVAS)

- **Umbral de retirada explícito y auditable en código, no solo en prosa**: el cálculo de "<10% de decisiones L3 elegibles" debe estar implementado como query reproducible sobre `decisions.jsonl` (campo `eligible_for_cor: true` o equivalente marcado por el master en el momento de clasificación). Sin esto, el architect a 3 meses operaría sobre estimación subjetiva — defeating el propósito empírico de la cláusula.

- **Definición operacional de "elegible para COR"** documentada en `council-angles.md` junto a la entrada: criterios objetivos (involucra I/O de protocolos, parsing, migración, serialización) verificables por inspección del enunciado del dossier. Sin esto, "10%" es divisor indeterminado.

- **Revisión obligatoria a los 3 meses (no opcional)**: si la cláusula dice "el architect propone retirarlo", debe haber un calendario activo (cron o recordatorio en `phases.md`) que dispare la revisión. Cláusulas de retirada que dependen de iniciativa proactiva tienden a no ejecutarse en sistemas vivos.
