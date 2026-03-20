# Library Linkage Documentation

**Date:** 2026-03-20
**Phase:** 3 of 7
**Status:** COMPLETE

## Purpose

This document describes the library linkage for enve. It serves as a reference for:
- Build system maintenance (qmake, Makefile)
- CMake migration planning
- Dependency troubleshooting
- Binary size optimization

## Dependency Graph

```
enve (executable)
│
├── libenvecore.a (static library)
│   │
│   ├── Skia (graphics engine)
│   │   └── System: ICU, HarfBuzz, WebP, JPEG, PNG, etc.
│   │
│   ├── libmypaint (brush engine)
│   │   └── System: GLib
│   │
│   ├── FFmpeg (media codec)
│   │   ├── libavcodec
│   │   ├── libavformat
│   │   ├── libavutil
│   │   ├── libswscale
│   │   └── libswresample
│   │
│   ├── Qt5 Modules
│   │   ├── Core (required)
│   │   ├── Gui (required)
│   │   ├── Svg (required)
│   │   ├── OpenGL (required)
│   │   ├── Sql (required)
│   │   ├── Qml (required)
│   │   ├── Xml (required)
│   │   ├── Concurrent (required)
│   │   └── Multimedia (required)
│   │
│   ├── OpenMP (optional, ENVE_USE_OPENMP)
│   │
│   ├── gperftools (optional, ENVE_USE_GPERFTOOLS)
│   │   └── libtcmalloc
│   │
│   └── System Libraries
│       ├── ZLIB
│       ├── PNG (libpng)
│       ├── Freetype
│       ├── Fontconfig
│       ├── Threads (pthread)
│       └── DL (dynamic loading)
│
├── QScintilla (optional, ENVE_USE_QSCINTILLA)
│   └── Qt5::Widgets
│
└── Qt WebEngineWidgets (optional, ENVE_USE_WEBENGINE)
    ├── Qt5::WebEngine
    └── Qt5::WebChannel
```

## Required Dependencies

### Skia

| Attribute | Value |
|-----------|-------|
| Type | Vendored (pinned) |
| Location | `third_party/skia/` |
| Build System | GN/Ninja |
| Library | `third_party/skia/out/Release/libskia.a` |
| Headers | `third_party/skia/include/` |
| Link Type | Static |

**Dependencies:**
- ICU (Unicode)
- HarfBuzz (text shaping)
- WebP, JPEG, PNG (image codecs)
- OpenGL, EGL (GPU backend)

**qmake:**
```qmake
INCLUDEPATH += $$SKIA_FOLDER
LIBS += -L$$SKIA_FOLDER/out/Release -lskia
```

**CMake:**
```cmake
target_include_directories(envecore PRIVATE ${SKIA_INCLUDE_DIR})
target_link_libraries(envecore PRIVATE ${SKIA_LIBRARY})
```

---

### libmypaint

| Attribute | Value |
|-----------|-------|
| Type | Vendored or System |
| Location | `third_party/libmypaint/` or system |
| Build System | Autotools |
| Library | `.libs/libmypaint.a` |
| Headers | Root directory |
| Link Type | Static |
| Feature Flag | `ENVE_USE_SYSTEM_LIBMYPAINT` |

**Dependencies:**
- GLib 2.0
- JSON-C

**qmake:**
```qmake
# Vendored
INCLUDEPATH += $$LIBMYPAINT_FOLDER
LIBS += -L$$LIBMYPAINT_FOLDER/.libs -lmypaint

# System
LIBS += -lmypaint
```

**CMake:**
```cmake
# Vendored
target_include_directories(envecore PRIVATE ${LIBMYPAINT_SOURCE_DIR})
target_link_libraries(envecore PRIVATE ${LIBMYPAINT_LIBRARY})

# System (pkg-config)
pkg_check_modules(MYPAINT REQUIRED libmypaint)
target_include_directories(envecore PRIVATE ${MYPAINT_INCLUDE_DIRS})
target_link_libraries(envecore PRIVATE ${MYPAINT_LIBRARIES})
```

---

### FFmpeg

| Attribute | Value |
|-----------|-------|
| Type | System packages |
| Location | System paths |
| Build System | N/A |
| Libraries | libavcodec, libavformat, libavutil, libswscale, libswresample |
| Headers | System include paths |
| Link Type | Shared |

**Dependencies:**
- None (self-contained)

**qmake:**
```qmake
LIBS += -lavutil -lavformat -lavcodec -lswscale -lswresample
```

**CMake:**
```cmake
pkg_check_modules(FFMPEG REQUIRED
    libavcodec
    libavformat
    libavutil
    libswscale
    libswresample
)
target_link_libraries(envecore PRIVATE ${FFMPEG_LIBRARIES})
```

