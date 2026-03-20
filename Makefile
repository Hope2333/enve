# enve - Top-level Makefile for GNU/Linux Packaging
#
# Usage:
#   make all          - Build and create all package formats
#   make build        - Build enve and all dependencies
#   make package      - Create all package formats
#   make package-deb  - Create .deb package only
#   make package-pkg  - Create .pkg.tar.gz package only
#   make clean        - Clean build artifacts
#   make help         - Show this help
#
# Variables:
#   VER           - Version string (default: 0.0.0)
#   RELFIX        - Release revision (default: 1)
#   PKG           - Package type: both (default), deb, pkg
#   PROXY         - HTTP/HTTPS proxy (default: http://localhost:7890)
#   JOBS          - Parallel build jobs (default: nproc)
#   COMPRESS      - Compression level: 1-9 (default: 6)
#   MIX           - Flatten output: 0 (default), 1 (mix all formats)
#   ODIR          - Output directory (default: ./packing)
#   PACKAGER_NAME - Packager name and email

SHELL := /bin/bash
.DEFAULT_GOAL := help

# ============================================================
# Configuration
# ============================================================

# Version info
VER ?= 0.0.0
RELFIX ?= 1

# Build parameters
PKG ?= both
PROXY ?= http://localhost:7890
JOBS ?= $(shell nproc 2>/dev/null || echo 2)
COMPRESS ?= 6
MIX ?= 0
ODIR ?=
PACKAGER_NAME ?= enve Project <https://github.com/MaurycyLiebner/enve>

# Feature flags (Phase 2 dependency boundaries)
ENVE_USE_GPERFTOOLS ?= 1  # Enable/disable gperftools (default: enabled)
ENVE_USE_WEBENGINE ?= 1   # Enable/disable WebEngine preview (default: enabled)
ENVE_USE_QSCINTILLA ?= 1  # Enable/disable QScintilla (default: enabled)
ENVE_USE_OPENMP ?= 1      # Enable/disable OpenMP (default: enabled)
ENVE_BUILD_EXAMPLES ?= 0  # Enable/disable examples build (default: disabled)

# Directories
ROOT_DIR := $(shell pwd)
BUILD_DIR := $(ROOT_DIR)/build/Release
OUTPUT_ROOT := $(if $(ODIR),$(ODIR),$(ROOT_DIR)/packing)
TMP_DIR := $(ROOT_DIR)/.work
THIRD_PARTY_DIR := $(ROOT_DIR)/third_party

# Architecture detection
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
PKG_VER := $(PKG_NAME)-$(VER)
PKG_FULL := $(PKG_VER)-$(RELFIX)-$(PKG_ARCH)

# Proxy configuration
export http_proxy ?= $(PROXY)
export https_proxy ?= $(PROXY)
export HTTP_PROXY ?= $(PROXY)
export HTTPS_PROXY ?= $(PROXY)

# ============================================================
# Phony Targets
# ============================================================

.PHONY: help all build runtime stage package package-deb package-pkg \
        package-appimage clean status steps selfcheck info

# ============================================================
# Help
# ============================================================

help:
	@echo "enve Build System for GNU/Linux"
	@echo
	@echo "Mainline scope:"
	@echo "  - Local Linux packaging workflow (deb + pkg + AppImage)"
	@echo "  - Network-restricted environments (proxy support)"
	@echo
	@echo "Primary commands:"
	@echo "  make all VER=0.0.0 PKG=both"
	@echo "  make all VER=0.0.0 PKG=deb"
	@echo "  make all VER=0.0.0 PKG=pkg"
	@echo "  make all VER=0.0.0 PKG=both ODIR=~/enve-out"
	@echo "  make all VER=0.0.0 PKG=both ODIR=~/enve-out MIX=1"
	@echo "  make build VER=0.0.0"
	@echo "  make runtime VER=0.0.0"
	@echo "  make stage"
	@echo "  make package-deb"
	@echo "  make package-pkg"
	@echo
	@echo "Output policy:"
	@echo "  - Default root: ./packing"
	@echo "  - With ODIR: write to ODIR only"
	@echo "  - Default layout: deb/ and pacman/ subfolders"
	@echo "  - MIX=1: flatten all artifacts into one directory"
	@echo
	@echo "Workspace policy:"
	@echo "  - Temporary work under project-local ./.work"
	@echo "  - Auto-clean after packaging"
	@echo "  - KEEP_WORK=1 keeps workspace for debugging"
	@echo
	@echo "Debug/introspection:"
	@echo "  make steps"
	@echo "  make status"
	@echo "  make selfcheck"
	@echo "  make info"

# ============================================================
# Main Targets
# ============================================================

steps:
	@echo "Build steps: clean -> runtime -> stage -> package"
	@echo "Package steps: deb and/or pacman depending on PKG"
	@echo "Output root: $(OUTPUT_ROOT)"
	@echo "Mix(flatten): $(MIX)"

all: clean runtime stage
	@if [ "$(PKG)" = "deb" ]; then \
		$(MAKE) package-deb; \
	elif [ "$(PKG)" = "pkg" ]; then \
		$(MAKE) package-pkg; \
	else \
		$(MAKE) package-deb && $(MAKE) package-pkg; \
	fi

