# FindQScintilla.cmake
#
# Find QScintilla2 Qt5 bindings
#
# This module defines:
#  QSCINTILLA_FOUND - System has QScintilla
#  QSCINTILLA_INCLUDE_DIR - QScintilla include directory
#  QSCINTILLA_LIBRARY - QScintilla library
#  QSCINTILLA_VERSION - QScintilla version
#
# QScintilla doesn't provide a standard CMake config file,
# so we search for it manually.

find_path(QSCINTILLA_INCLUDE_DIR
    NAMES Qsci/qsciscintilla.h
    PATHS
        /usr/include
        /usr/local/include
        /opt/qt5/include
    PATH_SUFFIXES
        qt5
        Qt5
)

find_library(QSCINTILLA_LIBRARY
    NAMES qscintilla2_qt5 qscintilla2-qt5 qscintilla_qt5
    PATHS
        /usr/lib
        /usr/local/lib
        /opt/qt5/lib
    PATH_SUFFIXES
        qt5
        Qt5
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(QScintilla
    REQUIRED_VARS QSCINTILLA_LIBRARY QSCINTILLA_INCLUDE_DIR
    VERSION_VAR QSCINTILLA_VERSION
)

mark_as_advanced(QSCINTILLA_INCLUDE_DIR QSCINTILLA_LIBRARY)

if(QSCINTILLA_FOUND AND NOT TARGET QScintilla::QScintilla)
    add_library(QScintilla::QScintilla UNKNOWN IMPORTED)
    set_target_properties(QScintilla::QScintilla PROPERTIES
        IMPORTED_LOCATION ${QSCINTILLA_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${QSCINTILLA_INCLUDE_DIR}
    )
endif()
