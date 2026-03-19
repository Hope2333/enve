#!/usr/bin/env bash
set -euo pipefail

if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  SUDO=""
fi

export DEBIAN_FRONTEND=noninteractive

$SUDO apt-get update
$SUDO apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  curl \
  freeglut3-dev \
  git \
  intltool \
  libavcodec-dev \
  libavformat-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libgif-dev \
  libgl1-mesa-dev \
  libglib2.0-dev \
  libglu1-mesa-dev \
  libgstreamer-plugins-base1.0-dev \
  libharfbuzz-dev \
  libicu-dev \
  libjpeg-dev \
  libjson-c-dev \
  libpng-dev \
  libpulse-dev \
  libqt5opengl5-dev \
  libqt5svg5-dev \
  libswresample-dev \
  libswscale-dev \
  libtool \
  libunwind-dev \
  libwebp-dev \
  libxkbcommon-x11-dev \
  ninja-build \
  pkg-config \
  python-is-python3 \
  python3 \
  qt5-qmake \
  qtbase5-dev \
  qtbase5-dev-tools \
  qtchooser \
  qtdeclarative5-dev \
  qtmultimedia5-dev \
  qttools5-dev \
  qtwebengine5-dev \
  unzip \
  wget

$SUDO mkdir -p /usr/local/bin

# libmypaint autogen checks legacy command names first.
if command -v automake >/dev/null 2>&1; then
  $SUDO ln -sf "$(command -v automake)" /usr/local/bin/automake-1.13
fi
if command -v aclocal >/dev/null 2>&1; then
  $SUDO ln -sf "$(command -v aclocal)" /usr/local/bin/aclocal-1.13
fi

$SUDO rm -rf /var/lib/apt/lists/*

echo "Linux build dependencies installed."
