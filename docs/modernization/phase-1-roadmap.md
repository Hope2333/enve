# Phase 1 Roadmap

> Historical note:
> Phase 1 is complete. The active medium-term execution plan now lives in `docs/modernization/phase-2-roadmap.md`.

## Goal

Turn the first successful branch-side Linux baseline build into a stable, repeatable, and policy-backed CI lane, then formalize the recovered toolchain as the new working reference.

## Current Starting Point

- A full Linux baseline build has already passed on the branch.
- The recovery lane is running on `ubuntu-22.04` with distro Qt 5.15.x packages, not the old Travis-era Qt 5.12.4 lane.
- Manual `master` validation has now passed through run `23288361000`.
- The remaining technical gate is CI trigger verification, not source compilation.
- PR checks are still misleading if read casually: `Preflight` runs on pull requests, but `Build (Linux)` is not yet proven on normal non-manual change flow.

## Gate Clarifications

- A green pull request check does not currently prove full build health.
- A green manual `workflow_dispatch` run on `master` is necessary but not sufficient for full Phase 1 closure.
- Phase 1 is not complete until a non-manual change-flow event actually executes `Build (Linux)` successfully.
- Phase 2 work should stay queued until the CI trigger policy, reference-lane documentation, smoke contract, and dependency-boundary candidate list are all in place.

## Workstreams

### 1. Baseline Stabilization

- Merge the branch recovery work to `master`.
- Run `linux-baseline.yml` on `master`.
- Require at least one green `master` validation run before changing trigger policy.
- Status: achieved through run `23288361000`.

### 2. CI Policy Upgrade

- Keep `preflight` automatic.
- After `master` proves stable, promote `Build (Linux)` from manual-only to automatic on relevant push and pull request events.
- Verify the first real non-manual run after the policy change; a YAML change alone does not close the gate.
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
- Start with `gperftools`, WebEngine preview, QScintilla, OpenMP, and examples.
- Produce the concrete Phase 2 implementation list, but keep the actual flagging/removal work behind the Phase 1 exit gate unless a tiny, low-risk change is required for CI stability.
- Prefer explicit build flags over undocumented assumptions.

## Exit Criteria

Phase 1 is complete when:

1. `master` has at least one confirmed green Linux baseline run.
2. The Linux build lane has at least one confirmed successful non-manual full build on normal change flow.
3. The recovered Ubuntu 22.04 + Qt 5.15.x lane is documented as the current Linux reference baseline.
4. A minimum smoke verification contract is documented.
5. Optional dependency candidates are identified with concrete next actions.
6. The team no longer confuses PR-side `preflight` success with a full baseline build signal.

## Non-Goals

- No Qt 6 migration
- No CMake migration
- No dependency replacement campaign
- No packaging redesign

## Suggested Execution Order

1. Validate on `master`
2. Prove the automatic build lane on normal change flow
3. Freeze and document the recovered toolchain lane
4. Add smoke verification expectations
5. Classify optional dependencies

## Risk Notes

- A green branch build does not automatically prove `master` stability.
- Automatic CI promotion before `master` validation will amplify noise.
- The recovered Qt 5.15.x lane may expose latent source issues that never showed up in the old 5.12.4 documentation path.
- Dependency reduction should stay behind CI stabilization, not run in parallel with it.
