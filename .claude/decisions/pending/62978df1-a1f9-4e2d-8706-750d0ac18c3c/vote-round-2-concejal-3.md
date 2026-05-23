---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-3
angulo: MNT
ronda: 2
timestamp: 2026-05-23T18:48:00Z
---

# Voto del concejal 3 sobre síntesis — ronda 2

## Voto
SÍ-CON-CONDICIONES-NUEVAS

## Razones (máximo 3, breves)

1. **Las tres condiciones MNT de ronda 1 quedan incorporadas con fidelidad.** La pregunta clave operacional reformulada ("¿existe un caso de entrada concreto donde el output sea distinto del esperado en ≥1 bit/byte/registro?") es instrumentable mecánicamente: predicado sí/no sobre existencia de contraejemplo concreto. El rail restringido a operaciones bit-a-bit/byte-a-byte comparables elimina el solape con `ROB` que señalé en ronda 1 (deserialización con esperado vs. afirmación de propiedad sin contraejemplo). La entrada congelada en historial combate el drift retroactivo.

2. **La cláusula de retirada empírica a 3 meses es un añadido neto positivo desde MNT**, no deuda. Una sola medición acotada del ratio de uso actúa como safety-valve contra los dos escenarios que advertí en ronda 1 (sobre/subutilización del ángulo por master futuro). El coste de mantenimiento es bounded y proporcionado al coste de salida del catálogo cerrado.

3. **Queda un eslabón débil operacional**: la síntesis no especifica *quién ejecuta* la medición a 3 meses, *con qué umbral numérico* dispara la propuesta de retirada, ni *dónde se loguea el resultado*. Sin owner, umbral y sink de datos, la cláusula corre riesgo de quedar huérfana — exactamente el patrón anti-MNT que la sección "Historial de cambios al catálogo" estaba diseñada para evitar. Por eso voto con condiciones nuevas, no SÍ limpio.

## Condiciones nuevas (solo si SÍ-CON-CONDICIONES-NUEVAS)

- **Condición nueva 1 (owner y sink de la medición a 3 meses)**: La cláusula de retirada empírica debe especificar (a) que el `agent-architect` es responsable de ejecutar la medición en la fecha `fecha_entrada_historial + 3 meses` contada desde la entrada de aprobación del ángulo; (b) que el resultado se loguea como una **entrada adicional en el "Historial de cambios al catálogo"** de `council-angles.md` con formato `{fecha, council_id_origen, invocaciones_observadas, decisión: mantener | retirar | reevaluar-a-6m}`, incluso si la decisión es mantener sin cambios. Sin esta entrada, la medición no existe operacionalmente y el catálogo pierde su propiedad de trazabilidad longitudinal.

- **Condición nueva 2 (umbral mínimo de invocación congelado ex ante)**: La síntesis debe fijar un umbral numérico concreto que dispare la propuesta de retirada — propuesta: *"menos de 2 invocaciones reales de `COR` en ventana de 3 meses contados desde la aprobación"*. Sin umbral fijado *ex ante*, el architect futuro tendrá que re-deliberar qué cuenta como "uso bajo" y la cláusula se vuelve interpretativa — exactamente lo que ronda 1 buscaba evitar para la propia definición del ángulo. El umbral debe quedar congelado en la misma entrada de historial que la definición del ángulo, de modo que sea inmodificable sin nueva entrada de changelog.
