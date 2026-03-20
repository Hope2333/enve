# Dependency Ledger

## Purpose

This ledger records the current build and runtime dependencies, their coupling level, and the recommended first modernization action. It is meant to guide sequencing, not to force immediate upgrades.

## Build and CI Dependencies

| Dependency | Evidence | Current role | Coupling | Recommended first action |
| --- | --- | --- | --- | --- |
| Travis CI | `.travis.yml` | Legacy Linux/macOS build and packaging orchestration | High | Replace with GitHub Actions or equivalent before version upgrades |
| GitHub Actions | `.github/workflows/linux-baseline.yml` | Current Linux baseline and Phase 2 validation lane | High | Automatic `master` push builds are proven; use the branch-side matrix to validate feature-boundary work without letting package fallout silently redefine the phase |
| qmake | `enve.pro`, `src/src.pro`, `src/app/app.pro`, `src/core/core.pro` | Primary build generator | High | Keep during baseline recovery; extract target and feature boundaries before any CMake migration |
| Historical Qt 5.12.4 lane | `.travis.yml`, `Source and building info.md` | Legacy documented UI/runtime baseline | High | Replace legacy documentation with the recovered Ubuntu 22.04 distro Qt 5.15.x reference lane |
| Historical `g++-7` / old macOS toolchain | `.travis.yml`, `Source and building info.md` | Legacy documented compiler baseline | Medium | Replace legacy documentation with the recovered Ubuntu 22.04 distro compiler lane before broader upgrades |
| Python 3 with legacy vendor scripts | `scripts/ci/build-linux-baseline.sh`, `third_party/skia/gn/is_clang.py`, `third_party/skia/third_party/externals/icu/scripts/make_data_assembly.py` | Skia dependency sync and ICU data generation during bootstrap | Medium | Keep the script-side compatibility shims until vendored sources are either updated or isolated from the bootstrap path |

## Vendored Third-Party Dependencies

| Dependency | Evidence | Used for | Coupling | Recommended first action | Status |
| --- | --- | --- | --- | --- | --- |
| Skia | `.gitmodules`, `src/core/core.pri`, `src/core/canvas.cpp`, `src/app/GUI/glwindow.cpp` | Core rendering, path ops, image and GPU surfaces | Very high | Keep vendored and pinned until the baseline build and CI are stable | ✅ Pinned |
| libmypaint | `.gitmodules`, `src/core/libmypaintincludes.h`, `src/core/Paint/`, `src/app/brushes/` | Brush engine and bundled brush presets | Very high | Keep vendored by default; the new system-lib flag should stay a CI/packaging escape hatch until baseline policy is explicit | ✅ Vendored by default, system flag added |
| QuaZip | `.gitmodules`, `src/core/zipfileloader.cpp`, `src/core/zipfilesaver.cpp` | Zip-backed file I/O | Medium | Candidate to replace with a maintained package source after CI is restored | ✅ Pinned |
| QScintilla | `.gitmodules`, `src/app/GUI/Expressions/expressiondialog.cpp` | Script/expression editor autocompletion | Low to medium | Treat as an optional UI feature and add an explicit build boundary | ✅ `ENVE_USE_QSCINTILLA` flag added (app.pro + Makefile) |
| gperftools / tcmalloc | `.gitmodules`, `third_party/Makefile`, `src/app/memorychecker.cpp` | Memory stats and allocator tuning on Unix | Medium | Make optional behind a build flag | ✅ `ENVE_USE_GPERFTOOLS` flag added (app.pro + Makefile) |

## System and Feature Dependencies

| Dependency | Evidence | Used for | Coupling | Recommended first action | Status |
| --- | --- | --- | --- | --- | --- |
| FFmpeg | `src/app/app.pro`, `src/core/core.pro`, `src/app/videoencoder.cpp`, `src/core/FileCacheHandlers/` | Audio/video decode and encode | High | Pin a known working version and record API assumptions before any upgrade | ✅ Pinned |
| Qt WebEngineWidgets | `src/app/app.pro`, `src/app/GUI/Dialogs/exportsvgdialog.cpp` | SVG preview UI | Low, but heavy to package | Add a feature flag before any Qt 6 spike | ✅ `ENVE_USE_WEBENGINE` flag added (app.pro + Makefile) |
| OpenMP | `src/core/core.pri`, `src/core/Paint/drawableautotiledsurface.cpp`, `src/core/Paint/autotiledsurface.cpp` | Paint-path parallelism | Medium | Make the toggle explicit in qmake now | ✅ `ENVE_USE_OPENMP` flag added (core.pri + Makefile) |
| GLib, json-c, fontconfig, freetype, libpng | `src/core/core.pri` | Linux-side native support for current rendering/paint stack | Medium | Pin in the baseline environment first | ✅ Pinned |
| Examples | `src/app/app.pro` | Sample effects and boxes | Low | Already has `ENVE_BUILD_EXAMPLES` flag | ✅ `ENVE_BUILD_EXAMPLES` flag exists |

## Immediate Priorities

1. Phase 1 is complete: automatic `master` push build proven by run `23306463704`.
2. Phase 2 implementation is present on the branch and is being validated in run `23324646178`.
3. Immediate branch-side concern: determine whether packaging failures remain inside the Phase 2 exit gate or move to a narrower follow-up lane.
4. Document the flags, defaults, and ownership before merge:
   - `ENVE_USE_GPERFTOOLS`
   - `ENVE_USE_WEBENGINE`
   - `ENVE_USE_QSCINTILLA`
   - `ENVE_USE_OPENMP`
   - `ENVE_BUILD_EXAMPLES`
   - `ENVE_USE_SYSTEM_LIBMYPAINT`
5. Do not start CMake or Qt 6 work until the feature-boundary work is merged and the default baseline remains stable.
