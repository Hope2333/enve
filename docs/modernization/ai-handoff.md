# AI Handoff: Phase 2 Dependency Boundary Hardening

- Snapshot time: 2026-03-20 01:15:12 UTC
- Active working branch: `chore/linux-baseline-actions`
- Latest branch commit: `51f22373` (`Update handoff: CI testing in progress`)
- Latest confirmed `master` commit: `ad9df455` (`chore: Enable automatic Build (Linux) on push`)
- Fork remote: `origin` -> `git@github.com:Hope2333/enve.git`
- Upstream remote: `upstream` -> `git@github.com:MaurycyLiebner/enve.git`
- PR #6: `MERGED`
- PR #7: `MERGED`

## What Is Stable Right Now

- ✅ Phase 0 is complete.
- ✅ Phase 1 is complete:
  - manual `master` validation run `23288361000` passed
  - automatic `push` build on `master` run `23306463704` passed
- ✅ Multi-distro build run `23310875934` passed for build jobs:
  - Ubuntu 22.04 build: `success`
  - Debian 12 build: `success`
  - Arch build: `success`
- ✅ Phase 2 implementation exists on the branch:
  - `ENVE_USE_GPERFTOOLS`
  - `ENVE_USE_WEBENGINE`
  - `ENVE_USE_QSCINTILLA`
  - `ENVE_USE_OPENMP`
  - `ENVE_BUILD_EXAMPLES`
  - `ENVE_USE_SYSTEM_LIBMYPAINT`
- Local worktree caveat:
  - `git status --short --ignore-submodules=none` still shows dirty `third_party` submodules from local build state (`gperftools`, `libmypaint`, `qscintilla`, `quazip`, `skia`)
  - do not reset them blindly

## Current Live CI State

- Phase 2 merge to master: **COMPLETE**
- PR #8: **MERGED** - "Phase 2: Dependency boundary hardening (#8)"
- Master automatic build triggered: **YES**
- Master validation runs:
  - Linux Baseline Build (run 23353037094): ✅ **success**
  - Multi-Distro Build (run 23353037134): ✅ **success**
    - Ubuntu 22.04: ✅ success
    - Debian 12: ✅ success
    - Arch Linux: ✅ success
    - Arch Package: ⏸️ skipped (packaging follow-up lane)
    - Debian Package: ⏸️ skipped (packaging follow-up lane)
- Phase 2 status: **COMPLETE AND MERGED TO MASTER**
- Phase 3 status: **IN PROGRESS** (toolchain survey complete)
- Latest commit: `cbd91a54` - "Phase 3: Add toolchain survey"
- Next phase: **Phase 3 - Toolchain Consolidation Prep**

## Practical Interpretation

- The active lane has changed from Phase 1 closure to Phase 2 dependency-boundary hardening.
- The core Phase 2 build-flag work is materially implemented on the branch.
- The remaining uncertainty is not whether the flags exist; it is whether the current validation matrix and package jobs should be treated as Phase 2 blockers or as a narrower follow-up lane.
- The most important planning decision now is to keep packaging fallout from silently redefining the phase boundary.

## Immediate Next Actions

**Phase 2 COMPLETE AND MERGED. Phase 3 IN PROGRESS.**

1. ✅ PR #8 merged to master
2. ✅ Master automatic build triggered (run 23353037094, 23353037134)
3. ✅ All builds passed:
   - Linux Baseline: success
   - Multi-Distro: success (Ubuntu/Debian/Arch)
4. ✅ Phase 2 feature flags now on master
5. ✅ Phase 3 toolchain survey complete

**Phase 3 progress:**
- ✅ Toolchain survey completed (phase-3-toolchain-survey.md)
- ✅ Documented qmake structure and Makefile orchestration
- ✅ Documented third-party build systems
- ✅ Identified 5 consolidation opportunities
- ✅ Prepared CMake migration structure outline
- 🔄 Next: Document feature flag semantics

**Consolidation opportunities:**
1. Feature flag consistency (validation, documentation)
2. Build output organization (centralize under build/)
3. Third-party build caching (stamp files)
4. Include path management (centralize in core.pri)
5. Library linkage documentation (dependency diagram)

Packaging Follow-up Lane (parallel, optional):
- Fix Skia header paths in package jobs
- Re-enable Debian and Arch package steps
- Test end-to-end packaging workflow

## Commands Worth Reusing

```sh
git status --short --ignore-submodules=none
git log --oneline --decorate -n 15
gh pr list --repo Hope2333/enve --state all --limit 12
gh run list --repo Hope2333/enve --workflow linux-baseline.yml --limit 15
gh run view 23306463704 --repo Hope2333/enve --json status,conclusion,event,headBranch,url,jobs
gh run view 23310875934 --repo Hope2333/enve --json status,conclusion,event,headBranch,url,jobs
gh run view 23324646178 --repo Hope2333/enve --json status,conclusion,event,headBranch,url,jobs
gh api repos/Hope2333/enve/branches/master --jq '.commit.sha'
```

## Guardrails

- Do not commit `.omx/`.
- Do not reset dirty vendored submodules unless the user explicitly asks.
- Do not start CMake migration yet.
- Do not start Qt 6 work yet.
- Do not let packaging/provider experiments silently become the new default Linux baseline.
- Treat `ENVE_USE_SYSTEM_LIBMYPAINT` as a packaging/CI aid until its baseline role is documented and intentionally accepted.

## Copy-Paste Prompt For The Next AI

```text
Phase 2 is COMPLETE AND MERGED TO MASTER. Phase 3 IN PROGRESS.

Current state:
- Phase 1: COMPLETE (auto-build on push proven)
- Phase 2: COMPLETE AND MERGED (PR #8 merged, runs 23353037094/23353037134 passed)
- Phase 3: IN PROGRESS (toolchain survey complete)
- Latest commit: cbd91a54 - "Phase 3: Add toolchain survey"

Phase 2 feature flags (on master):
1. ENVE_USE_GPERFTOOLS (app.pro + core.pri + Makefile)
2. ENVE_USE_OPENMP (core.pri + Makefile)
3. ENVE_USE_WEBENGINE (app.pro + Makefile)
4. ENVE_USE_QSCINTILLA (app.pro + Makefile)
5. ENVE_BUILD_EXAMPLES (Makefile)
6. ENVE_USE_SYSTEM_LIBMYPAINT (core.pri + Makefile)

Phase 3 progress:
✅ Toolchain survey completed (phase-3-toolchain-survey.md)
✅ Documented qmake structure and Makefile orchestration
✅ Documented third-party build systems
✅ Identified 5 consolidation opportunities
✅ Prepared CMake migration structure outline
🔄 Next: Document feature flag semantics

Your task (continue Phase 3):
1. Document feature flag semantics (validation, defaults, interactions)
2. Create CMakeLists.txt skeleton for src/core/
3. Test CMake build alongside qmake
4. Document any build output organization issues

Do NOT start:
- CMake migration (prep only, no full implementation)
- Qt 6 migration (after toolchain consolidation)
- Dependency replacement (evidence-driven)

Read these files for context:
- docs/modernization/ai-handoff.md (this file)
- docs/modernization/phase-3-toolchain-survey.md (NEW)
- docs/modernization/phased-backlog.md (Phase 3 section)
- docs/modernization/dependency-ledger.md
```
