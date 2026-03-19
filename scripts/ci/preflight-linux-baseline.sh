#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

required_files=(
  "${ROOT_DIR}/third_party/Makefile"
  "${ROOT_DIR}/enve.pro"
  "${ROOT_DIR}/src/app/app.pro"
  "${ROOT_DIR}/src/core/core.pro"
  "${ROOT_DIR}/src/core/core.pri"
  "${ROOT_DIR}/scripts/ci/install-linux-build-deps.sh"
  "${ROOT_DIR}/scripts/ci/build-linux-baseline.sh"
  "${ROOT_DIR}/scripts/ci/smoke-linux-baseline.sh"
  "${ROOT_DIR}/.github/workflows/linux-baseline.yml"
)

for path in "${required_files[@]}"; do
  if [[ ! -f "${path}" ]]; then
    echo "Missing required file: ${path}" >&2
    exit 1
  fi
done

bash -n "${ROOT_DIR}/scripts/ci/install-linux-build-deps.sh"
bash -n "${ROOT_DIR}/scripts/ci/build-linux-baseline.sh"
bash -n "${ROOT_DIR}/scripts/ci/smoke-linux-baseline.sh"

echo "Preflight checks passed."
