# Find libmypaint
#
# This module defines:
#  MYPAINT_INCLUDE_DIRS - Directory containing mypaint headers
#  MYPAINT_LIBRARIES    - Libraries to link against
#  MYPAINT_FOUND        - If false, do not try to use libmypaint
#  libmypaint::libmypaint - Imported target with transitive dependencies
#
# The following variables may be set before calling find_package() to
# influence the search:
#  MYPAINT_ROOT - Root directory of libmypaint installation

find_package(PkgConfig QUIET)

if(PkgConfig_FOUND)
    pkg_check_modules(PC_LIBMYPAINT QUIET IMPORTED_TARGET libmypaint)
endif()

# Use pkg-config results
if(PC_LIBMYPAINT_FOUND)
    set(MYPAINT_INCLUDE_DIRS ${PC_LIBMYPAINT_INCLUDE_DIRS})
    set(MYPAINT_LIBRARIES ${PC_LIBMYPAINT_LIBRARIES})
    set(MYPAINT_FOUND TRUE)
endif()

# If pkg-config didn't work, try to find manually
if(NOT MYPAINT_FOUND)
    find_path(MYPAINT_INCLUDE_DIR
        NAMES mypaint.h mypaint-brush.h
        HINTS ${MYPAINT_ROOT}/include
              /usr/include
              /usr/local/include
    )

    find_library(MYPAINT_LIBRARY
        NAMES mypaint
        HINTS ${MYPAINT_ROOT}/lib
              /usr/lib
              /usr/local/lib
    )

    if(MYPAINT_INCLUDE_DIR AND MYPAINT_LIBRARY)
        set(MYPAINT_INCLUDE_DIRS ${MYPAINT_INCLUDE_DIR})
        set(MYPAINT_LIBRARIES ${MYPAINT_LIBRARY})
        set(MYPAINT_FOUND TRUE)
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(libmypaint
    REQUIRED_VARS MYPAINT_LIBRARIES MYPAINT_INCLUDE_DIRS
)

# Also set MYPAINT_FOUND for backwards compatibility
if(libmypaint_FOUND)
    set(MYPAINT_FOUND TRUE)
endif()

if(MYPAINT_FOUND AND NOT TARGET libmypaint::libmypaint)
    if(PC_LIBMYPAINT_FOUND)
        # Use PkgConfig imported target which handles transitive deps correctly
        add_library(libmypaint::libmypaint INTERFACE IMPORTED)
        set_target_properties(libmypaint::libmypaint PROPERTIES
            INTERFACE_LINK_LIBRARIES "PkgConfig::PC_LIBMYPAINT"
        )
    else()
        # Fallback: manual target with explicit library
        add_library(libmypaint::libmypaint UNKNOWN IMPORTED)
        set_target_properties(libmypaint::libmypaint PROPERTIES
            IMPORTED_LOCATION "${MYPAINT_LIBRARIES}"
            INTERFACE_INCLUDE_DIRECTORIES "${MYPAINT_INCLUDE_DIRS}"
        )
    endif()
endif()

mark_as_advanced(MYPAINT_INCLUDE_DIRS MYPAINT_LIBRARIES)
