#!/usr/bin/env bash
#
# build-appimage.sh - Create AppImage for enve
#
# Usage: ./build-appimage.sh [BUILD_DIR] [OUTPUT_DIR]
#

set -euo pipefail

BUILD_DIR="${1:-build/Release}"
OUTPUT_DIR="${2:-dist}"
APP_NAME="enve"
VERSION="${ENVE_VERSION:-2.0.0}"

echo "=== Building AppImage for ${APP_NAME} ${VERSION} ==="

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Create AppDir structure
APPDIR="${OUTPUT_DIR}/AppDir"
rm -rf "${APPDIR}"
mkdir -p "${APPDIR}/usr/{bin,lib,share/applications,share/icons/hicolor/scalable/apps,share/mime/packages}"

# Copy main executable
echo "Copying executable..."
cp "${BUILD_DIR}/src/app/${APP_NAME}" "${APPDIR}/usr/bin/"
chmod +x "${APPDIR}/usr/bin/${APP_NAME}"

# Copy shared libraries
echo "Copying shared libraries..."
cp "${BUILD_DIR}/src/core/libenvecore.so"* "${APPDIR}/usr/lib/"

# Copy desktop file
if [[ -f "org.maurycy.enve.desktop" ]]; then
    echo "Copying desktop file..."
    cp "org.maurycy.enve.desktop" "${APPDIR}/usr/share/applications/"
else
    echo "Creating desktop file..."
    cat > "${APPDIR}/usr/share/applications/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Type=Application
Name=${APP_NAME}
GenericName=2D Animation Software
Comment=A free and open source 2D animation software
Exec=${APP_NAME}
Icon=${APP_NAME}
Categories=Graphics;Animation;
Keywords=animation;2d;vector;
EOF
fi

# Copy icon
if [[ -f "icons/${APP_NAME}.svg" ]]; then
    echo "Copying icon..."
    cp "icons/${APP_NAME}.svg" "${APPDIR}/usr/share/icons/hicolor/scalable/apps/"
else
    echo "Creating placeholder icon..."
    cat > "${APPDIR}/usr/share/icons/hicolor/scalable/apps/${APP_NAME}.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256">
  <rect width="256" height="256" fill="#4a90d9"/>
  <text x="128" y="148" font-size="80" text-anchor="middle" fill="white">enve</text>
</svg>
EOF
fi

# Copy MIME type
if [[ -f "org.maurycy.enve.xml" ]]; then
    echo "Copying MIME type..."
    cp "org.maurycy.enve.xml" "${APPDIR}/usr/share/mime/packages/"
fi

# Create AppRun
echo "Creating AppRun..."
cat > "${APPDIR}/AppRun" << 'EOF'
#!/usr/bin/env bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
exec "${HERE}/usr/bin/enve" "$@"
EOF
chmod +x "${APPDIR}/AppRun"

# Download linuxdeploy if not present
LINUXDEPLOY="${OUTPUT_DIR}/linuxdeploy-x86_64.AppImage"
if [[ ! -f "${LINUXDEPLOY}" ]]; then
    echo "Downloading linuxdeploy..."
    wget -q --show-progress \
        https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage \
        -O "${LINUXDEPLOY}"
    chmod +x "${LINUXDEPLOY}"
fi

LINUXDEPLOY_QT="${OUTPUT_DIR}/linuxdeploy-plugin-qt-x86_64.AppImage"
if [[ ! -f "${LINUXDEPLOY_QT}" ]]; then
    echo "Downloading linuxdeploy-plugin-qt..."
    wget -q --show-progress \
        https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage \
        -O "${LINUXDEPLOY_QT}"
    chmod +x "${LINUXDEPLOY_QT}"
fi

# Build AppImage
echo "Building AppImage..."
export OUTPUT="${OUTPUT_DIR}/${APP_NAME}-${VERSION}-x86_64.AppImage"
export VERSION="${VERSION}"

"${LINUXDEPLOY}" \
    --appdir "${APPDIR}" \
    --executable "${APPDIR}/usr/bin/${APP_NAME}" \
    --library "${APPDIR}/usr/lib/libenvecore.so" \
    --output appimage \
    --plugin qt

echo "=== AppImage created: ${OUTPUT} ==="

# Show file info
if command -v file &>/dev/null; then
    file "${OUTPUT}"
fi

ls -lh "${OUTPUT}"
