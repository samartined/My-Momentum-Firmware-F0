---
council_id: 62978df1-a1f9-4e2d-8706-750d0ac18c3c
concejal: concejal-3
angulo: MNT
ronda: 1
timestamp: 2026-05-23T16:23:57Z
---

# Veredicto del concejal 3 — ángulo MNT (Mantenibilidad)

## Recomendación
MODIFICAR

## Razones (máximo 3)

1. **La "pregunta clave" propuesta para `COR` carece de operacionalización suficiente para sobrevivir 6 meses.** El texto "¿La operación produce el resultado funcionalmente correcto sin pérdida o corrupción de datos?" usa tres términos no definidos: "funcionalmente correcto", "pérdida" y "corrupción". Sin una rúbrica que delimite qué cuenta como "correcto" frente a una propiedad estructural verificable (que ya cubre `ROB`), un master futuro — o el yo de Edgar de Q4-2026, sin la memoria fresca de esta deliberación — clasificará la misma decisión a veces bajo `ROB` y a veces bajo `COR` según el día. En contraste, ángulos del catálogo actual como `BIN` ("¿Cabe en flash y RAM disponibles?") o `COS` ("¿Cuántas llamadas a modelo añade y de qué tier?") son **medibles**: un número, un umbral, un veredicto. `COR` tal como está redactado no lo es. La diferencia entre `ROB` ("propiedad verificable") y `COR` ("resultado funcionalmente correcto sin pérdida/corrupción") es una distinción **interpretativa**, no operacional, y la deuda interpretativa se acumula en cada ADR posterior.

2. **El campo "Aplicable cuando" del catálogo es el rail estructural que combate el drift, y en la propuesta es demasiado laxo.** La lista "lectura/escritura de protocolos (NFC/SubGHz/RFID/IR), parsing de archivos, migraciones, código que serializa/deserializa" cubre una fracción enorme del firmware Momentum (literalmente la mayoría de los especialistas previstos en CLAUDE.md: `flipper-rf-subghz`, `flipper-nfc`, `flipper-rfid-ibutton`, `flipper-ir`, `flipper-c-furi`). Cuando un rail aplica a "casi todo lo que toca hardware", deja de ser un rail. Compárese con `ENE` ("Código que toca radio, display, GPIO") o `THR` ("Código que toca FreeRTOS, interrupciones, hardware") — son específicos por **subsistema**. `COR` tal como está propuesto se solapa por aplicabilidad con `ROB` (que ya dice "Decisiones que tocan el runtime del firmware o el sistema agente"). Mantener dos ángulos cuyos campos "aplicable cuando" se solapan tanto producirá inconsistencia retroactiva: ADRs cerrados con `ROB` cubriendo correctness serán indistinguibles de ADRs futuros con `COR` cubriendo lo mismo, sin nota.

3. **La sección "Historial de cambios al catálogo" del propio `council-angles.md` está vacía, y la propuesta no especifica entrada de changelog.** Esto es un síntoma de mantenibilidad: el catálogo se diseñó con un mecanismo de trazabilidad longitudinal (la propia tabla, la sección de historial) pero la propuesta no incluye qué entrada va a esa sección — fecha, ID del Concilio que aprobó, definición exacta congelada en ese momento. Sin ese registro, dentro de 6 meses no se podrá responder "¿qué quería decir `COR` cuando se introdujo?". Esto es exactamente el riesgo que la Alternativa C señala correctamente (cambio retroactivo de significado sin nota) — pero la Alternativa A no lo evita: simplemente lo desplaza al futuro. Cada vez que la definición de `COR` se afine en PR posterior, ADRs anteriores quedarán huérfanos a menos que el changelog del catálogo sea disciplinado, y nada en la propuesta lo garantiza.

## Riesgos detectados desde mi ángulo

- **Drift interpretativo entre concejales contemporáneos**. En la misma sesión del Concilio, dos concejales asignados a `COR` y `ROB` pueden razonar sobre el mismo caso (ej. "la deserialización del keystore SubGHz preserva los bits") y argumentar lo mismo desde ambos ángulos, anulando el valor del trío. El master no tiene una regla mecánica para detectarlo en runtime: la disciplina anti-sesgo del catálogo cerrado (D18) presupone que cada ángulo cubre una porción **disjunta** del espacio crítico, y `COR`/`ROB` tal como está propuesto no es disjunto.

