---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-1
angulo: ORT
ronda: 1
timestamp: 2026-05-23T16:35:00Z
---

# Veredicto del concejal 1 — ángulo ORT (Ortogonalidad)

## Recomendación
MODIFICAR

## Razones (máximo 3)

1. **El solape conceptual entre `ROB` y `COR` propuesto no es disjunto en el plano operacional, sino que se separa solo por un matiz semántico frágil.** La definición vigente de `ROB` es "¿qué propiedad del sistema queda verificable tras este cambio?". La correctitud funcional ("la operación produce el resultado funcionalmente correcto sin pérdida o corrupción de datos") es exactamente *una propiedad verificable* del sistema. El dossier intenta resolver el solape vía "verificabilidad estructural vs correctitud funcional" (Alternativa A, trade-off `-`), pero esta dicotomía no aparece en la definición catalogada de `ROB`: el catálogo no dice "verificabilidad estructural", dice "propiedad verificable" sin más. Por construcción, una propiedad funcional verificable cae bajo `ROB` tal como está hoy redactado. Para que `COR` sea genuinamente ortogonal, `ROB` debe reformularse simultáneamente para excluir explícitamente correctitud funcional — y esta reformulación no está incluida en la propuesta principal (Alternativa A).

2. **Los casos reales del firmware enumerados en el dossier (NFC sin perder bits, deserialización SubGHz sin truncamiento, `flipper_migrate_files()`, persistencia de slots) son simultáneamente problemas de `ROB` *y* de la `COR` propuesta, por lo que en runtime los concejales asignados competirían por la misma sub-cuestión.** Ejemplo concreto: para "deserialización del keystore SubGHz sin truncamiento", el concejal `ROB` legítimamente pregunta "¿qué invariante queda verificable: la longitud preservada, el checksum válido, la estructura íntegra?" — y el concejal `COR` pregunta "¿el resultado funcional es correcto, sin pérdida de bits?". Estas dos preguntas son la misma pregunta con etiquetas distintas. El dossier no aporta un solo caso donde `COR` produciría una crítica que `ROB` no produciría también, lo cual es el test definitivo de no-ortogonalidad. Esto viola el principio implícito del catálogo: cada ángulo debe iluminar una dimensión que ningún otro ilumina.

3. **La Alternativa C explicita el solape (admite que correctness es subpropiedad de robustez en literaturas Lamport/Lynch) y la Alternativa A lo replica sin admitirlo.** El propio dossier reconoce en C que "robustez en sentido amplio históricamente incluye correctness". Si la literatura formal trata correctness como subconjunto de robustness, separar `COR` de `ROB` como ángulos co-iguales del catálogo invierte la jerarquía conceptual y crea una taxonomía inconsistente. Los concejales futuros, sin acceso a este dossier, leerán solo el catálogo y verán dos ángulos que se traslapan sin guía clara de cuál aplica cuándo. El criterio "decisiones de arquitectura del firmware" de `ORT` y el criterio "I/O y parsing" implícito de `COR` chocarán en cualquier decisión arquitectónica que toque parsing/serialización — frecuente en este firmware.

## Riesgos detectados desde mi ángulo

- **Riesgo de doble asignación encubierta.** Si el master asigna `ROB` y `COR` al mismo trío (lo cual es estructuralmente legítimo bajo Alternativa A), los dos concejales producirán veredictos casi-idénticos sobre la misma propiedad, lo que reduce el Concilio efectivo a 2 voces independientes en lugar de 3. La regla D21 (2-de-3 SÍ) se ve afectada porque dos votos correlacionados cuentan como uno informativo. Esto degrada el mecanismo anti-sesgo del Concilio sin que el master lo perciba.

- **Riesgo de erosión taxonómica del catálogo cerrado.** Una vez que se admite un ángulo cuya distinción con otro existente requiere un párrafo de aclaración no escrito en el catálogo, queda abierto un precedente: futuros wildcards podrán argumentar "ya tenemos `COR` separado de `ROB`, así que esta subdistinción también merece ángulo propio". El catálogo cerrado (D18) protege contra precisamente esta dinámica. La integridad de la regla "extensión solo vía PR humano" depende de que cada nuevo ángulo añadido sea inequívocamente ortogonal a todos los previos.

- **Riesgo de coste de selección elevado al master.** Pasar de 12 a 13 ángulos no es un crecimiento aritmético menor cuando dos de ellos comparten frontera difusa. El master, al elegir 3 ángulos por sesión, deberá invertir en cada convocatoria un razonamiento adicional sobre "¿esto es `ROB`, `COR` o ambos?". Este coste cognitivo es exactamente el sesgo que el catálogo cerrado intenta acotar (D18 — "más opciones que elegir significa más espacio para sesgo del master"). El dossier reconoce este trade-off en la Alternativa A pero no lo resuelve.

## Voto
SÍ-CON-CONDICIONES

## Condiciones (solo si SÍ-CON-CONDICIONES)

- **Condición 1: Reformulación obligatoria y simultánea de `ROB` para excluir correctitud funcional.** En el mismo PR que introduce `COR`, la entrada de `ROB` en `.claude/design/council-angles.md` debe cambiarse a algo como: "¿Qué *invariante estructural* del sistema (lifecycle, estado, recuperación de fallos, manejo de errores) queda verificable tras este cambio? *No cubre correctitud del resultado funcional — ver `COR`.*". Sin esta reformulación explícita y co-publicada, los dos ángulos solapan por construcción y el voto se convierte en NO.

- **Condición 2: La entrada de `COR` debe incluir un campo "No aplicable cuando" que delimite claramente lo que es `ROB`.** Texto sugerido: "No aplicable cuando la cuestión es lifecycle de recursos, recuperación de fallos, manejo de errores estructurales o invariantes de estado — esos casos son `ROB`. `COR` aplica solo a transformaciones input→output donde el criterio de éxito es el contenido del output." Esto fuerza disjunción operacional verificable.

- **Condición 3: El historial de cambios al catálogo (sección final de `council-angles.md`) debe documentar explícitamente la fecha, el `council_id` de este Concilio y la justificación de la separación `ROB`/`COR`, para que un concejal futuro pueda reconstruir la intención sin acceso al dossier. La trazabilidad longitudinal (que el documento se preocupa de mantener con "IDs estables para que los logs sean parseables") exige esta documentación.

- **Condición 4: Antes de la siguiente convocatoria del Concilio que pueda involucrar `COR`, el master debe verificar que el script `.claude/scripts/check-irreversibility.sh` (si tiene lógica de disambiguación de ángulos) o cualquier doc de routing refleje la nueva delimitación. Si no existe tal script para ángulos, esta condición es informativa: el master humano-en-el-loop debe internalizar la frontera antes de delegar.
