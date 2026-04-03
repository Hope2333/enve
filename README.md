<p align="center">
  <img align="center" width="128" height="128" src="ICON">
</p>

<h1 align="center">WAITING FOR NEW NAME</h1>

??? is a new open-source 2D animation software for Linux and Windows.
You can use enve to create vector animations, raster animations, and even use sound and video files.
??? was created with flexibility and expandability in mind.

<p align="center">
<a href="???" target="_blank">
  <img src="https://cdn-icons-png.flaticon.com/512/187/187187.png" alt="enve on Twitter" height="64" border="10" hspace="20"/>
</a>
&nbsp;&nbsp;&nbsp;
<a href="???" target="_blank">
  <img src="https://cdn-icons-png.flaticon.com/512/187/187209.png" alt="??? on YouTube" height="64" border="10" hspace="20"/>
</a>
&nbsp;&nbsp;&nbsp;
<a href="???" target="_blank">
  <img src="https://is3-ssl.mzstatic.com/image/thumb/Purple128/v4/9e/f2/81/9ef281df-1da2-e183-18d2-6c475965fef8/AppIcon-0-1x_U007emarketing-0-0-GLES2_U002c0-512MB-sRGB-0-0-0-85-220-0-0-0-7.png/246x0w.jpg" alt="enve on Patreon" height="64" border="10" hspace="20"/>
</a>
&nbsp;&nbsp;&nbsp;
<a href="???" target="_blank">
  <img src="https://liberapay.com/assets/liberapay/icon-v2_white-on-yellow.svg?etag=.Z1LYSBJ8Z6GWUeLUUEf2XA~~" alt="enve on Liberapay" height="64" border="10" hspace="20"/>
</a>
&nbsp;&nbsp;&nbsp;
<a href="???" target="_blank">
  <img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_111x69.jpg" alt="enve on PayPal" height="64" border="10" hspace="20"/>
</a>
</p><br/>

<img src="https://user-images.githubusercontent.com/16670651/70745938-36e20900-1d25-11ea-9bdf-78d3fe402291.png"/>

## Download
You can download the latest enve release for <a href="???" target="_blank">Linux</a> and <a href="???" target="_blank">Windows</a>.

## Source and building instructions

### CMake (Recommended — Primary Build System)

```bash
# Initialize submodules and build third-party dependencies
git submodule update --init --recursive
cd third_party && make patch && make

# Configure and build (Release)
cd build/Release
cmake ../.. -DCMAKE_BUILD_TYPE=Release \
    -DENVE_USE_SYSTEM_LIBMYPAINT=ON \
    -DENVE_USE_QSCINTILLA=OFF \
    -DENVE_USE_GPERFTOOLS=OFF \
    -DENVE_USE_WEBENGINE=OFF
make -j"$(nproc)"

# Run the application
./bin/enve
```

**Build options:**
| Option | Default | Description |
|--------|---------|-------------|
| `ENVE_USE_SYSTEM_LIBMYPAINT` | OFF | Use system libmypaint (recommended on Linux) |
| `ENVE_USE_QSCINTILLA` | ON | Enable QScintilla script editor |
| `ENVE_USE_GPERFTOOLS` | ON | Enable gperftools/tcmalloc |
| `ENVE_USE_WEBENGINE` | ON | Enable Qt WebEngine for SVG preview |
| `ENVE_BUILD_EXAMPLES` | OFF | Build example effects |

### qmake (Legacy — Authoritative until full parity verified)

```bash
cd build/Release
qmake ../../enve.pro && make -j"$(nproc)"
```

### CI Status

[![CMake App Build](https://github.com/Hope2333/enve/actions/workflows/cmake-app.yml/badge.svg)](https://github.com/Hope2333/enve/actions/workflows/cmake-app.yml)
[![Code Quality](https://github.com/Hope2333/enve/actions/workflows/code-quality.yml/badge.svg)](https://github.com/Hope2333/enve/actions/workflows/code-quality.yml)

## Authors

**Maurycy Liebner** - 2016 - 2021 - [MaurycyLiebner](https://github.com/MaurycyLiebner)
**Hope2333 (幽零小喵)** - 2026 - ???? - [Hope2333](https://github.com/Hope2333)

## License

This project is licensed under the GPL3 License - see the [LICENSE.md](LICENSE.md) file for details
