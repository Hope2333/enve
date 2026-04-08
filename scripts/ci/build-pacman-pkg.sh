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

cp "$SCRIPT_DIR/PKGBUILD.template" "$WORKDIR/PKGBUILD"
sed -i "s/__VERSION__/${VERSION}/" "$WORKDIR/PKGBUILD"
sed -i "s|\${GITHUB_WORKSPACE}|${GITHUB_WORKSPACE}|g" "$WORKDIR/PKGBUILD"

chown -R "$BUILDER":"$BUILDER" "$WORKDIR"

su "$BUILDER" -c "cd '$WORKDIR' && makepkg -s --noconfirm"

ls -la "$WORKDIR"/enve-*.pkg.tar.zst
