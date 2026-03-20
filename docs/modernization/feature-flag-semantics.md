# Feature Flag Semantics

**Date:** 2026-03-20
**Phase:** 3 of 7
**Status:** DRAFT

## Purpose

This document defines the semantics for all feature flags in the enve build system. It covers validation, defaults, interactions, and documentation requirements.

## Flag Naming Convention

All feature flags follow this naming convention:
- Prefix: `ENVE_`
- Type: `USE_` for optional dependencies, `BUILD_` for optional components
- Name: Upper case with underscores (e.g., `GPERFTOOLS`, `EXAMPLES`)

**Examples:**
- `ENVE_USE_GPERFTOOLS` - Enable gperftools support
- `ENVE_BUILD_EXAMPLES` - Build example effects

## Flag Definitions

### ENVE_USE_GPERFTOOLS

**Type:** Optional dependency
**Default:** `1` (enabled)
**Location:** `Makefile`, `src/app/app.pro`, `src/core/core.pri`

**Purpose:**
Enable gperftools/tcmalloc for memory profiling and optimized allocation.

**Effect when enabled:**
- Includes gperftools headers from `third_party/gperftools/include`
- Links against `libtcmalloc` from `third_party/gperftools/.libs`
- Memory profiling features available at runtime

**Effect when disabled:**
- No gperftools headers included
- No tcmalloc linkage
- System malloc/free used instead
- Smaller binary size

**Validation:**
```qmake
GPERFTOOLS_ENABLED = $$[ENVE_USE_GPERFTOOLS]
isEmpty(GPERFTOOLS_ENABLED): GPERFTOOLS_ENABLED = 1
equals(GPERFTOOLS_ENABLED, 1) {
    # Enable gperftools
} else {
    # Disable gperftools
}
```

**Interactions:**
- None (independent flag)

**Platform support:**
- Linux: ✅ Supported
- macOS: ✅ Supported
- Windows: ❌ Not supported (vendored build only)

---

### ENVE_USE_OPENMP

**Type:** Optional dependency
**Default:** `1` (enabled)
**Location:** `Makefile`, `src/core/core.pri`

**Purpose:**
Enable OpenMP for parallel paint operations and image processing.

**Effect when enabled:**
- Adds `-fopenmp` (Linux) or `-openmp` (Windows) to compiler flags
- Links against OpenMP runtime (`libomp` or system OpenMP)
- Parallel paint surface operations

**Effect when disabled:**
- No OpenMP compiler flags
- Sequential paint operations
- May impact performance on multi-core systems

**Validation:**
```qmake
OPENMP_ENABLED = $$[ENVE_USE_OPENMP]
isEmpty(OPENMP_ENABLED): OPENMP_ENABLED = 1
equals(OPENMP_ENABLED, 1) {
    QMAKE_CXXFLAGS += -fopenmp
    LIBS += -fopenmp
}
```

**Interactions:**
- None (independent flag)

**Platform support:**
- Linux: ✅ Supported (gcc/clang)
- macOS: ✅ Supported (clang + libomp)
- Windows: ✅ Supported (MSVC + LLVM OpenMP)

---

### ENVE_USE_WEBENGINE

**Type:** Optional dependency
**Default:** `1` (enabled)
**Location:** `Makefile`, `src/app/app.pro`

**Purpose:**
Enable Qt WebEngine for SVG preview functionality.

**Effect when enabled:**
- Adds `webenginewidgets` to Qt modules
- SVG export dialog includes preview pane
- Requires Qt WebEngine libraries at runtime

**Effect when disabled:**
- No WebEngine module dependency
- SVG export dialog without preview
- Smaller runtime dependency footprint

**Validation:**
```qmake
WEBENGINE_ENABLED = $$[ENVE_USE_WEBENGINE]
isEmpty(WEBENGINE_ENABLED): WEBENGINE_ENABLED = 1
equals(WEBENGINE_ENABLED, 1) {
    QT += webenginewidgets
}
```

**Interactions:**
- None (independent flag)

**Platform support:**
- Linux: ✅ Supported (Qt 5.15+)
- macOS: ✅ Supported
- Windows: ✅ Supported

---

### ENVE_USE_QSCINTILLA

**Type:** Optional dependency
**Default:** `1` (enabled)
**Location:** `Makefile`, `src/app/app.pro`

**Purpose:**
Enable QScintilla for script/expression editor with autocompletion.

**Effect when enabled:**
- Includes QScintilla headers from `third_party/qscintilla/Qt4Qt5`
- Links against `libqscintilla2_qt5`
- Expression editor has autocompletion

**Effect when disabled:**
- No QScintilla dependency
- Expression editor without autocompletion
- Smaller binary and fewer dependencies

**Validation:**
```qmake
QSCINTILLA_ENABLED = $$[ENVE_USE_QSCINTILLA]
isEmpty(QSCINTILLA_ENABLED): QSCINTILLA_ENABLED = 1
equals(QSCINTILLA_ENABLED, 1) {
    DEFINES += QSCINTILLA_DLL
    INCLUDEPATH += $$QSCINTILLA_FOLDER
    LIBS += -L$$QSCINTILLA_FOLDER -lqscintilla2_qt5
}
```

**Interactions:**
- None (independent flag)

**Platform support:**
- Linux: ✅ Supported
- macOS: ✅ Supported
- Windows: ✅ Supported

---

