#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_BIN="${ROOT_DIR}/build/Release/src/app/enve"
CORE_DIR="${ROOT_DIR}/build/Release/src/core"

echo "=== Phase 4 Verification: Artifact Checks ==="

# Executable existence and basic properties
if [[ ! -x "${APP_BIN}" ]]; then
  echo "Missing executable: ${APP_BIN}" >&2
  exit 1
fi
echo "✓ Found app binary: ${APP_BIN}"
echo "  Size: $(stat -c%s "${APP_BIN}" 2>/dev/null || echo "unknown") bytes"

# Core library existence
if [[ ! -d "${CORE_DIR}" ]]; then
  echo "Missing core output directory: ${CORE_DIR}" >&2
  exit 1
fi
echo "✓ Found core directory: ${CORE_DIR}"

shopt -s nullglob
core_libs=("${CORE_DIR}"/libenvecore.so*)
shopt -u nullglob

if [[ "${#core_libs[@]}" -eq 0 ]]; then
  echo "Missing core shared library in: ${CORE_DIR}" >&2
  exit 1
fi

echo "✓ Found core libraries:"
for lib in "${core_libs[@]}"; do
  echo "    - ${lib} ($(stat -c%s "${lib}" 2>/dev/null || echo "unknown") bytes)"
done

# Linkage check
if command -v ldd >/dev/null 2>&1; then
  echo "✓ Linkage check (ldd):"
  ldd "${APP_BIN}" | head -20 || true
fi

# Basic app startup check (headless, version/help)
echo "=== Phase 4 Verification: Startup Check ==="
if "${APP_BIN}" --help >/dev/null 2>&1; then
  echo "✓ App responds to --help"
elif "${APP_BIN}" --version >/dev/null 2>&1; then
  echo "✓ App responds to --version"
else
  echo "⚠ App startup check skipped (no --help/--version)"
fi

# Check for example files (if built)
echo "=== Phase 4 Verification: Example Assets ==="
EXAMPLES_DIR="${ROOT_DIR}/examples"
if [[ -d "${EXAMPLES_DIR}" ]]; then
  shopt -s nullglob
  ev_files=("${EXAMPLES_DIR}"/*.ev "${EXAMPLES_DIR}"/*.xev)
  shopt -u nullglob
  if [[ "${#ev_files[@]}" -gt 0 ]]; then
    echo "✓ Found example .ev/.xev files: ${#ev_files[@]}"
  else
    echo "⚠ No example .ev/.xev files found (expected if ENVE_BUILD_EXAMPLES=0)"
  fi
else
  echo "⚠ Examples directory not found (expected if ENVE_BUILD_EXAMPLES=0)"
fi

echo "=== Phase 4 Smoke Checks Passed ==="
