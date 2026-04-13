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

# Copy Skia from workspace (downloaded artifact)
# The Download Skia artifact step puts files in third_party/skia/out/Release
SKIA_SRC=""
if [ -d "third_party/skia/out/Release" ] && [ -f "third_party/skia/out/Release/libskia.a" ]; then
	SKIA_SRC="$(pwd)/third_party/skia/out/Release"
fi

if [ -z "$SKIA_SRC" ]; then
	echo "ERROR: Skia artifact not found at third_party/skia/out/Release/libskia.a" >&2
	echo "The release workflow must download the skia-m100 artifact before makepkg starts." >&2
	exit 1
fi

mkdir -p "$WORKDIR/skia-cache/out/Release"
cp -a "$SKIA_SRC/." "$WORKDIR/skia-cache/out/Release/"
test -f "$WORKDIR/skia-cache/out/Release/libskia.a"

tar -C "$WORKDIR" -czf "$WORKDIR/skia-m100.tar.gz" skia-cache
tar -tzf "$WORKDIR/skia-m100.tar.gz" >"$WORKDIR/skia-m100.contents"
grep -Fxq 'skia-cache/out/Release/libskia.a' "$WORKDIR/skia-m100.contents"

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
source=("enve::git+file://${GITHUB_WORKSPACE}" "skia-m100.tar.gz")
sha256sums=('SKIP' 'SKIP')

prepare() {
  cd "\${srcdir}/enve"
  git submodule update --init --recursive

  # Build vendored quazip
  cd third_party/quazip
  qmake quazip.pro CONFIG+=release
  make -j"\$(nproc)"
  cd ../..

  if [ ! -f "\${srcdir}/skia-cache/out/Release/libskia.a" ]; then
    echo "ERROR: Skia source archive did not extract into \${srcdir}/skia-cache/out/Release/libskia.a" >&2
    find "\${srcdir}" -maxdepth 4 -type f -name 'libskia.a' -print >&2 || true
    exit 1
  fi

  mkdir -p third_party/skia/out/Release
  cp -a "\${srcdir}/skia-cache/out/Release/." third_party/skia/out/Release/
  test -f third_party/skia/out/Release/libskia.a
  ls -la third_party/skia/out/Release | head -50
}

build() {
  cd "\${srcdir}/enve"
  cmake -S . -B build \\
    -DCMAKE_BUILD_TYPE=Release \\
    -DCMAKE_INSTALL_PREFIX=/usr \\
    -DENVE_USE_SYSTEM_LIBMYPAINT=ON \\
    -DENVE_USE_WEBENGINE=OFF \\
    -DENVE_USE_QSCINTILLA=OFF \\
    -DENVE_USE_GPERFTOOLS=OFF \\
    -GNinja
  cmake --build build
}

package() {
  cd "\${srcdir}/enve"
  DESTDIR="\${pkgdir}" cmake --install build
  install -Dm755 third_party/quazip/quazip/libquazip.so.1.0.0 "\${pkgdir}/usr/lib/libquazip.so.1.0.0"
  ln -sf libquazip.so.1.0.0 "\${pkgdir}/usr/lib/libquazip.so.1"
  ln -sf libquazip.so.1 "\${pkgdir}/usr/lib/libquazip.so"
  install -Dm644 org.maurycy.enve.desktop "\${pkgdir}/usr/share/applications/org.maurycy.enve.desktop"
  install -Dm644 src/app/icons/enve.svg "\${pkgdir}/usr/share/icons/hicolor/scalable/apps/enve.svg"
}
PKGBUILD

chown -R "$BUILDER":"$BUILDER" "$WORKDIR"

su "$BUILDER" -c "cd '$WORKDIR' && makepkg -s --noconfirm"

ls -la "$WORKDIR"/enve-*.pkg.tar.zst
cp "$WORKDIR"/enve-*.pkg.tar.zst .
ls -la enve-*.pkg.tar.zst
