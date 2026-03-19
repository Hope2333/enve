# Modernization Status

- Last updated: 2026-03-19 17:10:00 UTC
- Overall status: **Phase 1 COMPLETE**. Ready for Phase 2.

## Landed So Far

- ✅ PR #6 MERGED to master (commit 2a1675d7) at 2026-03-19T09:26:14Z
- ✅ PR #7 MERGED to master (commit ad9df455) at 2026-03-19T16:53:14Z
- ✅ Manual master validation run `23288361000`: **SUCCESS**
- ✅ Automatic build on push run `23306463704`: **SUCCESS**
- ✅ CI auto-trigger PROVEN working for push to master/main
- A GitHub Actions workflow exists at `.github/workflows/linux-baseline.yml`.
- CI helper scripts exist in `scripts/ci/` for dependency install, preflight, build, smoke checks, and run monitoring.
- A clean Ubuntu 22.04 container recipe exists at `docker/linux-baseline.Dockerfile`.
- The baseline build script supports practical recovery knobs such as `ENVE_JOBS`, `ENVE_BUILD_EXAMPLES`, `ENVE_SKIP_THIRD_PARTY`, `ENVE_UPDATE_SUBMODULES`, and `ENVE_USE_PREBUILT_SKIA`.
- The baseline script now patches the known Skia Python 3 bootstrap issues in `gn/is_clang.py` and ICU `make_data_assembly.py`.
- QPainterPath incomplete type issue in `graphanimator.h` was fixed in commit `9f4c60d9`.
- libmypaint shared-library linkage was fixed with `-fPIC` in commit `a2d146ff`.
- Workflow auto-trigger on push was enabled in commit `4231103e`.
- Repository-wide relay, collaboration, and roadmap docs now exist under `docs/ai-relay.md`, `docs/ai-collaboration.md`, and `docs/modernization/`.
- Multi-distro packaging support added:
  - PKGBUILD for Arch Linux
  - GitHub Actions for Ubuntu/Debian/Arch
  - AppImage, .deb, and .pkg.tar.gz packaging scripts

## Current CI Behavior

- `preflight` runs automatically on pull requests and relevant pushes.
- `Build (Linux)` runs automatically on `push` to master/main branches (PROVEN).
- Latest automatic build run `23306463704`: **SUCCESS** ✅
- Latest manual validation run `23288361000`: **SUCCESS** ✅

## Active Blockers

- None! Phase 1 exit criteria met and proven.

## Next Steps (Phase 2)

1. Begin dependency-boundary hardening:
   - Start with gperftools (lowest coupling, highest maintenance)
   - Add build flags for optional dependencies
   - Keep default as "all enabled" for backwards compatibility
2. Update dependency-ledger.md:
   - Mark ownership (core vs optional)
   - Document default state (on/off)
   - Add upgrade notes
3. Do NOT start:
   - CMake migration (wait until qmake feature boundaries extracted)
   - Qt 6 migration (wait until after Phase 2)
   - Dependency replacement (Phase 2 is about boundaries, not replacement)
