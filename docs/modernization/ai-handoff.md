# AI Handoff: Phase 5 Build-System Migration

- Snapshot time: 2026-03-21 10:00:00 UTC
- Active branch: `master`
- Latest confirmed `master` commit: `f5ddeb92` (`Phase 5: Add narrow CMake/core Actions validation path`)
- Active local worktree delta:
  - no tracked Phase 5 source changes are currently uncommitted in the main tree
  - dirty vendored `third_party` submodule state still exists from local build history
- Latest confirmed qmake baseline CI on `master`:
  - Linux Baseline Build `23372328765`: `success`
  - Multi-Distro Build `23372328779`: `success`
- Fork remote: `origin` -> `git@github.com:Hope2333/enve.git`
- Upstream remote: `upstream` -> `git@github.com:MaurycyLiebner/enve.git`

## What Is Stable Right Now

- ✅ Phases 0 through 4 are complete on `master`.
- 🔄 Phase 5 is active:
  - ✅ qmake baseline remains green and authoritative
  - ✅ vendored `libmypaint` generated-header handling landed in `src/core/CMakeLists.txt`
  - ✅ a Phase 5 FFmpeg 6.x compatibility batch landed across `samples`, `esoundsettings`, `soundreader`, `audiostreamsdata`, and `videostreamsdata`
  - ✅ narrow CMake/core Actions workflow created (`cmake-core.yml`)
  - ⏳ waiting for first clean-room GitHub Actions proof for the CMake core slice
- ⏸️ Packaging and distribution remain outside the active lane.
- Local worktree caveat:
  - dirty `third_party` submodule state is present
  - do not reset vendored submodules blindly

## Latest Relevant Workflow Runs

- Linux Baseline Build `23372328765`
  - event: `push`
  - branch: `master`
  - head sha: `c2de8072`
  - url: `https://github.com/Hope2333/enve/actions/runs/23372328765`
  - conclusion: `success`
  - notes: qmake baseline green
- Multi-Distro Build `23372328779`
  - event: `push`
  - branch: `master`
  - head sha: `c2de8072`
  - url: `https://github.com/Hope2333/enve/actions/runs/23372328779`
  - conclusion: `success`
  - notes: Ubuntu/Debian/Arch compile-compatibility green; package jobs skipped by design
- CMake Core Build (Phase 5) `23377197769`
  - event: `workflow_dispatch`
  - branch: `master`
  - head sha: `f5ddeb92`
  - url: `https://github.com/Hope2333/enve/actions/runs/23377197769`
  - conclusion: `failure`
  - notes: ⏰ FIRST clean-room CMake proof attempt; failed on missing `libmypaint-config.h` (vendored libmypaint not built)

## What Was Verified Locally

- `git log --oneline --decorate -n 8` confirmed `f5ddeb92` is the current `master` head.
- `gh run list --repo Hope2333/enve --limit 8` confirmed the latest GitHub Actions evidence is still qmake baseline/multi-distro green on `23372328765` and `23372328779`.
- Local source inspection confirmed:
  - `.github/workflows/cmake-core.yml` created for narrow CMake/core validation
  - Workflow uploads `envecore.a` and build logs as artifacts
  - FFmpeg 6.x compatibility work is partial across the tree; more fixes may be needed

## Current Lane Boundary

- The active lane is **Phase 5: Build-System Migration**.
- Another implementation lane should **not** be opened yet.
- The next execution AI should stay inside a narrow Phase 5 core-only slice, with a revised proof strategy:
  - local builds are for quick sanity only and should use `-j3`
  - clean-room proof should move to a narrow GitHub Actions CMake/core validation path with downloadable logs/artifacts
  - only after one clean Actions proof should the lane widen to version-band hardening for FFmpeg `7.1` / `8.0` / `8.1`
- Keep qmake as the authoritative release path while CMake parity is incomplete.
- AI relay hygiene is now a standing guardrail:
  - keep volatile AI state under `.ai/`
  - do not reintroduce tracked active-state files under `docs/`

## Immediate Next Actions

1. ✅ First clean-room Actions proof attempted (run 23377197769)
2. ⏰ Blocker confirmed: vendored libmypaint not built in clean environment
3. Next: Add vendored libmypaint build step to CMake (ExternalProject or pre-build)
4. Re-trigger CMake Core Build after libmypaint fix
5. Record next real blocker from clean proof before broader FFmpeg compatibility work
4. Keep FFmpeg `7.x` / `8.x` widening explicitly queued behind one green FFmpeg `6.x` clean-room proof

## Guardrails

- Do not commit `.omx/`, `.ai/`, `.sisyphus/`, or `AGENTS.md`.
- Do not broaden scope to `src/app`, `examples`, packaging, AppImage, Flatpak, or distro expansion.
- Do not start Qt 6 or dependency replacement.
- Do not treat `PROXY` as a baseline requirement.
- Do not treat the existing qmake GitHub Actions green runs as proof for the current CMake core slice.
- Do not start README detachment/rename/logo implementation work in this lane; those are later planning items, not current execution scope.
