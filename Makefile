# enve - Top-level Makefile for GNU/Linux Packaging
#
# Usage:
#   make build          - Build enve and all dependencies
#   make package        - Create all package formats
#   make package-appimage - Create AppImage only
#   make package-deb    - Create .deb package only
#   make package-pkg    - Create .pkg.tar.gz package only
#   make clean          - Clean build artifacts
#   make help           - Show this help
#
# Variables:
#   VER       - Version string (e.g., 2.0.0)
#   PKGMGR    - Package manager: auto (default), pacman, dpkg
#   PROXY     - HTTP/HTTPS proxy (e.g., http://localhost:7890)
#   JOBS      - Parallel build jobs (default: nproc)
#   COMPRESS  - Compression level: 1-9 (default: 6)

SHELL := /bin/bash
.DEFAULT_GOAL := help

# ============================================================
# Configuration
# ============================================================

# Version info
VER ?= 2.0.0
RELFIX ?= 1

# Build parameters
PKGMGR ?= auto
PROXY ?= http://localhost:7890
JOBS ?= $(shell nproc 2>/dev/null || echo 2)
COMPRESS ?= 6

# Directories
ROOT_DIR := $(shell pwd)
BUILD_DIR := $(ROOT_DIR)/build/Release
DIST_DIR := $(ROOT_DIR)/dist
TMP_DIR := $(ROOT_DIR)/.tmp
THIRD_PARTY_DIR := $(ROOT_DIR)/third_party

# Package naming (following hope2333 standards)
# enve-VER-RELFIX-ARCH.pkg.tar.gz
# enve_VER-RELFIX_ARCH.deb
# enve-VER-ARCH.AppImage
ARCH := $(shell uname -m)
ifeq ($(ARCH),x86_64)
  PKG_ARCH := x86_64
  DEB_ARCH := amd64
else ifeq ($(ARCH),aarch64)
  PKG_ARCH := aarch64
  DEB_ARCH := arm64
else
  PKG_ARCH := $(ARCH)
  DEB_ARCH := $(ARCH)
endif

# Package names
PKG_NAME := enve
PKG_NAME_VER := $(PKG_NAME)-$(VER)
PKG_NAME_FULL := $(PKG_NAME_VER)-$(RELFIX)-$(PKG_ARCH)

# Proxy configuration for network-restricted environments
export http_proxy ?= $(PROXY)
export https_proxy ?= $(PROXY)
export HTTP_PROXY ?= $(PROXY)
export HTTPS_PROXY ?= $(PROXY)

# ============================================================
# Phony Targets
# ============================================================

.PHONY: help build build-deps build-enve package package-all \
        package-appimage package-deb package-pkg clean test \
        info check-deps

# ============================================================
# Help
# ============================================================

help:
	@echo "enve Build System for GNU/Linux"
	@echo ""
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Main Targets:"
	@echo "  build          Build enve and all dependencies"
	@echo "  package        Create all package formats"
	@echo "  package-appimage  Create AppImage (universal Linux)"
	@echo "  package-deb    Create Debian/Ubuntu package"
	@echo "  package-pkg    Create Arch Linux package"
	@echo "  clean          Clean build artifacts"
	@echo "  info           Show build configuration"
	@echo ""
	@echo "Variables:"
	@echo "  VER=$(VER)           Version string"
	@echo "  PKGMGR=$(PKGMGR)     Package manager (auto|pacman|dpkg)"
	@echo "  PROXY=$(PROXY)  HTTP/HTTPS proxy"
	@echo "  JOBS=$(JOBS)        Parallel build jobs"
	@echo "  COMPRESS=$(COMPRESS)       Compression level (1-9)"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make package VER=2.0.0"
	@echo "  make package-deb PROXY=http://localhost:7890"
	@echo "  make clean && make build-all JOBS=4"

# ============================================================
# Build Targets
# ============================================================

# Main build target
build: check-deps build-deps build-enve
	@echo "=========================================="
	@echo "✓ Build complete!"
	@echo "=========================================="
	@ls -lh $(BUILD_DIR)/src/app/enve
	@ls -lh $(BUILD_DIR)/src/core/libenvecore.so

# Check dependencies
check-deps:
	@echo "🔍 Checking build dependencies..."
	@command -v qmake >/dev/null 2>&1 || { echo "❌ qmake not found"; exit 1; }
	@command -v make >/dev/null 2>&1 || { echo "❌ make not found"; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "❌ git not found"; exit 1; }
	@command -v patch >/dev/null 2>&1 || { echo "❌ patch not found"; exit 1; }
	@command -v curl >/dev/null 2>&1 || { echo "❌ curl not found"; exit 1; }
	@echo "  ✓ All basic dependencies found"

# Build third-party dependencies
build-deps:
	@echo "🔨 Building third-party dependencies..."
	@mkdir -p $(BUILD_DIR)
	@cd $(ROOT_DIR) && $(MAKE) -C third_party -j$(JOBS)
	@echo "  ✓ Third-party build complete"

