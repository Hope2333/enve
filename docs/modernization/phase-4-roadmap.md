# Phase 4 Roadmap

## Goal

Reduce reliance on ad hoc manual testing by adding the smallest repeatable verification improvements that materially lower merge risk without reopening build-system, packaging, or Qt-migration scope.

## Current Starting Point

- Phase 1 is complete:
  - manual `master` validation run `23288361000` passed
  - automatic `push` build on `master` run `23306463704` passed
- Phase 2 is complete and merged to `master`.
- Phase 3 is complete on `master`:
  - Linux Baseline Build `23357140865` (`push`) passed
  - Multi-Distro Build `23357140871` (`push`) passed
  - Linux Baseline Build `23357156824` (`workflow_dispatch`) passed
  - Multi-Distro Build `23357158851` (`workflow_dispatch`) passed
- Existing automated coverage already includes:
  - `scripts/ci/preflight-linux-baseline.sh`
  - `scripts/ci/build-linux-baseline.sh`
  - `scripts/ci/smoke-linux-baseline.sh`
  - compile validation on Ubuntu 22.04, Debian 12, and Arch Linux
- Existing scope boundaries already include:
  - package jobs intentionally disabled in `.github/workflows/linux-multi-distro.yml`
  - CMake skeleton present, but no active CMake migration lane
  - `PROXY` support exists in `Makefile`, but should not be treated as mandatory

## Workstreams

### 1. Verification Inventory And Evidence Capture

- Map what the current baseline smoke actually proves:
  - startup
  - artifact existence
  - non-crash build completion
- Inventory what is still unproven:
  - import/export paths
  - render output
  - media handling
  - GPU-sensitive behavior
- Collect logs and reuse existing scripts before inventing new workflow structure.

### 2. Low-Cost Automated Smoke Expansion

- Extend the current baseline smoke path before adding more jobs.
- Prefer high-signal checks that are cheap and deterministic:
  - executable and library existence
  - app startup or headless non-crash path if available
  - one narrow import/export path
  - one narrow render or media path if it can be made stable
- Keep runtime cost proportional to the current baseline CI budget.

### 3. Manual Verification Contract

- Define the manual checks that automation should not pretend to cover yet.
- Minimum manual areas:
  - GPU-sensitive startup/render behavior
  - SVG/ORA/KRA import or link workflows
  - one focused media path
- Make the manual contract copy-paste ready for future PRs.

### 4. Multi-Distro Boundary Discipline

- Treat Multi-Distro Build as compile-compatibility evidence.
- Do not treat skipped package jobs as a Phase 4 blocker.
- Do not re-enable packaging here unless the phase is explicitly redefined.
- Record packaging follow-up items, but keep them in a deferred lane.

### 5. Environment Assumptions Cleanup

- Treat `PROXY` support as optional infrastructure, not as a required default.
- Leave proxy configuration unset unless the environment or logs prove it is needed.
- Avoid encoding localhost-only network assumptions into new verification scripts.

## Exit Criteria

Phase 4 is complete when:

1. The baseline workflow proves more than build success and artifact existence alone.
2. At least one focused path in each of these areas is either automated or explicitly assigned to manual verification:
   - import/export
   - render
   - media
3. GPU-sensitive changes have a documented manual verification contract.
4. CI cost remains controlled and does not require new distro/package fan-out.
5. The relay docs clearly record what is automated, what remains manual, and what stays deferred.

## Non-Goals

- No packaging redesign
- No AppImage or Flatpak rollout
- No distro-matrix expansion beyond the current Ubuntu/Debian/Arch build coverage
- No real CMake migration beyond the existing skeleton and reference docs
- No Qt 6 migration or spike
- No dependency replacement campaign
- No multilingual UI implementation
- No KDE/Plasma theme integration
- No file-format redesign or container rewrite
- No Blender integration
- No AE-feature-gap closure effort

## Suggested Execution Order

1. Audit `scripts/ci/smoke-linux-baseline.sh` and current workflow evidence
2. Identify the smallest missing high-signal checks
3. Implement one or two verification improvements only
4. Write the manual verification contract for the remaining risky paths
5. Pause after the next green verification improvement and hand back for review

## Risk Notes

- GUI-heavy verification can become flaky quickly if it assumes a desktop or GPU that CI does not reliably provide.
- Import/export and media checks can accidentally become broad integration tests if they are not tightly scoped.
- Packaging, AppImage, Flatpak, and more distro work can hijack the lane because they are visible but not phase-critical.
- `PROXY ?= http://localhost:7890` is convenient for restricted environments, but it is not a safe default assumption for every execution context.
- Starting product-scope work such as localization, theme integration, file-format redesign, Blender interoperability, or AE-gap closure here would break the current handoff trail and waste the present CI evidence.
