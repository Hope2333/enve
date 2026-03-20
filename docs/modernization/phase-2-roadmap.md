# Phase 2 Roadmap

## Goal

Turn the newly added dependency-boundary flags into a documented, CI-validated, merge-ready baseline without changing dependency providers by default and without broadening into CMake or Qt 6 work.

## Current Starting Point

- Phase 1 is complete:
  - manual `master` validation run `23288361000` passed
  - automatic `push` build on `master` run `23306463704` passed
- Multi-distro build run `23310875934` succeeded for Ubuntu, Debian, and Arch build jobs.
- The active Phase 2 branch is `chore/linux-baseline-actions`.
- Feature flags are already implemented in qmake/Makefile surfaces:
  - `ENVE_USE_GPERFTOOLS`
  - `ENVE_USE_WEBENGINE`
  - `ENVE_USE_QSCINTILLA`
  - `ENVE_USE_OPENMP`
  - `ENVE_BUILD_EXAMPLES`
  - `ENVE_USE_SYSTEM_LIBMYPAINT`
- Active validation run `23324646178` is testing:
  - Ubuntu default build
  - Ubuntu minimal-dependency build
  - Debian build
  - Arch build
  - package jobs

## Workstreams

### 1. CI Matrix Hardening

- Finish evaluating run `23324646178`.
- Keep Ubuntu default and minimal-dependency builds green.
- Confirm Debian and Arch build jobs remain green with the new flags.

### 2. Packaging Scope Clarification

- Decide whether package jobs are Phase 2 blockers or an explicit follow-up lane.
- Recommended default:
  - build-matrix health is a Phase 2 blocker
  - packaging fallout may become a narrower follow-up if it does not affect boundary extraction itself

### 3. Flag Documentation and Defaults

- Document each flag, owner, and default state.
- Keep default behavior as “enabled” unless there is a deliberate compatibility decision to change it.
- Record where each flag is consumed (`Makefile`, `src/app/app.pro`, `src/core/core.pri`).

### 4. Provider Boundary Cleanup

- Treat `ENVE_USE_SYSTEM_LIBMYPAINT` as a CI/packaging escape hatch unless and until it is explicitly promoted to baseline policy.
- Avoid turning provider switching into Phase 2 dependency replacement by accident.

### 5. Merge Readiness

- Merge Phase 2 only after:
  - build validation is good enough
  - defaults are documented
  - the phase boundary is explicit
- Re-validate the merged result on `master`.

## Exit Criteria

Phase 2 is complete when:

1. The optional-feature flags are present and working on the supported qmake/Makefile paths.
2. Ubuntu default and minimal-dependency builds are green.
3. Debian and Arch build jobs are green, or any remaining package failures are explicitly moved out of the Phase 2 exit gate.
4. The dependency ledger documents ownership, defaults, and boundary intent for the flagged features.
5. The Phase 2 branch merges without regressing the proven automatic `master` build lane.

## Non-Goals

- No CMake migration
- No Qt 6 migration
- No dependency replacement campaign
- No default provider switch for core dependencies
- No packaging redesign

## Suggested Execution Order

1. Finish the active CI run and classify failures by scope
2. Decide the packaging boundary for Phase 2
3. Document flags and defaults
4. Merge and validate on `master`
5. Move to Phase 3 toolchain consolidation

## Risk Notes

- Packaging jobs can hijack the phase if they are allowed to redefine the success criteria implicitly.
- qmake and Makefile can drift if flag behavior is not documented in one place.
- `ENVE_USE_SYSTEM_LIBMYPAINT` is useful for CI, but it also blurs the provider boundary if left undocumented.
- The highest technical-risk areas remain Skia, FFmpeg, GPU rendering, and libmypaint-backed painting flows.