# Build enve
build-enve:
	@echo "🔨 Building enve..."
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && \
		qmake CONFIG+=release ../../enve.pro && \
		make -j$(JOBS)
	@echo "  ✓ enve build complete"

# ============================================================
# Packaging Targets
# ============================================================

# Create all packages
package: package-appimage package-deb package-pkg
	@echo "=========================================="
	@echo "✓ All packages created!"
	@echo "=========================================="
	@ls -lh $(DIST_DIR)/

# Create AppImage
package-appimage: build
	@echo "📦 Creating AppImage..."
	@mkdir -p $(DIST_DIR) $(TMP_DIR)/AppDir/usr/{bin,lib,share/applications,share/icons/hicolor/scalable/apps}
	
	# Copy binaries
	@cp $(BUILD_DIR)/src/app/enve $(TMP_DIR)/AppDir/usr/bin/
	@cp $(BUILD_DIR)/src/core/libenvecore.so* $(TMP_DIR)/AppDir/usr/lib/
	
	# Copy desktop file and icon
	@cp -f org.maurycy.enve.desktop $(TMP_DIR)/AppDir/usr/share/applications/ 2>/dev/null || true
	@cp -f icons/enve.svg $(TMP_DIR)/AppDir/usr/share/icons/hicolor/scalable/apps/ 2>/dev/null || \
		echo "<svg xmlns='http://www.w3.org/2000/svg' width='256' height='256'><rect width='256' height='256' fill='#4a90d9'/><text x='128' y='148' font-size='80' text-anchor='middle' fill='white'>enve</text></svg>" > $(TMP_DIR)/AppDir/usr/share/icons/hicolor/scalable/apps/enve.svg
	
	# Create AppRun
	@echo '#!/usr/bin/env bash' > $(TMP_DIR)/AppDir/AppRun
	@echo 'SELF=$$(readlink -f "$$0")' >> $(TMP_DIR)/AppDir/AppRun
	@echo 'HERE=$${SELF%/*}' >> $(TMP_DIR)/AppDir/AppRun
	@echo 'export PATH="$${HERE}/usr/bin:$${PATH}"' >> $(TMP_DIR)/AppDir/AppRun
	@echo 'export LD_LIBRARY_PATH="$${HERE}/usr/lib:$${LD_LIBRARY_PATH}"' >> $(TMP_DIR)/AppDir/AppRun
	@echo 'exec "$${HERE}/usr/bin/enve" "$$@"' >> $(TMP_DIR)/AppDir/AppRun
	@chmod +x $(TMP_DIR)/AppDir/AppRun
	
	# Download linuxdeploy if needed
	@if [ ! -f $(TMP_DIR)/linuxdeploy-x86_64.AppImage ]; then \
		echo "⬇️  Downloading linuxdeploy..."; \
		curl -L -o $(TMP_DIR)/linuxdeploy-x86_64.AppImage \
			https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage; \
		chmod +x $(TMP_DIR)/linuxdeploy-x86_64.AppImage; \
	fi
	
	# Build AppImage
	@cd $(TMP_DIR) && \
		OUTPUT=$(DIST_DIR)/$(PKG_NAME)-$(VER)-$(PKG_ARCH).AppImage \
		./linuxdeploy-x86_64.AppImage \
			--appdir AppDir \
			--executable AppDir/usr/bin/enve \
			--library AppDir/usr/lib/libenvecore.so \
			--output appimage \
			--plugin qt 2>&1 | tail -20
	
	@echo "  ✓ AppImage created: $(DIST_DIR)/$(PKG_NAME)-$(VER)-$(PKG_ARCH).AppImage"

# Create .deb package
package-deb: build
	@echo "📦 Creating Debian package..."
	@mkdir -p $(DIST_DIR) $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/usr/{bin,lib,share/applications,share/icons/hicolor/scalable/apps}
	@mkdir -p $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN
	
	# Copy binaries
	@cp $(BUILD_DIR)/src/app/enve $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/usr/bin/
	@cp $(BUILD_DIR)/src/core/libenvecore.so* $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/usr/lib/
	@chmod +x $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/usr/bin/enve
	
	# Copy desktop file and icon
	@cp -f org.maurycy.enve.desktop $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/usr/share/applications/ 2>/dev/null || true
	@cp -f icons/enve.svg $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/usr/share/icons/hicolor/scalable/apps/ 2>/dev/null || true
	
	# Create control file
	@echo "Package: $(PKG_NAME)" > $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo "Version: $(VER)" >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo "Section: graphics" >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo "Priority: optional" >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo "Architecture: $(DEB_ARCH)" >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo "Depends: qt5-base, qt5-multimedia, qt5-svg, qt5-webengine, ffmpeg, libmypaint, gperftools, libjson-c, fontconfig, freetype" >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo "Maintainer: enve Project <https://github.com/MaurycyLiebner/enve>" >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo "Description: A free and open source 2D animation software" >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo " enve is a free and open source 2D animation software for Linux, Windows, and Mac." >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	@echo "Homepage: https://maurycyliebner.github.io/enve/" >> $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER)/DEBIAN/control
	
	# Build .deb
	@cd $(TMP_DIR)/deb-pkg && \
		dpkg-deb -Zxz -z$(COMPRESS) --build $(PKG_NAME)_$(VER)
	@mv $(TMP_DIR)/deb-pkg/$(PKG_NAME)_$(VER).deb $(DIST_DIR)/$(PKG_NAME)_$(VER)-$(RELFIX)_$(DEB_ARCH).deb
	@echo "  ✓ Debian package created: $(DIST_DIR)/$(PKG_NAME)_$(VER)-$(RELFIX)_$(DEB_ARCH).deb"

