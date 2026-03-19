# Modernization Status

- Last updated: 2026-03-19
- Overall status: Phase 0 (baseline recovery) and Phase 1 (CI replacement) are in progress.

## Landed So Far

- A GitHub Actions workflow exists at `.github/workflows/linux-baseline.yml`.
- CI helper scripts exist in `scripts/ci/` for dependency install, preflight, build, and smoke checks.
- A clean Ubuntu 22.04 container recipe exists at `docker/linux-baseline.Dockerfile`.
- The baseline build script supports practical recovery knobs such as `ENVE_JOBS`, `ENVE_BUILD_EXAMPLES`, `ENVE_SKIP_THIRD_PARTY`, `ENVE_UPDATE_SUBMODULES`, and `ENVE_USE_PREBUILT_SKIA`.
- The baseline script now patches the known Skia Python 3 bootstrap issues in `gn/is_clang.py` and ICU `make_data_assembly.py`.
- A timestamped coding handoff now lives in `docs/modernization/ai-handoff.md`.
- QPainterPath incomplete type issue in `graphanimator.h` fixed in commit `9f4c60d9`.
- libmypaint -fPIC link failure fixed in commit `a2d146ff`.

## Current CI Behavior

- `preflight` runs automatically on pull requests and pushes that touch workflow or build files.
- `Build (Linux)` runs only on `workflow_dispatch` until the compile path is stable.
- Successful build artifacts are expected at `build/Release/src/app/enve` and `build/Release/src/core/libenvecore.so*`.
- Validation run `23282890827` is in progress for commit `a2d146ff` (libmypaint -fPIC fix).

## Active Blockers

- The vendored Skia lane still pulls Python 2 era helper scripts into a Python 3 environment.
- The known early blockers in `third_party/skia/gn/is_clang.py` and `third_party/skia/third_party/externals/icu/scripts/make_data_assembly.py` are now patched in the baseline script.
- The QScintilla `qmake` path bug found in run `23279763328` is now patched in commit `1815ab0d`.
- The QPainterPath incomplete type issue is now patched in commit `9f4c60d9`.
- The libmypaint -fPIC link failure is now patched in commit `a2d146ff`.
- Awaiting CI validation from run `23282890827` to confirm the build unblocks.

## Next Steps

1. Monitor run `23282890827` for completion.
2. If it passes, open a PR to master and promote the Linux build from manual to automatic.
3. If it fails, capture the new first compile/link error and apply a minimal fix.
4. After compile stability, capture a graphical/manual smoke checklist and then begin compiler and Qt 5.15 work.
