# FuriOS — runtime del firmware Momentum (Flipper Zero)

Este documento es el **first-pass de alto nivel** sobre el runtime FuriOS que ejecuta el firmware Momentum/Flipper Zero. Sirve de contexto curado para los subagentes especialistas y para Claude Code en general cuando opera sobre `furi/`, `applications/`, o cualquier servicio que dependa del runtime.

Profundizaciones específicas (`subghz-internals.md`, `nfc-stack.md`, `build-system.md`, etc.) se añaden en Fases 2-3 conforme los especialistas los necesiten.

---

## 1. Contexto y propósito

**FuriOS** (Flipper Universal Registry Implementation) es la capa de runtime que envuelve **FreeRTOS** sobre el MCU **STM32WB55** del Flipper Zero. No es un kernel desde cero: es una capa de abstracción C que normaliza primitivas de FreeRTOS bajo una API coherente con naming `furi_*` y añade conceptos propios del producto (records, log unificado, app lifecycle, heap-tracing per-thread, etc.).

**Hardware**: STM32WB55 dual-core (Cortex-M4 para aplicación, Cortex-M0+ dedicado al stack BLE). El firmware Momentum es un fork del firmware oficial Flipper con features adicionales (apps, SubGHz extendido, parches NFC, etc.).

**Por qué FuriOS y no FreeRTOS pelado**: FreeRTOS provee primitivas crudas (xTaskCreate, xQueueCreate, xSemaphoreCreateMutex, etc.). FuriOS las envuelve para:
- Naming consistente (`furi_thread_alloc` en lugar de `xTaskCreate`).
- Encapsulación: tipos opacos (`FuriThread*` en lugar de `TaskHandle_t`).
- Convenciones de error: `FuriStatus` enum en lugar de `BaseType_t`.
- Features adicionales: heap tracing por thread, signal callbacks, application IDs.
- Records: registro global de servicios accesible por nombre.

---

## 2. Arquitectura global y entry points

### El boot

1. **`main()`** (no en `furi/`, en `targets/<board>/Src/main.c`): inicializa HAL del MCU, RAM, clocks, peripherals básicos. Llama a `furi_init()`.
2. **`furi_init()`** (`furi/furi.c`): inicializa el runtime — log, memmgr, records, kernel hooks. Tras esto, FreeRTOS scheduler está listo pero no corriendo.
3. **`flipper_init()`** (`furi/flipper.c:169`): crea threads de **servicios del sistema**. El primero es siempre `storage` (porque otros dependen de él), después el resto del array `FLIPPER_SERVICES`.
4. **`furi_run()`** (`furi/furi.c`): arranca el scheduler de FreeRTOS (`vTaskStartScheduler`). A partir de aquí, todo es event-driven y los servicios corren.
5. **`furi_background()`** (`furi/furi.c`): hook llamado desde el idle task de FreeRTOS para tareas de fondo (housekeeping del heap, watchdog, etc.).

### El modelo de servicios

Un **servicio** es un thread perpetuo (no termina) que ofrece una API vía **record** registrado en el registry global. Definidos en `applications.h` como un array:

```c
typedef struct {
    const char* name;         // human-readable
    const char* appid;        // app identifier
    uint32_t stack_size;
    FuriThreadCallback app;   // service entry point
    // ...
} FlipperInternalApplication;

extern const FlipperInternalApplication FLIPPER_SERVICES[];
extern const size_t FLIPPER_SERVICES_COUNT;
```

Servicios típicos: `storage`, `gui`, `notification`, `power`, `bt`, `dolphin`, `expansion`, `loader`, `cli`, etc.

`flipper_init()` itera el array y arranca cada uno con `flipper_start_service()` que llama a `furi_thread_alloc_service()`.

**Diferencia clave**: los servicios usan `furi_thread_alloc_service()` (no `furi_thread_alloc_ex()`). Service threads son más eficientes en memoria pero tienen restricciones: no pueden retornar de su callback (loop infinito obligatorio), no pueden ser joined ni freed, stack size es fijo. Razón: arrancan al boot y mueren con el dispositivo.

---

## 3. Primitivas core (`furi/core/`)

Todas se incluyen vía `#include <furi.h>` que reagrupa los headers individuales. Ver `furi/furi.h` para la lista canónica.

### 3.1 Threads — `FuriThread`

API en `furi/core/thread.h`. Patrón de uso típico para threads regulares (no servicios):

