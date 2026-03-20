# Phased Modernization Backlog

## Status Snapshot

- Phase 0 is complete on the recovery branch: one Linux baseline build has passed end to end.
- Phase 1 is complete: automatic `push` builds on `master` are proven by run `23306463704`.
- Phase 2 is active on `chore/linux-baseline-actions`: feature flags are implemented and branch-side CI validation is in progress.
- Phases 3 through 7 remain planned work and should not be mixed into the current Phase 2 validation gate.
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

**Status:** IN PROGRESS (started 2026-03-20)

Goal: formalize the already-recovered Linux reference lane and pay down the remaining source and documentation fallout without changing the app architecture.

- Formalize the recovered Ubuntu 22.04 distro compiler lane as the supported Linux baseline.
- Treat the already-proven Qt `5.15.x` compatibility lane as the current reference, then fix any remaining fallout explicitly.
- Remove or update stale documentation that still points at Qt `5.12.4`, `g++-7`, or Travis-era assumptions.
- Fix compile, warning, or deprecation fallout while keeping behavior stable.

**Progress:**
- ✅ Toolchain survey completed (phase-3-toolchain-survey.md)
- ✅ Documented qmake structure and Makefile orchestration
- ✅ Documented third-party build systems
- ✅ Identified 5 consolidation opportunities
- ✅ Prepared CMake migration structure outline
- ✅ Feature flag semantics documented (feature-flag-semantics.md)
- ✅ CMakeLists.txt skeleton created (root, src/core, src/app, examples)
- ✅ FindQScintilla.cmake module created
- ✅ Build output organization documented (build-output-organization.md)
- ✅ Library linkage documented (library-linkage.md)
- ✅ Stamp files for third_party builds implemented
- ✅ Main Makefile updated to use stamp files
- ✅ CI caching for third-party builds configured
- 🔄 CI validation in progress (runs 23357156824, 23357158851)

**Consolidation opportunities identified:**
1. Feature flag consistency (validation, documentation) - ✅ DONE
2. Build output organization (centralize under build/) - ✅ DOCUMENTED + IMPLEMENTED
3. Third-party build caching (stamp files) - ✅ IMPLEMENTED + CI CACHING
4. Include path management (centralize in core.pri) - ⏳ PENDING
5. Library linkage documentation (dependency diagram) - ✅ DONE

Exit criteria:
- CI passes on the new compiler and Qt 5 lane.
- Smoke verification shows no regression in startup, rendering, media, or scripting flows.
- ✅ Toolchain survey complete
- ✅ Feature flag semantics documented
- ✅ CMakeLists.txt skeleton created
- ✅ Build output organization documented
- ✅ Library linkage documented
- ✅ Stamp files for third_party builds implemented
- 🔄 CI validation with stamp files (IN PROGRESS)

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
- Avoid letting packaging fallout silently expand Phase 2 until it stops being about dependency boundaries at all; if needed, split packaging follow-up into a narrower lane.
