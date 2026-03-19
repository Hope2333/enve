#!/usr/bin/env bash
#
# build-arch-package.sh - Create Arch Linux package for enve
#
# Usage: ./build-arch-package.sh [BUILD_DIR] [VERSION]
#

set -euo pipefail

BUILD_DIR="${1:-build/Release}"
VERSION="${2:-2.0.0}"
APP_NAME="enve"
ARCH="x86_64"

echo "=== Building Arch package for ${APP_NAME} ${VERSION} ==="

# Create package structure
PKG_DIR="${APP_NAME}-${VERSION}-${ARCH}"
rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}/usr/{bin,lib,share/applications,share/icons/hicolor/scalable/apps,share/mime/packages}"

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

# Create .PKGINFO
echo "Creating .PKGINFO..."
cat > "${PKG_DIR}/.PKGINFO" << EOF
pkgname = ${APP_NAME}
pkgver = ${VERSION}
pkgdesc = A free and open source 2D animation software
url = https://maurycyliebner.github.io/enve/
builddate = $(date -u +%s)
packager = enve Project
size = $(du -sb "${PKG_DIR}/usr" | cut -f1)
arch = ${ARCH}
license = GPL3
depend = qt5-base
depend = qt5-multimedia
depend = qt5-svg
depend = qt5-webengine
depend = ffmpeg
depend = libmypaint
depend = gperftools
EOF

# Create install script (optional)
cat > "${PKG_DIR}/.INSTALL" << 'EOF'
post_install() {
    update-desktop-database &>/dev/null || true
    update-mime-database /usr/share/mime &>/dev/null || true
}

post_remove() {
    update-desktop-database &>/dev/null || true
    update-mime-database /usr/share/mime &>/dev/null || true
}
EOF

# Create tarball
echo "Creating package tarball..."
tar -czf "${APP_NAME}-${VERSION}-${ARCH}.pkg.tar.gz" -C "${PKG_DIR}" .

echo "=== Package created: ${APP_NAME}-${VERSION}-${ARCH}.pkg.tar.gz ==="
ls -lh "${APP_NAME}-${VERSION}-${ARCH}.pkg.tar.gz"
