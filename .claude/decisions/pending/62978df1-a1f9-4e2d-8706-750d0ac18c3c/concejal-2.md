---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-2
angulo: SIM
ronda: 1
timestamp: 2026-05-23T16:23:33Z
---

# Veredicto del concejal 2 — ángulo SIM (Simplicidad)

## Recomendación
RECHAZAR

## Razones (máximo 3)

1. **El wildcard ya es la implementación mínima que cubre el caso.** La pregunta clave de SIM es "¿cuál es la implementación mínima que cubre el caso?". El catálogo actual (12 ángulos) más el mecanismo de wildcard de D18 ya resuelve correctness ocasional sin tocar nada: justificación expandida de 3-5 líneas a `.claude/state/wildcards.jsonl`, y promoción opt-in del usuario vía `/flipper-review-wildcards` cuando aparezca evidencia de recurrencia. Coste de implementación: cero líneas. Coste cognitivo: cero entradas adicionales en la tabla del catálogo. La Alternativa A añade una entrada de catálogo, una pregunta clave, una columna de "aplicable cuando", y un riesgo de solape con `ROB` — todo eso para un caso que el mecanismo de excepción ya cubre. Eso no es la implementación mínima; es la implementación anticipatoria.

2. **Falta evidencia empírica de recurrencia: añadir COR de oficio es YAGNI invertido.** El dossier enumera casos *potenciales* del firmware (NFC, SubGHz, FAT, `flipper_migrate_files()`, slots), pero no presenta una sola deliberación L3 histórica donde un wildcard de correctness se haya invocado y resuelto. Cero datapoints. El sistema multi-agente está en fase 1.G de validación funcional — el log `decisions.jsonl` está vacío o casi vacío. YAGNI aplicado a catálogos de evaluación dice: se añade un ángulo cuando 3-5 wildcards convergentes lo demanden empíricamente, no cuando un dossier especule que podría ser útil. El mecanismo de wildcard + promoción está diseñado precisamente para evitar esta clase de extensión especulativa; renunciar a él en la primera decisión real es renunciar al diseño.

3. **Pasar de 12 a 13 ángulos infla un 30% el espacio de selección del master sin reducir wildcards mensurablemente.** El master selecciona 3 ángulos por sesión: C(12,3)=220 tercetos posibles hoy, C(13,3)=286 con COR (+30%). Más opciones significan más espacio para sesgo en la selección, y mayor presión cognitiva al justificar implícitamente "por qué estos 3 y no otro terceto". El dossier reconoce que esto reduciría wildcards de correctness, pero NO cuantifica cuántos: si la frecuencia esperada es <5% de las decisiones, el coste estructural permanente (catálogo +8.3% en tamaño, +30% combinatoria) no se amortiza. La Alternativa B preserva exactamente la disciplina actual y delega la prueba empírica al wildcard.

## Riesgos detectados desde mi ángulo

- **Riesgo de "ratchet de catálogo"**: una vez que el catálogo crece a 13 ángulos por argumentos de cobertura especulativa, futuros dossieres podrán justificar 14, 15, 20 con la misma lógica ("este caso también merece ángulo dedicado"). Sin presión hacia abajo (eliminación), la simplicidad del catálogo se erosiona monotónicamente. SIM exige que la primera extensión tenga vara de medir muy alta — y la vara de "casos potenciales sin recurrencia medida" es demasiado baja.

- **Alternativa C es falsa simplicidad**: aunque preserva N=12, diluye la semántica de `ROB` al fusionarle dos sub-propiedades (verificabilidad estructural + corrección funcional). Un concejal con ángulo ROB pasaría de responder una pregunta a responder dos en una sola intervención. Simplicidad aparente del catálogo, complejidad real de la deliberación. No es la opción simple — es la opción confusa disfrazada de económica. Desde SIM, C es estrictamente peor que A y que B.

- **Solape semántico ROB↔COR (aplicable solo si A procede)**: la distinción "propiedad verificable" (ROB) vs "resultado funcionalmente correcto" (COR) requiere párrafo de explicación para el master cada vez que elija ángulos. Si la frontera entre dos ángulos necesita prosa para resolverse en runtime, los ángulos están demasiado cerca para coexistir limpiamente — el master perderá tiempo o se equivocará de asignación. SIM penaliza fronteras ambiguas.

## Voto
NO
