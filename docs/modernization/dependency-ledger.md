# Dependency Ledger

## Purpose

This ledger records the current build and runtime dependencies, their coupling level, and the recommended first modernization action. It is meant to guide sequencing, not to force immediate upgrades.

## Build and CI Dependencies

| Dependency | Evidence | Current role | Coupling | Recommended first action |
| --- | --- | --- | --- | --- |
| Travis CI | `.travis.yml` | Legacy Linux/macOS build and packaging orchestration | High | Replace with GitHub Actions or equivalent before version upgrades |
| GitHub Actions | `.github/workflows/linux-baseline.yml` | Current Linux baseline recovery lane | High | Manual `master` validation is done; now prove that a normal non-manual event actually executes `Build (Linux)` before closing Phase 1 |
| qmake | `enve.pro`, `src/src.pro`, `src/app/app.pro`, `src/core/core.pro` | Primary build generator | High | Keep during baseline recovery; extract target and feature boundaries before any CMake migration |
| Historical Qt 5.12.4 lane | `.travis.yml`, `Source and building info.md` | Legacy documented UI/runtime baseline | High | Replace legacy documentation with the recovered Ubuntu 22.04 distro Qt 5.15.x reference lane |
| Historical `g++-7` / old macOS toolchain | `.travis.yml`, `Source and building info.md` | Legacy documented compiler baseline | Medium | Replace legacy documentation with the recovered Ubuntu 22.04 distro compiler lane before broader upgrades |
| Python 3 with legacy vendor scripts | `scripts/ci/build-linux-baseline.sh`, `third_party/skia/gn/is_clang.py`, `third_party/skia/third_party/externals/icu/scripts/make_data_assembly.py` | Skia dependency sync and ICU data generation during bootstrap | Medium | Keep the script-side compatibility shims until vendored sources are either updated or isolated from the bootstrap path |

## Vendored Third-Party Dependencies

| Dependency | Evidence | Used for | Coupling | Recommended first action | Status |
| --- | --- | --- | --- | --- | --- |
| Skia | `.gitmodules`, `src/core/core.pri`, `src/core/canvas.cpp`, `src/app/GUI/glwindow.cpp` | Core rendering, path ops, image and GPU surfaces | Very high | Keep vendored and pinned until the baseline build and CI are stable | ✅ Pinned |
| libmypaint | `.gitmodules`, `src/core/libmypaintincludes.h`, `src/core/Paint/`, `src/app/brushes/` | Brush engine and bundled brush presets | Very high | Keep vendored; document exact ABI/build assumptions before any upgrade | ✅ Pinned |
| QuaZip | `.gitmodules`, `src/core/zipfileloader.cpp`, `src/core/zipfilesaver.cpp` | Zip-backed file I/O | Medium | Candidate to replace with a maintained package source after CI is restored | ✅ Pinned |
| QScintilla | `.gitmodules`, `src/app/GUI/Expressions/expressiondialog.cpp` | Script/expression editor autocompletion | Low to medium | Treat as an optional UI feature and add an explicit build boundary | 🔄 `ENVE_USE_QSCINTILLA` flag added |
| gperftools / tcmalloc | `.gitmodules`, `third_party/Makefile`, `src/app/memorychecker.cpp` | Memory stats and allocator tuning on Unix | Medium | Make optional behind a build flag | ✅ `ENVE_USE_GPERFTOOLS` flag added |

## System and Feature Dependencies

| Dependency | Evidence | Used for | Coupling | Recommended first action | Status |
| --- | --- | --- | --- | --- | --- |
| FFmpeg | `src/app/app.pro`, `src/core/core.pro`, `src/app/videoencoder.cpp`, `src/core/FileCacheHandlers/` | Audio/video decode and encode | High | Pin a known working version and record API assumptions before any upgrade | ✅ Pinned |
| Qt WebEngineWidgets | `src/app/app.pro`, `src/app/GUI/Dialogs/exportsvgdialog.cpp` | SVG preview UI | Low, but heavy to package | Add a feature flag before any Qt 6 spike | 🔄 `ENVE_USE_WEBENGINE` flag added |
| OpenMP | `src/core/core.pri`, `src/core/Paint/drawableautotiledsurface.cpp`, `src/core/Paint/autotiledsurface.cpp` | Paint-path parallelism | Medium | Make the toggle explicit in qmake now | 🔄 `ENVE_USE_OPENMP` flag added |
| GLib, json-c, fontconfig, freetype, libpng | `src/core/core.pri` | Linux-side native support for current rendering/paint stack | Medium | Pin in the baseline environment first | ✅ Pinned |
| Examples | `src/app/app.pro` | Sample effects and boxes | Low | Already has `ENVE_BUILD_EXAMPLES` flag | ✅ `ENVE_BUILD_EXAMPLES` flag exists |

## Immediate Priorities

1. ✅ Phase 1 COMPLETE - Automatic Build (Linux) on push proven (run `23306463704`)
2. ✅ Multi-Distro Build working (run `23310875934`)
3. ✅ Dependency boundaries started:
   - `ENVE_USE_GPERFTOOLS` flag added to `src/app/app.pro` and `Makefile`
   - `ENVE_USE_WEBENGINE` flag added to `Makefile`
   - `ENVE_USE_QSCINTILLA` flag added to `Makefile`
   - `ENVE_USE_OPENMP` flag added to `Makefile`
   - `ENVE_BUILD_EXAMPLES` flag already existed
4. Next: Apply flags to remaining `.pro` files (`core.pri`)
5. Do NOT start CMake or Qt 6 work until all feature flags are in place
