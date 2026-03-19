# AI Handoff: Linux Baseline Recovery

- Snapshot time: 2026-03-19 06:25:00 UTC
- Owner branch: `chore/linux-baseline-actions`
- Fork remote: `origin` -> `git@github.com:Hope2333/enve.git`
- Upstream remote: `upstream` -> `git@github.com:MaurycyLiebner/enve.git`
- Default fork branch: `origin/master`
- Head commit: `b9f5a258` (Update handoff with run 23282109523 status.)

## What Is Stable Right Now

- The top-level worktree only has documentation edits plus untracked `.omx/`.
- If checked with `git status --short --ignore-submodules=none`, several `third_party` submodules appear dirty from local build state (`gperftools`, `libmypaint`, `quazip`, `skia`). Do not reset them blindly during CI recovery.
- `.omx/` should remain uncommitted.
- Documentation was already refreshed in commit `22ad984a` (`Refresh modernization documentation.`).
- The latest CI fix commit is `9f4c60d9` (`Fix QPainterPath incomplete type in graphanimator.h.`), following `1815ab0d` (`Fix QScintilla qmake target in baseline build.`).
- Build monitor script added: `scripts/ci/watch-build-status.sh` (usage corrected).
- `scripts/ci/preflight-linux-baseline.sh` passes locally.
- `.github/workflows/linux-baseline.yml` is the active Linux recovery lane.
- `Preflight` runs automatically on relevant pushes and pull requests.
- `Build (Linux)` still runs only through `workflow_dispatch`.

## Current Live CI State

- Latest workflow run: `23282109523`
- URL: `https://github.com/Hope2333/enve/actions/runs/23282109523`
- Status at snapshot time: `in_progress` (Build baseline step running)
- Updated at: `2026-03-19T06:03:14Z`
- Triggered by: commit sequence `9f4c60d9` -> `f551f1c7` -> `c89a5232` -> `b9f5a258`
- Previous run `23281619400`: `completed` / `failure` / failed at `graphanimator.h:105` - `QPainterPath` incomplete type
- Previous run `23280524470`: `completed` / `failure` / failed at core compilation due to `QPainterPath` incomplete type

## Failure Timeline Already Investigated

| Run | Branch | Duration | First confirmed failure | Status |
| --- | --- | --- | --- | --- |
| `23277656350` | `master` | 6m33s | `third_party/skia/gn/is_clang.py`: `TypeError: a bytes-like object is required, not 'str'` | Fixed by later patch |
| `23277985241` | `master` | 6m21s | ICU `make_data_assembly.py`: Python 2 `print` syntax | Fixed by later patch |
| `23278302240` | `master` | 5m41s | ICU `make_data_assembly.py`: same `print` failure after workflow restructuring | Fixed by later patch |
| `23278882899` | `master` | 5m59s | ICU `make_data_assembly.py`: same `print` failure before matcher fix | Fixed by later patch |
| `23279169598` | `master` | 5m58s | ICU `make_data_assembly.py`: `input_data.find("icudt")` bytes/str mismatch | Fixed by latest patch chain |
| `23279763328` | `chore/linux-baseline-actions` | 15m | `qmake` usage failure while building QScintilla | Fixed in commit `1815ab0d` |
| `23280524470` | `chore/linux-baseline-actions` | 17m | Core compile failure: `QPainterPath` incomplete type in `graphanimator.h` | Fixed in commit `9f4c60d9` |
| `23281619400` | `chore/linux-baseline-actions` | 15m | Core compile failure: `QPainterPath` incomplete type in `graphanimator.h` (same error, fix commit not yet pushed when run started) | Fix pushed in `c89a5232`, new run `23282109523` triggered |
| `23282109523` | `chore/linux-baseline-actions` | TBD | Validation run for commits including `9f4c60d9` | Just triggered |

## What The Latest Script Change Actually Does

The current `scripts/ci/build-linux-baseline.sh` now applies four Skia Python 3 compatibility shims around ICU data generation:

1. `print "Generated " + output_file` -> `print(...)`
2. `input_data.find("icudt")` -> `input_data.find(b"icudt")`
3. `version_number = input_data[n + 5:n + 7]` -> decode to ASCII text
4. `hexlify(...).upper().lstrip('0')` -> decode to ASCII before string operations

This builds on the earlier `is_clang.py` bytes fix and the post-sync patching flow already present in the branch.

## Previously Confirmed Blocker

The latest run failed after the Python 3 fixes were applied successfully. The log shows:

- ICU assembly generation completed: `Generated gen/third_party/icu/icudtl_dat.S`
- The build continued deep into Skia and later through gperftools.
- The final failing output is the plain `qmake` help text, which means `qmake` was invoked without a usable project file.

This strongly points to `build_qscintilla()` in `scripts/ci/build-linux-baseline.sh`:

- The script currently does:
  - `pushd "${ROOT_DIR}/third_party/qscintilla"`
  - `qmake CONFIG+=release`