# Create Arch package
package-pkg: build
	@echo "📦 Creating Arch package..."
	@mkdir -p $(DIST_DIR) $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/usr/{bin,lib,share/applications,share/icons/hicolor/scalable/apps}
	
	# Copy binaries
	@cp $(BUILD_DIR)/src/app/enve $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/usr/bin/
	@cp $(BUILD_DIR)/src/core/libenvecore.so* $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/usr/lib/
	@chmod +x $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/usr/bin/enve
	
	# Copy desktop file and icon
	@cp -f org.maurycy.enve.desktop $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/usr/share/applications/ 2>/dev/null || true
	@cp -f icons/enve.svg $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/usr/share/icons/hicolor/scalable/apps/ 2>/dev/null || true
	
	# Create .PKGINFO
	@echo "pkgname = $(PKG_NAME)" > $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "pkgver = $(VER)" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "pkgdesc = A free and open source 2D animation software" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "url = https://maurycyliebner.github.io/enve/" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "builddate = $$(date -u +%s)" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "packager = enve Project" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "size = $$(du -sb $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/usr | cut -f1)" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "arch = $(PKG_ARCH)" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "license = GPL3" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "depend = qt5-base" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "depend = qt5-multimedia" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "depend = qt5-svg" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "depend = qt5-webengine" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "depend = ffmpeg" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "depend = libmypaint" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	@echo "depend = gperftools" >> $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER)/.PKGINFO
	
	# Create tarball
	@cd $(TMP_DIR)/pkg-pkg/$(PKG_NAME)-$(VER) && \
		tar -cvf - . | xz -$(COMPRESS) > $(DIST_DIR)/$(PKG_NAME)-$(VER)-$(RELFIX)-$(PKG_ARCH).pkg.tar.gz
	@echo "  ✓ Arch package created: $(DIST_DIR)/$(PKG_NAME)-$(VER)-$(RELFIX)-$(PKG_ARCH).pkg.tar.gz"

# ============================================================
# Cleanup
# ============================================================

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DIST_DIR)
	@rm -rf $(TMP_DIR)
	@echo "✓ Clean complete"

# ============================================================
# Info
# ============================================================

info:
	@echo "enve Build Configuration"
	@echo "=========================================="
	@echo "Version:        $(VER)"
	@echo "Release:        $(RELFIX)"
	@echo "Architecture:   $(PKG_ARCH) / $(DEB_ARCH)"
	@echo "Package Manager: $(PKGMGR)"
	@echo "Proxy:          $(PROXY)"
	@echo "Build Jobs:     $(JOBS)"
	@echo "Compression:    $(COMPRESS)"
	@echo ""
	@echo "Directories:"
	@echo "  Root:         $(ROOT_DIR)"
	@echo "  Build:        $(BUILD_DIR)"
	@echo "  Dist:         $(DIST_DIR)"
	@echo "  Temp:         $(TMP_DIR)"
	@echo ""
	@echo "Package Names:"
	@echo "  AppImage:     $(PKG_NAME)-$(VER)-$(PKG_ARCH).AppImage"
	@echo "  Debian:       $(PKG_NAME)_$(VER)-$(RELFIX)_$(DEB_ARCH).deb"
	@echo "  Arch:         $(PKG_NAME)-$(VER)-$(RELFIX)-$(PKG_ARCH).pkg.tar.gz"

# ============================================================
# Test
# ============================================================

test: build
	@echo "🧪 Running basic tests..."
	@echo "Checking executable..."
	@test -x $(BUILD_DIR)/src/app/enve && echo "  ✓ enve executable found" || echo "  ✗ enve executable not found"
	@echo "Checking shared library..."
	@test -f $(BUILD_DIR)/src/core/libenvecore.so && echo "  ✓ libenvecore.so found" || echo "  ✗ libenvecore.so not found"
	@echo "Checking dependencies..."
	@ldd $(BUILD_DIR)/src/app/enve 2>&1 | grep -E "not found" && echo "  ✗ Missing dependencies" || echo "  ✓ All dependencies resolved"
	@echo "Tests complete"
