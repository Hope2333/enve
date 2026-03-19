# Dependency Ledger

## Purpose

This ledger records the current build and runtime dependencies, their coupling level, and the recommended first modernization action. It is meant to guide sequencing, not to force immediate upgrades.

## Build and CI Dependencies

| Dependency | Evidence | Current role | Coupling | Recommended first action |
| --- | --- | --- | --- | --- |
| Travis CI | `.travis.yml` | Legacy Linux/macOS build and packaging orchestration | High | Replace with GitHub Actions or equivalent before version upgrades |
| GitHub Actions | `.github/workflows/linux-baseline.yml` | Current Linux baseline recovery lane | High | Keep the full compile job manual until one clean baseline build is reproducible |
| qmake | `enve.pro`, `src/src.pro`, `src/app/app.pro`, `src/core/core.pro` | Primary build generator | High | Keep during baseline recovery; migrate only after CI and smoke tests exist |
| Qt 5.12.4 | `.travis.yml`, `Source and building info.md` | UI/runtime foundation | High | Move to a supported Qt 5.15 lane before any Qt 6 work |
| `g++-7` / old macOS toolchain | `.travis.yml`, `Source and building info.md` | Compiler baseline | Medium | Raise compiler version in a compatibility phase without changing app architecture |
| Python 3 with legacy vendor scripts | `scripts/ci/build-linux-baseline.sh`, `third_party/skia/gn/is_clang.py`, `third_party/skia/third_party/externals/icu/scripts/make_data_assembly.py` | Skia dependency sync and ICU data generation during bootstrap | Medium | Patch or isolate the remaining Python 2 assumptions before widening CI coverage |

## Vendored Third-Party Dependencies

| Dependency | Evidence | Used for | Coupling | Recommended first action |
| --- | --- | --- | --- | --- |
| Skia | `.gitmodules`, `src/core/core.pri`, `src/core/canvas.cpp`, `src/app/GUI/glwindow.cpp` | Core rendering, path ops, image and GPU surfaces | Very high | Keep vendored and pinned until the baseline build and CI are stable |
| libmypaint | `.gitmodules`, `src/core/libmypaintincludes.h`, `src/core/Paint/`, `src/app/brushes/` | Brush engine and bundled brush presets | Very high | Keep vendored; document exact ABI/build assumptions before any upgrade |
| QuaZip | `.gitmodules`, `src/core/zipfileloader.cpp`, `src/core/zipfilesaver.cpp` | Zip-backed file I/O | Medium | Candidate to replace with a maintained package source after CI is restored |
| QScintilla | `.gitmodules`, `src/app/GUI/Expressions/expressiondialog.cpp` | Script/expression editor autocompletion | Low to medium | Treat as an optional UI feature; upgrade or replace later |
| gperftools / tcmalloc | `.gitmodules`, `third_party/Makefile`, `src/app/memorychecker.cpp` | Memory stats and allocator tuning on Unix | Medium | Make optional behind a build flag so the base app does not depend on it |

## System and Feature Dependencies

| Dependency | Evidence | Used for | Coupling | Recommended first action |
| --- | --- | --- | --- | --- |
| FFmpeg | `src/app/app.pro`, `src/core/core.pro`, `src/app/videoencoder.cpp`, `src/core/FileCacheHandlers/` | Audio/video decode and encode | High | Pin a known working version and record API assumptions before any upgrade |
| Qt WebEngineWidgets | `src/app/app.pro`, `src/app/GUI/Dialogs/exportsvgdialog.cpp` | SVG preview UI | Low, but heavy to package | Consider making the preview optional if packaging remains costly |
| OpenMP | `src/core/core.pri`, `src/core/Paint/drawableautotiledsurface.cpp`, `src/core/Paint/autotiledsurface.cpp` | Paint-path parallelism | Medium | Keep optional and ensure non-OpenMP fallback remains valid |
| GLib, json-c, fontconfig, freetype, libpng | `src/core/core.pri` | Linux-side native support for current rendering/paint stack | Medium | Pin in the baseline environment first; defer provider changes |

## Immediate Priorities

1. Build a reproducible Linux baseline image with the current qmake flow and third-party setup.
2. Get one green GitHub Actions Linux release build before changing dependency versions.
3. Mark optional dependencies explicitly: `gperftools`, OpenMP, and WebEngine preview are the best first candidates.
4. Upgrade the compiler and Qt within a Qt 5 compatibility lane before attempting CMake or Qt 6.
