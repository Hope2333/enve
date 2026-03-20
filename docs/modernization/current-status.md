# Modernization Status

- Last updated: 2026-03-20 22:34:52 UTC
- Overall status: **Phase 3 COMPLETE on `master`. Phase 4 Verification Upgrade is now the active lane.**

## Landed So Far

- ✅ PR #6 merged to `master`
- ✅ PR #7 merged to `master`
- ✅ PR #8 merged to `master`
- ✅ Manual Phase 1 validation run `23288361000`: `success`
- ✅ Automatic Phase 1 `push` validation run `23306463704`: `success`
- ✅ Phase 2 feature flags are on `master`:
  - `ENVE_USE_GPERFTOOLS`
  - `ENVE_USE_WEBENGINE`
  - `ENVE_USE_QSCINTILLA`
  - `ENVE_USE_OPENMP`
  - `ENVE_BUILD_EXAMPLES`
  - `ENVE_USE_SYSTEM_LIBMYPAINT`
- ✅ Phase 3 toolchain-consolidation outputs are on `master`:
  - toolchain survey
  - feature-flag semantics
  - CMake skeleton
  - build-output organization notes
  - library-linkage notes
  - stamp files for `third_party`
  - CI caching for `third_party`
- ✅ Latest `master` validation is green:
  - Linux Baseline Build `23357140865` (`push`): `success`
  - Multi-Distro Build `23357140871` (`push`): `success`
  - Linux Baseline Build `23357156824` (`workflow_dispatch`): `success`
  - Multi-Distro Build `23357158851` (`workflow_dispatch`): `success`

## Current CI Behavior

- `preflight` runs automatically on pull requests and relevant pushes.
- `Build (Linux)` runs automatically on `push` to `master` and remains proven.
- `scripts/ci/smoke-linux-baseline.sh` already runs in the baseline workflow after the build.
- Multi-Distro Build currently proves compile compatibility across:
  - Ubuntu 22.04
  - Debian 12
  - Arch Linux
- Multi-Distro package jobs are currently disabled by design:
  - Debian Package: `if: false`
  - Arch Package: `if: false`
- Current multi-distro CI should be read as build compatibility evidence, not as complete release-packaging coverage.

## Active Blockers

- No build-stability blocker is active right now.
- The active gap is verification depth:
  - startup and artifact smoke exists
  - focused import/export, render, and media regression coverage is still thin
- Scope discipline is the main planning constraint:
  - do not let packaging/distribution work hijack Phase 4
  - do not let proxy-specific behavior become an assumed baseline requirement

## Next Steps

1. Create or refine the Phase 4 layered TODO list from `docs/modernization/phase-4-roadmap.md`.
2. Audit current smoke coverage before adding any new workflow fan-out.
3. Add the smallest repeatable verification checks with the highest signal-to-cost ratio.
4. Define the manual verification contract for GPU-sensitive changes.
5. Pause after the next green verification improvement and hand back for review.
6. Do NOT start packaging/distribution expansion, CMake migration, Qt 6 work, dependency replacement, multilingual UI work, or KDE/Plasma theme integration here.
