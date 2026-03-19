#!/usr/bin/env bash
#
# Package enve for multiple distributions
#
# Usage: ./package-all.sh [BUILD_DIR] [VERSION]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${1:-build/Release}"
VERSION="${2:-2.0.0}"
OUTPUT_DIR="${SCRIPT_DIR}/output"

echo "=== Packaging enve ${VERSION} ==="
echo "Build directory: ${BUILD_DIR}"
echo "Output directory: ${OUTPUT_DIR}"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Check if build exists
if [[ ! -f "${BUILD_DIR}/src/app/enve" ]]; then
    echo "Error: Build not found at ${BUILD_DIR}"
    echo "Please build first with: ./scripts/ci/build-linux-baseline.sh"
    exit 1
fi

# Build AppImage
echo ""
echo "=== Building AppImage ==="
"${SCRIPT_DIR}/build-appimage.sh" "${BUILD_DIR}" "${OUTPUT_DIR}"

# Build .deb package
echo ""
echo "=== Building Debian package ==="
"${SCRIPT_DIR}/build-deb.sh" "${BUILD_DIR}" "${VERSION}"
mv enve_*.deb "${OUTPUT_DIR}/" 2>/dev/null || true

# Build Arch package
echo ""
echo "=== Building Arch package ==="
"${SCRIPT_DIR}/build-arch-package.sh" "${BUILD_DIR}" "${VERSION}"
mv enve-*.pkg.tar.gz "${OUTPUT_DIR}/" 2>/dev/null || true

echo ""
echo "=== All packages created ==="
ls -lh "${OUTPUT_DIR}/"
