# CMake configuration for enve examples
#
# Phase 7.A: CMake Completion
#
# Status: Full examples build support with envecore linkage.
# Examples are compiled against the built envecore library.

# Collect all example source files
file(GLOB_RECURSE examples_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/**/*.cpp"
)

# Build each example as a separate executable
foreach(example_src ${examples_SOURCES})
    get_filename_component(example_name ${example_src} NAME_WE)
    get_filename_component(example_dir ${example_src} DIRECTORY)

    add_executable(enve-example-${example_name} ${example_src})

    target_include_directories(enve-example-${example_name} PRIVATE
        ${CMAKE_SOURCE_DIR}/src/core
        ${CMAKE_SOURCE_DIR}/include/enveCore
    )

    target_link_libraries(enve-example-${example_name} PRIVATE
        envecore
        Qt5::Core
        Qt5::Gui
        Qt5::OpenGL
    )

    set_target_properties(enve-example-${example_name} PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/examples
    )
endforeach()
