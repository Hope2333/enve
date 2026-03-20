# Build Output Organization

**Date:** 2026-03-20
**Phase:** 3 of 7
**Status:** PROPOSAL

## Current State

### Build Directory Structure

```
build/
├── AppDir/          # AppImage staging (unused in CI)
├── Debug/           # Debug builds (unused in CI)
└── Release/         # Release builds (active)
    ├── .qmake.stash # qmake cache
    ├── src/
    │   ├── app/
    │   │   └── enve          # Main executable
    │   └── core/
    │       └── libenvecore.so.a  # Core static library
    └── third_party/   # (not used - third_party builds in-place)
```

### Third-Party Build Outputs

```
third_party/
├── gperftools/
│   └── .libs/
│       ├── libtcmalloc.so
│       ├── libtcmalloc.a
│       └── ...
├── libmypaint/
│   └── .libs/
│       └── libmypaint.a
├── qscintilla/
│   └── Qt4Qt5/
│       └── libqscintilla2_qt5.a
├── quazip/
│   └── quazip/
│       └── libquazip.a
└── skia/
    └── out/
        └── Release/
            └── libskia.a
```

## Issues

### 1. Mixed Output Locations

**Problem:**
- Application builds: `build/Release/`
- Third-party builds: `third_party/*/.libs/` (in-place)
- Skia: `third_party/skia/out/Release/`

**Impact:**
- Hard to clean all build artifacts
- Inconsistent paths for CMake migration
- Difficult to relocate builds

### 2. No Build State Tracking

**Problem:**
- No stamp files to track build completion
- `make stage` always rebuilds third_party
- No incremental build detection

**Impact:**
- Wasted build time in CI
- No way to skip unchanged dependencies

### 3. qmake Cache Scattering

**Problem:**
- `.qmake.stash` in `build/Release/`
- No centralized cache location
- qmake re-runs on every invocation

## Recommendations

### 1. Centralize Third-Party Builds

**Proposal:**
Move all third-party builds to `build/third_party/`:

```
build/
└── third_party/
    ├── gperftools/
    │   ├── build/      # Build directory
    │   ├── install/    # Install prefix
    │   └── .stamp-built  # Build completion marker
    ├── libmypaint/
    ├── qscintilla/
    ├── quazip/
    └── skia/
```

**Benefits:**
- Single cleanup target
- Consistent paths for CMake
- Easy to relocate or cache

**Migration:**
1. Add new build rules to `third_party/Makefile`
2. Keep old paths as fallback during transition
3. Update include/library paths in qmake files

### 2. Add Stamp Files for Incremental Builds

**Proposal:**
Use stamp files to track build state:

```makefile
# In third_party/Makefile

STAMP_DIR := $(BUILD_DIR)/stamps

$(STAMP_DIR)/gperftools-built: $(GPERFTOOLS_SOURCES)
	@echo "Building gperftools..."
	$(BUILD_GPERFTOOLS)
	@touch $@

gperftools: $(STAMP_DIR)/gperftools-built

clean-gperftools:
	rm -f $(STAMP_DIR)/gperftools-built
	rm -rf $(BUILD_DIR)/third_party/gperftools/*
```

**Benefits:**
- Skip unchanged dependencies
- Faster CI builds
- Clear build state

### 3. Centralize qmake Cache

**Proposal:**
Move all qmake cache to single location:

```
build/
└── .qmake/
    ├── app.stash
    ├── core.stash
    └── third_party.stash
```

**Implementation:**
```makefile
# In Makefile
QMAKE_CACHE_DIR := $(BUILD_DIR)/.qmake

build-enve:
	cd $(BUILD_DIR) && \
		qmake -cache $(QMAKE_CACHE_DIR) ../../enve.pro
```

### 4. Document Library Linkage

**Proposal:**
Create dependency diagram:

```
enve (executable)
├── libenvecore.a (static)
│   ├── Skia
│   ├── libmypaint
│   ├── FFmpeg
│   ├── Qt5 (Core, Gui, Svg, OpenGL, Sql, Qml, Xml, Concurrent, Multimedia)
│   ├── OpenMP (optional)
│   ├── gperftools (optional)
│   └── System (ZLIB, PNG, Freetype, Fontconfig, Threads)
├── QScintilla (optional)
└── Qt WebEngine (optional)
```

**File:** `docs/modernization/library-linkage.md`

## Implementation Priority

1. **High Priority:**
   - Add stamp files for third_party builds
   - Document library linkage

2. **Medium Priority:**
   - Centralize third_party build output
   - Update Makefile with new paths

3. **Low Priority:**
   - Centralize qmake cache
   - Clean up old build paths

## CMake Integration

These improvements will benefit CMake migration:

1. **Stamp files** → CMake's built-in dependency tracking
2. **Centralized output** → `CMAKE_ARCHIVE_OUTPUT_DIRECTORY`, `CMAKE_LIBRARY_OUTPUT_DIRECTORY`
3. **Documented linkage** → `target_link_libraries` in CMakeLists.txt

## References

- [Phase 3 Toolchain Survey](phase-3-toolchain-survey.md)
- [Feature Flag Semantics](feature-flag-semantics.md)
- [Phased Backlog](phased-backlog.md)
