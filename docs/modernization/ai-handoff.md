# AI Handoff: Phase 5 Build-System Migration

- Snapshot time: 2026-03-21 16:00:00 UTC
- Active branch: `master`
- Latest confirmed `master` commit: `13cbff49` (`Phase 5: FFmpeg 6.x compatibility for CMake build`)
- Latest qmake baseline CI:
  - Linux Baseline Build `23372328765`: `success`
  - Multi-Distro Build `23372328779`: `success`
- Fork remote: `origin` -> `git@github.com:Hope2333/enve.git`
- Upstream remote: `upstream` -> `git@github.com:MaurycyLiebner/enve.git`

## What Is Stable Right Now

- ✅ Phase 0-4 are complete on `master`.
- 🔄 Phase 5 is IN PROGRESS:
  - ✅ CMake configuration for root + src/core succeeds
  - ✅ Vendored libmypaint generated header support added
  - ✅ FFmpeg 6.x channel layout API compatibility added
  - ⏳ envecore build still has remaining FFmpeg 6.x issues in samples.cpp
- ✅ qmake remains the authoritative build path.
- ⏸️ Package jobs are intentionally outside the active lane.
- Local worktree caveat:
  - `git status --short --ignore-submodules=none` shows dirty `third_party` submodules
  - do not reset them blindly

## Latest Relevant Workflow Runs

- Linux Baseline Build `23372328765`
  - event: `push`
  - branch: `master`
  - url: `https://github.com/Hope2333/enve/actions/runs/23372328765`
  - conclusion: `success`
  - notes: qmake baseline green
- Multi-Distro Build `23372328779`
  - event: `push`
  - branch: `master`
  - url: `https://github.com/Hope2333/enve/actions/runs/23372328779`
  - conclusion: `success`
  - notes: Ubuntu/Debian/Arch builds passed

## Current Lane Boundary

- The active lane is **Phase 5: Build-System Migration**.
- Scope is narrow: core-only CMake startup slice.
- Priority order within Phase 5:
  1. ✅ Generated third-party artifacts parity (libmypaint) - DONE
  2. ✅ FFmpeg 6.x channel layout API compatibility - PARTIAL
  3. ⏳ Complete remaining FFmpeg 6.x fixes (samples.cpp, etc.)
  4. Local envecore compile proof
  5. Only then consider src/app
- Packaging, Qt 6, dependency replacement are OUT OF SCOPE.

## Immediate Next Actions

1. Fix remaining FFmpeg 6.x issues in samples.cpp and related files.
2. Complete envecore CMake build.
3. Record next real blocker if any.
4. Do NOT start src/app CMake work yet.

## Guardrails

- Do not commit `.omx/`, `.ai/`, `.sisyphus/`, `AGENTS.md`.
- Do not reset dirty vendored submodules blindly.
- Do not broaden to src/app, examples, packaging.
- Do not start Qt 6 or dependency replacement.
