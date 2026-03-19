#!/usr/bin/env bash
#
# Package enve for Debian/Ubuntu (.deb)
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/Release"
VERSION="${VERSION:-0.0.0}"
RELFIX="${RELFIX:-1}"
ARCH_DEB="${ARCH_DEB:-amd64}"
MAINTAINER="${MAINTAINER:-enve Project <https://github.com/MaurycyLiebner/enve>}"
COMPRESS="${COMPRESS:-6}"

command -v dpkg-deb >/dev/null 2>&1 || {
	echo "Error: dpkg-deb not found"
	exit 1
}

[[ -x "$BUILD_DIR/src/app/enve" ]] || {
	echo "Error: missing enve executable"
	exit 1
}

DEB_ROOT="$ROOT_DIR/.work/deb-pkg/enve_${VERSION}"
OUT_DIR="${OUTPUT_ROOT:-$ROOT_DIR/packing}/deb"
OUT_FILE="$OUT_DIR/enve_${VERSION}-${RELFIX}_${ARCH_DEB}.deb"

rm -rf "$DEB_ROOT"
mkdir -p "$DEB_ROOT/DEBIAN" "$DEB_ROOT/usr/{bin,lib,share/applications,share/icons/hicolor/scalable/apps}" "$OUT_DIR"
chmod 755 "$DEB_ROOT" "$DEB_ROOT/DEBIAN"

# Copy binaries
cp "$BUILD_DIR/src/app/enve" "$DEB_ROOT/usr/bin/"
cp "$BUILD_DIR/src/core/libenvecore.so"* "$DEB_ROOT/usr/lib/"
chmod +x "$DEB_ROOT/usr/bin/enve"

# Copy desktop file and icon
if [[ -f "$ROOT_DIR/org.maurycy.enve.desktop" ]]; then
	cp "$ROOT_DIR/org.maurycy.enve.desktop" "$DEB_ROOT/usr/share/applications/"
fi
if [[ -f "$ROOT_DIR/icons/enve.svg" ]]; then
	cp "$ROOT_DIR/icons/enve.svg" "$DEB_ROOT/usr/share/icons/hicolor/scalable/apps/"
fi

# Create control file
cat >"$DEB_ROOT/DEBIAN/control" <<EOF
Package: enve
Version: ${VERSION}
Section: graphics
Priority: optional
Architecture: $ARCH_DEB
Depends: qt5-base, qt5-multimedia, qt5-svg, qt5-webengine, ffmpeg, libmypaint, gperftools, libjson-c, fontconfig, freetype
Maintainer: $MAINTAINER
Description: A free and open source 2D animation software
 enve is a free and open source 2D animation software for Linux, Windows, and Mac.
 It supports vector and raster workflows with a wide range of features.
Homepage: https://maurycyliebner.github.io/enve/
EOF

INSTALLED_SIZE=$(du -sk "$DEB_ROOT" | cut -f1)
echo "Installed-Size: $INSTALLED_SIZE" >>"$DEB_ROOT/DEBIAN/control"

# Build .deb
dpkg-deb -Zxz -z${COMPRESS} --build "$DEB_ROOT" "$OUT_FILE"

echo "✓ Created: $OUT_FILE"
ls -lh "$OUT_FILE"
