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

- ✅ **First automatic build on master: SUCCESS**
- Run: `23306463704`
- URL: `https://github.com/Hope2333/enve/actions/runs/23306463704`
- Event: `push` (automatic trigger from PR #7 merge)
- Status: `completed`
- Conclusion: `success`
- Duration: ~14 minutes
- This PROVES Phase 1 exit criteria: automatic Build (Linux) on push is now working.

- PR #7: MERGED at 2026-03-19T16:53:14Z

- Previous post-merge `push` run on `master`: `23288282562`
- URL: `https://github.com/Hope2333/enve/actions/runs/23288282562`
- Event: `push`
- Overall conclusion: `success`
- What actually happened:
  - `Preflight`: `success`
  - `Build (Linux)`: `skipped` (workflow at merge commit still had `workflow_dispatch`-only condition)
- Root cause: The workflow fix (adding `|| github.event_name == 'push'`) was committed AFTER the PR #6 merge, not included in PR #6 itself.
- Fix: PR #7 created and MERGED at 2026-03-19T16:53:14Z.

- Full master validation run: `23288361000`
- URL: `https://github.com/Hope2333/enve/actions/runs/23288361000`
- Event: `workflow_dispatch`
- Conclusion: `success`

## Practical Interpretation

- ✅ Phase 0: CLOSED (manual validation passed)
- ✅ Phase 1: CLOSED (automatic build on push now proven)
- ✅ PR #6 merged: Code fixes landed
- ✅ PR #7 merged: Auto-trigger enabled
- ✅ Run 23306463704: SUCCESS (first automatic build on master)
- Ready for: Phase 2 dependency-boundary hardening

## Immediate Next Actions

**Phase 1 COMPLETE! Ready for Phase 2.**

1. ✅ Root cause diagnosed: workflow fix was committed AFTER PR #6 merge.
2. ✅ PR #7 created and MERGED.
3. ✅ First automatic build run `23306463704`: SUCCESS.
4. ✅ Phase 1 exit criteria PROVEN: automatic Build (Linux) on push is working.
5. Next: Begin Phase 2 dependency-boundary hardening.

Phase 2 targets (in priority order):
1. `gperftools` - Make optional (profiling only, not core functionality)
2. WebEngine preview - Make optional (SVG preview feature)
3. QScintilla - Make optional (scripting editor)
4. OpenMP - Make optional (parallelism)
5. Examples - Make optional (sample effects)

Phase 2 approach:
- Add build flags to enable/disable each optional dependency
- Keep default as "all enabled" for backwards compatibility
- Update dependency-ledger.md with ownership and default state
- Do NOT start CMake migration yet
- Do NOT start Qt 6 migration yet
- Do NOT start dependency replacement yet

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
Phase 1 COMPLETE! Ready for Phase 2.

Current state:
- Phase 0: COMPLETE (manual validation run 23288361000: success)
- Phase 1: COMPLETE (automatic build run 23306463704: success)
- Automatic Build (Linux) on push: PROVEN working
- Master commit: ad9df455 (PR #7 merged)

Your task:
1. Begin Phase 2: dependency-boundary hardening.
   - Start with gperftools (lowest coupling, highest maintenance)
   - Add build flag to enable/disable
   - Keep default as enabled for backwards compatibility
2. Update dependency-ledger.md with:
   - Ownership (core vs optional)
   - Default state (on/off)
   - Upgrade notes
3. Do NOT start:
   - CMake migration (wait until qmake feature boundaries extracted)
   - Qt 6 migration (wait until after Phase 2)
   - Dependency replacement (Phase 2 is about boundaries, not replacement)

Read these files for context:
- docs/modernization/ai-handoff.md (this file)
- docs/modernization/phased-backlog.md (Phase 2 section)
- docs/modernization/dependency-ledger.md
- docs/modernization/phase-1-roadmap.md (completed work)
```
- docs/modernization/current-status.md
- docs/modernization/phase-1-roadmap.md
- docs/modernization/phased-backlog.md
- docs/modernization/dependency-ledger.md
```