```c
FuriThread* t = furi_thread_alloc_ex("MyThread", 1024, my_callback, my_context);
furi_thread_set_priority(t, FuriThreadPriorityNormal);
furi_thread_start(t);
// ...
furi_thread_join(t);            // espera a que termine
furi_thread_free(t);            // libera estructura
```

**Estados**: `FuriThreadStateStopped`, `Starting`, `Running`, `Stopping`. Transiciones reportadas vía `furi_thread_set_state_callback()`.

**Prioridades**: `FuriThreadPriorityIdle` (0), `Init` (4), `Lowest` (14), `Low` (15), `Normal` (16, default), `High` (17), `Highest` (18), `Isr` (max - 1, para deferred ISR).

**Comunicación entre threads** (más allá de message queues):

- **Signals**: `furi_thread_signal(thread, signal, arg)` invoca el `signal_callback` del thread destinatario.
- **Thread flags**: `furi_thread_flags_set/clear/get/wait` — bitmask 32-bit per-thread para señalización ligera.

**Stdio per-thread**: cada thread tiene callbacks de stdout/stdin opcionales (`furi_thread_set_stdout_callback`). Esto permite que `printf` desde una app vaya a la pantalla, mientras el mismo `printf` desde el servicio CLI vaya al UART.

**Heap tracing**: `furi_thread_enable_heap_trace(thread)` activa contabilidad de heap para ese thread. `furi_thread_get_heap_size(thread)` reporta cuánto usa. Útil para diagnosticar leaks por app.

### 3.2 Mutex — `FuriMutex`

API en `furi/core/mutex.h`. Dos tipos:

- `FuriMutexTypeNormal`: mutex binario. NO recursivo. Intentar adquirirlo dos veces desde el mismo thread es deadlock.
- `FuriMutexTypeRecursive`: el mismo thread puede acquirelo N veces, debe release N veces.

```c
FuriMutex* m = furi_mutex_alloc(FuriMutexTypeNormal);
if(furi_mutex_acquire(m, FuriWaitForever) == FuriStatusOk) {
    // critical section
    furi_mutex_release(m);
}
furi_mutex_free(m);
```

**Preferencia**: usar `Normal` por defecto. `Recursive` solo cuando hay diseño explícito que lo necesita (callbacks que llaman a la misma sección crítica). Recursive es más caro en RAM y CPU.

### 3.3 Semaphore — `FuriSemaphore`

API en `furi/core/semaphore.h`. Counting y binary. Patrón clásico productor-consumidor o señalización ISR→thread (vía `furi_semaphore_release_from_isr`).

### 3.4 Event Flag — `FuriEventFlag`

API en `furi/core/event_flag.h`. Bitmask compartido entre threads. Más expresivo que un solo semaphore cuando hay varias señales distintas (ej. "datos listos" + "abortar" + "timeout").

### 3.5 Message Queue — `FuriMessageQueue`

API en `furi/core/message_queue.h`. Cola FIFO de tamaño fijo con mensajes de tamaño fijo. La primitiva más usada para comunicación inter-thread en el firmware.

```c
typedef struct { uint8_t op; uint16_t data; } MyMsg;
FuriMessageQueue* q = furi_message_queue_alloc(8, sizeof(MyMsg));
furi_message_queue_put(q, &msg, FuriWaitForever);
furi_message_queue_get(q, &msg_out, 100);  // timeout en ms (vía ticks)
furi_message_queue_free(q);
```

`FuriWait` es un alias de `uint32_t`; valores especiales: `FuriWaitForever` (block indefinido), `0` (no espera, returns immediately).

### 3.6 Stream Buffer — `FuriStreamBuffer`

API en `furi/core/stream_buffer.h`. Buffer de bytes para transferencias streaming (no message-oriented). Útil para datos de tamaño variable (e.g. logs, UART RX).

### 3.7 Event Loop — `FuriEventLoop`

API en `furi/core/event_loop.h`. Loop de eventos con primitivas combinables: timers, mensajes de queue, flags, custom callbacks. Permite escribir threads event-driven sin loops `while(1) { msg_queue_get(); switch(msg) }` manuales.

```c
FuriEventLoop* loop = furi_event_loop_alloc();
furi_event_loop_subscribe_message_queue(loop, q, FuriEventLoopEventIn, on_message, NULL);
furi_event_loop_run(loop);  // bloquea hasta furi_event_loop_stop
furi_event_loop_free(loop);
```

Patrón recomendado en código nuevo. Apps modernas (storage, gui, expansion) lo usan.

### 3.8 Timer — `FuriTimer` y Event Loop Timer

