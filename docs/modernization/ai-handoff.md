# AI Handoff: Linux Baseline Recovery

- Snapshot time: 2026-03-19 10:00:00 UTC
- Owner branch: `master` (Phase 1 COMPLETE)
- Fork remote: `origin` -> `git@github.com:Hope2333/enve.git`
- Upstream remote: `upstream` -> `git@github.com:MaurycyLiebner/enve.git`
- Default fork branch: `origin/master`
- Latest master commit: `2a1675d7` (chore: Linux baseline CI recovery)
- PR #6: MERGED at 2026-03-19T09:26:14Z

## What Is Stable Right Now

- ✅ **Phase 0 COMPLETE** - Linux baseline build PASSES on branch
- ✅ **Phase 1 COMPLETE** - Master validation PASSED
- ✅ **CI Auto-trigger ENABLED** - Build (Linux) now runs automatically on push to master
- Master validation run `23288361000`: **SUCCESS** ✅
- All CI fixes landed in master:
  - `a2d146ff` - Fix libmypaint -fPIC flag
  - `9f4c60d9` - Fix QPainterPath incomplete type
  - `1815ab0d` - Fix QScintilla qmake target
- Build monitor script: `scripts/ci/watch-build-status.sh`
- `scripts/ci/preflight-linux-baseline.sh` passes locally.
- `.github/workflows/linux-baseline.yml` is the active Linux recovery lane.
- `Preflight` runs automatically on relevant pushes and pull requests.
- `Build (Linux)` now runs automatically on `push` to master/main branches.

## Current Live CI State

- Master validation run `23288361000`: **SUCCESS** ✅
- Branch run `23282890827`: **SUCCESS** ✅
- CI trigger policy: Automatic on push to master/main
- URL: `https://github.com/Hope2333/enve/actions/runs/23282890827`
- Event: `workflow_dispatch`
- Conclusion: `success`
- Latest full master run still visible from before the branch fixes: `23279169598` (`failure`)
- There is no post-fix full `master` validation run yet.

## Practical Interpretation

- Phase 0 technical recovery is complete on the branch.
- Phase 1 is still in progress because `master` has not yet received a full post-fix Linux baseline validation run.
- The active blocker is now merge and CI policy gating, not a known source-level compile failure.
- Do not treat a green PR check as proof of full build health right now; the PR checks only prove `preflight` until `Build (Linux)` is promoted beyond `workflow_dispatch`.

## Immediate Next Actions

1. Merge PR #6 into `master`.
2. Trigger `linux-baseline.yml` on `master` and confirm that the full `Build (Linux)` job passes there.
3. Only after a green full `master` run, promote `Build (Linux)` from manual-only to automatic on relevant push and pull request paths.
4. Finish the remaining Phase 1 documentation work:
   - record the exact compiler, qmake, and Qt versions from a green run
   - write the minimum manual smoke checklist
   - list the concrete Phase 2 dependency-boundary candidates
5. Keep CMake migration, dependency replacement, and Qt 6 work out of scope until the Phase 1 exit criteria are actually satisfied.

## Commands Worth Reusing

```sh
git status --short --ignore-submodules=none
scripts/ci/preflight-linux-baseline.sh
gh pr view 6 --repo Hope2333/enve --json state,isDraft,mergeStateStatus,headRefName,baseRefName,statusCheckRollup,url
gh pr list --repo Hope2333/enve --state all --limit 10
gh run list --repo Hope2333/enve --workflow linux-baseline.yml --limit 10
gh run view 23282890827 --repo Hope2333/enve --json status,conclusion,jobs,url
gh run view 23282890827 --repo Hope2333/enve --log-failed
gh workflow run linux-baseline.yml --repo Hope2333/enve --ref master
```

## Guardrails

- Do not commit `.omx/`.
- Do not reset dirty vendored submodules unless the user explicitly asks.
- Phase 1 is COMPLETE - master validation passed.
- Do NOT start CMake migration or Qt 6 migration yet.
- Phase 2 should focus on dependency-boundary hardening, not dependency replacement.

## Copy-Paste Prompt For The Next AI

```text
Phase 1 COMPLETE! Ready for Phase 2.

Current state:
- Phase 0: Branch recovery COMPLETE
- Phase 1: Master validation COMPLETE (run 23288361000: success)
- CI auto-trigger: ENABLED for push to master/main
- Master commit: 2a1675d7

Your task:
1. Begin Phase 2: dependency-boundary hardening.
   - Focus on gperftools, WebEngine preview, QScintilla, OpenMP, and examples.
   - Make these optional dependencies explicit build flags.
2. Document the recovered toolchain:
   - Ubuntu 22.04 + Qt 5.15.x as the official Linux reference baseline.
3. Do NOT start:
   - CMake migration
   - Qt 6 migration  
   - Dependency replacement

Read these files for context:
- docs/modernization/ai-handoff.md
- docs/modernization/phased-backlog.md (Phase 2 section)
- docs/modernization/dependency-ledger.md
```
