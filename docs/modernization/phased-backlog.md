# Phased Modernization Backlog

## Status Snapshot

- Phase 0 is complete on the recovery branch: one Linux baseline build has passed end to end.
- Phase 1 is complete: automatic `push` builds on `master` are proven by run `23306463704`.
- Phase 2 is complete and merged to `master`: dependency-boundary flags are landed.
- Phase 3 is complete on `master`: toolchain consolidation outputs are landed and validated by runs `23357140865`, `23357140871`, `23357156824`, and `23357158851`.
- Phase 4 is now the active lane: verification upgrade.
- Phases 5 through 7 remain planned work and should not be mixed into the current Phase 4 verification gate.
- The recovered Ubuntu 22.04 + Qt 5.15.x lane is no longer hypothetical future work; later phases should treat it as the baseline to formalize and harden.
- Packaging and distribution hardening remain a deferred follow-up lane candidate, not the current phase.

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

**Status:** COMPLETE

Goal: formalize the already-recovered Linux reference lane and pay down the remaining source and documentation fallout without changing the app architecture.

- Formalize the recovered Ubuntu 22.04 distro compiler lane as the supported Linux baseline.
- Treat the already-proven Qt `5.15.x` compatibility lane as the current reference, then fix any remaining fallout explicitly.
- Remove or update stale documentation that still points at Qt `5.12.4`, `g++-7`, or Travis-era assumptions.
- Fix compile, warning, or deprecation fallout while keeping behavior stable.

**Delivered:**
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
- ✅ CI validation passed:
  - `23357140865` Linux Baseline Build (`push`)
  - `23357140871` Multi-Distro Build (`push`)
  - `23357156824` Linux Baseline Build (`workflow_dispatch`)
  - `23357158851` Multi-Distro Build (`workflow_dispatch`)

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
- ✅ CI validation with stamp files

## Phase 4: Verification Upgrade

**Status:** IN PROGRESS (smoke extended, manual contract created)

Goal: reduce reliance on ad hoc manual testing.

- Add repeatable smoke checks for startup and artifact existence.
- Add focused regression checks for import/export, render, and media code paths.
- Define what must be manually verified for GPU-sensitive changes.
- Keep CI cost low by extending existing scripts before adding new matrix fan-out.
- Treat Multi-Distro Build as compile-compatibility evidence, not as packaging completeness.
- Keep proxy handling optional; do not assume `PROXY` is required outside restricted environments.

**Progress:**
- ✅ Smoke coverage audited
- ✅ smoke-linux-baseline.sh extended:
  - Artifact size reporting
  - App startup check (--help/--version)
  - Example file detection
- ✅ Manual verification contract created (manual-verification-contract.md)
- ✅ CI validation passed (run 23365762835)
- 🔄 Next: Supervisory review for Phase 4 exit criteria

**Exit criteria progress:**
- ✅ Baseline workflow proves more than build success alone
- ⏳ Import/export path (manual contract defined, automation optional)
- ⏳ Render path (manual contract defined, automation optional)
- ⏳ Media path (manual contract defined, automation optional)
- ✅ GPU-sensitive changes have documented manual verification contract
- ✅ CI cost controlled (no new distro fan-out)
- ⏳ Relay docs record automated vs manual vs deferred

Exit criteria:
- Core change types have a defined verification path.
- Contributors can tell whether a modernization change is safe before merging.
- Packaging, AppImage, Flatpak, and distro-matrix expansion remain outside the exit gate.

## Deferred Parallel Lane Candidate: Packaging And Distribution Hardening

Goal: harden release artifact coverage after verification work is less ad hoc.

- Revisit Debian and Arch package jobs once they are a release priority again.
- Decide whether AppImage is a real supported format or only local tooling residue.
- Evaluate whether Flatpak belongs in project scope after the baseline verification contract is stable.
- Only expand distro coverage when there is a packaging or release reason, not just because the matrix can grow.

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
- Avoid letting packaging or distro-matrix growth silently expand Phase 4.
- Avoid treating proxy-specific networking assumptions as part of the default baseline unless logs prove they are required.