API en `furi/core/timer.h` (`FuriTimer` clásico, basado en FreeRTOS timer task) y `furi/core/event_loop_timer.h` (timers integrados en un event loop específico).

- **`FuriTimer`**: timers globales gestionados por el FreeRTOS timer service task. Útil cuando el callback debe correr en un contexto independiente.
- **`FuriEventLoopTimer`**: timers que corren en el thread dueño del event loop. Más predecibles, sin race con el timer task global.

### 3.9 PubSub — `FuriPubSub`

API en `furi/core/pubsub.h`. Patrón publisher-subscriber tipo broker dentro del firmware. Usado por servicios para notificar eventos (ej. `storage` publica `StorageEventTypeCardMount` cuando la SD se inserta; otros servicios se suscriben).

### 3.10 Records — `FuriRecord` (registry global)

API en `furi/core/record.h`. **La pieza más característica de FuriOS.**

Un record es un singleton registrado por nombre (string) en un registry global. Servicios exponen sus APIs registrando un objeto. Apps obtienen acceso al servicio abriendo el record.

```c
// Servicio (al boot):
Storage* storage = storage_alloc();
furi_record_create(RECORD_STORAGE, storage);

// App (durante ejecución):
Storage* storage = furi_record_open(RECORD_STORAGE);
// ... usar storage ...
furi_record_close(RECORD_STORAGE);
```

Records típicos: `RECORD_STORAGE`, `RECORD_GUI`, `RECORD_NOTIFICATION`, `RECORD_DIALOGS`, `RECORD_LOADER`, `RECORD_POWER`, `RECORD_BT`, `RECORD_INPUT`, `RECORD_CLI`, etc.

**Importante**: `furi_record_open()` es bloqueante — si el record aún no está creado (servicio aún no boot), suspende el thread hasta que aparezca. **Esto es por qué `storage` arranca primero**: muchos servicios lo abren en su `_init`.

`furi_record_close()` decrementa un refcount. `furi_record_destroy()` solo procede si el refcount está a 0 y el thread es el dueño.

**Anti-patrón clásico**: `furi_record_open()` sin `furi_record_close()` correspondiente — el record nunca puede destruirse y el refcount queda inflado. Detectable con `furi_thread_enable_heap_trace`.

### 3.11 Time y delays — `furi_kernel_*`, `furi_delay_*`

API en `furi/core/kernel.h`:

- `furi_get_tick()` → ticks desde boot (ms, puede overflow).
- `furi_kernel_get_tick_frequency()` → ticks por segundo (típicamente 1000).
- `furi_ms_to_ticks(ms)` → conversión.
- `furi_delay_tick(ticks)`, `furi_delay_ms(ms)` → bloquean el thread, **NUNCA usar desde ISR**.
- `furi_delay_us(us)` → busy-wait usando el DWT cycle counter del Cortex-M4. No aliased a ticks. Útil para timing fino.
- `furi_kernel_is_irq_or_masked()` → chequea contexto ISR.
- `furi_kernel_lock()` / `furi_kernel_unlock()` → suspende/reanuda el scheduler (operaciones críticas).

### 3.12 Memory — `FuriMemmgr` y heap

API en `furi/core/memmgr.h` y `furi/core/memmgr_heap.h`. Wrappers sobre el heap de FreeRTOS (typically heap_4) con tracing y canary opcionales.

- `malloc`/`free` estándar funcionan (redirigen a `memmgr`).
- `aligned_malloc`/`aligned_free` para alineamiento específico.
- `memmgr_alloc_from_pool` — alloca desde un pool especial (visible en `flipper.c` para los `vApplicationGet*Memory` callbacks de FreeRTOS).
- `HEAP_CANARY_VALUE` = `0x8BADF00D` (en `flipper.c:15`) — detecta corrupciones de heap.

### 3.13 Logging — `FuriLog`

API en `furi/core/log.h`. Niveles `FuriLogLevelError/Warn/Info/Debug/Trace`. Macros:

```c
#define TAG "MyApp"
FURI_LOG_E(TAG, "Error %d", err);   // rojo
FURI_LOG_W(TAG, "Warning");          // marrón
FURI_LOG_I(TAG, "Info");             // verde
FURI_LOG_D(TAG, "Debug %x", val);    // azul
FURI_LOG_T(TAG, "Trace");            // morado
```

Los logs van por defecto al UART de debug. Pueden añadirse handlers extra (`furi_log_add_handler`) para dirigirlos a otros sinks (pantalla, archivo, CLI, etc.).

Nivel global ajustable en runtime via `furi_log_set_level(level)`. Default suele ser `Info` en release, `Debug` en debug builds.

