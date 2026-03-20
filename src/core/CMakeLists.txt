# CMake configuration for enve core library
#
# This is a work-in-progress. Currently a SKELETON ONLY.

# Collect all source files
# TODO: Verify this list matches qmake build
set(envecore_SOURCES
    # Animators
    Animators/animator.cpp
    Animators/animatorreferencekey.cpp
    Animators/bezieranimator.cpp
    Animators/bezierkey.cpp
    Animators/doubleanimator.cpp
    Animators/doublekey.cpp
    Animators/graphanimator.cpp
    Animators/graphkey.cpp
    Animators/intanimator.cpp
    Animators/intkey.cpp
    Animators/key.cpp
    Animators/maskanimator.cpp
    Animators/qrealanimator.cpp
    Animators/qrealkey.cpp
    Animators/simplesnap.cpp
    Animators/snap.cpp
    Animators/stringkey.cpp
    Animators/textanimator.cpp

    # Brushes
    brushes/brush.cpp
    brushes/brushesmanager.cpp
    brushes/brushpreset.cpp
    brushes/brushsettings.cpp

    # Effects
    Effects/boxblur.cpp
    Effects/effect.cpp
    Effects/effectcollection.cpp
    Effects/fastblur.cpp
    Effects/gaussianblur.cpp
    Effects/pixelate.cpp

    # File I/O
    FileCacheHandlers/abstractpgformat.cpp
    FileCacheHandlers/cachehandler.cpp
    FileCacheHandlers/gifformat.cpp
    FileCacheHandlers/imagescachehandler.cpp
    FileCacheHandlers/jpgformat.cpp
    FileCacheHandlers/oggformat.cpp
    FileCacheHandlers/pgf.cpp
    FileCacheHandlers/pngformat.cpp
    FileCacheHandlers/rawimagescachehandler.cpp
    FileCacheHandlers/svgformat.cpp
    FileCacheHandlers/tgaformat.cpp
    FileCacheHandlers/tiffformat.cpp
    FileCacheHandlers/vectormime.cpp
    FileCacheHandlers/webpformat.cpp

    # GUI (core components)
    GUI/effectdetails.cpp
    GUI/effectlistwidget.cpp
    GUI/enveaction.cpp
    GUI/envelistwidget.cpp
    GUI/envescrollarea.cpp
    GUI/envewidget.cpp
    GUI/glwindow.cpp
    GUI/movablescrollbar.cpp
    GUI/propertieswidget.cpp
    GUI/timeline.cpp

    # Import/Export
    importexport.cpp
    importexportinterface.cpp

    # Paint
    Paint/autotiledsurface.cpp
    Paint/drawable.cpp
    Paint/drawableautotiledsurface.cpp
    Paint/mypaint.cpp
    Paint/mypaintbrush.cpp
    Paint/mypaintsurface.cpp
    Paint/paintutils.cpp
    Paint/tile.cpp
    Paint/tilecontext.cpp
    Paint/tilespainter.cpp

    # Properties
    Properties/boxpropertieswidget.cpp
    Properties/coloranimatorwidget.cpp
    Properties/doubleanimatorwidget.cpp
    Properties/propertywidget.cpp

    # Rendering
    renderarea.cpp
    renderpresets.cpp
    renderer.cpp
    rendervector.cpp

    # Skia integration
    skia/skiaincludes.cpp
    skia/skiautils.cpp

    # XML
    XML/attr.cpp
    XML/node.cpp
    XML/xmlfileloader.cpp
    XML/xmlfilesaver.cpp
    XML/zipfileloader.cpp
    XML/zipfilesaver.cpp

    # Core components
    box2d.cpp
    box2dcontainer.cpp
    boxcontainer.cpp
    canvas.cpp
    canvasanimatedobject.cpp
    canvasobject.cpp
    coloranimator.cpp
    constraint.cpp
    container.cpp
    degug.cpp
    dynamicpatheffect.cpp
    effector.cpp
    fillpath.cpp
    gradient.cpp
    image.cpp
    layer.cpp
    linecap.cpp
    mask.cpp
    objectbox.cpp
    offscreenbuffer.cpp
    paintdata.cpp
    palette.cpp
    pardegeffect.cpp
    path.cpp
    patheffect.cpp
    pathutils.cpp
    propertylist.cpp
    rasterpath.cpp
    rasterization.cpp
    realsimplexnoise.cpp
    rectangle.cpp
    rootcanvas.cpp
    scene.cpp
    scenepreview.cpp
    simplepath.cpp
    sound.cpp
    stroke.cpp
    text.cpp
    textpath.cpp
    transform.cpp
    userevent.cpp
    vectorpath.cpp
    videobox.cpp
    videodecoder.cpp
)

