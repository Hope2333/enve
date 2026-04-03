# CMake Configuration for enve
#
# Phase 5: Build-System Migration
# 
# Status: Core library (envecore) is real and builds.
# qmake remains the authoritative release path until full parity is achieved.
#
# See: docs/modernization/phase-5-roadmap.md

cmake_minimum_required(VERSION 3.16)

project(enve
    VERSION 0.0.0
    DESCRIPTION "2D animation software"
    LANGUAGES CXX C
)

# ============================================================
# CMake Module Path
# ============================================================

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# ============================================================
# Build Options (Phase 2 feature flags)
# ============================================================

option(ENVE_USE_GPERFTOOLS "Enable gperftools/tcmalloc support" ON)
option(ENVE_USE_OPENMP "Enable OpenMP parallelism" ON)
option(ENVE_USE_WEBENGINE "Enable Qt WebEngine for SVG preview" ON)
option(ENVE_USE_QSCINTILLA "Enable QScintilla script editor" ON)
option(ENVE_BUILD_EXAMPLES "Build example effects" OFF)
option(ENVE_USE_SYSTEM_LIBMYPAINT "Use system libmypaint instead of vendored" OFF)

# ============================================================
# CMake Configuration
# ============================================================

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# ============================================================
# Find Dependencies
# ============================================================

# Qt5 (required)
find_package(Qt5 REQUIRED COMPONENTS
    Core
    Gui
    Svg
    OpenGL
    Sql
    Qml
    Xml
    Concurrent
    Multimedia
    Widgets
)

# Qt WebEngine (optional)
if(ENVE_USE_WEBENGINE)
    find_package(Qt5 COMPONENTS WebEngineWidgets)
    if(Qt5WebEngineWidgets_FOUND)
        message(STATUS "Qt WebEngine enabled")
    else()
        message(WARNING "Qt WebEngine requested but not found")
        set(ENVE_USE_WEBENGINE OFF)
    endif()
else()
    message(STATUS "Qt WebEngine disabled")
endif()

# OpenMP (optional)
if(ENVE_USE_OPENMP)
    find_package(OpenMP)
    if(OpenMP_CXX_FOUND)
        message(STATUS "OpenMP enabled")
    else()
        message(WARNING "OpenMP requested but not found")
        set(ENVE_USE_OPENMP OFF)
    endif()
else()
    message(STATUS "OpenMP disabled")
endif()

# gperftools (optional)
if(ENVE_USE_GPERFTOOLS)
    find_package(PkgConfig)
    if(PkgConfig_FOUND)
        pkg_check_modules(GPERFTOOLS libtcmalloc)
    endif()
    if(GPERFTOOLS_FOUND)
        message(STATUS "gperftools enabled")
    else()
        message(WARNING "gperftools requested but not found")
        set(ENVE_USE_GPERFTOOLS OFF)
    endif()
else()
    message(STATUS "gperftools disabled")
endif()

# QScintilla (optional)
if(ENVE_USE_QSCINTILLA)
    find_package(QScintilla)
    if(QScintilla_FOUND)
        message(STATUS "QScintilla found: ${QSCINTILLA_LIBRARY}")
    else()
        message(WARNING "QScintilla requested but not found, using vendored")
        # Will use vendored QScintilla from third_party
    endif()
else()
    message(STATUS "QScintilla disabled")
endif()

# libmypaint (optional system/vendored)
# Phase 6.B: Bridge to system package (low-risk debt cleanup)
# Note: Actual libmypaint build is in src/core/CMakeLists.txt

# FFmpeg (required)
find_package(PkgConfig REQUIRED)
pkg_check_modules(FFMPEG REQUIRED
    libavcodec
    libavformat
    libavutil
    libswscale
    libswresample
)

# System libraries
find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)
find_package(Freetype REQUIRED)
find_package(Fontconfig REQUIRED)

# ============================================================
# Third-Party Dependencies (vendored)
# ============================================================

# Skia (required, vendored)
# Skia uses GN/Ninja for building, so we need to either:
# 1. Pre-build Skia and link against it
# 2. Use ExternalProject to build Skia during CMake configure
# 3. Use a pre-built Skia package
#
# For now, we assume Skia is pre-built
add_library(Skia INTERFACE)
target_include_directories(Skia INTERFACE
    ${CMAKE_SOURCE_DIR}/third_party/skia
    ${CMAKE_SOURCE_DIR}/third_party/skia/include
)
target_link_libraries(Skia INTERFACE
    ${CMAKE_SOURCE_DIR}/third_party/skia/out/Release/libskia.a
)

# ============================================================
# Core Library
# ============================================================

add_subdirectory(src/core)

# ============================================================
# Application
# ============================================================

add_subdirectory(src/app)

# ============================================================
# Examples (optional)
# ============================================================

if(ENVE_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# ============================================================
# Installation
# ============================================================

install(TARGETS enve
    RUNTIME DESTINATION bin
)

# Install desktop file and icons (Linux)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    install(FILES org.maurycy.enve.desktop
        DESTINATION share/applications
    )
    install(FILES pixmaps/enve.svg
        DESTINATION share/icons/hicolor/scalable/apps
    )
endif()

# ============================================================
# Configuration Summary
# ============================================================

message(STATUS "")
message(STATUS "enve ${PROJECT_VERSION} configuration summary:")
message(STATUS "")
message(STATUS "  Build type:           ${CMAKE_BUILD_TYPE}")
message(STATUS "  Install prefix:       ${CMAKE_INSTALL_PREFIX}")
message(STATUS "")
message(STATUS "  Qt version:           ${Qt5Core_VERSION}")
message(STATUS "  FFmpeg:               ${FFMPEG_FOUND}")
message(STATUS "")
message(STATUS "  gperftools:           ${ENVE_USE_GPERFTOOLS}")
message(STATUS "  OpenMP:               ${ENVE_USE_OPENMP}")
message(STATUS "  WebEngine:            ${ENVE_USE_WEBENGINE}")
message(STATUS "  QScintilla:           ${ENVE_USE_QSCINTILLA}")
message(STATUS "  Examples:             ${ENVE_BUILD_EXAMPLES}")
message(STATUS "  System libmypaint:    ${ENVE_USE_SYSTEM_LIBMYPAINT}")
message(STATUS "")
