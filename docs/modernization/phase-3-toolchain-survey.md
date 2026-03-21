# Phase 3: Toolchain Consolidation Survey

**Date:** 2026-03-20
**Status:** COMPLETE
**Phase:** 3 of 7

## Purpose

This document surveys the current toolchain state after Phase 2 completion. It identifies consolidation opportunities and documents toolchain assumptions for future CMake migration.

## Current Toolchain State

### Build Systems

| System | Files | Purpose | Status |
|--------|-------|---------|--------|
| qmake | `enve.pro`, `src/src.pro`, `src/app/app.pro`, `src/core/core.pro`, `src/core/core.pri` | Primary build generator | ✅ Active |
| Makefile | `Makefile`, `third_party/Makefile` | Orchestration and packaging | ✅ Active |
| GN/Ninja | `third_party/skia/` | Skia build system | ✅ Vendored |

### QMake Structure

```
enve.pro (TEMPLATE = subdirs)
└── src/
    └── src.pro (TEMPLATE = subdirs)
        ├── core/ (core.pro + core.pri)
        ├── app/ (app.pro)
        ├── colorwidgetshaders/
        └── shaders/
```

**Key observations:**
- Two-level subdirs template
- `core.pri` contains most configuration logic
- `app.pro` includes `../core/core.pri`
- Feature flags passed via qmake command line: `ENVE_USE_*`

### Makefile Orchestration

**Top-level targets:**
- `all` - Build and package (deb + pkg)
- `build` - Build enve + third_party
- `runtime` - Prepare build environment
- `stage` - Build third_party + enve
- `package-deb` - Create .deb package
- `package-pkg` - Create .pkg.tar.gz package
- `clean` - Clean build artifacts

**Feature flag integration:**
```makefile
ENVE_USE_GPERFTOOLS ?= 1
ENVE_USE_WEBENGINE ?= 1
ENVE_USE_QSCINTILLA ?= 1
ENVE_USE_OPENMP ?= 1
ENVE_BUILD_EXAMPLES ?= 0
ENVE_USE_SYSTEM_LIBMYPAINT ?= 0
```

**QMake invocation:**
```makefile
qmake CONFIG+=release \
    ENVE_USE_GPERFTOOLS=$(ENVE_USE_GPERFTOOLS) \
    ENVE_USE_WEBENGINE=$(ENVE_USE_WEBENGINE) \
    ENVE_USE_QSCINTILLA=$(ENVE_USE_QSCINTILLA) \
    ENVE_USE_OPENMP=$(ENVE_USE_OPENMP) \
    ENVE_BUILD_EXAMPLES=$(ENVE_BUILD_EXAMPLES) \
    ../../enve.pro
```

### Third-Party Build Systems

| Dependency | Build System | Location | Notes |
|------------|--------------|----------|-------|
| Skia | GN/Ninja | `third_party/skia/` | Vendored, custom patches |
| libmypaint | Autotools | `third_party/libmypaint/` | Vendored, requires autogen |
| QuaZip | qmake | `third_party/quazip/` | Vendored |
| QScintilla | qmake | `third_party/qscintilla/` | Vendored |
| gperftools | Autotools | `third_party/gperftools/` | Vendored, patched |

## Toolchain Assumptions

### Skia

**Version:** Vendored (pinned in third_party)
**Build requirements:**
- Python 3 with specific versions for bootstrap scripts
- GN binary (bundled)
- Ninja (bundled or system)

**Known issues:**
- Python 3 compatibility patches in `third_party/skia/gn/is_clang.py`
- ICU `make_data_assembly.py` compatibility

**Include paths:**
```
$$SKIA_FOLDER/include
$$SKIA_FOLDER/include/gpu/
$$SKIA_FOLDER/include/core/
```

**Library linkage:**
```
-L$$SKIA_FOLDER/out/Release -lskia
# or
-L$$SKIA_FOLDER/out/Debug -lskia
```

### libmypaint

**Version:** Vendored (pinned in third_party)
**Build requirements:**
- Autotools (autoconf, automake, libtool)
- intltool
- Version check: automake >= 1.13

**Build process:**
```bash
./autogen.sh
./configure --enable-static --enable-shared=false
make
```

**Generated files:**
- `mypaint-brush-settings-gen.h` (from brushsettings.json)

**Include paths:**
```
$$LIBMYPAINT_FOLDER/
$$LIBMYPAINT_FOLDER/.libs/  # for static library
```

**System package alternative:**
```bash
# Ubuntu/Debian
apt-get install libmypaint-dev

# Arch
pacman -S libmypaint
```

