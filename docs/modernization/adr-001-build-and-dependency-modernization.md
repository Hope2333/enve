# ADR 001: Build and Dependency Modernization Strategy

- Status: Accepted
- Date: 2026-03-19

## Context

The current delivery chain is tightly coupled to aging infrastructure and manual setup:

- CI is still defined in Travis and pinned to Ubuntu Xenial, `g++-7`, and Qt `5.12.4` in `.travis.yml`.
- Local setup instructions still depend on hand-built third-party libraries and manual tool installation in `Source and building info.md`.
- The qmake projects (`enve.pro`, `src/app/app.pro`, `src/core/core.pro`) directly wire Skia, libmypaint, QuaZip, FFmpeg, QScintilla, and gperftools through `src/core/core.pri`.
- Rendering, media, and packaging concerns are spread across both `src/core/` and `src/app/`, so a single-step migration would change too many failure variables at once.

## Implementation Status

- A GitHub Actions baseline workflow now exists at `.github/workflows/linux-baseline.yml`.
- Linux bootstrap scripts now exist in `scripts/ci/`, plus a container recipe at `docker/linux-baseline.Dockerfile`.
- Preflight validation already runs automatically.
- One full branch-side Linux baseline build has already passed end to end.
- One full manual `master` validation run has now passed end to end.
- Automatic non-manual `master` push builds are now proven through run `23306463704`.
- The active implementation lane is now Phase 2 dependency-boundary hardening on `chore/linux-baseline-actions`, with branch-side CI validating the new feature flags.

## Decision

Modernize in phases and keep each phase single-purpose:

1. Reproduce the current build in a clean environment and record the exact dependency set.
2. Replace Travis with a modern CI pipeline that proves one Linux release build.
3. Maintain a dependency ledger before changing versions or providers.
4. Upgrade the toolchain first while staying on qmake and a Qt 5.x compatibility lane.
5. Add smoke tests for startup, sample loading, import/export, and render paths.
6. Reduce or optionalize non-essential dependencies.
7. Migrate from qmake to CMake only after the build is reproducible and observable.
8. Evaluate Qt 6 only after the CMake and smoke-test baseline is stable.

## Options Considered

### Option A: Big-bang move to CMake, Qt 6, and latest dependencies

Rejected. This would mix infrastructure, API, ABI, and packaging changes in one step.

### Option B: Migrate to CMake first

Rejected for now. qmake currently also carries platform flags, version injection, and third-party linkage, so replacing it before stabilizing the dependency graph increases debugging cost.

### Option C: Phased compatibility-first migration

Accepted. It minimizes change surface, improves rollback options, and creates clear exit criteria per phase.

## Phase Exit Criteria

- Baseline: a clean machine or container can build the current app from documented steps.
- CI refresh: one Linux job builds on every change and preserves logs/artifacts.
- Toolchain refresh: newer compiler and Qt 5.x build without feature loss.
- Smoke tests: the app launches, opens a sample, renders, and completes one import/export path.
- Build-system migration: CMake produces equivalent binaries before qmake is retired.
- Qt 6 evaluation: all current optional dependencies have a clear compatibility story.

## Consequences

This path is slower than a rewrite, but it is safer for a rendering-heavy desktop application with native dependencies. It also turns future upgrades into routine maintenance instead of another rescue project.