- The actual project file is `third_party/qscintilla/Qt4Qt5/qscintilla.pro`.
- Local validation confirmed:
  - `cd third_party/qscintilla && qmake CONFIG+=release` fails with the same help output.
  - `cd third_party/qscintilla/Qt4Qt5 && qmake qscintilla.pro CONFIG+=release` succeeds.

Conservative diagnosis was confirmed locally, and the fix is now committed in `1815ab0d` by building QScintilla from `third_party/qscintilla/Qt4Qt5/` with an explicit `qscintilla.pro` target.

## Fixed Blocker: QPainterPath Incomplete Type

Run `23280524470` and `23281619400` both failed in `src/core` compilation with the same error:

First confirmed compile error:

- `src/core/Animators/graphanimator.h:105:22: error: field 'fPath' has incomplete type 'QPainterPath'`
- Follow-up error at `graphanimator.h:102`: invalid use of incomplete type `QPainterPath`

Root cause:

- `graphanimator.h` stores `QPainterPath` by value and constructs it inline.
- The header includes `animator.h` but did not include `<QPainterPath>`.
- The compiler sees only the forward declaration that arrives transitively from Qt headers.

Fix applied in commit `9f4c60d9`:

1. Added `#include <QPainterPath>` to `src/core/Animators/graphanimator.h`.
2. Verified with `scripts/ci/preflight-linux-baseline.sh`.
3. Run `23281619400` was triggered before the fix commit was pushed to remote.
4. Fix has been pushed in commit `c89a5232`.
5. New validation run `23282109523` triggered.

Awaiting CI results from run `23282109523` to confirm this fix unblocks the build.

## Practical Interpretation

- The baseline lane is no longer blocked at the first obvious Python 3 incompatibility.
- The QScintilla `qmake` path issue is confirmed fixed.
- The current blocker is now a project compile issue exposed by the newer Linux/Qt 5.15 environment.
- Since the cache key includes `scripts/ci/build-linux-baseline.sh`, the just-finished run was again a cold validation path through the full baseline chain.

## Immediate Next Actions

**Current: Monitoring run `23282109523` in progress.**

Use the monitor script to wait for completion:
```bash
./scripts/ci/watch-build-status.sh
```

1. If it passes:
   - Open a PR from `chore/linux-baseline-actions` to `master`.
   - Trigger `linux-baseline.yml` on `master` after merge.
   - Consider promoting `Build (Linux)` from manual to automatic.
2. If it fails:
   - Capture the new first compile error from the workflow log.
   - Patch only the minimal next blocker.
   - Re-run the workflow and repeat.

## Commands Worth Reusing

```sh
git status --short
scripts/ci/preflight-linux-baseline.sh
gh run list --repo Hope2333/enve --workflow linux-baseline.yml --limit 10
gh run view 23280524470 --repo Hope2333/enve --json status,conclusion,jobs,url
gh run view 23280524470 --repo Hope2333/enve --log-failed
gh workflow run linux-baseline.yml --repo Hope2333/enve --ref chore/linux-baseline-actions
gh pr list --repo Hope2333/enve --state all --limit 10
```

## Guardrails

- Do not commit `.omx/`.
- Do not mix unrelated documentation work into the next CI fix commit.
- Keep changes focused on baseline recovery; do not start Qt 5.15, CMake, or dependency replacement work yet.
- Prefer explicit script-side compatibility shims over invasive vendor edits unless a later failure proves that insufficient.
- The QScintilla `qmake` path issue is already fixed in `1815ab0d`; do not re-debug that unless a later run disproves it.

## Copy-Paste Prompt For The Next AI

```text
Continue the Linux baseline CI recovery for /home/miao/develop/enve.

Read these files first:
- docs/modernization/ai-handoff.md
- docs/modernization/README.md
- docs/modernization/current-status.md
- .github/workflows/linux-baseline.yml
- scripts/ci/build-linux-baseline.sh

Current branch: chore/linux-baseline-actions
Current fork remote: origin -> git@github.com:Hope2333/enve.git
Do not commit .omx/.

Known facts:
- Documentation refresh is already committed as 22ad984a.
- QPainterPath fix committed as 9f4c60d9.
- Workflow run 23282109523 is the validation run for the fix.
- Earlier failures were:
  - 23277656350: Skia gn/is_clang.py bytes/str issue
  - 23277985241 / 23278302240 / 23278882899: ICU make_data_assembly.py print syntax
  - 23279169598: ICU make_data_assembly.py input_data.find("icudt") bytes/str issue
  - 23279763328: QScintilla build step invoked bare qmake from third_party/qscintilla root
  - 23280524470: core compile fails because graphanimator.h uses QPainterPath as a complete type without including <QPainterPath>
  - 23281619400: same QPainterPath error (run started before fix was pushed)

Your task:
1. Check the status of run 23282109523.
2. If it passed, open a PR to master and trigger the workflow on master.
3. If it failed, capture the new first compile error and patch only the minimal next blocker.
4. Keep the work focused on Linux baseline recovery only.
```