- **Erosión de la pregunta-prueba en master futuro**. Cuando el master clasifica una decisión y selecciona 3 ángulos, hace una "pregunta-prueba" mental: ¿qué pregunta concreta quiero que se responda? Si la pregunta clave del ángulo es vaga, el master tiende a evitarlo (sesgo de aversión a ambigüedad) o lo elige por inercia. En 6 meses, sin la memoria de esta sesión, `COR` será o bien sobreutilizado (porque "correctness" suena universal y aplica a casi todo) o bien evitado (porque su pregunta es difícil de instrumentar). Ninguno de los dos escenarios es bueno.

- **Coste de mantenimiento del catálogo crece supralineal**. Cada ángulo nuevo no añade trabajo aditivo: añade trabajo de **coherencia con los 12 existentes** (verificar solape con cada uno, mantener changelog, actualizar agentes que invocan el catálogo, formar al master en cuándo aplicar cuál). Pasar de 12 a 13 ángulos en sí no es caro; pasar a 13 con un par con solape ambiguo sí lo es. La Alternativa B (wildcard recurrente) tiene una ventaja de mantenibilidad subestimada en el dossier: el wildcard *fuerza* a escribir la justificación de 3-5 líneas cada vez, lo que actúa como datos empíricos sobre si la categoría es realmente necesaria y bien definida antes de cristalizarla. El comando `/flipper-review-wildcards` es exactamente la herramienta de mantenibilidad pensada para esto.

- **La nota meta del dossier reduce el incentivo a hacer la entrada robusta**. El dossier dice "cualquiera de las 3 alternativas es defendible" porque la decisión real está subordinada a la validación V2 del sistema. Si se aprueba `COR` con la entrada actual sin reforzarla, queda permanentemente en el catálogo cerrado — y el catálogo cerrado es por diseño difícil de modificar (requiere PR humano, D18). La barra de calidad de entrada al catálogo debe ser proporcional al coste de salida, no al valor de la deliberación que la introduce.

## Voto
SÍ-CON-CONDICIONES

## Condiciones (solo si SÍ-CON-CONDICIONES)

- **Condición 1 (pregunta clave operacional)**: Reformular la pregunta clave de `COR` para que sea instrumentable. Propuesta concreta: *"¿Existe un caso de entrada concreto donde el output sea distinto del esperado en ≥1 bit, ≥1 byte, o ≥1 registro, y ese caso no esté cubierto por un test o invariante existente?"*. Esto convierte "correctness" en un predicado verificable (¿hay un caso concreto? sí/no) y lo distingue mecánicamente de `ROB` ("¿qué propiedad queda verificable?" — `ROB` pregunta por la existencia de la garantía, `COR` pregunta por la existencia del contraejemplo).

- **Condición 2 (rail de aplicabilidad disjunto con `ROB`)**: Restringir el campo "Aplicable cuando" de `COR` a casos donde **el resultado de la operación es comparable bit-a-bit o byte-a-byte con un esperado**: deserialización de formatos estructurados (FAT, NFC dumps, SubGHz keystore, archivos `.sub`, `.nfc`, `.ir`), migraciones de archivos con esquema, parsing de protocolos con frame definido. **Excluir explícitamente**: lógica de control, máquinas de estado, UI, scheduling — esos siguen siendo territorio de `ROB`. Esta restricción debe escribirse en el campo "Aplicable cuando" de la tabla, no solo en el ADR de cierre.

- **Condición 3 (entrada obligatoria en el historial)**: La modificación del catálogo debe incluir, en la sección "Historial de cambios al catálogo" de `council-angles.md`, una entrada con: fecha (`2026-05-23`), council_id (`62978df1-...`), ID del ADR de cierre, definición exacta de `COR` aprobada (texto completo de pregunta clave y aplicabilidad — no por referencia, en línea), y delimitación explícita frente a `ROB` (una frase: *"`COR` aplica cuando hay un esperado concreto comparable; `ROB` aplica cuando se afirma una propiedad sin contraejemplo concreto"*). Esta entrada queda **congelada**: cualquier refinamiento futuro de la definición de `COR` requiere una nueva entrada en el historial, no edición in-place de la tabla. Sin esta condición, los ADRs futuros que invoquen `COR` tendrán deuda interpretativa retroactiva la primera vez que la definición se afine.
