#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: $0 <version>}"

git config --global --add safe.directory '*'

BUILDER=builduser
if ! id "$BUILDER" &>/dev/null; then
	useradd -m "$BUILDER"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="$(pwd)/pkgbuild-work"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

# Copy Skia cache so builduser can access it
if [ -d "$GITHUB_WORKSPACE/third_party/skia/out/Release" ]; then
	mkdir -p "$WORKDIR/skia-cache"
	cp -r "$GITHUB_WORKSPACE/third_party/skia/out/Release" "$WORKDIR/skia-cache/"
	chown -R "$BUILDER":"$BUILDER" "$WORKDIR/skia-cache"
fi

cp "$SCRIPT_DIR/PKGBUILD.template" "$WORKDIR/PKGBUILD"
sed -i "s/__VERSION__/${VERSION}/" "$WORKDIR/PKGBUILD"
sed -i "s|\${GITHUB_WORKSPACE}|${GITHUB_WORKSPACE}|g" "$WORKDIR/PKGBUILD"
sed -i "s|\${SKIA_CACHE_DIR}|${WORKDIR}/skia-cache|g" "$WORKDIR/PKGBUILD"

chown -R "$BUILDER":"$BUILDER" "$WORKDIR"

su "$BUILDER" -c "cd '$WORKDIR' && SKIA_CACHE_DIR='$WORKDIR/skia-cache' makepkg -s --noconfirm"

ls -la "$WORKDIR"/enve-*.pkg.tar.zst
