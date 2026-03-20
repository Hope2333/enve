# CMake configuration for enve application
#
# This is a work-in-progress. Currently a SKELETON ONLY.

# Collect all source files
# TODO: Verify this list matches qmake build
set(enve_SOURCES
    main.cpp

    # GUI
    GUI/BoxesList/boxscroller.cpp
    GUI/BoxesList/OptimalScrollArea/scrollvisiblepartbase.cpp
    GUI/BrushWidgets/bookmarkedbrushes.cpp
    GUI/BrushWidgets/brushlabel.cpp
    GUI/ColorWidgets/bookmarkedcolors.cpp
    GUI/ColorWidgets/paintcolorwidget.cpp
    GUI/Dialogs/animationtopaintdialog.cpp
    GUI/Dialogs/applyexpressiondialog.cpp
    GUI/Dialogs/dialogsinterfaceimpl.cpp
    GUI/Dialogs/durationrectsettingsdialog.cpp
    GUI/Dialogs/exportsvgdialog.cpp
    # ... more GUI sources

    # Expressions
    GUI/Expressions/expressiondialog.cpp
    # ... more expression sources

    # Timeline
    GUI/Timeline/timelineheader.cpp
    GUI/Timeline/timelinewidget.cpp
    # ... more timeline sources
)

# Collect all header files
set(enve_HEADERS
    GUI/BoxesList/boxscroller.h
    GUI/BoxesList/OptimalScrollArea/scrollvisiblepartbase.h
    # ... more headers
)

# Create executable
add_executable(enve ${enve_SOURCES} ${enve_HEADERS})

# Set include directories
target_include_directories(enve PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/src/core
)

# Add compiler definitions
target_compile_definitions(enve PRIVATE
    QT_NO_FOREACH
    QSCINTILLA_DLL
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
)

# Optional WebEngine
if(ENVE_USE_WEBENGINE AND Qt5WebEngineWidgets_FOUND)
    target_link_libraries(enve PRIVATE Qt5::WebEngineWidgets)
endif()

# Optional QScintilla
if(ENVE_USE_QSCINTILLA)
    # TODO: Add QScintilla link
    # target_link_libraries(enve PRIVATE ${QSCINTILLA_LIBRARY})
endif()

# Compiler options
target_compile_options(enve PRIVATE
    -Wall
    -Wextra
    -Wno-unused-parameter
)

# Set executable properties
set_target_properties(enve PROPERTIES
    OUTPUT_NAME enve
    VERSION ${PROJECT_VERSION}
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Install executable
install(TARGETS enve
    RUNTIME DESTINATION bin
)