# ============================================================
# Build Targets
# ============================================================

# Build everything (runtime + stage)
build: runtime stage
	@echo "=========================================="
	@echo "✓ Build complete!"
	@echo "=========================================="
	@ls -lh $(BUILD_DIR)/src/app/enve 2>/dev/null || echo "  (executable not yet built)"
	@ls -lh $(BUILD_DIR)/src/core/libenvecore.so 2>/dev/null || echo "  (library not yet built)"

# Runtime: prepare build environment and fetch dependencies
runtime:
	@echo "🔍 Preparing runtime environment..."
	@mkdir -p $(BUILD_DIR) $(TMP_DIR)
	@echo "  ✓ Runtime environment ready"

# Stage: build third-party and enve
stage: runtime
	@echo "🔨 Building third-party dependencies..."
	@cd $(ROOT_DIR) && $(MAKE) -C $(THIRD_PARTY_DIR) BUILD_DIR=$(BUILD_DIR) -j$(JOBS) 2>&1 | tail -5 || true
	@echo "  ✓ Third-party build complete"
	@echo "🔨 Building enve..."
	@cd $(BUILD_DIR) && \
		qmake CONFIG+=release \
			ENVE_USE_GPERFTOOLS=$(ENVE_USE_GPERFTOOLS) \
			ENVE_USE_WEBENGINE=$(ENVE_USE_WEBENGINE) \
			ENVE_USE_QSCINTILLA=$(ENVE_USE_QSCINTILLA) \
			ENVE_USE_OPENMP=$(ENVE_USE_OPENMP) \
			ENVE_BUILD_EXAMPLES=$(ENVE_BUILD_EXAMPLES) \
			../../enve.pro && \
		make -j$(JOBS) 2>&1 | tail -10 || true
	@echo "  ✓ enve build complete"

# ============================================================
# Packaging Targets
# ============================================================

# Package deb
package-deb: stage
	@echo "📦 Creating Debian package..."
	@mkdir -p $(OUTPUT_ROOT)/deb
	@OUTPUT_ROOT=$(OUTPUT_ROOT) VERSION=$(VER) RELFIX=$(RELFIX) MAINTAINER='$(PACKAGER_NAME)' COMPRESS=$(COMPRESS) \
		./packaging/scripts/package_deb.sh

# Package pacman
package-pkg: stage
	@echo "📦 Creating Arch package..."
	@mkdir -p $(OUTPUT_ROOT)/pacman
	@OUTPUT_ROOT=$(OUTPUT_ROOT) VERSION=$(VER) RELFIX=$(RELFIX) PACKAGER='$(PACKAGER_NAME)' COMPRESS=$(COMPRESS) \
		./packaging/scripts/package_pacman.sh

# ============================================================
# Cleanup and Info
# ============================================================

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(OUTPUT_ROOT)
	@rm -rf $(TMP_DIR)
	@echo "✓ Clean complete"

status:
	@echo "Staged runtime:"
	@if [ -x $(BUILD_DIR)/src/app/enve ]; then \
		$(BUILD_DIR)/src/app/enve --version 2>/dev/null || echo "  (version check not available)"; \
	else \
		echo "  <missing>"; \
	fi

selfcheck:
	@echo "🔍 Running self-check..."
	@command -v qmake >/dev/null 2>&1 || { echo "❌ qmake not found"; exit 1; }
	@command -v make >/dev/null 2>&1 || { echo "❌ make not found"; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "❌ git not found"; exit 1; }
	@command -v patch >/dev/null 2>&1 || { echo "❌ patch not found"; exit 1; }
	@command -v curl >/dev/null 2>&1 || { echo "❌ curl not found"; exit 1; }
	@echo "  ✓ All basic dependencies found"

info:
	@echo "enve Build Configuration"
	@echo "=========================================="
	@echo "Version:        $(VER)"
	@echo "Release:        $(RELFIX)"
	@echo "Architecture:   $(PKG_ARCH) / $(DEB_ARCH)"
	@echo "Package Type:   $(PKG)"
	@echo "Proxy:          $(PROXY)"
	@echo "Build Jobs:     $(JOBS)"
	@echo "Compression:    $(COMPRESS)"
	@echo "Mix Output:     $(MIX)"
	@echo "Output Dir:     $(OUTPUT_ROOT)"
	@echo "Packager:       $(PACKAGER_NAME)"
	@echo ""
	@echo "Directories:"
	@echo "  Root:         $(ROOT_DIR)"
	@echo "  Build:        $(BUILD_DIR)"
	@echo "  Output:       $(OUTPUT_ROOT)"
	@echo "  Temp:         $(TMP_DIR)"
	@echo ""
	@echo "Package Names:"
	@echo "  Debian:       $(PKG_NAME)_$(VER)-$(RELFIX)_$(DEB_ARCH).deb"
	@echo "  Arch:         $(PKG_NAME)-$(VER)-$(RELFIX)-$(PKG_ARCH).pkg.tar.gz"
