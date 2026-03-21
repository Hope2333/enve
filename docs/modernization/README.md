# Build and Dependency Modernization

This directory tracks the staged recovery of a reproducible build before larger moves such as CMake or Qt 6.

AI working-state docs for this lane now live under `.ai/modernization/` and are intentionally local-only / not committed. This `docs/modernization/` directory should stay focused on stable human-facing operational reference.
If tracked bridge files with old AI-state names still exist here, do not use them as the active relay source of truth; use `docs/ai-relay.md` and the `.ai/modernization/` paths it lists.

## Start Here

- [Repository-wide AI relay protocol](../ai-relay.md): global handoff rules that every AI session must read and maintain.
- [AI collaboration protocol](../ai-collaboration.md): role split, cadence, and prompt templates for supervisory and execution AIs.
- Private AI handoff/state files live under local-only `.ai/modernization/`.
- [Phase 3 toolchain survey](phase-3-toolchain-survey.md): current CMake-skeleton and toolchain context.
- [ADR 001](adr-001-build-and-dependency-modernization.md): the migration strategy and why it is phased.
- [Baseline build specification](baseline-build-spec.md): the target Linux baseline, scripts, and success criteria.
- Stable human-oriented build references stay in this directory; volatile AI planning/relay files do not.

## Current Working Rules

- Linux is the first recovery target; do not mix Linux baseline work with Windows or macOS changes.
- `scripts/ci/build-linux-baseline.sh` is the source of truth for the current bootstrap flow.
- `.github/workflows/linux-baseline.yml` remains the active baseline CI lane. `preflight` runs automatically, the main Linux build is proven on `push` to `master`, and the current follow-up work is CMake migration start without destabilizing the qmake baseline.
- `.github/workflows/linux-multi-distro.yml` is currently compile-compatibility evidence for Ubuntu, Debian, and Arch; it is not yet the release-packaging lane.
- `docker/linux-baseline.Dockerfile` mirrors the CI package lane and is the easiest clean-room starting point.
- `PROXY` support exists for restricted environments, but it is not a mandatory baseline assumption.
- qmake remains the authoritative build path until Phase 5 proves a narrow CMake slice locally.

## Quick Commands

Run the lightweight validation locally:

```sh
scripts/ci/preflight-linux-baseline.sh
```

Run the baseline build locally after installing packages:

```sh
scripts/ci/install-linux-build-deps.sh
ENVE_JOBS=2 scripts/ci/build-linux-baseline.sh
scripts/ci/smoke-linux-baseline.sh
```

Trigger the GitHub Actions build manually:

```sh
gh workflow run linux-baseline.yml --ref master
```

Wait for a GitHub Actions run to finish with the local AI wait tool:

```sh
.ai/tools/watch-build-status.sh Hope2333/enve 23365762835 45
```

Important:
- parameter order is `REPO RUN_ID INTERVAL`
- do not swap `Hope2333/enve` and the numeric run ID
- if you want to sleep before watching, keep the same order:

```sh
sleep 120 && .ai/tools/watch-build-status.sh Hope2333/enve 23365762835 45
```
