# FuriOS — Momentum firmware runtime (Flipper Zero)

This document is a **high-level first pass** on the FuriOS runtime that powers the Momentum/Flipper Zero firmware. It serves as curated context for specialist subagents and for Claude Code in general when operating on `furi/`, `applications/`, or any service that depends on the runtime.

Deeper dives (`subghz-internals.md`, `nfc-stack.md`, `build-system.md`, etc.) will be added in Phases 2-3 as the specialists need them.

---

## 1. Context and purpose

**FuriOS** (Flipper Universal Registry Implementation) is the runtime layer that wraps **FreeRTOS** on the Flipper Zero's **STM32WB55** MCU. It is not a kernel built from scratch: it's a C abstraction layer that normalizes FreeRTOS primitives under a coherent API with `furi_*` naming and adds product-specific concepts (records, unified logging, app lifecycle, per-thread heap tracing, etc.).

**Hardware**: dual-core STM32WB55 (Cortex-M4 for the application, a dedicated Cortex-M0+ for the BLE stack). The Momentum firmware is a fork of the official Flipper firmware with additional features (apps, extended SubGHz, NFC patches, etc.).

**Why FuriOS instead of plain FreeRTOS**: FreeRTOS provides raw primitives (xTaskCreate, xQueueCreate, xSemaphoreCreateMutex, etc.). FuriOS wraps them to provide:
- Consistent naming (`furi_thread_alloc` instead of `xTaskCreate`).
- Encapsulation: opaque types (`FuriThread*` instead of `TaskHandle_t`).
- Error conventions: `FuriStatus` enum instead of `BaseType_t`.
- Additional features: per-thread heap tracing, signal callbacks, application IDs.
- Records: a global registry of services accessible by name.

---

## 2. Global architecture and entry points

### The boot

1. **`main()`** (not in `furi/`, in `targets/<board>/Src/main.c`): initializes the MCU's HAL, RAM, clocks, basic peripherals. Calls `furi_init()`.
2. **`furi_init()`** (`furi/furi.c`): initializes the runtime — log, memmgr, records, kernel hooks. After this, the FreeRTOS scheduler is ready but not yet running.
3. **`flipper_init()`** (`furi/flipper.c:169`): creates the **system service** threads. The first one is always `storage` (since others depend on it), then the rest of the `FLIPPER_SERVICES` array.
4. **`furi_run()`** (`furi/furi.c`): starts the FreeRTOS scheduler (`vTaskStartScheduler`). From here on, everything is event-driven and the services run.
5. **`furi_background()`** (`furi/furi.c`): hook called from the FreeRTOS idle task for background tasks (heap housekeeping, watchdog, etc.).

### The service model

A **service** is a perpetual thread (never terminates) that offers an API via a **record** registered in the global registry. Defined in `applications.h` as an array:

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

Typical services: `storage`, `gui`, `notification`, `power`, `bt`, `dolphin`, `expansion`, `loader`, `cli`, etc.

`flipper_init()` iterates the array and starts each one with `flipper_start_service()`, which calls `furi_thread_alloc_service()`.

**Key difference**: services use `furi_thread_alloc_service()` (not `furi_thread_alloc_ex()`). Service threads are more memory-efficient but have restrictions: they cannot return from their callback (an infinite loop is mandatory), cannot be joined or freed, and have a fixed stack size. Reason: they start at boot and die only with the device.

---

## 3. Core primitives (`furi/core/`)

All are included via `#include <furi.h>`, which regroups the individual headers. See `furi/furi.h` for the canonical list.

### 3.1 Threads — `FuriThread`

API in `furi/core/thread.h`. Typical usage pattern for regular (non-service) threads:

```c
FuriThread* t = furi_thread_alloc_ex("MyThread", 1024, my_callback, my_context);
furi_thread_set_priority(t, FuriThreadPriorityNormal);
furi_thread_start(t);
// ...
furi_thread_join(t);            // waits for it to finish
furi_thread_free(t);            // frees the structure
```

**States**: `FuriThreadStateStopped`, `Starting`, `Running`, `Stopping`. Transitions reported via `furi_thread_set_state_callback()`.