### ENVE_BUILD_EXAMPLES

**Type:** Optional component
**Default:** `0` (disabled)
**Location:** `Makefile`, `enve.pro`

**Purpose:**
Build example effects and boxes for testing and demonstration.

**Effect when enabled:**
- Adds `examples` subdirectory to build
- Builds sample effects in `examples/` directory
- Useful for testing effect system

**Effect when disabled:**
- Examples not built
- Faster build time
- Smaller build output

**Validation:**
```qmake
# In enve.pro
build_examples {
    SUBDIRS += examples
    examples.depends = src
}
```

**Interactions:**
- Depends on `src` being built first
- Independent of other flags

**Platform support:**
- Linux: ✅ Supported
- macOS: ✅ Supported
- Windows: ✅ Supported

---

### ENVE_USE_SYSTEM_LIBMYPAINT

**Type:** Provider selection
**Default:** `0` (vendored)
**Location:** `Makefile`, `src/core/core.pri`

**Purpose:**
Select between vendored libmypaint and system-installed libmypaint.

**Effect when enabled (system):**
- Uses system libmypaint headers (`/usr/include`)
- Links against system libmypaint (`-lmypaint`)
- Required for CI packaging

**Effect when disabled (vendored):**
- Uses vendored libmypaint from `third_party/libmypaint`
- Links against vendored static library
- Consistent across platforms

**Validation:**
```qmake
USE_SYSTEM_LIBMYPAINT = $$[ENVE_USE_SYSTEM_LIBMYPAINT]
isEmpty(USE_SYSTEM_LIBMYPAINT): USE_SYSTEM_LIBMYPAINT = 0
equals(USE_SYSTEM_LIBMYPAINT, 1) {
    LIBS += -lmypaint
    message("Using system libmypaint")
} else {
    INCLUDEPATH += $$LIBMYPAINT_FOLDER
    LIBS += -L$$LIBMYPAINT_FOLDER/.libs -lmypaint
    message("Using vendored libmypaint")
}
```

**Interactions:**
- Affects third_party build requirements
- When enabled, libmypaint build can be skipped

**Platform support:**
- Linux: ✅ Supported (system packages available)
- macOS: ⚠️ Limited (Homebrew libmypaint)
- Windows: ❌ Not supported (vendored only)

---

## Flag Validation Rules

### qmake Validation

All flags are validated in qmake with this pattern:

```qmake
FLAG_ENABLED = $$[ENVE_USE_FLAG]
isEmpty(FLAG_ENABLED): FLAG_ENABLED = 1  # Default to enabled
equals(FLAG_ENABLED, 1) {
    # Enable feature
    message("Feature enabled")
} else {
    # Disable feature
    message("Feature disabled")
}
```

### Makefile Defaults

All flags have explicit defaults in the Makefile:

```makefile
ENVE_USE_GPERFTOOLS ?= 1
ENVE_USE_OPENMP ?= 1
ENVE_USE_WEBENGINE ?= 1
ENVE_USE_QSCINTILLA ?= 1
ENVE_BUILD_EXAMPLES ?= 0
ENVE_USE_SYSTEM_LIBMYPAINT ?= 0
```

### Flag Combinations

**Recommended combinations:**

| Use Case | GPERFTOOLS | OPENMP | WEBENGINE | QSCINTILLA | EXAMPLES | SYSTEM_LIBMYPAINT |
|----------|------------|--------|-----------|------------|----------|-------------------|
| Default desktop | 1 | 1 | 1 | 1 | 0 | 0 |
| Minimal build | 0 | 0 | 0 | 0 | 0 | 0 |
| CI packaging | 1 | 1 | 1 | 1 | 0 | 1 |
| Development | 1 | 1 | 1 | 1 | 1 | 0 |
| Performance testing | 1 | 1 | 0 | 0 | 0 | 0 |

**Invalid combinations:**
- None currently defined (all flags are independent)

---

## Documentation Requirements

### User-Facing Documentation

Users should be able to find:
1. List of all flags with descriptions
2. Default values
3. Effect of enabling/disabling
4. Platform support matrix
5. Recommended combinations

### Developer Documentation

Developers should document:
1. How to add new flags
2. Validation patterns
3. Interaction testing requirements
4. Deprecation process

---

## Adding New Flags

### Step 1: Define in Makefile

```makefile
ENVE_USE_NEWFEATURE ?= 1  # Default value
```

### Step 2: Add to qmake

In the appropriate `.pro` or `.pri` file:

```qmake
NEWFEATURE_ENABLED = $$[ENVE_USE_NEWFEATURE]
isEmpty(NEWFEATURE_ENABLED): NEWFEATURE_ENABLED = 1
equals(NEWFEATURE_ENABLED, 1) {
    # Enable feature
    message("New feature enabled")
} else {
    message("New feature disabled")
}
```

### Step 3: Update Documentation

- Add to this file (feature-flag-semantics.md)
- Update dependency-ledger.md
- Update README.md or BUILDING.md

### Step 4: Test

- Test with flag enabled (default)
- Test with flag disabled
- Test on all supported platforms
- Document any platform-specific behavior

---

## References

- [Phase 2 Roadmap](phase-2-roadmap.md)
- [Dependency Ledger](dependency-ledger.md)
- [Toolchain Survey](phase-3-toolchain-survey.md)
- [Phased Backlog](phased-backlog.md)