---

### Qt5 Modules

| Module | Required | Purpose |
|--------|----------|---------|
| Core | ✅ | Basic Qt functionality |
| Gui | ✅ | GUI components, painting |
| Svg | ✅ | SVG rendering |
| OpenGL | ✅ | OpenGL integration |
| Sql | ✅ | SQL database access |
| Qml | ✅ | QML engine |
| Xml | ✅ | XML parsing |
| Concurrent | ✅ | Threading, parallel algorithms |
| Multimedia | ✅ | Audio/video playback |
| WebEngineWidgets | ⏸️ Optional | SVG preview (ENVE_USE_WEBENGINE) |

**qmake:**
```qmake
QT += core gui svg opengl sql qml xml concurrent multimedia
QT += webenginewidgets  # Optional
```

**CMake:**
```cmake
find_package(Qt5 REQUIRED COMPONENTS
    Core Gui Svg OpenGL Sql Qml Xml Concurrent Multimedia
)
# Optional
if(ENVE_USE_WEBENGINE)
    find_package(Qt5 REQUIRED COMPONENTS WebEngineWidgets)
endif()
```

---

## Optional Dependencies

### gperftools (ENVE_USE_GPERFTOOLS)

| Attribute | Value |
|-----------|-------|
| Type | Vendored |
| Location | `third_party/gperftools/` |
| Build System | Autotools |
| Library | `.libs/libtcmalloc.so` or `.a` |
| Purpose | Memory profiling, optimized allocation |
| Default | Enabled (1) |

**qmake:**
```qmake
equals(ENVE_USE_GPERFTOOLS, 1) {
    INCLUDEPATH += $$GPERFTOOLS_FOLDER/include
    LIBS += -L$$GPERFTOOLS_FOLDER/.libs -ltcmalloc
}
```

---

### OpenMP (ENVE_USE_OPENMP)

| Attribute | Value |
|-----------|-------|
| Type | Compiler feature |
| Provider | GCC/Clang (`-fopenmp`), MSVC (`-openmp`) |
| Purpose | Parallel paint operations |
| Default | Enabled (1) |

**qmake:**
```qmake
equals(ENVE_USE_OPENMP, 1) {
    QMAKE_CXXFLAGS += -fopenmp
    LIBS += -fopenmp
}
```

---

### QScintilla (ENVE_USE_QSCINTILLA)

| Attribute | Value |
|-----------|-------|
| Type | Vendored |
| Location | `third_party/qscintilla/Qt4Qt5/` |
| Build System | qmake |
| Library | `libqscintilla2_qt5.a` |
| Purpose | Script/expression editor autocompletion |
| Default | Enabled (1) |

---

### Qt WebEngine (ENVE_USE_WEBENGINE)

| Attribute | Value |
|-----------|-------|
| Type | System package |
| Module | Qt5::WebEngineWidgets |
| Purpose | SVG preview pane |
| Default | Enabled (1) |

---

## System Libraries

| Library | Purpose | pkg-config Name |
|---------|---------|-----------------|
| ZLIB | Compression | zlib |
| PNG | PNG images | libpng |
| Freetype | Font rendering | freetype2 |
| Fontconfig | Font discovery | fontconfig |
| Threads (pthread) | Threading | (built-in) |
| DL | Dynamic loading | (built-in) |
| GLib 2.0 | libmypaint dependency | glib-2.0 |
| JSON-C | libmypaint dependency | json-c |

---

## Link Order (qmake)

qmake handles link order automatically for most cases. The order in `.pro` files:

1. Qt modules (`QT += ...`)
2. Third-party libraries (`LIBS += -L... -l...`)
3. System libraries (`LIBS += -lz -lpng ...`)

## Link Order (CMake)

CMake handles transitive dependencies automatically:

```cmake
target_link_libraries(envecore PUBLIC
    Qt5::Core
    Qt5::Gui
    # ... other Qt modules
    Skia
    ${FFMPEG_LIBRARIES}
    ZLIB::ZLIB
    PNG::PNG
    # ... system libraries
)
```

---

## Platform-Specific Notes

### Linux

- All dependencies available via system packages
- Recommended for CI/CD
- Default target platform

### macOS

- Some dependencies require Homebrew
- libmypaint: `brew install libmypaint`
- gperftools: `brew install gperftools`

### Windows

- Vendored dependencies only
- FFmpeg from pre-built binaries
- Skia pre-built for Windows

---

## References

- [Phase 3 Toolchain Survey](phase-3-toolchain-survey.md)
- [Feature Flag Semantics](feature-flag-semantics.md)
- [Build Output Organization](build-output-organization.md)
