#!/usr/bin/env bash
#
# build-deb.sh - Create Debian package for enve
#
# Usage: ./build-deb.sh [BUILD_DIR] [VERSION]
#

set -euo pipefail

BUILD_DIR="${1:-build/Release}"
VERSION="${2:-2.0.0}"
APP_NAME="enve"
ARCH="amd64"

echo "=== Building .deb package for ${APP_NAME} ${VERSION} ==="

# Create package structure
PKG_DIR="${APP_NAME}_${VERSION}_${ARCH}"
rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}/usr/{bin,lib,share/applications,share/icons/hicolor/scalable/apps,share/mime/packages}"
mkdir -p "${PKG_DIR}/DEBIAN"

# Copy executable
echo "Copying executable..."
cp "${BUILD_DIR}/src/app/${APP_NAME}" "${PKG_DIR}/usr/bin/"
chmod +x "${PKG_DIR}/usr/bin/${APP_NAME}"

# Copy shared libraries
echo "Copying shared libraries..."
cp "${BUILD_DIR}/src/core/libenvecore.so"* "${PKG_DIR}/usr/lib/"

# Copy desktop file
if [[ -f "org.maurycy.enve.desktop" ]]; then
    cp "org.maurycy.enve.desktop" "${PKG_DIR}/usr/share/applications/"
fi

# Copy icon
if [[ -f "icons/${APP_NAME}.svg" ]]; then
    cp "icons/${APP_NAME}.svg" "${PKG_DIR}/usr/share/icons/hicolor/scalable/apps/"
fi

# Create control file
echo "Creating control file..."
cat > "${PKG_DIR}/DEBIAN/control" << EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: graphics
Priority: optional
Architecture: ${ARCH}
Depends: qt5-base, qt5-multimedia, qt5-svg, qt5-webengine, qt5-webchannel, ffmpeg, libmypaint, gperftools, libjson-c, fontconfig, freetype
Maintainer: enve Project <https://github.com/MaurycyLiebner/enve>
Description: A free and open source 2D animation software
 enve is a free and open source 2D animation software for Linux, Windows, and Mac.
 It supports vector and raster workflows with a wide range of features.
Homepage: https://maurycyliebner.github.io/enve/
EOF

# Build package
echo "Building .deb package..."
dpkg-deb --build "${PKG_DIR}" "${APP_NAME}_${VERSION}_${ARCH}.deb"

echo "=== Package created: ${APP_NAME}_${VERSION}_${ARCH}.deb ==="
ls -lh "${APP_NAME}_${VERSION}_${ARCH}.deb"
