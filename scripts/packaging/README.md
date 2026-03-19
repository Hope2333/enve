# enve Packaging Scripts

This directory contains scripts for packaging enve for various Linux distributions.

## Prerequisites

Before packaging, you need to build enve first:

```bash
# Build enve
./scripts/ci/build-linux-baseline.sh
```

## Available Packages

### AppImage (Universal Linux)

```bash
# Build AppImage
./scripts/packaging/build-appimage.sh

# Usage
./enve-*.AppImage
```

The AppImage should work on most modern Linux distributions including:
- Ubuntu 20.04+
- Debian 11+
- Fedora 35+
- Arch Linux
- openSUSE Tumbleweed

### Debian/Ubuntu Package (.deb)

```bash
# Build .deb package
./scripts/packaging/build-deb.sh build/Release 2.0.0

# Install
sudo dpkg -i enve_2.0.0_amd64.deb

# Or with dependencies
sudo apt install ./enve_2.0.0_amd64.deb
```

Supported distributions:
- Ubuntu 20.04, 22.04, 24.04
- Debian 11, 12
- Linux Mint 20+
- Pop!_OS 20.04+

### Arch Linux Package (.pkg.tar.gz)

```bash
# Build Arch package
./scripts/packaging/build-arch-package.sh build/Release 2.0.0

# Install
sudo pacman -U enve-2.0.0-x86_64.pkg.tar.gz
```

Supported distributions:
- Arch Linux
- Manjaro
- EndeavourOS
- ArcoLinux

### Using PKGBUILD (AUR-style)

```bash
cd packaging/arch

# Build package
makepkg -si

# This will:
# 1. Download source tarball
# 2. Build all dependencies
# 3. Build enve
# 4. Install the package
```

## Build All Packages

To build all available packages at once:

```bash
./scripts/packaging/package-all.sh build/Release 2.0.0
```

This will create:
- `dist/enve-2.0.0-x86_64.AppImage`
- `dist/enve_2.0.0_amd64.deb`
- `dist/enve-2.0.0-x86_64.pkg.tar.gz`

## CI/CD Integration

### GitHub Actions

The workflow `.github/workflows/linux-multi-distro.yml` automatically builds packages for:
- Ubuntu 22.04
- Debian 12
- Arch Linux
- AppImage

Packages are available as build artifacts after each successful run.

### CircleCI

The configuration `.circleci/config.yml` provides the same builds on CircleCI infrastructure.

## Troubleshooting

### Missing Dependencies

If you encounter missing dependency errors:

**Ubuntu/Debian:**
```bash
sudo apt install qt5-base qt5-multimedia qt5-svg qt5-webengine ffmpeg libmypaint gperftools
```

**Arch Linux:**
```bash
sudo pacman -S qt5-base qt5-multimedia qt5-svg qt5-webengine ffmpeg libmypaint gperftools
```

### Library Loading Issues

If the application fails to load shared libraries:

```bash
# Check library dependencies
ldd build/Release/src/app/enve

# Set LD_LIBRARY_PATH temporarily
export LD_LIBRARY_PATH=build/Release/src/core:$LD_LIBRARY_PATH
```

### AppImage Not Executing

Make sure the AppImage is executable:

```bash
chmod +x enve-*.AppImage
./enve-*.AppImage
```

If you encounter FUSE errors on newer systems:

```bash
# Ubuntu 22.04+
sudo apt install libfuse2

# Or extract and run
./enve-*.AppImage --appimage-extract
cd squashfs-root
./AppRun
```

## Version Numbering

Package versions follow the format: `MAJOR.MINOR.PATCH`

- Update `VERSION` in build scripts
- Update `pkgver` in PKGBUILD
- Update `Version` in Debian control file
- Update workflow artifact names

## Signing Packages

For production releases, consider signing packages:

### Debian
```bash
dpkg-sig --sign builder enve_2.0.0_amd64.deb
```

### Arch
```bash
# Add to /etc/makepkg.conf
SIGNPKG="gpg"
GPGKEY="your-key-id"
```

## Contributing

When adding support for new distributions:

1. Create distribution-specific build script
2. Add to CI workflow
3. Update this README
4. Test on clean VM/container

## License

Same as enve: GPL-3.0-or-later
