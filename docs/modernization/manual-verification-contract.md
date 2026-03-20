# Manual Verification Contract

**Date:** 2026-03-20
**Phase:** 4 of 7
**Status:** DRAFT

## Purpose

This document defines the manual verification checks that cannot (yet) be automated in CI. It applies to changes that affect GPU-sensitive rendering, file format import/export, and media handling.

## When Manual Verification Is Required

Manual verification is required for PRs that touch:

1. **GPU rendering paths:**
   - Skia backend changes
   - OpenGL context creation or cleanup
   - Surface creation or format changes
   - Shader compilation or linking

2. **File import/export:**
   - `.ev` / `.xev` project files
   - `.svg` export/import
   - `.ora` (OpenRaster) import/export
   - `.kra` (Krita) import/export

3. **Media handling:**
   - Video decode/encode
   - Audio playback
   - FFmpeg integration changes

4. **Paint system:**
   - libmypaint integration
   - Brush engine changes
   - Surface tiling or caching

## Manual Verification Checklist

### GPU-Sensitive Changes

**Test Environment:**
- Linux desktop with GPU acceleration (NVIDIA/AMD/Intel)
- Qt 5.15.x
- enve built with `ENVE_USE_OPENMP=1`

**Checks:**

| Check | Steps | Expected |
|-------|-------|----------|
| App startup | Launch enve, create new document | No crashes, UI responsive |
| Canvas navigation | Pan, zoom, rotate viewport | Smooth, no artifacts |
| Object creation | Add rectangle, ellipse, text | Objects visible, properties editable |
| Timeline playback | Create simple animation, press play | Playback smooth, no stuttering |
| GPU memory | Monitor GPU memory during use | No unbounded growth |

**Evidence to record:**
- Screenshot of working canvas
- GPU memory before/after (if tools available)
- Any console errors or warnings

---

### Import/Export Changes

**Test Files:**
- Sample `.ev` project (provided in examples/)
- Sample `.svg` file
- Sample `.ora` file (if available)
- Sample `.kra` file (if available)

**Checks:**

| Check | Steps | Expected |
|-------|-------|----------|
| Open .ev | File → Open, select .ev file | Project loads without errors |
| Open .xev | File → Open, select .xev file | Project loads without errors |
| Export SVG | File → Export, select SVG | Export completes, file valid |
| Import SVG | File → Import, select SVG | SVG imports as vector objects |
| Open .ora | File → Open, select .ora | Layers preserved, colors correct |
| Open .kra | File → Open, select .kra | Layers preserved, brushes intact |

**Evidence to record:**
- Before/after screenshots
- Any import/export errors
- File size comparison (if relevant)

---

### Media Handling Changes

**Test Files:**
- Sample video file (MP4 H.264)
- Sample audio file (WAV or MP3)

**Checks:**

| Check | Steps | Expected |
|-------|-------|----------|
| Import video | Import video file | Video appears in timeline |
| Video playback | Play video in timeline | Smooth playback, audio sync |
| Export video | Export animation to video | Export completes, file playable |
| Audio import | Import audio file | Audio waveform visible |
| Audio playback | Play timeline with audio | Audio plays, no crackling |

**Evidence to record:**
- Export settings used
- Playback quality notes
- Any FFmpeg console output

---

### Paint System Changes

**Checks:**

| Check | Steps | Expected |
|-------|-------|----------|
| Brush selection | Select different brushes | Brush preview updates |
| Stroke rendering | Draw on canvas | Stroke appears immediately |
| Brush settings | Adjust size, opacity | Changes apply in real-time |
| Tile caching | Draw large area, pan | No tile dropout or corruption |

**Evidence to record:**
- Brush settings tested
- Any rendering artifacts
- Performance notes (latency, stuttering)

## CI Coverage Gaps

The following checks are **NOT** automated in CI:

- [ ] GPU-accelerated rendering verification
- [ ] Visual output correctness (pixel-perfect)
- [ ] Interactive UI behavior
- [ ] Multi-touch or tablet pressure sensitivity
- [ ] Audio playback quality
- [ ] Video encode/decode quality
- [ ] Long-running stability (memory leaks over hours)
- [ ] Multi-monitor or high-DPI behavior

## Future Automation Candidates

These checks could be automated in Phase 4+ or Phase 5:

- [ ] Headless render verification (compare to golden image)
- [ ] Import/export round-trip (export then re-import)
- [ ] Basic timeline playback (frame comparison)
- [ ] Brush stroke verification (output image hash)

## References

- [Phase 4 Roadmap](phase-4-roadmap.md)
- [Phase 3 Toolchain Survey](phase-3-toolchain-survey.md)
- [Dependency Ledger](dependency-ledger.md)
- [AI Handoff](ai-handoff.md)
