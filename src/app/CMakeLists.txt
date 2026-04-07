# CMake configuration for enve application
#
# Phase 5: Build-System Migration - Batch B.2
#
# Status: MINIMAL IMPLEMENTATION
# - Qt modules configured
# - Source files auto-generated from disk
# - Optional dependency gates included
# - Resources DEFERRED to Batch B.3
# - QScintilla files excluded when disabled
#
# qmake remains the authoritative release path for the application.

# ============================================================
# libmypaint transitive dependencies (Linux)
# Matches qmake core.pri: LIBS += -lgobject-2.0 -lglib-2.0 -ljson-c
# ============================================================
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBMYPAINT REQUIRED IMPORTED_TARGET libmypaint)

# Collect all source files from disk
file(GLOB_RECURSE enve_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
)

# Collect all header files from disk
file(GLOB_RECURSE enve_HEADERS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.h"
)

# Exclude QScintilla-dependent files if QScintilla is disabled
if(NOT ENVE_USE_QSCINTILLA OR NOT QScintilla_FOUND)
    list(FILTER enve_SOURCES EXCLUDE REGEX ".*GUI/Expressions/.*\\.cpp$")
    list(FILTER enve_HEADERS EXCLUDE REGEX ".*GUI/Expressions/.*\\.h$")
endif()

# Create executable
add_executable(enve ${enve_SOURCES} ${enve_HEADERS})

# Add Qt resource files (.qrc)
# Batch B.3: Resources migration
qt5_add_resources(enve_RESOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/resources.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/toolbarButtonsBg.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/toolbarButtonsPlain.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/toolbarButtonsCheckable.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/noInterpolation.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/plain.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/brushesClassic.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/brushesDeevad.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/brushesDieterle.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/brushesExperimental.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/brushesKaerhon.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/brushesRamon.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/brushesTanda.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/tips.qrc
)
target_sources(enve PRIVATE ${enve_RESOURCES})

# Define ENVE_VERSION macro from git tag or fallback
execute_process(
    COMMAND git describe --tags --abbrev=0
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_TAG
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    RESULT_VARIABLE GIT_RESULT
)
if(GIT_RESULT EQUAL 0)
    string(SUBSTRING "${GIT_TAG}" 1 -1 ENVE_VERSION) # Strip 'v' prefix
else()
    set(ENVE_VERSION "0.0.0-CMake")
endif()

target_compile_definitions(enve PRIVATE
    ENVE_VERSION="${ENVE_VERSION}"
)

# Set include directories
target_include_directories(enve PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${CMAKE_SOURCE_DIR}/src/core
)

# Set C++ standard
set_target_properties(enve PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
)

# Enable Qt MOC, RCC, UIC
set_target_properties(enve PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    AUTOUIC ON
)

# Link dependencies
target_link_libraries(enve PRIVATE
    envecore
    Qt5::Core
    Qt5::Gui
    Qt5::Svg
    Qt5::OpenGL
    Qt5::Sql
    Qt5::Qml
    Qt5::Xml
    Qt5::Concurrent
    Qt5::Multimedia
    Qt5::Widgets
    # Skia dependencies
    ${CMAKE_SOURCE_DIR}/third_party/skia/out/Release/libskia.a
    # WebP for Skia WebP encoder
    webp
    webpmux
    webpdemux
    # GLX for Skia GL backend
    GLX
    # JPEG for Skia JPEG decoder
    jpeg
)

# libmypaint transitive dependencies (Linux)
# Matches qmake core.pri: LIBS += -lgobject-2.0 -lglib-2.0 -ljson-c
target_link_libraries(enve PRIVATE PkgConfig::LIBMYPAINT)

# Optional: WebEngine (for SVG preview)
if(ENVE_USE_WEBENGINE AND Qt5WebEngineWidgets_FOUND)
    target_link_libraries(enve PRIVATE Qt5::WebEngineWidgets)
    target_compile_definitions(enve PRIVATE ENVE_USE_WEBENGINE)
endif()

# Optional: QScintilla (for expression editor)
if(ENVE_USE_QSCINTILLA AND QScintilla_FOUND)
    target_include_directories(enve PRIVATE ${QSCINTILLA_INCLUDE_DIR})
    target_link_libraries(enve PRIVATE ${QSCINTILLA_LIBRARY})
    target_compile_definitions(enve PRIVATE QSCINTILLA_DLL)
endif()

# Optional: gperftools (tcmalloc)
if(ENVE_USE_GPERFTOOLS AND GPERFTOOLS_FOUND)
    target_include_directories(enve PRIVATE
        ${CMAKE_SOURCE_DIR}/third_party/gperftools/include
    )
    target_link_libraries(enve PRIVATE ${GPERFTOOLS_LIBRARIES})
endif()

# FFmpeg (inherited from envecore)
target_link_libraries(enve PRIVATE
    ${FFMPEG_LIBRARIES}
)

# Set output directory
set_target_properties(enve PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Platform-specific
if(WIN32)
    # Windows-specific configuration
    target_sources(enve PRIVATE pixmaps/enve.rc)
endif()

# Note: Resources (.qrc files) are DEFERRED to Batch B.3
# The following resource groups need to be added:
# - resources.qrc
# - toolbarButtonsBg
# - toolbarButtonsPlain
# - toolbarButtonsCheckable
# - noInterpolation
# - plain
# - brushesClassic/Deevad/Dieterle/Experimental/Kaerhon/Ramon/Tanda
# - tips
