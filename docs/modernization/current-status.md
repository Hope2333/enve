# Modernization Status

- Last updated: 2026-03-21 23:45:00 UTC
- Overall status: **Phase 5 Build-System Migration IN PROGRESS on `master`.**

## Landed So Far

- ✅ Phase 1 CI replacement completed on `master`
- ✅ Phase 2 dependency-boundary hardening completed on `master`
- ✅ Phase 3 toolchain consolidation completed on `master`
- ✅ Phase 4 verification upgrade completed on `master`
- ✅ Phase 5 kickoff landed on `master` in `c2de8072`
  - Linux Baseline Build `23372328765`: `success`
  - Multi-Distro Build `23372328779`: `success`
- ✅ Phase 5 FFmpeg 6.x compatibility batch is now on `master` through `28a2d2ee`
  - vendored `libmypaint` generated-header generation added in `src/core/CMakeLists.txt`
  - FFmpeg 6.x updates landed in `samples`, `esoundsettings`, `soundreader`, `audiostreamsdata`, and `videostreamsdata`
- ✅ Narrow CMake/core Actions validation path added on `master` in `f5ddeb92`
  - first clean-room run `23377197769` reached `Build envecore`
  - later runs `23377735693`, `23377739478`, and `23377916687` are green for the Ubuntu 22.04 baseline core slice
- ✅ FFmpeg `6.x` clean-room proof is now green on Ubuntu 24.04:
  - `23386697350` (`push`): `success`
  - `23386717779` (`workflow_dispatch`): `success`

## Active Blocker

- Current qmake CI is green.
- Current Phase 5 core-only validation batch is green on both:
  - Ubuntu 22.04 baseline
  - Ubuntu 24.04 / FFmpeg `6.x`
- There is no immediate technical blocker on the current batch.
- The lane is now at a supervisory decision gate, not an active red lane.

## Next Steps

1. Keep local `-j3` sanity builds only for fast confirmation.
2. Decide whether the next Phase 5 batch should target app-side CMake boundary planning/audit or explicit FFmpeg `7.x` / `8.x` widening.
3. Do not start the next batch until that sequencing decision is written into the handoff/roadmap.