**Priorities**: `FuriThreadPriorityIdle` (0), `Init` (4), `Lowest` (14), `Low` (15), `Normal` (16, default), `High` (17), `Highest` (18), `Isr` (max - 1, for deferred ISR).

**Inter-thread communication** (beyond message queues):

- **Signals**: `furi_thread_signal(thread, signal, arg)` invokes the target thread's `signal_callback`.
- **Thread flags**: `furi_thread_flags_set/clear/get/wait` — a 32-bit per-thread bitmask for lightweight signaling.

**Per-thread stdio**: each thread has optional stdout/stdin callbacks (`furi_thread_set_stdout_callback`). This lets `printf` from an app go to the screen, while the same `printf` from the CLI service goes to the UART.

**Heap tracing**: `furi_thread_enable_heap_trace(thread)` enables heap accounting for that thread. `furi_thread_get_heap_size(thread)` reports how much it uses. Useful for diagnosing per-app leaks.

### 3.2 Mutex — `FuriMutex`

API in `furi/core/mutex.h`. Two types:

- `FuriMutexTypeNormal`: binary mutex. NOT recursive. Acquiring it twice from the same thread is a deadlock.
- `FuriMutexTypeRecursive`: the same thread may acquire it N times, and must release it N times.

```c
FuriMutex* m = furi_mutex_alloc(FuriMutexTypeNormal);
if(furi_mutex_acquire(m, FuriWaitForever) == FuriStatusOk) {
    // critical section
    furi_mutex_release(m);
}
furi_mutex_free(m);
```

**Preference**: use `Normal` by default. `Recursive` only when there is an explicit design that needs it (callbacks that call into the same critical section). Recursive is more expensive in RAM and CPU.

### 3.3 Semaphore — `FuriSemaphore`

API in `furi/core/semaphore.h`. Counting and binary. Classic producer-consumer pattern, or ISR→thread signaling (via `furi_semaphore_release_from_isr`).

### 3.4 Event Flag — `FuriEventFlag`

API in `furi/core/event_flag.h`. Bitmask shared between threads. More expressive than a single semaphore when there are several distinct signals (e.g. "data ready" + "abort" + "timeout").

### 3.5 Message Queue — `FuriMessageQueue`

API in `furi/core/message_queue.h`. Fixed-size FIFO queue of fixed-size messages. The most-used primitive for inter-thread communication in the firmware.

```c
typedef struct { uint8_t op; uint16_t data; } MyMsg;
FuriMessageQueue* q = furi_message_queue_alloc(8, sizeof(MyMsg));
furi_message_queue_put(q, &msg, FuriWaitForever);
furi_message_queue_get(q, &msg_out, 100);  // timeout in ms (via ticks)
furi_message_queue_free(q);
```

`FuriWait` is an alias for `uint32_t`; special values: `FuriWaitForever` (block indefinitely), `0` (no wait, returns immediately).

### 3.6 Stream Buffer — `FuriStreamBuffer`

API in `furi/core/stream_buffer.h`. Byte buffer for streaming transfers (not message-oriented). Useful for variable-size data (e.g. logs, UART RX).

### 3.7 Event Loop — `FuriEventLoop`

API in `furi/core/event_loop.h`. Event loop with combinable primitives: timers, queue messages, flags, custom callbacks. Lets you write event-driven threads without manual `while(1) { msg_queue_get(); switch(msg) }` loops.

```c
FuriEventLoop* loop = furi_event_loop_alloc();
furi_event_loop_subscribe_message_queue(loop, q, FuriEventLoopEventIn, on_message, NULL);
furi_event_loop_run(loop);  // blocks until furi_event_loop_stop
furi_event_loop_free(loop);
```

Recommended pattern in new code. Modern apps (storage, gui, expansion) use it.

### 3.8 Timer — `FuriTimer` and Event Loop Timer

API in `furi/core/timer.h` (the classic `FuriTimer`, based on the FreeRTOS timer task) and `furi/core/event_loop_timer.h` (timers integrated into a specific event loop).

