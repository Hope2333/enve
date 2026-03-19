# Dependency Ledger

## Purpose

This ledger records the current build and runtime dependencies, their coupling level, and the recommended first modernization action. It is meant to guide sequencing, not to force immediate upgrades.

## Build and CI Dependencies

| Dependency | Evidence | Current role | Coupling | Recommended first action |
| --- | --- | --- | --- | --- |
| Travis CI | `.travis.yml` | Legacy Linux/macOS build and packaging orchestration | High | Replace with GitHub Actions or equivalent before version upgrades |
| GitHub Actions | `.github/workflows/linux-baseline.yml` | Current Linux baseline recovery lane | High | Validate the green baseline on `master`, then promote the Linux build from manual-only to automatic; do not treat PR-side `preflight` as equivalent evidence |
| qmake | `enve.pro`, `src/src.pro`, `src/app/app.pro`, `src/core/core.pro` | Primary build generator | High | Keep during baseline recovery; extract target and feature boundaries before any CMake migration |
| Historical Qt 5.12.4 lane | `.travis.yml`, `Source and building info.md` | Legacy documented UI/runtime baseline | High | Replace legacy documentation with the recovered Ubuntu 22.04 distro Qt 5.15.x reference lane |
| Historical `g++-7` / old macOS toolchain | `.travis.yml`, `Source and building info.md` | Legacy documented compiler baseline | Medium | Replace legacy documentation with the recovered Ubuntu 22.04 distro compiler lane before broader upgrades |
| Python 3 with legacy vendor scripts | `scripts/ci/build-linux-baseline.sh`, `third_party/skia/gn/is_clang.py`, `third_party/skia/third_party/externals/icu/scripts/make_data_assembly.py` | Skia dependency sync and ICU data generation during bootstrap | Medium | Keep the script-side compatibility shims until vendored sources are either updated or isolated from the bootstrap path |

## Vendored Third-Party Dependencies

| Dependency | Evidence | Used for | Coupling | Recommended first action |
| --- | --- | --- | --- | --- |
| Skia | `.gitmodules`, `src/core/core.pri`, `src/core/canvas.cpp`, `src/app/GUI/glwindow.cpp` | Core rendering, path ops, image and GPU surfaces | Very high | Keep vendored and pinned until the baseline build and CI are stable |
| libmypaint | `.gitmodules`, `src/core/libmypaintincludes.h`, `src/core/Paint/`, `src/app/brushes/` | Brush engine and bundled brush presets | Very high | Keep vendored; document exact ABI/build assumptions before any upgrade |
| QuaZip | `.gitmodules`, `src/core/zipfileloader.cpp`, `src/core/zipfilesaver.cpp` | Zip-backed file I/O | Medium | Candidate to replace with a maintained package source after CI is restored |
| QScintilla | `.gitmodules`, `src/app/GUI/Expressions/expressiondialog.cpp` | Script/expression editor autocompletion | Low to medium | Treat as an optional UI feature and add an explicit build boundary before any upgrade or replacement decision |
| gperftools / tcmalloc | `.gitmodules`, `third_party/Makefile`, `src/app/memorychecker.cpp` | Memory stats and allocator tuning on Unix | Medium | Make optional behind a build flag so the default base app does not depend on it |

## System and Feature Dependencies

| Dependency | Evidence | Used for | Coupling | Recommended first action |
| --- | --- | --- | --- | --- |
| FFmpeg | `src/app/app.pro`, `src/core/core.pro`, `src/app/videoencoder.cpp`, `src/core/FileCacheHandlers/` | Audio/video decode and encode | High | Pin a known working version and record API assumptions before any upgrade |
| Qt WebEngineWidgets | `src/app/app.pro`, `src/app/GUI/Dialogs/exportsvgdialog.cpp` | SVG preview UI | Low, but heavy to package | Add a feature flag before any Qt 6 spike so preview can be removed from the base lane if needed |
| OpenMP | `src/core/core.pri`, `src/core/Paint/drawableautotiledsurface.cpp`, `src/core/Paint/autotiledsurface.cpp` | Paint-path parallelism | Medium | Make the toggle explicit in qmake now and preserve a valid non-OpenMP fallback for future CMake work |
| GLib, json-c, fontconfig, freetype, libpng | `src/core/core.pri` | Linux-side native support for current rendering/paint stack | Medium | Pin in the baseline environment first; defer provider changes |

## Immediate Priorities

1. Validate the first green Linux baseline build on `master`.
2. Promote the Linux build lane from manual-only to routine CI after `master` validation succeeds.
3. Record the recovered Ubuntu 22.04 + distro Qt 5.15.x lane as the reference baseline, including compiler, qmake, and smoke expectations.
4. Make dependency boundaries explicit before broader modernization: `gperftools`, WebEngine preview, QScintilla, OpenMP, and examples are the best first candidates.
5. Do not start CMake or Qt 6 work until the feature boundary work has reduced the default build surface.
