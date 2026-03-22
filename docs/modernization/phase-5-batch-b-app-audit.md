# Phase 5 Batch B: src/app CMake Boundary Audit

**Status:** IN PROGRESS  
**Date:** 2026-03-22  
**Scope:** Audit `src/app/app.pro` vs `src/app/CMakeLists.txt` to identify migration gaps

## Executive Summary

- **Current State:** `src/app/CMakeLists.txt` is a SKELETON ONLY placeholder
- **qmake Status:** Authoritative build path for application
- **Complexity Level:** HIGH - Qt modules, resources, optional dependencies

## Audit Findings

### 1. Qt Modules

**Required (from app.pro):**
```qmake
QT += multimedia core gui svg opengl sql qml xml concurrent widgets
```

**Optional (feature-flagged):**
- `webenginewidgets` - controlled by `ENVE_USE_WEBENGINE`
  - Default: enabled (backwards compatibility)
  - Used for: SVG preview

**CMake Mapping:**
```cmake
find_package(Qt5 REQUIRED COMPONENTS
    Core Gui Svg OpenGL Sql Qml Xml Concurrent Multimedia Widgets
)
# Optional:
find_package(Qt5 COMPONENTS WebEngineWidgets)
```

### 2. Source Files

**Count:** 128 `.cpp` files in `src/app/`

**Key Categories:**
- `GUI/BoxesList/` - Box list widgets and scroll areas
- `GUI/BrushWidgets/` - Brush selection UI
- `GUI/ColorWidgets/` - Color pickers and palettes
- `GUI/Dialogs/` - Various dialogs
- `GUI/Expressions/` - Expression editor (QScintilla)
- `GUI/RenderWidgets/` - Render settings UI
- `GUI/Settings/` - Settings dialogs
- `GUI/Timeline*` - Timeline widgets
- Core app: `main.cpp`, `renderhandler.cpp`, `effectsloader.cpp`, etc.

### 3. Resources (.qrc files)

**Multiple resource files identified:**
- `resources.qrc` - main application resources
- `toolbarButtonsBg` - Toolbar button backgrounds
- `toolbarButtonsPlain` - Plain toolbar buttons
- `toolbarButtonsCheckable` - Checkable toolbar buttons
- `noInterpolation` - Interpolation icons
- `plain` - Plain icons
- `brushesClassic` - Classic brush presets
- `brushesDeevad` - Deevad brush presets
- `brushesDieterle` - Dieterle brush presets
- `brushesExperimental` - Experimental brushes
- `brushesKaerhon` - Kaerhon brush presets
- `brushesRamon` - Ramon brush presets
- `brushesTanda` - Tanda brush presets
- `tips` - Application tips

**CMake Impact:** Requires `CMAKE_AUTORCC ON` and careful `.qrc` path management

### 4. Optional Dependencies

#### QScintilla (ENVE_USE_QSCINTILLA)
- **Purpose:** Expression editor
- **qmake:**
  ```qmake
  DEFINES += QSCINTILLA_DLL
  INCLUDEPATH += $$QSCINTILLA_FOLDER
  LIBS += -L$$QSCINTILLA_FOLDER -lqscintilla2_qt5
  ```
- **CMake Mapping:**
  ```cmake
  find_package(QScintilla)
  target_compile_definitions(enve PRIVATE QSCINTILLA_DLL)
  target_link_libraries(enve PRIVATE QScintilla::QScintilla)
  ```

#### gperftools (ENVE_USE_GPERFTOOLS)
- **Purpose:** Memory allocator (tcmalloc)
- **qmake:**
  ```qmake
  INCLUDEPATH += $$GPERFTOOLS_FOLDER/include
  LIBS += -L$$GPERFTOOLS_FOLDER/.libs -ltcmalloc
  ```
- **CMake Mapping:**
  ```cmake
  find_package(PkgConfig)
  pkg_check_modules(GPERFTOOLS libtcmalloc)
  target_link_libraries(enve PRIVATE ${GPERFTOOLS_LIBRARIES})
  ```

### 5. Third-Party Dependencies (from core)

**Inherited via `core.pri`:**
- Skia (vendored)
- FFmpeg (system)
- libmypaint (vendored or system)
- QuaZip (vendored)

### 6. Platform-Specific Configuration

**Windows:**
```qmake
win32 {
    CONFIG -= debug_and_release
    RC_ICONS = pixmaps\enve.ico
}
```

**Unix/Linux:**
- gperftools configuration (see above)

### 7. Build Configuration

**C++ Standard:**
```qmake
CONFIG += c++14
```

**Definitions:**
```qmake
DEFINES += QT_NO_FOREACH
```

**Target:**
```qmake
TARGET = enve
TEMPLATE = app
```

## Recommended Migration Approach

### Phase 5 Batch B.1: Minimal Audit Output

1. **Document gap list** (this file) ✅
2. **Identify minimal future migration slice:**
   - Start with basic app target (no optional deps)
   - Add Qt modules incrementally
   - Defer resources to later batch
   - Keep qmake as authoritative path

### Phase 5 Batch B.2: Implementation (Deferred)

1. Create `src/app/CMakeLists.txt` with:
   - Basic executable target
   - Required Qt modules
   - Link to `envecore`
   - Optional dependency gates (WebEngine, QScintilla, gperftools)

2. Update root `CMakeLists.txt`:
   - Feature flag definitions
   - Optional dependency find_package calls

3. **DO NOT:**
   - Remove qmake
   - Add to CI matrix yet
   - Handle resources in first pass

### Phase 5 Batch B.3: Resource Handling (Deferred)

- Resources are complex and should be handled separately
- Recommend: separate batch after basic app target works

## Risk Assessment

| Risk Area | Level | Notes |
|-----------|-------|-------|
| Qt Modules | LOW | Standard CMake find_package |
| Source Files | MEDIUM | 128 files, need accurate list |
| Resources | HIGH | Multiple .qrc files, path complexity |
| QScintilla | MEDIUM | Vendored build complexity |
| gperftools | LOW | Optional, system package available |
| WebEngine | LOW | Optional, standard Qt module |
| Platform-specific | MEDIUM | Windows RC_ICONS, Unix gperftools |

## Out of Scope (This Batch)

- Full app implementation (Batch B.2+)
- Resource migration (Batch B.3+)
- CI integration for app
- Packaging
- Install layout

## Next Actions

1. ✅ Gap analysis complete
2. ⏳ Awaiting supervisory review before Batch B.2 implementation
3. ⏳ FFmpeg 7.x/8.x widening remains deferred

## Guardrails

- Keep qmake as authoritative release path
- Local builds only for now (-j3)
- No CI matrix expansion yet
- Do not start FFmpeg version widening until Batch B complete
