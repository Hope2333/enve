# Phase 5 Roadmap

## Goal

Start the CMake migration without destabilizing the working qmake release path.
Phase 5 begins with a narrow, auditable `src/core` slice instead of immediate whole-repo parity.

## Current Starting Point

- qmake remains the authoritative build generator.
- `master` head is `83d69750`.
- qmake baseline CI remains green:
  - `23372328765` Linux Baseline Build: `success`
  - `23372328779` Multi-Distro Build: `success`
- Root + `src/core` CMake configure succeeded locally.
- The original vendored `libmypaint` generated-header blocker is no longer the leading issue; a fix landed in `src/core/CMakeLists.txt`.
- A follow-up compatibility batch also landed, and hosted-runner CMake/core proof now exists for the Ubuntu 22.04 baseline slice.
- The execution strategy should now prefer hosted-runner proof over long local builds on a constrained machine.
- A narrow hosted-runner proof path now exists at `.github/workflows/cmake-core.yml`.
- The first run `23377197769` got past `Configure CMake` and failed in compilation on missing vendored `libmypaint/mypaint-config.h`.
- Later runs `23377735693`, `23377739478`, and `23377916687` are green for the Ubuntu 22.04 baseline environment.
- FFmpeg `6.x` hosted-target proof is now also green via `23386697350` and `23386717779` on Ubuntu 24.04.

## Workstreams

### 1. Scope Lock: Core First

- Treat `src/core` as the only implementation target in the current batch.
- Do not start `src/app`, `examples`, packaging, or install-layout parity.
- Keep qmake as fallback until `envecore` parity is materially proven.

### 2. Third-Party Precondition Parity

- Make qmake/autotools-era generated-artifact assumptions explicit in the CMake path.
- Current first target is now broader vendored `libmypaint` parity:
  - generated header `mypaint-brush-settings-gen.h`
  - exported/include-visible `mypaint-config.h`
  - clean-runner include-path assumptions under `src/core/libmypaintincludes.h`
- Re-verify before assuming the next blocker is FFmpeg or source/API drift.

### 3. Local Proof Before CI

- Local verification remains useful, but only for fast sanity checks.
- On this workstation, cap validation builds at `-j3` to preserve usable headroom.
- The current batch is now narrow enough to justify a clean-room GitHub Actions CMake/core proof path with downloadable logs/artifacts.
- Keep that proof path narrow and phase-specific; do not contaminate the existing qmake baseline lane.
- GitHub-hosted runner sizing should be treated as an input to workflow design:
  - standard `ubuntu-22.04` hosted runners are currently documented by GitHub as `4 vCPU / 16 GB RAM / 14 GB SSD` for public repositories
  - the corresponding private-repo baseline is smaller, so workflow assumptions should stay explicit instead of implicit

### 4. Version-Band Hardening After First Proof

- Treat Ubuntu 22.04 / FFmpeg `4.x` proof as achieved for the current core slice.
- Treat actual FFmpeg `6.x` support as achieved for the current core slice.
- Queue FFmpeg `7.1`, `8.0`, and `8.1` compatibility only after a new supervisory decision authorizes widening beyond the current batch.
- Record runner/image assumptions explicitly when widening the compatibility band.

### 5. Supervisory Gate Before Next Batch

- The current core-only validation batch has reached its success criteria.
- Do not assume the next batch is automatically FFmpeg version widening.
- Re-evaluate whether the next Phase 5 batch should instead move to the next migration boundary, such as app-side CMake audit/planning.

## Immediate Next Actions

1. Treat the current batch as complete evidence for core-only CMake validation
2. Decide the next Phase 5 batch before any new implementation begins
3. If execution resumes, keep local sanity at `-j3`
4. Do not widen to FFmpeg `7.1` / `8.0` / `8.1` without an explicit supervisory go

## Non-Goals

- No qmake removal
- No `src/app` CMake migration yet
- No examples or packaging migration yet
- No AppImage or Flatpak work
- No distro-matrix expansion
- No Qt 6 work
- No dependency replacement
- No README detachment/rename/logo implementation in Phase 5
