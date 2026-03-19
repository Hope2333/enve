# Baseline Build Specification

## Goal

Define a reproducible reference build for the current codebase before any dependency or build-system migration. The first target is Linux release build parity with the existing Travis flow. macOS can remain a follow-up baseline once Linux is stable.

## Scope

This baseline is intentionally conservative:

- Keep qmake as the build generator.
- Keep vendored third-party dependencies under `third_party/`.
- Keep the current Qt 5.12.4 lane and current FFmpeg integration.
- Do not upgrade APIs, replace dependencies, or migrate packaging in this step.

## Baseline Success Criteria

A clean environment is considered baseline-complete when it can:

1. Clone the repository with submodules.
2. Apply local third-party patches.
3. Build the vendored dependencies required by `src/core/core.pri` and `src/app/app.pro`.
4. Build `enve` and `envecore` via qmake from `build/Release/`.
5. Build examples with `CONFIG+=build_examples`.
6. Produce the expected binary outputs:
   - `build/Release/src/app/enve`
   - `build/Release/src/core/` shared library output
7. Complete a manual smoke pass in a graphical session.

## Required Evidence to Capture

Record the following in the baseline artifact set:

- OS image and version
- compiler and linker versions
- qmake path and `qmake -v`
- Qt version and install path
- package-manager dependencies installed
- third-party submodule SHAs
- any local environment variables needed during the build
- exact commands used for dependency build, app build, and packaging

## Reference Build Sequence

Use the current project flow as the source of truth:

1. `git clone --recurse-submodules ...`
2. `cd third_party && make patch`
3. Build third-party libraries, either through `make -C third_party` or explicit per-library commands where needed:
   - Skia
   - libmypaint
   - QuaZip
   - gperftools
   - QScintilla
4. Build the app:

```sh
cd build/Release
qmake ../../enve.pro CONFIG+=build_examples
make -j"$(nproc)"
```

5. If packaging is part of the baseline capture, record the AppDir/AppImage flow separately from compile success.

## Starter Artifacts in This Repository

This repository now includes a baseline bootstrap path you can run locally or in CI:

- Dependency install script: `scripts/ci/install-linux-build-deps.sh`
- Baseline build script: `scripts/ci/build-linux-baseline.sh`
- Smoke script: `scripts/ci/smoke-linux-baseline.sh`
- Preflight script: `scripts/ci/preflight-linux-baseline.sh`
- Draft GitHub Actions workflow: `.github/workflows/linux-baseline.yml`
- Baseline container file: `docker/linux-baseline.Dockerfile`

The workflow uses two layers:

- `preflight` runs automatically on pull requests and pushes for script/workflow changes.
- Full baseline compile remains manual via `workflow_dispatch` until compile stability is proven.

Useful build-script knobs:

- `ENVE_JOBS`: override parallel build jobs (default: `nproc`).
- `ENVE_BUILD_EXAMPLES`: set `0` to skip `CONFIG+=build_examples`.
- `ENVE_SKIP_THIRD_PARTY`: set `1` only when third-party artifacts are already built; the script now validates required artifacts up front.
- `ENVE_UPDATE_SUBMODULES`: set `1` to force `git submodule update --init --recursive` inside the build script (default is `0`).
- `ENVE_USE_PREBUILT_SKIA`: set `1` to skip Skia rebuild and build only the remaining third-party libraries (requires `third_party/skia/out/Release/libskia.a`).

Network note:

- If `third_party/skia/out/Release/libskia.a` is missing, baseline build requires outbound access to `skia.googlesource.com` and `chromium.googlesource.com` for Skia deps sync.

## Smoke Verification Contract

The baseline should define a minimum manual verification pass:

1. Launch `enve` in a graphical session.
2. Open the application without immediate startup failure.
3. Load at least one sample or example-backed workflow.
4. Exercise one render-preview path.
5. Exercise one import or export path, ideally SVG or video-related.
6. Confirm the expression editor and brush tooling still open, since they pull in QScintilla and libmypaint-backed features.

## Deliverables

- A container recipe or bootstrap script for Linux baseline recovery
- One CI job that reproduces the release build
- A short runbook describing expected outputs and known caveats
- A captured dependency manifest checked into `docs/modernization/`

## Non-Goals

- No Qt 6 migration
- No CMake migration
- No dependency replacement work
- No packaging redesign