**Feature flag:** `ENVE_USE_SYSTEM_LIBMYPAINT`

### FFmpeg

**Version:** System packages (CI) or vendored (Windows)
**Build requirements:**
- Development headers: `libavcodec-dev`, `libavformat-dev`, etc.

**Library linkage:**
```
-lavutil -lavformat -lavcodec -lswscale -lswresample
```

### Qt

**Current baseline:** Qt 5.15.x (distro packages on Ubuntu 22.04)
**Required modules:**
- core
- gui
- svg
- opengl
- sql
- qml
- xml
- concurrent
- multimedia
- webenginewidgets (optional, Phase 2)

**Optional modules:**
- webenginewidgets (ENVE_USE_WEBENGINE)

### QScintilla

**Version:** Vendored (pinned in third_party)
**Build system:** qmake
**Location:** `third_party/qscintilla/Qt4Qt5/`

**Feature flag:** `ENVE_USE_QSCINTILLA`

### gperftools

**Version:** Vendored (pinned in third_party)
**Build system:** Autotools
**Patches:** `gperftools-enve-mod.patch`

**Feature flag:** `ENVE_USE_GPERFTOOLS`

### OpenMP

**Provider:** System compiler (gcc/clang)
**Flags:** `-fopenmp` (Linux), `-openmp` (Windows)

**Feature flag:** `ENVE_USE_OPENMP`

## Consolidation Opportunities

### 1. Feature Flag Consistency

**Current state:**
- Flags defined in Makefile
- Passed to qmake via command line
- Read in `.pro`/`.pri` files via `$$[FLAG_NAME]`

**Issue:** No validation of flag values, silent fallback to defaults

**Recommendation:**
- Add flag validation in qmake
- Document all flags in a single location
- Consider `config.pri` for flag documentation

### 2. Build Output Organization

**Current state:**
- `build/Release/` - Release builds
- `build/Debug/` - Debug builds (not used in CI)
- Third-party builds in `third_party/*/`

**Issue:** Mixed output locations, hard to clean

**Recommendation:**
- Centralize all build outputs under `build/`
- Separate third-party build directories
- Add `make clean-all` for complete cleanup

### 3. Third-Party Build Caching

**Current state:**
- Third-party rebuilt on every `make stage`
- No incremental build detection

**Recommendation:**
- Add stamp files to track build state
- Skip rebuild if source unchanged
- Consider pre-built third-party for CI

### 4. Include Path Management

**Current state:**
- Scattered across `.pro` and `.pri` files
- Some paths relative, some absolute

**Issue:** Hard to audit, potential conflicts

**Recommendation:**
- Centralize include paths in `core.pri`
- Document all external dependencies
- Add include path validation

### 5. Library Linkage Documentation

**Current state:**
- LIBS defined in multiple files
- Some conditional on platform

**Recommendation:**
- Document all library dependencies
- Separate required vs optional
- Add linkage diagram

## CMake Migration Preparation

### Recommended CMake Structure

```
CMakeLists.txt (root)
├── cmake/
│   ├── FindSkia.cmake
│   ├── FindLibmypaint.cmake
│   └── FeatureFlags.cmake
├── src/
│   ├── CMakeLists.txt
│   ├── core/
│   │   └── CMakeLists.txt
│   └── app/
│       └── CMakeLists.txt
└── third_party/
    └── CMakeLists.txt (optional, or use FetchContent)
```

### Feature Flags in CMake

```cmake
option(ENVE_USE_GPERFTOOLS "Enable gperftools support" ON)
option(ENVE_USE_WEBENGINE "Enable Qt WebEngine preview" ON)
option(ENVE_USE_QSCINTILLA "Enable QScintilla editor" ON)
option(ENVE_USE_OPENMP "Enable OpenMP parallelism" ON)
option(ENVE_BUILD_EXAMPLES "Build example effects" OFF)
option(ENVE_USE_SYSTEM_LIBMYPAINT "Use system libmypaint" OFF)
```

### Migration Order

1. `src/core/` first (library, no UI dependencies)
2. `src/app/` second (depends on core)
3. Examples last (optional)
4. Packaging scripts (adapt to new output structure)

## Next Steps

1. ✅ Complete toolchain survey (this document)
2. Document feature flag semantics
3. Create CMakeLists.txt skeleton for `src/core/`
4. Test CMake build alongside qmake
5. Document migration progress

## References

- [Repository AI Relay](../ai-relay.md)
- Active modernization AI relay/planning state: local-only `.ai/modernization/`
- [ADR 001](adr-001-build-and-dependency-modernization.md)
- [Feature Flag Semantics](feature-flag-semantics.md)