- **`FuriTimer`**: global timers managed by the FreeRTOS timer service task. Useful when the callback needs to run in an independent context.
- **`FuriEventLoopTimer`**: timers that run on the thread owning the event loop. More predictable, no race with the global timer task.

### 3.9 PubSub — `FuriPubSub`

API in `furi/core/pubsub.h`. A broker-style publisher-subscriber pattern within the firmware. Used by services to notify events (e.g. `storage` publishes `StorageEventTypeCardMount` when the SD card is inserted; other services subscribe).

### 3.10 Records — `FuriRecord` (global registry)

API in `furi/core/record.h`. **The most distinctive piece of FuriOS.**

A record is a singleton registered by name (string) in a global registry. Services expose their APIs by registering an object. Apps get access to a service by opening the record.

```c
// Service (at boot):
Storage* storage = storage_alloc();
furi_record_create(RECORD_STORAGE, storage);

// App (at runtime):
Storage* storage = furi_record_open(RECORD_STORAGE);
// ... use storage ...
furi_record_close(RECORD_STORAGE);
```

Typical records: `RECORD_STORAGE`, `RECORD_GUI`, `RECORD_NOTIFICATION`, `RECORD_DIALOGS`, `RECORD_LOADER`, `RECORD_POWER`, `RECORD_BT`, `RECORD_INPUT`, `RECORD_CLI`, etc.

**Important**: `furi_record_open()` is blocking — if the record hasn't been created yet (the service hasn't booted yet), it suspends the thread until it appears. **This is why `storage` boots first**: many services open it in their `_init`.

`furi_record_close()` decrements a refcount. `furi_record_destroy()` only proceeds if the refcount is 0 and the calling thread is the owner.

**Classic anti-pattern**: `furi_record_open()` without a matching `furi_record_close()` — the record can never be destroyed and the refcount stays inflated. Detectable with `furi_thread_enable_heap_trace`.

### 3.11 Time and delays — `furi_kernel_*`, `furi_delay_*`

API in `furi/core/kernel.h`:

- `furi_get_tick()` → ticks since boot (ms, may overflow).
- `furi_kernel_get_tick_frequency()` → ticks per second (typically 1000).
- `furi_ms_to_ticks(ms)` → conversion.
- `furi_delay_tick(ticks)`, `furi_delay_ms(ms)` → block the thread, **NEVER use from an ISR**.
- `furi_delay_us(us)` → busy-wait using the Cortex-M4's DWT cycle counter. Not aliased to ticks. Useful for fine-grained timing.
- `furi_kernel_is_irq_or_masked()` → checks for ISR context.
- `furi_kernel_lock()` / `furi_kernel_unlock()` → suspends/resumes the scheduler (critical operations).

### 3.12 Memory — `FuriMemmgr` and heap

API in `furi/core/memmgr.h` and `furi/core/memmgr_heap.h`. Wrappers over the FreeRTOS heap (typically heap_4) with optional tracing and canaries.

