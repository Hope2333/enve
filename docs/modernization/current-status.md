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

## Current CI Behavior

- `preflight` runs automatically on pull requests and pushes that touch workflow or build files.
- `Build (Linux)` runs only on `workflow_dispatch` until the compile path is stable.
- Successful build artifacts are expected at `build/Release/src/app/enve` and `build/Release/src/core/libenvecore.so*`.

## Active Blockers

- The vendored Skia lane still pulls Python 2 era helper scripts into a Python 3 environment.
- The known early blockers in `third_party/skia/gn/is_clang.py` and `third_party/skia/third_party/externals/icu/scripts/make_data_assembly.py` are now patched in the baseline script, but the full cold build is still being validated in Actions.
- The QScintilla `qmake` path bug found in run `23279763328` is now patched in commit `1815ab0d`.
- Validation run `23280524470` got through the third-party baseline chain and then failed in `src/core` because `graphanimator.h` uses `QPainterPath` as a complete type without including `<QPainterPath>`.
- Until this path produces one green full build, the Actions compile job should stay manual rather than mandatory on every push.

## Next Steps

1. Add `<QPainterPath>` to `src/core/Animators/graphanimator.h`, then rerun the branch-side workflow.
2. Preserve logs and artifact paths so failures stay diagnosable from Actions alone.
3. Promote the Linux build from manual to automatic only after the baseline is repeatable.
4. After compile stability, capture a graphical/manual smoke checklist and then begin compiler and Qt 5.15 work.
