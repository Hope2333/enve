# AI Handoff: Linux Baseline Recovery

- Snapshot time: 2026-03-19 10:25:00 UTC
- Active reference branch: `master`
- Local working branch still present: `chore/linux-baseline-actions`
- Fork remote: `origin` -> `git@github.com:Hope2333/enve.git`
- Upstream remote: `upstream` -> `git@github.com:MaurycyLiebner/enve.git`
- Default fork branch: `origin/master`
- Latest confirmed `master` commit: `2a1675d7` (`chore: Linux baseline CI recovery`)
- PR #6: `MERGED` at `2026-03-19T09:26:14Z`

## What Is Stable Right Now

- ✅ PR #6 is merged to `master`.
- ✅ One full master validation run passed end to end:
  - run `23288361000`
  - event: `workflow_dispatch`
  - conclusion: `success`
  - duration: `26m2s`
- ✅ One full branch-side baseline run had already passed before merge:
  - run `23282890827`
  - event: `workflow_dispatch`
  - conclusion: `success`
- The workflow file now intends to run `Build (Linux)` on both `workflow_dispatch` and `push`.
- The active Linux lane remains Ubuntu 22.04 with distro Qt 5.15.x packages, qmake, and the vendored `third_party/` stack.
- Local worktree caveat:
  - `git status --short --ignore-submodules=none` still shows dirty `third_party` submodules from local build state (`gperftools`, `libmypaint`, `qscintilla`, `quazip`, `skia`).
  - Do not reset them blindly.

## Current Live CI State

- ✅ **First automatic build on master: SUCCESS** (run `23306463704`)
- ✅ **Multi-Distro Build: SUCCESS** (run `23310875934`)
  - Ubuntu 22.04 (Qt 5.15): ✅ success
  - Debian 12 (Bookworm): ✅ success
  - Arch Linux (Latest Qt): ✅ success
  - Package steps: ⏸️ temporarily disabled (libmypaint header issues)

- PR #7: MERGED at 2026-03-19T16:53:14Z
- Phase 1: **COMPLETE** - automatic Build (Linux) on push is proven working
- Phase 2: **READY TO START** - dependency-boundary hardening

## Practical Interpretation

- ✅ Phase 0: CLOSED (manual validation passed)
- ✅ Phase 1: CLOSED (automatic build on push now proven)
- ✅ PR #6 merged: Code fixes landed
- ✅ PR #7 merged: Auto-trigger enabled
- ✅ Run 23306463704: SUCCESS (first automatic build on master)
- Ready for: Phase 2 dependency-boundary hardening

## Immediate Next Actions

**Phase 1 COMPLETE! Phase 2 IN PROGRESS.**

1. ✅ Root cause diagnosed: workflow fix was committed AFTER PR #6 merge.
2. ✅ PR #7 created and MERGED.
3. ✅ First automatic build run `23306463704`: SUCCESS.
4. ✅ Phase 1 exit criteria PROVEN: automatic Build (Linux) on push is working.
5. ✅ Multi-Distro Build: SUCCESS (Ubuntu/Debian/Arch all building).
6. ✅ Phase 2 STARTED: dependency-boundary hardening in progress.

Phase 2 progress (dependency boundaries):
✅ COMPLETED (all 5 flags + 1 packaging flag):
1. gperftools - ENVE_USE_GPERFTOOLS flag (app.pro + core.pri + Makefile)
2. OpenMP - ENVE_USE_OPENMP flag (core.pri + Makefile)
3. WebEngine - ENVE_USE_WEBENGINE flag (app.pro + Makefile)
4. QScintilla - ENVE_USE_QSCINTILLA flag (app.pro + Makefile)
5. Examples - ENVE_BUILD_EXAMPLES flag (Makefile, already existed)
6. System libmypaint - ENVE_USE_SYSTEM_LIBMYPAINT flag (core.pri + Makefile)

