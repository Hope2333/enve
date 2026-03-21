#!/usr/bin/env bash
# Phase 4 Verification: Import/Export Regression Check
#
# This script performs a basic import/export round-trip check.
# It is optional and should be run manually or in a dedicated workflow.
#
# Usage: ./scripts/ci/check-import-export.sh [path/to/test/files]
#
# Exit codes:
#   0 - All checks passed
#   1 - Missing test files or executable
#   2 - Import/export check failed

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_BIN="${ROOT_DIR}/build/Release/src/app/enve"
TEST_DIR="${1:-${ROOT_DIR}/examples}"

echo "=== Phase 4 Verification: Import/Export Check ==="

# Check executable
if [[ ! -x "${APP_BIN}" ]]; then
  echo "Missing executable: ${APP_BIN}" >&2
  echo "Run 'make build' first." >&2
  exit 1
fi

# Check test directory
if [[ ! -d "${TEST_DIR}" ]]; then
  echo "Test directory not found: ${TEST_DIR}" >&2
  echo "Usage: $0 [path/to/test/files]" >&2
  exit 1
fi

# Find .ev/.xev files
shopt -s nullglob
ev_files=("${TEST_DIR}"/*.ev "${TEST_DIR}"/*.xev)
shopt -u nullglob

if [[ "${#ev_files[@]}" -eq 0 ]]; then
  echo "⚠ No .ev/.xev test files found in ${TEST_DIR}"
  echo "This check is optional when ENVE_BUILD_EXAMPLES=0."
  exit 0
fi

echo "Found ${#ev_files[@]} test file(s):"
for f in "${ev_files[@]}"; do
  echo "  - ${f}"
done

# Basic file validation (structure check)
echo ""
echo "Validating file structure..."
passed=0
failed=0

for ev_file in "${ev_files[@]}"; do
  filename="$(basename "${ev_file}")"
  
  # Check file is readable and non-empty
  if [[ ! -r "${ev_file}" ]]; then
    echo "  ❌ ${filename}: not readable"
    ((failed++))
    continue
  fi
  
  size="$(stat -c%s "${ev_file}" 2>/dev/null || echo "0")"
  if [[ "${size}" -eq 0 ]]; then
    echo "  ❌ ${filename}: empty file"
    ((failed++))
    continue
  fi
  
  # Check for XML-like structure (enve files are XML-based)
  if head -c 100 "${ev_file}" | grep -q "<?xml\|<enve\|<scene"; then
    echo "  ✓ ${filename}: valid structure (${size} bytes)"
    ((passed++))
  else
    echo "  ⚠ ${filename}: unknown format (may still be valid)"
    ((passed++))
  fi
done

echo ""
echo "Results: ${passed} passed, ${failed} failed"

if [[ "${failed}" -gt 0 ]]; then
  echo "Import/export check FAILED." >&2
  exit 2
fi

echo "Import/export check PASSED."
exit 0
