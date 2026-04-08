#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: $0 <version>}"

git config --global --add safe.directory '*'

BUILDER=builduser
if ! id "$BUILDER" &>/dev/null; then
	useradd -m "$BUILDER"
fi

WORKDIR="$(pwd)/pkgbuild-work"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

# Copy Skia cache into workdir so builduser can access it
if [ -d "$GITHUB_WORKSPACE/third_party/skia/out/Release" ]; then
	mkdir -p "$WORKDIR/skia-cache/out/Release"
	cp -r "$GITHUB_WORKSPACE/third_party/skia/out/Release/"* "$WORKDIR/skia-cache/out/Release/"
	chown -R "$BUILDER":"$BUILDER" "$WORKDIR/skia-cache"
fi

cat >"$WORKDIR/PKGBUILD" <<PKGBUILD
pkgname=enve
pkgver=${VERSION}
pkgrel=1
pkgdesc="2D animation software with vector and raster graphics support"
arch=('x86_64')
url="https://maurycyliebner.github.io/"
license=('GPL-3.0-or-later')
depends=(
  'qt5-base' 'qt5-declarative' 'qt5-multimedia'
  'qt5-svg' 'qt5-quickcontrols2'
  'ffmpeg' 'freetype2' 'fontconfig' 'libpng' 'harfbuzz'
  'glib2' 'libmypaint' 'zstd' 'libglvnd'
  'libwebp' 'libjpeg-turbo' 'libxi' 'libxkbcommon' 'expat' 'json-c'
)
makedepends=('cmake' 'ninja' 'git')
optdepends=('qt5-webengine: for SVG preview' 'qscintilla: for expression editor')
source=("enve::git+file://${GITHUB_WORKSPACE}")
sha256sums=('SKIP')

prepare() {
  cd "\${srcdir}/enve"
  git submodule update --init --recursive

  if [ -d "$WORKDIR/skia-cache/out/Release" ]; then
    mkdir -p third_party/skia/out/Release
    cp -r "$WORKDIR/skia-cache/out/Release/"* third_party/skia/out/Release/
  fi
}

build() {
  cd "\${srcdir}/enve"
  cmake -S . -B build \\\\
    -DCMAKE_BUILD_TYPE=Release \\\\
    -DCMAKE_INSTALL_PREFIX=/usr \\\\
    -DENVE_USE_SYSTEM_LIBMYPAINT=ON \\\\
    -DENVE_USE_WEBENGINE=OFF \\\\
    -DENVE_USE_QSCINTILLA=OFF \\\\
    -DENVE_USE_GPERFTOOLS=OFF \\\\
    -GNinja
  cmake --build build
}

package() {
  cd "\${srcdir}/enve"
  DESTDIR="\${pkgdir}" cmake --install build
  install -Dm644 org.maurycy.enve.desktop "\${pkgdir}/usr/share/applications/org.maurycy.enve.desktop"
  install -Dm644 src/app/icons/enve.svg "\${pkgdir}/usr/share/icons/hicolor/scalable/apps/enve.svg"
}
PKGBUILD

chown -R "$BUILDER":"$BUILDER" "$WORKDIR"

su "$BUILDER" -c "cd '$WORKDIR' && makepkg -s --noconfirm"

ls -la "$WORKDIR"/enve-*.pkg.tar.zst
