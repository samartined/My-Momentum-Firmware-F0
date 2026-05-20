# Catálogo de ángulos del Concilio Tripartito

Este documento es el catálogo cerrado de ángulos que el master puede asignar a los 3 concejales al convocar al Concilio (nivel L3). Cada ángulo tiene un ID estable para que los logs de deliberación sean parseables longitudinalmente.

Resolución del Concilio: D18.

## Reglas de uso

- El master selecciona exactamente 3 ángulos del catálogo cuando convoca al Concilio.
- Cada concejal recibe un único ángulo asignado y debe argumentar desde él.
- Máximo 1 ángulo wildcard ad-hoc (fuera de catálogo) por sesión, con justificación expandida de 3-5 líneas escrita al log de deliberaciones.
- Promoción de wildcard al catálogo: comando `/flipper-review-wildcards` opt-in del usuario.
- Extensión del catálogo: vía PR humano. No se permite añadir ángulos en runtime.

## Catálogo inicial (12 ángulos)

| ID | Ángulo | Pregunta clave | Aplicable cuando |
|----|--------|----------------|------------------|
| ROB | Robustez | ¿Qué propiedad del sistema queda verificable tras este cambio? | Decisiones que tocan el runtime del firmware o el sistema agente |
| SIM | Simplicidad | ¿Cuál es la implementación mínima que cubre el caso? | Refactors, nuevas features, mecanismos de control |
| SEC | Seguridad | ¿Qué vector de ataque o fuga abre o cierra esta decisión? | Cualquier cosa que toque credenciales, criptografía, ACL |
| REV | Reversibilidad | ¿Cuánto cuesta deshacer esta decisión si resulta mala? | Decisiones con impacto > 1 día de trabajo |
| COS | Coste-token | ¿Cuántas llamadas a modelo añade y de qué tier? | Cualquier mecanismo que invoca subagentes |
| UPS | Compatibilidad upstream | ¿Esto cierra la puerta a contribuir al firmware oficial? | Refactors que tocan código compartido con Next-Flip |
| MNT | Mantenibilidad | ¿Quién mantiene esto dentro de 6 meses? | Decisiones con nuevas dependencias o frameworks |
| UX | Ergonomía de usuario | ¿Añade fricción para el operador del Flipper? | Cualquier UI, slash command, flujo del usuario |
| ORT | Ortogonalidad | ¿Esta feature se ortogona con las existentes o las acopla? | Decisiones de arquitectura del firmware |
| ENE | Energía/batería | ¿Afecta consumo del dispositivo? | Código que toca radio, display, GPIO |
| BIN | Tamaño binario | ¿Cabe en flash y RAM disponibles? | Nuevas apps, librerías, assets |
| THR | Threading/timing | ¿Hay condiciones de carrera o violaciones de timing? | Código que toca FreeRTOS, interrupciones, hardware |

## Wildcard

Si ninguno de los 12 ángulos captura adecuadamente la perspectiva crítica para una decisión, el master puede definir un wildcard ad-hoc para esa sesión. Requisitos:

- Identificador temporal: `WILD-<timestamp>`.
- Justificación expandida (3-5 líneas) sobre por qué los ángulos del catálogo no aplican.
- La justificación se escribe a `.claude/state/wildcards.jsonl` con timestamp, ID del Concilio, ángulo wildcard, justificación.
- Si `/flipper-review-wildcards` detecta el mismo wildcard recurrente, el usuario decide si promoverlo al catálogo mediante PR.

## Historial de cambios al catálogo

(Esta sección se actualiza al final de cada PR que modifique el catálogo.)
