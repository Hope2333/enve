# Maintainer: Hope2333 (幽零小喵) <u0catmiao@proton.me>
# Contributor: enve team

pkgname=enve
pkgver=0.0.0
pkgrel=1
pkgdesc="2D animation software with vector and raster graphics support"
arch=('x86_64' 'aarch64')
url="https://maurycyliebner.github.io/"
license=('GPL-3.0-or-later')
depends=(
  'qt5-base'
  'qt5-declarative'
  'qt5-multimedia'
  'qt5-svg'
  'qt5-quickcontrols2'
  'ffmpeg'
  'freetype2'
  'fontconfig'
  'libpng'
  'harfbuzz'
  'glib2'
  'libmypaint'
  'zstd'
  'libglvnd'
  'libwebp'
  'libjpeg-turbo'
  'libxi'
  'libxkbcommon'
)
makedepends=(
  'cmake'
  'ninja'
  'git'
  'autoconf'
  'automake'
  'libtool'
  'intltool'
)
optdepends=(
  'qt5-webengine: for SVG preview'
  'qscintilla: for expression editor'
)
source=(
  "${pkgname}-${pkgver}.tar.gz::${url}/archive/${pkgver}.tar.gz"
)
sha256sums=('SKIP')

prepare() {
  cd "${srcdir}/${pkgname}-${pkgver}"
  git submodule update --init --recursive
}

build() {
  cd "${srcdir}/${pkgname}-${pkgver}"
  
  # Build vendored libmypaint
  cd third_party/libmypaint
  ./autogen.sh
  ./configure --prefix=/usr --disable-static --enable-shared
  make -j"$(nproc)"
  cd ../..
  
  # Build enve with CMake
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
  cd "${srcdir}/${pkgname}-${pkgver}"
  cmake --install build --destdir "${pkgdir}"
  
  # Install desktop file and icon
  install -Dm644 org.maurycy.enve.desktop "${pkgdir}/usr/share/applications/org.maurycy.enve.desktop"
  install -Dm644 pixmaps/enve.svg "${pkgdir}/usr/share/icons/hicolor/scalable/apps/enve.svg"
}

# vim:set ts=2 sw=2 et:
