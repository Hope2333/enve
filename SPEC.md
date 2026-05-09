# §G goal

AI-usable command interface for enve. → external AI/test harness sends JSON commands,
enve executes → returns structured result. Testing first, API surface extensible forever.

## §C constraints

- Qt 5.15 C++17, qmake build.
- No new third-party deps (!).
- Follow Logger singleton pattern (`src/core/logger.h:79-114`) → `CommandRegistry`.
- JSON message format matching Logger JSON (`pid`,`ts`,`src`).
- transport: stdin first (CI test), Unix socket next, D-Bus last.
- low-level command: inject Qt event into app loop.
- high-level command: call existing Action / Canvas / Document / Animator APIs.
- all dev error msg output via LOG_JSON=1, string: en. ! emoji.

## §I interfaces

env: `ENVE_AI` → "stdin" | "socket" | "off" (default off).
env: `ENVE_AI_SOCKET` → path (default `$XDG_RUNTIME_DIR/enve-ai.sock`).
stdin: JSONL → `{id,cmd,args}` → `{id,ok,result|error}` JSONL.
socket: QLocalServer Unix socket → same JSON message format.
class: `CommandRegistry` @ `src/core/commandregistry.h` → `process(cmd,args)`.
class: `CommandHandler` → `execute(const QJsonObject& args) → QJsonObject`.
hook: `Canvas::addUndoRedo(name,undo,redo)` for undoable AI ops.
hook: `Actions::sInstance-><action>->execute()` for menu actions.
hook: `Animator::anim_createKey()` / `anim_addKeyAtRelFrame()` for keyframes.
hook: `QCoreApplication::postEvent()` + `QCoreApplication::sendEvent()` for event injection.

## §V invariants

V1|∀ command → `{id,ok,result|error}` response emitted.
V2|`ENVE_AI` unset or "off" → `CommandRegistry` disabled, transports silent.
V3|command execution → structured log entry via Logger (pid/ts level).
V4|unknown command → `{ok:false,error:"unknown: <cmd>"}` not crash.
V5|low-level event injection → target widget set via `args.target` (objectName). ! null target.
V6|undoable ops → use `Canvas::addUndoRedo()`. AI commands ! bypass undo stack.
V7|transport (stdin/socket) → parse JSONL line at a time. invalid JSON → `{ok:false,error:"parse"}`, continue.

## §T tasks

id|status|task|cites
T1|.|`CommandRegistry` singleton: dispatch table, `register(name,handler)`, `process(cmd,args)` → result|V4,I.registry
T2|.|define `CommandHandler` abstract: `QString name()`, `QJsonObject execute(QJsonObject args)`|V4,I.handler
T3|.|implement `EchoHandler`: returns args back → verify transport roundtrip|T1,T2
T4|.|stdin transport: read JSONL from stdin line-buffered, `ENVE_AI=stdin` activates|V2,I.stdin
T5|.|low-level: `InjectEventHandler`: `mouse_press`,`mouse_move`,`mouse_release`,`key_press`,`key_release` → `QCoreApplication::postEvent()`|V5,I.event
T6|.|low-level: `ScreenshotHandler`: grab widget → base64 PNG → result|∅
T7|.|low-level: `StateHandler`: dump visible widget tree, active canvas scene graph → JSON|∅
T8|.|high-level: `CanvasHandler`: `create(width,height,fps)`, `set_active(canvas_id)`, `export(path)` → `Document::createNewScene()` + `CanvasWindow::setCurrentCanvas()`|I.canvas
T9|.|high-level: `KeyframeHandler`: `add_key(box_path,property,frame,value)` → `Animator::anim_addKeyAtRelFrame()`|I.animator
T10|.|high-level: `MenuHandler`: `trigger(action_name)` → `Actions::sInstance→<action>→execute()`|I.actions
T11|.|high-level: `BoxHandler`: `add_box(type,layer)` → `ContainerBox::ca_addChild()`|I.containerbox
T12|.|`main.cpp` integration: spawn transport, register handlers, `QSocketNotifier` for stdin|V2,I.env
T13|.|`ENVE_AI=stdin` e2e test: echo, create canvas(640,480,30), add rectangle, export SVG → verify|V1,T3,T8,T11
T14|.|socket transport: QLocalServer on `$ENVE_AI_SOCKET`, JSONL over Unix socket|I.socket

## §B bugs

id|date|cause|fix
