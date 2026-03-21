# AI Handoff: Phase 5 Build-System Migration

- Snapshot time: 2026-03-21 17:00:00 UTC
- Active branch: `master`
- Latest confirmed `master` commit: `b9df7e69` (`Phase 5: Continue FFmpeg 6.x compatibility`)
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
  - ✅ FFmpeg 6.x channel layout API compatibility (PARTIAL):
    - samples.h/samples.cpp: AVChannelLayout serialization
    - esoundsettings.h: AVChannelLayout support
    - audiostreamsdata.cpp: channel layout API updates (INCOMPLETE)
  - ⏳ envecore build has remaining FFmpeg 6.x issues:
    - soundreader.cpp needs AVChannelLayout fixes
    - audiostreamsdata.cpp avcodec_free fix needed
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
  2. 🔄 FFmpeg 6.x channel layout API compatibility - IN PROGRESS
  3. ⏳ Complete remaining FFmpeg 6.x fixes (soundreader.cpp, etc.)
  4. Local envecore compile proof
  5. Only then consider src/app
- Packaging, Qt 6, dependency replacement are OUT OF SCOPE.

## Immediate Next Actions

1. Fix soundreader.cpp AVChannelLayout compatibility.
2. Fix audiostreamsdata.cpp avcodec_free issue.
3. Complete envecore CMake build.
4. Record next real blocker if any.
5. Do NOT start src/app CMake work yet.

## Guardrails

- Do not commit `.omx/`, `.ai/`, `.sisyphus/`, `AGENTS.md`.
- Do not reset dirty vendored submodules blindly.
- Do not broaden to src/app, examples, packaging.
- Do not start Qt 6 or dependency replacement.
