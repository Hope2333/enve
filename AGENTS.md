# Repository Guidelines

## Project Structure & Module Organization
`src/app/` contains the Qt desktop application, UI, import/export flow, and platform-specific startup code. `src/core/` contains the reusable animation engine and rendering logic; public headers for downstream consumers live in `include/enveCore/`. `examples/` holds optional sample effects and boxes built with `CONFIG+=build_examples`. Vendored dependencies and local patches live in `third_party/`. Treat `build/Debug/` and `build/Release/` as generated output, not hand-edited source.

## Build, Test, and Development Commands
Initialize submodules before building:

```sh
git submodule update --init --recursive
cd third_party && make patch
```

Build bundled libraries with `make -C third_party` when you need a full local setup. Build the application with qmake from a build directory:

```sh
cd build/Release
qmake ../../enve.pro CONFIG+=build_examples
make -j"$(nproc)"
```

For debug builds, use `cd build/Debug && qmake CONFIG+=debug ../../enve.pro && make -j"$(nproc)"`. CI historically uses the same qmake flow plus packaging scripts from `.travis_*.sh`.

## Coding Style & Naming Conventions
Follow the existing C++/Qt style: 4-space indentation, opening braces on the same line, and grouped `#include`s with project headers before Qt/system headers when practical. Types use `UpperCamelCase` (`Canvas`, `MemoryHandler`), methods use `lowerCamelCase`, member fields typically use the `mName` pattern, and shared/static globals often use `sName`. Match nearby file naming: core source files are usually lowercase (`canvas.cpp`), while many UI subdirectories use Qt-style `UpperCamelCase`.

## Testing Guidelines
There is no dedicated automated unit-test tree in this repository. Validate changes by building the affected target, running the desktop app, and exercising a focused example from `examples/` when rendering or effect behavior changes. Document the exact manual checks in your PR, especially for animation playback, import/export, and GPU-sensitive code paths.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commit subjects with sentence-style capitalization and a trailing period, for example `Fix backup saving.` or `Use parent transform in setupRenderData.` Keep commits narrowly scoped. PRs should summarize user-visible behavior, list build/manual test coverage, link related issues, and include screenshots or short recordings for UI or rendering changes.
