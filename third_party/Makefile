# Build third party dependencies
.PHONY: all patch build skia libmypaint quazip gperftools qscintilla clean clean-all

# Build directory configuration
BUILD_DIR ?= ../build/Release
STAMP_DIR := $(BUILD_DIR)/stamps/third_party

all: patch build

patch:
	patch -d gperftools -p1 < gperftools-enve-mod.patch

# Create stamp directory
$(STAMP_DIR):
	mkdir -p $(STAMP_DIR)

# Clean targets
clean:
	rm -rf $(STAMP_DIR)/*.stamp

clean-all: clean
	rm -rf skia/out skia/tools/git-sync-deps
	rm -rf libmypaint/autom4te.cache libmypaint/configure libmypaint/Makefile
	rm -rf quazip/.qmake.stash quazip/Makefile
	rm -rf gperftools/autom4te.cache gperftools/configure gperftools/Makefile
	rm -rf qscintilla/.qmake.stash qscintilla/Makefile

# Build with stamp files for incremental builds
build: skia libmypaint quazip gperftools qscintilla
	@echo "✓ All third-party dependencies built"

# Stamp file wrapper for each dependency
skia: $(STAMP_DIR)/skia.stamp
libmypaint: $(STAMP_DIR)/libmypaint.stamp
quazip: $(STAMP_DIR)/quazip.stamp
gperftools: $(STAMP_DIR)/gperftools.stamp
qscintilla: $(STAMP_DIR)/qscintilla.stamp

.ONESHELL:
$(STAMP_DIR)/skia.stamp: $(STAMP_DIR) skia/*
	@echo "🔨 Building Skia..."
	cd skia
	python tools/git-sync-deps
	bin/gn gen out/Release --args='is_official_build=true is_debug=false extra_cflags=["-Wno-error"] skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false'
	ninja -C out/Release libskia.a
	touch $@
	@echo "  ✓ Skia build complete"

.ONESHELL:
$(STAMP_DIR)/libmypaint.stamp: $(STAMP_DIR) libmypaint/*
	@echo "🔨 Building libmypaint..."
	cd libmypaint
	./autogen.sh
	./configure --enable-static --enable-shared=false
	make -j$$(nproc)
	ln -s `pwd` libmypaint
	touch $@
	@echo "  ✓ libmypaint build complete"

.ONESHELL:
$(STAMP_DIR)/quazip.stamp: $(STAMP_DIR) quazip/*
	@echo "🔨 Building QuaZip..."
	cd quazip
	qmake quazip.pro CONFIG+=release
	make -j$$(nproc)
	touch $@
	@echo "  ✓ QuaZip build complete"

.ONESHELL:
$(STAMP_DIR)/gperftools.stamp: $(STAMP_DIR) gperftools/*
	@echo "🔨 Building gperftools..."
	cd gperftools
	./autogen.sh
	./configure --prefix /usr LIBS=-lpthread
	make -j$$(nproc)
	touch $@
	@echo "  ✓ gperftools build complete"

.ONESHELL:
$(STAMP_DIR)/qscintilla.stamp: $(STAMP_DIR) qscintilla/*
	@echo "🔨 Building QScintilla..."
	cd qscintilla
	qmake CONFIG+=release
	make -j$$(nproc)
	touch $@
	@echo "  ✓ QScintilla build complete"