# Collect all header files
set(envecore_HEADERS
    Animators/animator.h
    Animators/animatorreferencekey.h
    Animators/bezieranimator.h
    Animators/bezierkey.h
    Animators/doubleanimator.h
    Animators/doublekey.h
    Animators/graphanimator.h
    Animators/graphkey.h
    Animators/intanimator.h
    Animators/intkey.h
    Animators/key.h
    Animators/maskanimator.h
    Animators/qrealanimator.h
    Animators/qrealkey.h
    Animators/simplesnap.h
    Animators/snap.h
    Animators/stringkey.h
    Animators/textanimator.h

    brushes/brush.h
    brushes/brushesmanager.h
    brushes/brushpreset.h
    brushes/brushsettings.h

    Effects/boxblur.h
    Effects/effect.h
    Effects/effectcollection.h
    Effects/fastblur.h
    Effects/gaussianblur.h
    Effects/pixelate.h

    FileCacheHandlers/abstractpgformat.h
    FileCacheHandlers/cachehandler.h
    FileCacheHandlers/gifformat.h
    FileCacheHandlers/imagescachehandler.h
    FileCacheHandlers/jpgformat.h
    FileCacheHandlers/oggformat.h
    FileCacheHandlers/pgf.h
    FileCacheHandlers/pngformat.h
    FileCacheHandlers/rawimagescachehandler.h
    FileCacheHandlers/svgformat.h
    FileCacheHandlers/tgaformat.h
    FileCacheHandlers/tiffformat.h
    FileCacheHandlers/vectormime.h
    FileCacheHandlers/webpformat.h

    GUI/effectdetails.h
    GUI/effectlistwidget.h
    GUI/enveaction.h
    GUI/envelistwidget.h
    GUI/envescrollarea.h
    GUI/envewidget.h
    GUI/glwindow.h
    GUI/movablescrollbar.h
    GUI/propertieswidget.h
    GUI/timeline.h

    importexport.h
    importexportinterface.h

    Paint/autotiledsurface.h
    Paint/drawable.h
    Paint/drawableautotiledsurface.h
    Paint/mypaint.h
    Paint/mypaintbrush.h
    Paint/mypaintsurface.h
    Paint/paintutils.h
    Paint/tile.h
    Paint/tilecontext.h
    Paint/tilespainter.h

    Properties/boxpropertieswidget.h
    Properties/coloranimatorwidget.h
    Properties/doubleanimatorwidget.h
    Properties/propertywidget.h

    renderarea.h
    renderpresets.h
    renderer.h
    rendervector.h

    skia/skiaincludes.h
    skia/skiautils.h

    XML/attr.h
    XML/node.h
    XML/xmlfileloader.h
    XML/xmlfilesaver.h
    XML/zipfileloader.h
    XML/zipfilesaver.h

    box2d.h
    box2dcontainer.h
    boxcontainer.h
    canvas.h
    canvasanimatedobject.h
    canvasobject.h
    coloranimator.h
    constraint.h
    container.h
    degug.h
    dynamicpatheffect.h
    effector.h
    fillpath.h
    gradient.h
    image.h
    layer.h
    linecap.h
    mask.h
    objectbox.h
    offscreenbuffer.h
    paintdata.h
    palette.h
    pardegeffect.h
    path.h
    patheffect.h
    pathutils.h
    propertylist.h
    rasterpath.h
    rasterization.h
    realsimplexnoise.h
    rectangle.h
    rootcanvas.h
    scene.h
    scenepreview.h
    simplepath.h
    sound.h
    stroke.h
    text.h
    textpath.h
    transform.h
    userevent.h
    vectorpath.h
    videobox.h
    videodecoder.h

    # Private headers (not installed)
    core_global.h
)

# Create static library
add_library(envecore STATIC ${envecore_SOURCES} ${envecore_HEADERS})

# Set include directories
target_include_directories(envecore PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${FFMPEG_INCLUDE_DIRS}
)

# Add compiler definitions
target_compile_definitions(envecore PRIVATE
    QT_NO_FOREACH
)

# Link dependencies
target_link_libraries(envecore PUBLIC
    Qt5::Core
    Qt5::Gui
    Qt5::Svg
    Qt5::OpenGL
    Qt5::Sql
    Qt5::Qml
    Qt5::Xml
    Qt5::Concurrent
    Qt5::Multimedia
    Skia
    ${FFMPEG_LIBRARIES}
    ZLIB::ZLIB
    PNG::PNG
    Freetype::Freetype
    Fontconfig::Fontconfig
    Threads::Threads
)

# Optional dependencies
if(ENVE_USE_OPENMP AND OpenMP_CXX_FOUND)
    target_link_libraries(envecore PUBLIC OpenMP::OpenMP_CXX)
endif()

if(ENVE_USE_GPERFTOOLS AND GPERFTOOLS_FOUND)
    target_include_directories(envecore PRIVATE
        ${CMAKE_SOURCE_DIR}/third_party/gperftools/include
    )
    target_link_libraries(envecore PRIVATE
        ${GPERFTOOLS_LIBRARIES}
    )
endif()

if(ENVE_USE_QSCINTILLA)
    # TODO: Add QScintilla include and link directories
    # target_include_directories(envecore PRIVATE ${QSCINTILLA_INCLUDE_DIR})
    # target_link_libraries(envecore PRIVATE ${QSCINTILLA_LIBRARY})
endif()

if(ENVE_USE_SYSTEM_LIBMYPAINT AND MYPAINT_FOUND)
    target_include_directories(envecore PRIVATE ${MYPAINT_INCLUDE_DIRS})
    target_link_libraries(envecore PRIVATE ${MYPAINT_LIBRARIES})
else()
    # Vendored libmypaint
    target_include_directories(envecore PRIVATE
        ${CMAKE_SOURCE_DIR}/third_party/libmypaint
    )
    target_link_libraries(envecore PRIVATE
        ${CMAKE_SOURCE_DIR}/third_party/libmypaint/.libs/libmypaint.a
    )
endif()

# Compiler options
target_compile_options(envecore PRIVATE
    -Wall
    -Wextra
    -Wno-unused-parameter
    -Wno-unused-variable
)

# Set library properties
set_target_properties(envecore PROPERTIES
    OUTPUT_NAME envecore
    VERSION ${PROJECT_VERSION}
    POSITION_INDEPENDENT_CODE ON
)

# Install headers (public API)
# TODO: Determine which headers are part of the public API
# install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
#     DESTINATION include/enveCore
#     FILES_MATCHING PATTERN "*.h"
# )
