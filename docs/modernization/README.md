# Build and Dependency Modernization

This directory tracks the staged recovery of a reproducible build before larger moves such as CMake or Qt 6.

## Start Here

- [Repository-wide AI relay protocol](../ai-relay.md): global handoff rules that every AI session must read and maintain.
- [AI collaboration protocol](../ai-collaboration.md): role split, cadence, and prompt templates for supervisory and execution AIs.
- [AI handoff](ai-handoff.md): timestamped coding handoff with run history, current branch state, and a copy-paste continuation prompt.
- [Current status](current-status.md): what is already landed, what still fails, and what should happen next.
- [Phase 2 roadmap](phase-2-roadmap.md): active medium-term plan for dependency-boundary hardening.
- [Phase 1 roadmap](phase-1-roadmap.md): historical plan for CI replacement and baseline formalization.
- [ADR 001](adr-001-build-and-dependency-modernization.md): the migration strategy and why it is phased.
- [Baseline build specification](baseline-build-spec.md): the target Linux baseline, scripts, and success criteria.
- [Dependency ledger](dependency-ledger.md): current dependencies, coupling level, and first action for each.
- [Phased backlog](phased-backlog.md): the execution order after baseline recovery.

## Current Working Rules

- Linux is the first recovery target; do not mix Linux baseline work with Windows or macOS changes.
- `scripts/ci/build-linux-baseline.sh` is the source of truth for the current bootstrap flow.
- `.github/workflows/linux-baseline.yml` is the active CI lane. `preflight` runs automatically and the main Linux build is proven on `push` to `master`.
- `docker/linux-baseline.Dockerfile` mirrors the CI package lane and is the easiest clean-room starting point.

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
