# Modernization Status

- Last updated: 2026-03-19
- Overall status: Phase 0 (baseline recovery) COMPLETED. Phase 1 (CI replacement) in progress.

## Landed So Far

- A GitHub Actions workflow exists at `.github/workflows/linux-baseline.yml`.
- CI helper scripts exist in `scripts/ci/` for dependency install, preflight, build, and smoke checks.
- A clean Ubuntu 22.04 container recipe exists at `docker/linux-baseline.Dockerfile`.
- The baseline build script supports practical recovery knobs such as `ENVE_JOBS`, `ENVE_BUILD_EXAMPLES`, `ENVE_SKIP_THIRD_PARTY`, `ENVE_UPDATE_SUBMODULES`, and `ENVE_USE_PREBUILT_SKIA`.
- The baseline script now patches the known Skia Python 3 bootstrap issues in `gn/is_clang.py` and ICU `make_data_assembly.py`.
- A timestamped coding handoff now lives in `docs/modernization/ai-handoff.md`.
- Repository-wide supervisory/execution guidance now lives in `docs/ai-collaboration.md`.
- Medium-term post-baseline planning now lives in `docs/modernization/phase-1-roadmap.md`.
- QPainterPath incomplete type issue in `graphanimator.h` fixed in commit `9f4c60d9`.
- libmypaint -fPIC link failure fixed in commit `a2d146ff`.

## Current CI Behavior

- `preflight` runs automatically on pull requests and pushes that touch workflow or build files.
- `Build (Linux)` runs only on `workflow_dispatch` until the compile path is stable.
- Successful build artifacts are expected at `build/Release/src/app/enve` and `build/Release/src/core/libenvecore.so*`.
- Validation run `23282890827`: **PASSED** ✅

## Active Blockers

- No active technical blocker is currently confirmed on the branch-side baseline lane.
- Immediate gating work remains: PR #6 merge and `master` validation.

## Next Steps

1. Merge PR #6 to master.
2. Trigger linux-baseline.yml on master to confirm stability.
3. Consider promoting Build (Linux) from manual to automatic trigger.
4. Execute the workstreams in `docs/modernization/phase-1-roadmap.md`.
