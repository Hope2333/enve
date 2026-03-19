# Phased Modernization Backlog

## Status Snapshot

- Phase 0 is complete on the recovery branch: one Linux baseline build has passed end to end.
- Phase 1 has cleared manual `master` validation, but the automatic-build gate is still open because the first post-merge `push` run skipped `Build (Linux)`.
- Phases 2 through 7 remain planned work and should not be mixed into the current stabilization gate.
- The recovered Ubuntu 22.04 + Qt 5.15.x lane is no longer hypothetical future work; later phases should treat it as the baseline to formalize and harden.

## Phase 0: Baseline Recovery

Goal: recover one reproducible Linux release build using the current qmake and vendored dependency model.

- Create a Linux baseline recipe or container image.
- Record compiler, Qt, package, and submodule versions.
- Capture the exact dependency build flow from `third_party/` and `build/Release/`.
- Define a minimum manual smoke checklist.

Exit criteria:
- A clean environment can build `enve` and examples.
- Build steps are documented without hidden local knowledge.
- Status: achieved on the branch-side recovery lane; master confirmation still belongs to Phase 1.

## Phase 1: CI Replacement

Goal: replace Travis with a maintained CI system while preserving current behavior.

- Add one Linux release workflow that installs the current dependency set.
- Upload logs and build artifacts for debugging.
- Validate the first successful branch baseline on `master`.
- Keep the full compile job manual until the build is repeatable, then promote it to automatic.
- After the trigger policy changes, verify at least one real non-manual full build executes as intended.
- Keep packaging as a separate follow-up job unless it is required for parity.

Exit criteria:
- Every change runs a Linux build automatically.
- CI failures are actionable without reproducing everything locally.

## Phase 2: Dependency Boundary Hardening

Goal: turn obvious optional features into explicit build choices so the base Linux build surface becomes smaller and easier to reason about.

- Confirm which dependencies are strictly required for core app startup.
- Add real build flags or clearly enforced toggles for optional pieces such as `gperftools`, WebEngine preview, QScintilla, OpenMP, and examples.
- Keep provider replacement out of scope here; this phase is about boundaries, not new vendors.
- Update the dependency ledger with ownership, default-on/default-off intent, and upgrade notes.

Exit criteria:
- Optional dependencies are explicit instead of implicit.
- The base build can be discussed independently from profiling, preview, editor, or example extras.

## Phase 3: Toolchain Consolidation

Goal: formalize the already-recovered Linux reference lane and pay down the remaining source and documentation fallout without changing the app architecture.

- Formalize the recovered Ubuntu 22.04 distro compiler lane as the supported Linux baseline.
- Treat the already-proven Qt `5.15.x` compatibility lane as the current reference, then fix any remaining fallout explicitly.
- Remove or update stale documentation that still points at Qt `5.12.4`, `g++-7`, or Travis-era assumptions.
- Fix compile, warning, or deprecation fallout while keeping behavior stable.

Exit criteria:
- CI passes on the new compiler and Qt 5 lane.
- Smoke verification shows no regression in startup, rendering, media, or scripting flows.

## Phase 4: Verification Upgrade

Goal: reduce reliance on ad hoc manual testing.

- Add repeatable smoke checks for startup and artifact existence.
- Add focused regression checks for import/export, render, and media code paths.
- Define what must be manually verified for GPU-sensitive changes.

Exit criteria:
- Core change types have a defined verification path.
- Contributors can tell whether a modernization change is safe before merging.

## Phase 5: Build-System Migration

Goal: introduce CMake without breaking the existing release path.

- Start with `src/core/` and establish equivalent library outputs.
- Extend CMake to `src/app/` once core linkage is stable.
- Port examples and packaging only after the main app is building reliably.
- Keep qmake available as fallback until binary parity is demonstrated.

Exit criteria:
- CMake builds the same main targets as qmake.
- qmake is no longer needed for routine development.

## Phase 6: Dependency Reduction and Replacement

Goal: lower the maintenance cost of vendored and niche dependencies.

- Re-evaluate QuaZip and QScintilla for replacement or system-package sourcing.
- Decide whether `gperftools` remains supported, optional, or removed.
- Reassess WebEngine preview cost versus feature value.

Exit criteria:
- Each dependency has an explicit keep, replace, optionalize, or remove decision.
- The baseline build becomes smaller and easier to reproduce.

## Phase 7: Qt 6 Evaluation

Goal: decide whether Qt 6 is worth the migration cost after infrastructure risk is reduced.

- Audit Qt 5-only APIs and modules in use.
- Check Qt 6 compatibility for WebEngine, QScintilla, OpenGL paths, and packaging.
- Run a small spike before committing to a full migration.

Exit criteria:
- The team has a clear go/no-go decision backed by prototype evidence.

## Priority Order

1. Phase 0
2. Phase 1
3. Phase 2
4. Phase 3
5. Phase 4
6. Phase 5
7. Phase 6
8. Phase 7

## Risk Notes

- The highest-risk areas are Skia integration, FFmpeg integration, GPU rendering, and libmypaint-backed painting flows.
- Avoid combining build-system migration with Qt major-version migration.
- Avoid changing packaging and runtime dependency strategy in the same phase as compiler or Qt upgrades.
- Avoid starting the first CMake lane before Phase 2 has made the optional-feature boundaries explicit, or the initial CMake graph will inherit avoidable complexity.
