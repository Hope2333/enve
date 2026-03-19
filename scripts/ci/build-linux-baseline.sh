#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
JOBS="${ENVE_JOBS:-}"
SKIP_THIRD_PARTY="${ENVE_SKIP_THIRD_PARTY:-0}"
BUILD_EXAMPLES="${ENVE_BUILD_EXAMPLES:-1}"
UPDATE_SUBMODULES="${ENVE_UPDATE_SUBMODULES:-0}"
USE_PREBUILT_SKIA="${ENVE_USE_PREBUILT_SKIA:-0}"

if [[ -z "${JOBS}" ]]; then
  if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)"
  else
    JOBS=2
  fi
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd git
require_cmd make
require_cmd qmake
require_cmd patch
require_cmd curl

run_third_party_make() {
  make -C "${ROOT_DIR}/third_party" \
    SHELL=/bin/bash \
    .SHELLFLAGS="-eu -o pipefail -c" \
    "$@"
}

verify_artifact() {
  local label="$1"
  local pattern="$2"
  shopt -s nullglob
  local matches=( ${pattern} )
  shopt -u nullglob
  if [[ "${#matches[@]}" -eq 0 ]]; then
    echo "Missing third-party artifact (${label}): ${pattern}" >&2
    return 1
  fi
}

verify_third_party_artifacts() {
  verify_artifact "skia" "${ROOT_DIR}/third_party/skia/out/Release/libskia.a"
  verify_artifact "libmypaint" "${ROOT_DIR}/third_party/libmypaint/.libs/libmypaint.*"
  verify_artifact "quazip" "${ROOT_DIR}/third_party/quazip/quazip/libquazip*"
  verify_artifact "gperftools" "${ROOT_DIR}/third_party/gperftools/.libs/libtcmalloc*"
  verify_artifact "qscintilla" "${ROOT_DIR}/third_party/qscintilla/Qt4Qt5/libqscintilla2_qt5*"
}

verify_submodule_checkout() {
  local required_paths=(
    "${ROOT_DIR}/third_party/skia/tools/git-sync-deps"
    "${ROOT_DIR}/third_party/skia/BUILD.gn"
    "${ROOT_DIR}/third_party/libmypaint/autogen.sh"
    "${ROOT_DIR}/third_party/quazip/quazip/quazip.pro"
    "${ROOT_DIR}/third_party/gperftools/autogen.sh"
    "${ROOT_DIR}/third_party/qscintilla/Qt4Qt5/qscintilla.pro"
  )

  for path in "${required_paths[@]}"; do
    if [[ ! -f "${path}" ]]; then
      echo "Missing submodule file: ${path}" >&2
      echo "Run: git submodule update --init --recursive" >&2
      return 1
    fi
  done
}

apply_gperftools_patch_if_needed() {
  local gperf_dir="${ROOT_DIR}/third_party/gperftools"
  local patch_file="${ROOT_DIR}/third_party/gperftools-enve-mod.patch"
  local sentinel="${gperf_dir}/include/gperftools/heap-checker.h"

  # enve patch introduces additional gperftools public headers.
  # If one of them already exists, treat patch as applied.
  if [[ -f "${sentinel}" ]]; then
    echo "gperftools patch already applied."
    return
  fi

  echo "Applying gperftools patch..."
  patch -d "${gperf_dir}" -p1 < "${patch_file}"
}

require_skia_network_if_needed() {
  local skia_lib="${ROOT_DIR}/third_party/skia/out/Release/libskia.a"
  if [[ -f "${skia_lib}" ]]; then
    return
  fi

  local endpoints=(
    "https://skia.googlesource.com"
    "https://chromium.googlesource.com"
  )

  for endpoint in "${endpoints[@]}"; do
    if ! curl -fsSL --connect-timeout 5 --max-time 10 "${endpoint}" >/dev/null; then
      echo "Network check failed for ${endpoint}" >&2
      echo "Skia deps sync requires internet access to googlesource endpoints." >&2
      echo "Either restore network access or prebuild/cache third_party/skia/out/Release." >&2
      return 1
    fi
  done
}

echo "Using root: ${ROOT_DIR}"
echo "Using jobs: ${JOBS}"
echo "Skip third-party build: ${SKIP_THIRD_PARTY}"
echo "Build examples: ${BUILD_EXAMPLES}"
echo "Update submodules: ${UPDATE_SUBMODULES}"
echo "Use prebuilt skia: ${USE_PREBUILT_SKIA}"

pushd "${ROOT_DIR}" >/dev/null

if [[ "${UPDATE_SUBMODULES}" == "1" ]]; then
  git submodule update --init --recursive
fi

verify_submodule_checkout

if [[ "${SKIP_THIRD_PARTY}" != "1" ]]; then
  echo "Building third-party dependencies..."
  if [[ "${USE_PREBUILT_SKIA}" != "1" ]]; then
    require_skia_network_if_needed
  fi
  apply_gperftools_patch_if_needed
  if [[ "${USE_PREBUILT_SKIA}" == "1" ]]; then
    verify_artifact "skia" "${ROOT_DIR}/third_party/skia/out/Release/libskia.a"
    run_third_party_make libmypaint quazip gperftools qscintilla
  else
    run_third_party_make build
  fi
  verify_third_party_artifacts
else
  echo "Skipping third-party build (ENVE_SKIP_THIRD_PARTY=1)."
  verify_third_party_artifacts
fi

mkdir -p build/Release
pushd build/Release >/dev/null

if [[ "${BUILD_EXAMPLES}" == "1" ]]; then
  qmake CONFIG+=build_examples ../../enve.pro
else
  qmake ../../enve.pro
fi

make -j"${JOBS}"

popd >/dev/null
popd >/dev/null

echo "Baseline build finished."
