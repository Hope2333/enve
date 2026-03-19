#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_BIN="${ROOT_DIR}/build/Release/src/app/enve"
CORE_DIR="${ROOT_DIR}/build/Release/src/core"

if [[ ! -x "${APP_BIN}" ]]; then
  echo "Missing executable: ${APP_BIN}" >&2
  exit 1
fi

if [[ ! -d "${CORE_DIR}" ]]; then
  echo "Missing core output directory: ${CORE_DIR}" >&2
  exit 1
fi

shopt -s nullglob
core_libs=("${CORE_DIR}"/libenvecore.so*)
shopt -u nullglob

if [[ "${#core_libs[@]}" -eq 0 ]]; then
  echo "Missing core shared library in: ${CORE_DIR}" >&2
  exit 1
fi

echo "Found app binary: ${APP_BIN}"
echo "Found core libraries:"
for lib in "${core_libs[@]}"; do
  echo "  - ${lib}"
done

if command -v ldd >/dev/null 2>&1; then
  echo "Linkage check (ldd):"
  ldd "${APP_BIN}" || true
fi

echo "Smoke checks passed."