🔄 IN PROGRESS:
1. CI testing (run `23324646178`):
   - Testing minimal dependency build
   - Testing Debian and Arch packaging

Phase 2 approach:
- Add build flags to enable/disable each optional dependency
- Keep default as "all enabled" for backwards compatibility
- Use system libmypaint for CI packaging (avoid vendored build issues)
- Update dependency-ledger.md with ownership and default state
- Do NOT start CMake migration yet
- Do NOT start Qt 6 migration yet
- Do NOT start dependency replacement yet

Multi-Distro Build notes:
- Package steps ENABLED (using system libmypaint)
- Test run: `23324646178`

## Commands Worth Reusing

```sh
git status --short --ignore-submodules=none
gh pr list --repo Hope2333/enve --state all --limit 10
gh pr view 6 --repo Hope2333/enve --json state,mergedAt,headRefName,baseRefName,statusCheckRollup,url
gh run list --repo Hope2333/enve --workflow linux-baseline.yml --limit 12
gh run view 23288282562 --repo Hope2333/enve --json status,conclusion,event,headBranch,url,jobs
gh run view 23288361000 --repo Hope2333/enve --json status,conclusion,event,headBranch,url,jobs
gh api repos/Hope2333/enve/branches/master --jq '.commit.sha'
```

## Guardrails

- Do not commit `.omx/`.
- Do not reset dirty vendored submodules unless the user explicitly asks.
- Phase 1 IS NOW COMPLETE (run 23306463704 proved automatic build on push).
- Phase 2 can now start: dependency-boundary hardening.
- Do NOT start CMake migration, dependency replacement, or Qt 6 work yet.

## Copy-Paste Prompt For The Next AI

```text
Phase 1 COMPLETE! Phase 2 IN PROGRESS.

Current state:
- Phase 0: COMPLETE (manual validation run 23288361000: success)
- Phase 1: COMPLETE (automatic build run 23306463704: success)
- Multi-Distro Build: SUCCESS (run 23310875934)
  - Ubuntu 22.04: ✅ success
  - Debian 12: ✅ success
  - Arch Linux: ✅ success
- Automatic Build (Linux) on push: PROVEN working
- Master commit: latest on chore/linux-baseline-actions
- CI testing in progress: run 23324646178

Phase 2 progress (dependency boundaries):
✅ COMPLETED (all 6 flags):
1. gperftools - ENVE_USE_GPERFTOOLS flag (app.pro + core.pri + Makefile)
2. OpenMP - ENVE_USE_OPENMP flag (core.pri + Makefile)
3. WebEngine - ENVE_USE_WEBENGINE flag (app.pro + Makefile)
4. QScintilla - ENVE_USE_QSCINTILLA flag (app.pro + Makefile)
5. Examples - ENVE_BUILD_EXAMPLES flag (Makefile)
6. System libmypaint - ENVE_USE_SYSTEM_LIBMYPAINT flag (core.pri + Makefile)

Your task:
1. Check CI run 23324646178 results:
   - Did minimal dependency build pass?
   - Did Debian packaging pass?
   - Did Arch packaging pass?

2. If CI passes:
   - Document feature flags in README.md or BUILDING.md
   - Consider Phase 2 complete

3. If CI fails:
   - Check error logs
   - Apply minimal fix
   - Re-trigger CI

Do NOT start:
- CMake migration (wait until all feature flags are tested)
- Qt 6 migration (wait until after Phase 2)
- Dependency replacement (Phase 2 is about boundaries, not replacement)

Read these files for context:
- docs/modernization/ai-handoff.md (this file)
- docs/modernization/dependency-ledger.md (flag status)
- docs/modernization/phased-backlog.md (Phase 2 section)
- Makefile (feature flag definitions)
- src/app/app.pro (WebEngine, QScintilla, gperftools flags)
- src/core/core.pri (OpenMP, libmypaint flags)
```
