# CMake configuration for enve application
#
# Phase 5: Build-System Migration
#
# Status: SKELETON ONLY - app CMake migration is Phase 5 follow-up work.
# qmake remains the authoritative release path for the application.
#
# See: docs/modernization/phase-5-roadmap.md

# Placeholder to allow root CMakeLists.txt to configure without errors.
# The real app CMake migration will happen after envecore is stable.

message(STATUS "src/app/CMakeLists.txt: SKELETON ONLY - qmake is authoritative for app")

# Minimal target to satisfy root CMakeLists.txt add_subdirectory()
add_executable(enve main.cpp)
target_link_libraries(enve PRIVATE envecore)
