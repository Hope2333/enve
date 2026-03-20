# Third-Party Build Stamp Files

**Date:** 2026-03-20
**Phase:** 3 of 7
**Status:** IMPLEMENTED

## Purpose

Stamp files track the build state of third-party dependencies, enabling incremental builds and skipping unchanged dependencies.

## How It Works

Each dependency has a corresponding stamp file:

```
build/Release/stamps/third_party/
├── skia.stamp
├── libmypaint.stamp
├── quazip.stamp
├── gperftools.stamp
└── qscintilla.stamp
```

When you run `make build`:
1. Make checks if the stamp file exists
2. If yes and source files unchanged → **skip build**
3. If no or source files changed → **rebuild**

## Usage

### Build All Dependencies

```bash
cd third_party
make build
```

First run: builds all dependencies
Second run: skips all (already built)

### Build Single Dependency

```bash
cd third_party
make skia      # Build only Skia
make quazip    # Build only QuaZip
```

### Clean Build State

```bash
cd third_party
make clean     # Remove all stamp files
make clean-all # Remove stamp files + build artifacts
```

### Force Rebuild

```bash
cd third_party
make clean && make build  # Clean and rebuild everything
```

## Dependency Tracking

Stamp files depend on source files:

| Dependency | Tracked Sources |
|------------|-----------------|
| Skia | `skia/*` (all files in skia directory) |
| libmypaint | `libmypaint/*` |
| QuaZip | `quazip/*` |
| gperftools | `gperftools/*` |
| QScintilla | `qscintilla/*` |

**Note:** Currently uses wildcard (`*`) for simplicity. Can be refined to track specific source files only.

## Integration with Main Build

The main Makefile calls `third_party/Makefile`:

```bash
# From project root
make stage  # Builds third_party + enve
```

Stamp files ensure third_party is only rebuilt when sources change.

## CI/CD Benefits

### Before Stamp Files

```yaml
- name: Build third-party
  run: make -C third_party build  # Always rebuilds everything
```

**Time:** ~10-15 minutes (full rebuild every time)

### After Stamp Files

```yaml
- name: Build third-party
  run: make -C third_party build  # Skips if cached
```

**Time:** ~0 minutes (if cached from previous run)

### CI Caching Strategy

```yaml
- name: Cache third-party builds
  uses: actions/cache@v3
  with:
    path: |
      build/Release/stamps/third_party
      third_party/skia/out
      third_party/libmypaint/.libs
      third_party/quazip/quazip
      third_party/gperftools/.libs
      third_party/qscintilla/Qt4Qt5
    key: third-party-${{ hashFiles('third_party/**/*') }}
```

## Troubleshooting

### Dependency Not Rebuilding

If a dependency should rebuild but doesn't:

```bash
# Check if stamp file exists
ls build/Release/stamps/third_party/*.stamp

# Remove specific stamp
rm build/Release/stamps/third_party/skia.stamp

# Rebuild that dependency
make skia
```

### Stamp File Exists But Library Missing

This can happen if build was interrupted:

```bash
# Clean and rebuild
make clean
make skia  # or specific dependency
```

### Verbose Build Output

To see what make is doing:

```bash
make build V=1  # If supported
# or
make -d build   # Debug mode (very verbose)
```

## Migration Notes

### Old Behavior

```makefile
.PHONY: skia
skia:
	cd skia && python tools/git-sync-deps && ...
```

**Problem:** Always rebuilds, even if nothing changed

### New Behavior

```makefile
skia: $(STAMP_DIR)/skia.stamp

$(STAMP_DIR)/skia.stamp: $(STAMP_DIR) skia/*
	cd skia && python tools/git-sync-deps && ...
	touch $@
```

**Benefit:** Skips if sources unchanged

## Future Improvements

1. **Granular dependency tracking:**
   - Track specific source files instead of `*`
   - Use `.d` dependency files

2. **Hash-based invalidation:**
   - Store source hash in stamp file
   - Rebuild if hash changes

3. **Parallel builds:**
   - Independent dependencies can build in parallel
   - `make -j4 build`

## References

- [Build Output Organization](build-output-organization.md)
- [Phase 3 Toolchain Survey](phase-3-toolchain-survey.md)
- [Phased Backlog](phased-backlog.md)
