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

- Post-merge `push` run on `master`: `23288282562`
- URL: `https://github.com/Hope2333/enve/actions/runs/23288282562`
- Event: `push`
- Overall conclusion: `success`
- What actually happened:
  - `Preflight`: `success`
  - `Build (Linux)`: `skipped` (workflow at merge commit still had `workflow_dispatch`-only condition)
- Root cause: The workflow fix (adding `|| github.event_name == 'push'`) was committed AFTER the PR #6 merge, not included in PR #6 itself.
- Fix: PR #7 created to merge the workflow fix.
- Full master validation run: `23288361000`
- URL: `https://github.com/Hope2333/enve/actions/runs/23288361000`
- Event: `workflow_dispatch`
- Conclusion: `success`
- This means the code path is healthy on `master`, but the automatic trigger policy needs PR #7 to be merged.

## Practical Interpretation

- Phase 0 is closed.
- Manual `master` validation succeeded, which clears the original recovery goal.
- Phase 1 is not cleanly closed yet because the first real `push` run on `master` still skipped `Build (Linux)` even though the workflow now claims to allow `push`.
- The active blocker is no longer source compilation; it is CI policy behavior drift between the workflow definition and the observed run result.

## Immediate Next Actions

1. ✅ Root cause diagnosed: workflow fix was committed AFTER PR #6 merge.
2. ✅ PR #7 created: https://github.com/Hope2333/enve/pull/7
3. Next: Merge PR #7 to master.
4. After merge: Trigger workflow to verify automatic Build (Linux) runs on push.
5. Once one successful non-manual full build on normal change flow is confirmed, mark Phase 1 fully complete.
6. Begin Phase 2 dependency-boundary hardening:
   - `gperftools`
   - WebEngine preview
   - QScintilla
   - OpenMP
   - examples

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
- Do not call Phase 1 complete until a non-manual full build actually runs on normal change flow.
- Do not start CMake migration, dependency replacement, or Qt 6 work yet.
- Phase 2 planning can continue, but Phase 2 implementation should wait until the CI trigger discrepancy is closed.

## Copy-Paste Prompt For The Next AI

```text
Linux baseline recovery is technically successful on master, but Phase 1 still has one unresolved gate.

Current state:
- PR #6 is merged to master
- Latest confirmed master commit: 2a1675d7
- Manual master validation run 23288361000 succeeded
- The first post-merge push run 23288282562 skipped Build (Linux) and only ran Preflight
- The workflow file now intends to run Build (Linux) on push, but that behavior is not yet proven

Your task:
1. Diagnose why Build (Linux) was skipped on push run 23288282562.
2. Get one successful push-driven full build on master.
3. Only then mark Phase 1 complete and begin Phase 2 dependency-boundary hardening.

Read these files for context:
- docs/modernization/ai-handoff.md
- docs/modernization/current-status.md
- docs/modernization/phase-1-roadmap.md
- docs/modernization/phased-backlog.md
- docs/modernization/dependency-ledger.md
```
