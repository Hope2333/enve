#!/usr/bin/env bash
# Build enve pacman package using PKGBUILD + makepkg
# Called from release.yml matrix build step
set -euo pipefail

VERSION="${1:?Usage: $0 <version>}"

git config --global --add safe.directory '*'

mkdir -p pkgbuild-work
cd pkgbuild-work

cat >PKGBUILD <<'PKGBUILD_EOF'
# Maintainer: Hope2333 (幽零小喵) <u0catmiao@proton.me>
# Contributor: enve team

pkgname=enve
pkgver=__VERSION__
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
source=("enve::file://${GITHUB_WORKSPACE}")
sha256sums=('SKIP')

prepare() {
  cd "${srcdir}/enve"
  git submodule update --init --recursive
}

build() {
  cd "${srcdir}/enve"
  cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DENVE_USE_SYSTEM_LIBMYPAINT=ON \
    -DENVE_USE_WEBENGINE=OFF \
    -DENVE_USE_QSCINTILLA=OFF \
    -DENVE_USE_GPERFTOOLS=OFF \
    -GNinja
  cmake --build build
}

package() {
  cd "${srcdir}/enve"
  DESTDIR="${pkgdir}" cmake --install build
  install -Dm644 org.maurycy.enve.desktop "${pkgdir}/usr/share/applications/org.maurycy.enve.desktop"
  install -Dm644 src/app/icons/enve.svg "${pkgdir}/usr/share/icons/hicolor/scalable/apps/enve.svg"
}
PKGBUILD_EOF

sed -i "s/__VERSION__/${VERSION}/" PKGBUILD

makepkg -s --noconfirm
ls -la enve-*.pkg.tar.zst