### 3.14 Asserts y checks — `furi_check`, `furi_assert`, `furi_crash`

Macros en `furi/core/check.h`:

- `furi_check(cond)` — chequea en build release Y debug. Si falla, llama a `furi_crash` que halta el sistema con un mensaje.
- `furi_assert(cond)` — solo en debug builds. En release se compila a nada.
- `furi_crash("msg")` — halta el sistema deliberadamente. Útil para invariantes que NO deben fallar.

**Convención del firmware**: usar `furi_check` para invariantes runtime que dependen de input externo o estado del sistema; usar `furi_assert` para invariantes de diseño que solo fallarían por bug interno.

### 3.15 String — `FuriString`

API en `furi/core/string.h`. Wrapper sobre la librería **mlib m-string**. Strings dinámicos de longitud variable.

```c
FuriString* s = furi_string_alloc();
furi_string_printf(s, "value: %d", x);
const char* cstr = furi_string_get_cstr(s);
furi_string_free(s);
```

Preferir `FuriString` sobre `char[N]` cuando el tamaño no es trivialmente acotado.

---

## 4. El pattern service-record (cómo arrancan los servicios)

Visible directamente en `furi/flipper.c`:

1. **Definir el servicio**: una función `void my_service(void* context)` que es loop infinito.
2. **Registrarlo en `FLIPPER_SERVICES`**: array externo (en `applications.h` generado por SCons desde manifests `.fam`).
3. **`flipper_start_service()`** itera el array y arranca cada uno con `furi_thread_alloc_service()` + `furi_thread_set_appid()` + `furi_thread_start()`.
4. **Dentro del servicio**:
   - Alloca su estado.
   - Registra el record: `furi_record_create(RECORD_NAME, state)`.
   - Entra al loop principal (event loop o message queue blocking).
5. **Apps externas**: abren records con `furi_record_open()`, los usan, los cierran con `furi_record_close()`.

**Ejemplo concreto en `flipper.c:159`**:

```c
void flipper_start_service(const FlipperInternalApplication* service) {
    FURI_LOG_D(TAG, "Starting service %s", service->name);
    FuriThread* thread =
        furi_thread_alloc_service(service->name, service->stack_size, service->app, NULL);
    furi_thread_set_appid(thread, service->appid);
    furi_thread_start(thread);
}
```

Nótese que el thread se "fuga" (no se guarda referencia) — es intencional, los servicios viven hasta el shutdown del dispositivo.

---

## 5. App lifecycle (apps externas y main)

### Apps externas (FAPs)

Las apps externas viven en `applications/external/` (oficiales) y `applications_user/` (de usuario). Cada una tiene un `application.fam` (manifest) que SCons procesa para generar `applications.h` y compilar el `.fap` (Flipper App Pack).

Estructura típica de manifest (referencia rápida; detalle completo en `.claude/docs/adding-an-app-checklist.md` cuando lo creemos):

```python
App(
    appid="my_app",
    name="My App",
    apptype=FlipperAppType.EXTERNAL,
    entry_point="my_app_main",
    requires=["gui", "storage"],
    stack_size=4 * 1024,
    fap_icon="icon.png",
    fap_category="Tools",
)
```

### Ciclo de vida

1. Usuario navega menú → `loader` service detecta selección.
2. `loader` carga el `.fap` desde SD, resuelve symbols dinámicamente, alloca el thread con `stack_size` del manifest.
3. Llama al `entry_point` con argumentos (típicamente `void* context` o un parámetro de string).
4. La app corre — típicamente abre records (`gui`, `storage`, etc.), crea su event loop, gestiona scenes/views.
5. Cuando la app termina, cierra sus records, libera estado, retorna del entry_point.
6. `loader` joinea el thread y descarga el `.fap`.

### Scenes y Views (GUI)

Apps con UI usan el framework `gui/scene_manager` + `view_dispatcher`:

- **Scene**: un "pantalla" con on_enter/on_event/on_exit.
- **View**: el render concreto (canvas, input handling).
- **ViewDispatcher**: cambia entre views, rutea input.

Esto se documenta más a fondo en `flipper-app-builder.md` (especialista Fase 2).

---

## 6. HAL bridge — `furi_hal_*`

`furi/` provee primitivas de OS. **`furi_hal_*`** (en `targets/<board>/furi_hal/`) provee acceso al hardware.

Convención: drivers de hardware exponen API `furi_hal_<peripheral>_*`. Ejemplos:

