# Find libmypaint
#
# This module defines:
#  MYPAINT_INCLUDE_DIRS - Directory containing mypaint headers
#  MYPAINT_LIBRARIES    - Libraries to link against
#  MYPAINT_FOUND        - If false, do not try to use libmypaint
#
# The following variables may be set before calling find_package() to
# influence the search:
#  MYPAINT_ROOT - Root directory of libmypaint installation

find_package(PkgConfig QUIET)

if(PkgConfig_FOUND)
    pkg_check_modules(PC_LIBMYPAINT QUIET libmypaint)
endif()

# Use pkg-config results as hints
set(MYPAINT_INCLUDE_DIRS ${PC_LIBMYPAINT_INCLUDE_DIRS})
set(MYPAINT_LIBRARIES ${PC_LIBMYPAINT_LIBRARIES})

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
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(libmypaint
    REQUIRED_VARS MYPAINT_LIBRARIES MYPAINT_INCLUDE_DIRS
)

if(MYPAINT_FOUND AND NOT TARGET libmypaint::libmypaint)
    add_library(libmypaint::libmypaint UNKNOWN IMPORTED)
    set_target_properties(libmypaint::libmypaint PROPERTIES
        IMPORTED_LOCATION "${MYPAINT_LIBRARIES}"
        INTERFACE_INCLUDE_DIRECTORIES "${MYPAINT_INCLUDE_DIRS}"
    )
endif()

mark_as_advanced(MYPAINT_INCLUDE_DIRS MYPAINT_LIBRARIES)
