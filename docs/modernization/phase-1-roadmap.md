# Phase 1 Roadmap

## Goal

Turn the first successful branch-side Linux baseline build into a stable, repeatable, and policy-backed CI lane, then formalize the recovered toolchain as the new working reference.

## Current Starting Point

- A full Linux baseline build has already passed on the branch.
- The recovery lane is running on `ubuntu-22.04` with distro Qt 5.15.x packages, not the old Travis-era Qt 5.12.4 lane.
- The next technical gate is not baseline recovery anymore; it is master validation and CI stabilization.

## Workstreams

### 1. Baseline Stabilization

- Merge the branch recovery work to `master`.
- Run `linux-baseline.yml` on `master`.
- Require at least one green `master` validation run before changing trigger policy.

### 2. CI Policy Upgrade

- Keep `preflight` automatic.
- After `master` proves stable, promote `Build (Linux)` from manual-only to automatic on relevant push and pull request events.
- Preserve build artifacts and failed logs so regressions stay diagnosable without local reproduction.

### 3. Toolchain Formalization

- Stop treating Qt 5.15.x on Ubuntu 22.04 as an accidental compatibility success.
- Document it as the recovered Linux reference lane.
- Record the effective compiler, qmake, and Qt versions from green CI runs.
- Update legacy docs that still imply Qt 5.12.4 and `g++-7` are the active Linux target.

### 4. Verification Upgrade

- Keep the existing binary and linkage smoke checks.
- Add a documented manual smoke pass for application startup, sample opening, render-preview, and one import/export path.
- Decide which checks can eventually become automated.

### 5. Dependency Classification

- Separate hard requirements from optional features.
- Start with `gperftools`, OpenMP, WebEngine preview, and examples.
- Prefer explicit build flags over undocumented assumptions.

## Exit Criteria

Phase 1 is complete when:

1. `master` has at least one confirmed green Linux baseline run.
2. The Linux build lane can run automatically on normal change flow.
3. The recovered Ubuntu 22.04 + Qt 5.15.x lane is documented as the current Linux reference baseline.
4. A minimum smoke verification contract is documented.
5. Optional dependency candidates are identified with concrete next actions.

## Non-Goals

- No Qt 6 migration
- No CMake migration
- No dependency replacement campaign
- No packaging redesign

## Suggested Execution Order

1. Merge and validate on `master`
2. Promote CI trigger policy
3. Freeze and document the recovered toolchain lane
4. Add smoke verification expectations
5. Classify optional dependencies

## Risk Notes

- A green branch build does not automatically prove `master` stability.
- Automatic CI promotion before `master` validation will amplify noise.
- The recovered Qt 5.15.x lane may expose latent source issues that never showed up in the old 5.12.4 documentation path.
- Dependency reduction should stay behind CI stabilization, not run in parallel with it.