- `furi_hal_gpio` — GPIO config y read/write.
- `furi_hal_subghz` — radio CC1101.
- `furi_hal_nfc` — chip NFC.
- `furi_hal_bt` — Bluetooth (via STM32WB55 Cortex-M0+).
- `furi_hal_rtc` — real-time clock.
- `furi_hal_random` — TRNG.
- `furi_hal_power` — battery, charging, sleep.
- `furi_hal_light` — RGB LED.

Las apps y servicios NO deben acceder directamente a registros del MCU — siempre vía `furi_hal_*`.

---

## 7. Convenciones (resumen de `CODING_STYLE.md`)

- **Tab = 4 espacios.** `./fbt format` aplica el estilo.
- **Funciones**: `snake_case`. `furi_thread_alloc`, `subghz_keystore_read`.
- **Tipos**: `PascalCase`. `FuriThread`, `SubGhzKeystore`.
- **Prefix por package**: archivos en `subghz/` exponen tipos `SubGhz*` y funciones `subghz_*`.
- **Constructor/destructor**: `_alloc()` retorna pointer; `_free(ptr)` libera.
- **Encapsulación**: tipos opacos (`struct FuriThread;` en header sin contenido) + funciones que los manejan. No exponer raw data.
- **Files**: `[0-9A-Za-z_]+.{c,h,cpp,cxx,hpp}`. Linter enforced.

---

## 8. Anti-patrones comunes a evitar

1. **Records leaks**: `furi_record_open(...)` sin `furi_record_close(...)` correspondiente. Si la app crashea entre medias, el refcount queda inflado para siempre. **Patrón seguro**: open en `_alloc` de tu estado, close en `_free`.
2. **`furi_delay_ms` en hot path / event loop**: bloquea el thread. Si tu thread tiene un event loop o procesa una queue, `furi_delay_ms(50)` mata responsiveness. Usar timers en su lugar.
3. **Threads sin nombre o sin appid**: dificultan debug y crash dumps. Siempre `furi_thread_set_name` y `furi_thread_set_appid` si la app es identificable.
4. **`FuriMutexTypeRecursive` por defecto**: es más caro. Usar `Normal` salvo que el diseño explícitamente requiera reentry.
5. **`furi_delay_ms` desde ISR**: prohibido (`furi_kernel_is_irq_or_masked` lo detecta). Usar `furi_*_release_from_isr` y dejar al thread procesar.
6. **`malloc` directo sin chequear NULL**: usar `furi_check` o `furi_assert` sobre el resultado.
7. **Mantener references a `FuriThread*` de servicios**: los servicios no joinables. Solo guardar el ID si necesario, no la struct.
8. **Modificar prioridades de threads ajenos sin coordinación**: lleva a inversión de prioridad y deadlocks en cascada.
9. **Usar `printf` directo sin `FURI_LOG_*`**: los `FURI_LOG_*` añaden tag, timestamp y color; respetan el log level global; tienen color.
10. **Asumir `FuriString` y `char*` son intercambiables**: la conversión es explícita vía `furi_string_get_cstr()`. No `strcpy` directo sobre el buffer interno.

---

## 9. Archivos clave para profundizar

Para investigaciones profundas, los headers más relevantes en orden de utilidad:

- `furi/furi.h` — punto de entrada del runtime (lista de includes).
- `furi/flipper.c` — boot sequence completo (ver `flipper_init` línea 169).
- `furi/core/thread.h` — API completa de threads.
- `furi/core/record.h` — registry global.
- `furi/core/message_queue.h`, `mutex.h`, `semaphore.h`, `event_flag.h` — sincronización.
- `furi/core/event_loop.h` — event loops (12 KB, el más complejo).
- `furi/core/kernel.h` — time y kernel utilities.
- `furi/core/log.h` — logging macros.
- `furi/core/check.h` — asserts.
- `furi/core/string.h` — FuriString.

Para HAL: `targets/<board>/furi_hal/furi_hal_*.h`.

Para apps: `applications/services/` (servicios oficiales), `applications/main/` (apps main del menú), `applications/external/` (FAPs oficiales), `applications_user/` (FAPs de usuario).

---

## 10. Referencias externas

- **CODING_STYLE.md** del repo — convenciones de naming y estilo.
- **`documentation/` del repo** — docs oficiales por feature (SubGHz, NFC, OTA, etc.).
- **`developer.flipper.net`** — docs públicas del SDK (versionadas, pueden estar desactualizadas respecto al fork Momentum).
- **FreeRTOS docs** — para entender la capa subyacente. Útil sobre todo para entender heap_4 y los hooks `vApplicationGet*Memory`.
