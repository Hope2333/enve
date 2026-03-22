# Dependency Ledger

This local-only ledger tracks sequencing-relevant dependency notes for the active modernization lane.

## Immediate Phase 5 Relevance

- `qmake` remains authoritative during early CMake migration.
- vendored `libmypaint` is a high-coupling dependency and currently exposes generated-artifact parity issues in the CMake path.
- Skia, FFmpeg, and libmypaint remain the highest-risk technical surfaces for Phase 5 and beyond.
- FFmpeg version-window work should be staged:
  - already proven: Ubuntu 22.04 / FFmpeg `4.x` core CMake slice
  - already proven: Ubuntu 24.04 / FFmpeg `6.x` core CMake slice
  - deferred until after a new supervisory decision: FFmpeg `7.1`, `8.0`, and `8.1`

## Deferred Follow-Up

- Packaging/distribution expansion remains outside the active lane.
- Qt 6 remains later than Phase 5 and Phase 6.
- Upstream-detachment README prep, rename evaluation, and logo changes belong to later product/governance planning, not current Phase 5 execution.
