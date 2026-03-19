#!/usr/bin/env bash
#
# Package enve for Arch Linux (.pkg.tar.gz)
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/Release"
VERSION="${VERSION:-0.0.0}"
RELFIX="${RELFIX:-1}"
ARCH_PKG="${ARCH_PKG:-x86_64}"
PACKAGER="${PACKAGER:-enve Project <https://github.com/MaurycyLiebner/enve>}"
COMPRESS="${COMPRESS:-6}"

command -v tar >/dev/null 2>&1 || {
	echo "Error: tar not found"
	exit 1
}

[[ -x "$BUILD_DIR/src/app/enve" ]] || {
	echo "Error: missing enve executable"
	exit 1
}

PKG_ROOT="$ROOT_DIR/.work/pkg-pkg/enve-${VERSION}"
OUT_DIR="${OUTPUT_ROOT:-$ROOT_DIR/packing}/pacman"
OUT_FILE="$OUT_DIR/enve-${VERSION}-${RELFIX}-${ARCH_PKG}.pkg.tar.gz"

rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/usr/{bin,lib,share/applications,share/icons/hicolor/scalable/apps}" "$OUT_DIR"

# Copy binaries
cp "$BUILD_DIR/src/app/enve" "$PKG_ROOT/usr/bin/"
cp "$BUILD_DIR/src/core/libenvecore.so"* "$PKG_ROOT/usr/lib/"
chmod +x "$PKG_ROOT/usr/bin/enve"

# Copy desktop file and icon
if [[ -f "$ROOT_DIR/org.maurycy.enve.desktop" ]]; then
	cp "$ROOT_DIR/org.maurycy.enve.desktop" "$PKG_ROOT/usr/share/applications/"
fi
if [[ -f "$ROOT_DIR/icons/enve.svg" ]]; then
	cp "$ROOT_DIR/icons/enve.svg" "$PKG_ROOT/usr/share/icons/hicolor/scalable/apps/"
fi

# Create .PKGINFO
cat >"$PKG_ROOT/.PKGINFO" <<EOF
pkgname = enve
pkgver = ${VERSION}
pkgdesc = A free and open source 2D animation software
url = https://maurycyliebner.github.io/enve/
builddate = $(date -u +%s)
packager = $PACKAGER
size = $(du -sb "$PKG_ROOT/usr" | cut -f1)
arch = $ARCH_PKG
license = GPL3
depend = qt5-base
depend = qt5-multimedia
depend = qt5-svg
depend = qt5-webengine
depend = ffmpeg
depend = libmypaint
depend = gperftools
depend = libjson-c
depend = fontconfig
depend = freetype2
EOF

# Create install script
cat >"$PKG_ROOT/.INSTALL" <<'INSTALL'
post_install() {
    update-desktop-database &>/dev/null || true
    update-mime-database /usr/share/mime &>/dev/null || true
}

post_remove() {
    update-desktop-database &>/dev/null || true
    update-mime-database /usr/share/mime &>/dev/null || true
}
INSTALL

# Create tarball
cd "$PKG_ROOT" && tar -cvf - . | xz -${COMPRESS} > "$OUT_FILE"

echo "✓ Created: $OUT_FILE"
ls -lh "$OUT_FILE"