- Standard `malloc`/`free` work (redirect to `memmgr`).
- `aligned_malloc`/`aligned_free` for specific alignment.
- `memmgr_alloc_from_pool` — allocates from a special pool (visible in `flipper.c` for FreeRTOS's `vApplicationGet*Memory` callbacks).
- `HEAP_CANARY_VALUE` = `0x8BADF00D` (in `flipper.c:15`) — detects heap corruption.

### 3.13 Logging — `FuriLog`

API in `furi/core/log.h`. Levels `FuriLogLevelError/Warn/Info/Debug/Trace`. Macros:

```c
#define TAG "MyApp"
FURI_LOG_E(TAG, "Error %d", err);   // red
FURI_LOG_W(TAG, "Warning");          // brown
FURI_LOG_I(TAG, "Info");             // green
FURI_LOG_D(TAG, "Debug %x", val);    // blue
FURI_LOG_T(TAG, "Trace");            // purple
```

Logs go to the debug UART by default. Extra handlers can be added (`furi_log_add_handler`) to route them to other sinks (screen, file, CLI, etc.).

The global level is adjustable at runtime via `furi_log_set_level(level)`. Default is usually `Info` in release, `Debug` in debug builds.

### 3.14 Asserts and checks — `furi_check`, `furi_assert`, `furi_crash`

Macros in `furi/core/check.h`:

- `furi_check(cond)` — checked in both release AND debug builds. If it fails, it calls `furi_crash`, which halts the system with a message.
- `furi_assert(cond)` — debug builds only. Compiles to nothing in release.
- `furi_crash("msg")` — deliberately halts the system. Useful for invariants that must NEVER fail.

**Firmware convention**: use `furi_check` for runtime invariants that depend on external input or system state; use `furi_assert` for design invariants that would only fail due to an internal bug.

### 3.15 String — `FuriString`

API in `furi/core/string.h`. Wrapper over the **mlib m-string** library. Dynamic, variable-length strings.

```c
FuriString* s = furi_string_alloc();
furi_string_printf(s, "value: %d", x);
const char* cstr = furi_string_get_cstr(s);
furi_string_free(s);
```

Prefer `FuriString` over `char[N]` when the size is not trivially bounded.

---

## 4. The service-record pattern (how services boot)

Visible directly in `furi/flipper.c`:

1. **Define the service**: a `void my_service(void* context)` function that is an infinite loop.
2. **Register it in `FLIPPER_SERVICES`**: an external array (in `applications.h`, generated by SCons from `.fam` manifests).
3. **`flipper_start_service()`** iterates the array and starts each one with `furi_thread_alloc_service()` + `furi_thread_set_appid()` + `furi_thread_start()`.
4. **Inside the service**:
   - Allocates its state.
   - Registers the record: `furi_record_create(RECORD_NAME, state)`.
   - Enters the main loop (event loop or blocking message queue).
5. **External apps**: open records with `furi_record_open()`, use them, close them with `furi_record_close()`.

**Concrete example in `flipper.c:159`**:

```c
void flipper_start_service(const FlipperInternalApplication* service) {
    FURI_LOG_D(TAG, "Starting service %s", service->name);
    FuriThread* thread =
        furi_thread_alloc_service(service->name, service->stack_size, service->app, NULL);
    furi_thread_set_appid(thread, service->appid);
    furi_thread_start(thread);
}
```

Note that the thread "leaks" (no reference is kept) — this is intentional; services live until the device shuts down.

---

## 5. App lifecycle (external apps and main)

### External apps (FAPs)

External apps live in `applications/external/` (official) and `applications_user/` (user-made). Each has an `application.fam` (manifest) that SCons processes to generate `applications.h` and build the `.fap` (Flipper App Pack).

Typical manifest structure (quick reference; full detail in `.claude/docs/adding-an-app-checklist.md` once we create it):

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

### Lifecycle

1. User navigates the menu → the `loader` service detects the selection.
2. `loader` loads the `.fap` from the SD card, resolves symbols dynamically, allocates the thread with the `stack_size` from the manifest.
3. Calls the `entry_point` with arguments (typically `void* context` or a string parameter).
4. The app runs — typically opens records (`gui`, `storage`, etc.), creates its event loop, manages scenes/views.
5. When the app finishes, it closes its records, frees its state, and returns from the entry_point.
6. `loader` joins the thread and unloads the `.fap`.

### Scenes and Views (GUI)

Apps with UI use the `gui/scene_manager` + `view_dispatcher` framework:

- **Scene**: a "screen" with on_enter/on_event/on_exit.
- **View**: the concrete render (canvas, input handling).
- **ViewDispatcher**: switches between views, routes input.

This will be documented in more depth in `flipper-app-builder.md` (Phase 2 specialist).

---

## 6. HAL bridge — `furi_hal_*`

`furi/` provides OS primitives. **`furi_hal_*`** (in `targets/<board>/furi_hal/`) provides access to the hardware.

Convention: hardware drivers expose a `furi_hal_<peripheral>_*` API. Examples:

- `furi_hal_gpio` — GPIO config and read/write.
- `furi_hal_subghz` — CC1101 radio.
- `furi_hal_nfc` — NFC chip.
- `furi_hal_bt` — Bluetooth (via the STM32WB55 Cortex-M0+).
- `furi_hal_rtc` — real-time clock.
- `furi_hal_random` — TRNG.
- `furi_hal_power` — battery, charging, sleep.
- `furi_hal_light` — RGB LED.

Apps and services must NOT access MCU registers directly — always go through `furi_hal_*`.

---

## 7. Conventions (summary of `CODING_STYLE.md`)

- **Tab = 4 spaces.** `./fbt format` applies the style.
- **Functions**: `snake_case`. `furi_thread_alloc`, `subghz_keystore_read`.
- **Types**: `PascalCase`. `FuriThread`, `SubGhzKeystore`.
- **Per-package prefix**: files in `subghz/` expose `SubGhz*` types and `subghz_*` functions.
- **Constructor/destructor**: `_alloc()` returns a pointer; `_free(ptr)` frees it.
- **Encapsulation**: opaque types (`struct FuriThread;` in a header with no body) + functions that operate on them. Raw data is not exposed.
- **Files**: `[0-9A-Za-z_]+.{c,h,cpp,cxx,hpp}`. Linter enforced.

---

## 8. Common anti-patterns to avoid

1. **Record leaks**: `furi_record_open(...)` without a matching `furi_record_close(...)`. If the app crashes in between, the refcount stays inflated forever. **Safe pattern**: open in your state's `_alloc`, close in its `_free`.
2. **`furi_delay_ms` in a hot path / event loop**: blocks the thread. If your thread has an event loop or processes a queue, `furi_delay_ms(50)` kills responsiveness. Use timers instead.
3. **Threads with no name or no appid**: makes debugging and crash dumps harder. Always call `furi_thread_set_name` and `furi_thread_set_appid` if the app is identifiable.
4. **`FuriMutexTypeRecursive` by default**: it's more expensive. Use `Normal` unless the design explicitly requires reentry.
5. **`furi_delay_ms` from an ISR**: forbidden (`furi_kernel_is_irq_or_masked` detects it). Use `furi_*_release_from_isr` and let the thread process it.
6. **Direct `malloc` without checking for NULL**: use `furi_check` or `furi_assert` on the result.
7. **Holding references to a service's `FuriThread*`**: services are not joinable. Only keep the ID if needed, not the struct.
8. **Modifying other threads' priorities without coordination**: leads to priority inversion and cascading deadlocks.
9. **Using raw `printf` instead of `FURI_LOG_*`**: the `FURI_LOG_*` macros add a tag, timestamp, and color; they respect the global log level; they have color.
10. **Assuming `FuriString` and `char*` are interchangeable**: the conversion is explicit via `furi_string_get_cstr()`. No direct `strcpy` onto the internal buffer.

---

## 9. Key files for deeper investigation

For deep dives, the most useful headers in order of relevance:

- `furi/furi.h` — the runtime's entry point (list of includes).
- `furi/flipper.c` — the full boot sequence (see `flipper_init` line 169).
- `furi/core/thread.h` — full thread API.
- `furi/core/record.h` — global registry.
- `furi/core/message_queue.h`, `mutex.h`, `semaphore.h`, `event_flag.h` — synchronization.
- `furi/core/event_loop.h` — event loops (12 KB, the most complex one).
- `furi/core/kernel.h` — time and kernel utilities.
- `furi/core/log.h` — logging macros.
- `furi/core/check.h` — asserts.
- `furi/core/string.h` — FuriString.

For HAL: `targets/<board>/furi_hal/furi_hal_*.h`.

For apps: `applications/services/` (official services), `applications/main/` (main menu apps), `applications/external/` (official FAPs), `applications_user/` (user FAPs).

---

## 10. External references

- **CODING_STYLE.md** in the repo — naming and style conventions.
- **`documentation/` in the repo** — official per-feature docs (SubGHz, NFC, OTA, etc.).
- **`developer.flipper.net`** — public SDK docs (versioned, may be out of date relative to the Momentum fork).
- **FreeRTOS docs** — to understand the underlying layer. Especially useful for understanding heap_4 and the `vApplicationGet*Memory` hooks.
